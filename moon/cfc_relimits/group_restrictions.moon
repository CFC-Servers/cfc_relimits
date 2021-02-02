-- class Restrictions
json = require "json"

math.randomseed(os.time())

class RestrictionGroup
    new: =>
        @allowances = {}

    setRestricted: (itemName, restricted=true) =>
        @allowances[itemName] = restricted

    isRestricted: (itemName) =>
        allowed = @allowances[itemName]
        return if allowed == nil

        return not allowed

    isAllowed: (itemName) =>
        @allowances[itemName]

class WeaponRestrictionGroup extends RestrictionGroup
    @restrictionType: "WEAPON"

class ToolRestrictionGroup extends RestrictionGroup
    @restrictionType: "TOOL"

class EntityRestrictionGroup extends RestrictionGroup
    @restrictionType: "ENTITY"

class ModelRestrictionGroup extends RestrictionGroup
    @restrictionType: "MODEL"

newRestrictionGroupSet = () -> {
    [WeaponRestrictionGroup.restrictionType]: WeaponRestrictionGroup!
    [ToolRestrictionGroup.restrictionType]: ToolRestrictionGroup!
    [EntityRestrictionGroup.restrictionType]: EntityRestrictionGroup!
}

local UserGroup

class UserGroups
    @groups: {}

    register: (uuid, group) =>
        @@groups[uuid] = group
    
    getUserGroup: (groupName) =>
        for _, group in pairs @@groups
            if group.name == groupName
                return group

    serialize: () =>
        groups = {}

        for _, group in pairs @@groups
            table.insert groups, {
                uuid: group.uuid
                name: group.name
                inherits: group.parent and group.parent.uuid
                restrictions: { k, v.allowances for k, v in pairs group\getRestrictions! }
            }

        json.encode groups

    deserialize: (data) =>
        decodedData = json.decode data

        onLoaded = {}

        for _, groupData in pairs decodedData
            parent = groupData.inherits and @@groups[groupData.inherits]
            newGroup = UserGroup groupData.name, parent, groupData.uuid

            -- load allowances
            for restrictionType, allowances in pairs groupData.restrictions
                restrictionGroup = newGroup.restrictions[restrictionType]
                restrictionGroup.allowances = allowances

            -- handle parent not being loaded
            if not parent and groupData.inherits
                onLoaded[groupData.inherits] = (parent) ->
                    newGroup\setParent parent

            if onLoaded[newGroup.uuid]
                onLoaded[newGroup.uuid] newGroup

class UserGroup
    new: (@name, @parent, @uuid=math.random(1,1000000000000000)) =>
        @restrictions = newRestrictionGroupSet!
        UserGroups\register @uuid, self

    setParent: (parent) =>
        @parent = parent

    setRestricted: (restrictionType, itemName, restricted) =>
        restrictionsGroup = @restrictions[restrictionType]
        return unless restrictionsGroup

        restrictionsGroup\setRestricted itemName, restricted

    isAllowed: (restrictionType, itemName) =>
        restrictionsGroup = @restrictions[restrictionType]
        return unless restrictionsGroup

        isAllowed = restrictionsGroup\isAllowed itemName

        return isAllowed unless isAllowed == nil

        return @parent\isAllowed restrictionType, itemName unless @parent == nil

    getRestrictions: () => @restrictions


-- example

exampleDeserialize = () ->
    UserGroups\deserialize [==[
    [{"uuid":"394383","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":true}},"name":"regular","inherits":"840188"},{"uuid":"840188","name":"user","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":false,"m9k_davy_crocket":false}}}]
    ]==]

    regular = UserGroups\getUserGroup("regular")
    print "regular minigun", regular\isAllowed "WEAPON", "m9k_minigun"
    print "regular davy crocket", regular\isAllowed "WEAPON", "m9k_davy_crocket"
    print "regular random gun", regular\isAllowed "WEAPON", "random_gun"
    
    print UserGroups\serialize!

exampleGroupCreation = () ->
    user = UserGroup "user"
    user\setRestricted  "WEAPON", "m9k_davy_crocket", false
    user\setRestricted "WEAPON", "m9k_minigun", false

    regular = UserGroup "regular", user
    regular\setRestricted "WEAPON", "m9k_minigun", true

    print "regular minigun", regular\isAllowed "WEAPON", "m9k_minigun"
    print "regular davy crocket", regular\isAllowed "WEAPON", "m9k_davy_crocket"
    print "regular random gun", regular\isAllowed "WEAPON", "random_gun"

    print UserGroups\serialize!

-- exampleGroupCreation!
exampleDeserialize!

