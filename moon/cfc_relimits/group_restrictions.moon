-- class Restrictions
json = require "json"

class RestrictionGroup
    new: =>
        @allowances = {}

    setRestricted: (itemName, restricted=true) =>
        print "called ", itemName
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


class UserGroups
    @groups: {}

    register: (uuid, group) =>
        @@groups[uuid] = group

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

newUserGroup = () =>
    -- TODO: UUID

    class UserGroup
        @restrictions: newRestrictionGroupSet!

    new: (@name, @parent) =>
        @uuid = tostring(math.random(1, 1000000)) -- TODO use uuid
        UserGroups\register @uuid, self

    setRestricted: (restrictionType, itemName, restricted) =>
        restrictionsGroup = @@restrictions[restrictionType]
        return unless restrictionsGroup

        restrictionsGroup\setRestricted itemName, restricted

    isAllowed: (restrictionType, itemName) =>
        restrictionsGroup = @@restrictions[restrictionType]
        return unless restrictionsGroup

        return restrictionsGroup\isAllowed itemName, "test"

    getRestrictions: () => @@restrictions

-- example
user = UserGroup "user"
user\setRestricted  "WEAPON", "m9k_davy_crocket", false
user\setRestricted "WEAPON", "m9k_minigun", false

regular = UserGroup "regular", user
regular\setRestricted "WEAPON", "m9k_minigun", true

print "regular minigun", UserGroup\isAllowed "WEAPON", "m9k_minigun"
print "regular davy crocket", UserGroup\isAllowed "WEAPON", "m9k_davy_crocket"
print "regular random gun", UserGroup\isAllowed "WEAPON", "random_gun"

print UserGroups\serialize!
