-- class Restrictions
json = require "json"

class RestrictionGroup
	new: =>
		@allowances = {}

	addRestriction: (itemName, restricted=true) =>
        print("called ", itemName)
		@allowances[itemName] = restricted

	isRestricted: (itemName) =>
		allowed = @allowances[itemName]
        return if allowed == nil

        return not allowed

	isAllowed: (itemName) =>
		@allowances[itemName]


class WeaponRestrictionGroup extends RestrictionGroup
	@type: "WEAPON"

class ToolRestrictionGroup extends RestrictionGroup
	@type: "TOOL"

class EntityRestrictionGroup extends RestrictionGroup
	@type: "ENTITY"

class ModelRestrictionGroup extends RestrictionGroup
	@type: "MODEL"

newRestrictionGroupSet = () -> {
	[WeaponRestrictionGroup.type]: WeaponRestrictionGroup(),
	[ToolRestrictionGroup.type]: ToolRestrictionGroup(),
	[EntityRestrictionGroup.type]: EntityRestrictionGroup()
}


class UserGroups
	@groups: {}

	register: (uuid, group) =>
		@@groups[uuid] = group

    serialize: () =>
        groups = {}
        for _, group in pairs @@groups
            table.insert groups, {
                uuid: group.uuid,
                name: group.name,
                inherits: group.parent and group.parent.uuid
                restrictions: { k, v.allowances for k, v in pairs group\getRestrictions! },
            }
        json.encode groups

newUserGroup = () =>
	-- TODO: UUID


class UserGroup
	@restrictions: newRestrictionGroupSet!

	new: (@name, @parent) =>
        @uuid = tostring(math.random( 1, 1000000)) -- TODO use uuid
		UserGroups\register @uuid, @


    addRestriction: (type, itemName, value) =>
        restrictionsGroup = @@restrictions[type]
        return unless restrictionsGroup

        restrictionsGroup\addRestriction itemName, value

    isAllowed: (type, itemName) =>
        restrictionsGroup = @@restrictions[type]
        return unless restrictionsGroup

        return restrictionsGroup\isAllowed itemName, "test"

    getRestrictions: () =>
        @@restrictions

-- example
user = UserGroup "user"
user\addRestriction  "WEAPON", "m9k_davy_crocket", false
user\addRestriction "WEAPON", "m9k_minigun", false

regular = UserGroup "regular", user
regular\addRestriction "WEAPON", "m9k_minigun", true

print "regular minigun", UserGroup\isAllowed "WEAPON", "m9k_minigun"
print "regular davy crocket", UserGroup\isAllowed "WEAPON", "m9k_davy_crocket"
print "regular random gun", UserGroup\isAllowed "WEAPON", "random_gun"

print UserGroups\serialize!
