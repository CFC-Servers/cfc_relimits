-- class Restrictions 

class RestrictionGroup
	new: =>
		restrictions = {}

	addRestriction: (itemName, restricted=true) =>
		restrictions[itemName] = restricted

	isRestricted: (itemName) =>
		restrictions[itemName]

	isAllowed: (itemName) =>
		~isRestricted 


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


newUserGroup = () =>
	-- TODO: UUID


class UserGroup
	new: (@name, parent) =>
		UserGroups.register name
		uuid = "" -- TODO: Generate UUID

	restrictions = newRestrictionGroupSet!



