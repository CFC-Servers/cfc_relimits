-- class Restrictions
json = require "json"
exampleJson = require "example_json"

math.randomseed(os.time())

istable = (v) -> type(v) == "table"


newUUID = ->
    bytes = {}
    for i = 1, 16 do
        bytes[i] = math.random(1, 256)

    return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
        bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], math.floor((bytes[7] / 16) + 64), bytes[8], 
        math.floor((bytes[9] / 4) + 128), bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16])

tableMerge = ( dest, source ) ->
    for k, v in pairs( source )
        if ( istable( v ) and istable( dest[ k ] ) ) then
            tableMerge( dest[ k ], v )
        else
            dest[ k ] = v

    return dest

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
    [ModelRestrictionGroup.restrictionType]: ModelRestrictionGroup!
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
                restrictions: { k, v.allowances for k, v in pairs group.restrictions }
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
    new: (@name, @parent, @uuid=newUUID()) =>
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

    getRestrictions: () =>
        parentRestrictions = @parent and @parent\getRestrictions!
        tableMerge(parentRestrictions or {}, @restrictions)

-- example

exampleDeserialize = () ->
    -- UserGroups\deserialize [==[
    -- [{"uuid":"394383","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":true}},"name":"regular","inherits":"840188"},{"uuid":"840188","name":"user","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":false,"m9k_davy_crocket":false}}}]
    -- ]==]
    UserGroups\deserialize exampleJson

    groups = { "1", "2", "3", "4" }

    for uuid in *groups
        group = UserGroups.groups[uuid]
        groupName = group.name

        for restrictionType, allowances in pairs group\getRestrictions!
            print groupName, restrictionType

            for name, isAllowed in pairs allowances.allowances
                print "  #{name}: #{isAllowed}"

            print ""

        print ""
        print "-------------------------------------------------------"
        print ""

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

