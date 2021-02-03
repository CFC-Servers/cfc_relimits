local json = require("json")
local exampleJson = require("example_json")
math.randomseed(os.time())
local istable
istable = function(v)
  return type(v) == "table"
end
local newUUID
newUUID = function()
  local bytes = { }
  for i = 1, 16 do
    bytes[i] = math.random(1, 256)
  end
  return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], math.floor((bytes[7] / 16) + 64), bytes[8], math.floor((bytes[9] / 4) + 128), bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16])
end
local tableMerge
tableMerge = function(dest, source)
  for k, v in pairs(source) do
    if (istable(v) and istable(dest[k])) then
      tableMerge(dest[k], v)
    else
      dest[k] = v
    end
  end
  return dest
end
local RestrictionGroup
do
  local _class_0
  local _base_0 = {
    setRestricted = function(self, itemName, restricted)
      if restricted == nil then
        restricted = true
      end
      self.allowances[itemName] = restricted
    end,
    isRestricted = function(self, itemName)
      local allowed = self.allowances[itemName]
      if allowed == nil then
        return 
      end
      return not allowed
    end,
    isAllowed = function(self, itemName)
      return self.allowances[itemName]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.allowances = { }
    end,
    __base = _base_0,
    __name = "RestrictionGroup"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  RestrictionGroup = _class_0
end
local WeaponRestrictionGroup
do
  local _class_0
  local _parent_0 = RestrictionGroup
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "WeaponRestrictionGroup",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.restrictionType = "WEAPON"
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  WeaponRestrictionGroup = _class_0
end
local ToolRestrictionGroup
do
  local _class_0
  local _parent_0 = RestrictionGroup
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "ToolRestrictionGroup",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.restrictionType = "TOOL"
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ToolRestrictionGroup = _class_0
end
local EntityRestrictionGroup
do
  local _class_0
  local _parent_0 = RestrictionGroup
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "EntityRestrictionGroup",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.restrictionType = "ENTITY"
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  EntityRestrictionGroup = _class_0
end
local ModelRestrictionGroup
do
  local _class_0
  local _parent_0 = RestrictionGroup
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "ModelRestrictionGroup",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.restrictionType = "MODEL"
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ModelRestrictionGroup = _class_0
end
local newRestrictionGroupSet
newRestrictionGroupSet = function()
  return {
    [WeaponRestrictionGroup.restrictionType] = WeaponRestrictionGroup(),
    [ToolRestrictionGroup.restrictionType] = ToolRestrictionGroup(),
    [EntityRestrictionGroup.restrictionType] = EntityRestrictionGroup(),
    [ModelRestrictionGroup.restrictionType] = ModelRestrictionGroup()
  }
end
local UserGroup
local UserGroups
do
  local _class_0
  local _base_0 = {
    register = function(self, uuid, group)
      self.__class.groups[uuid] = group
    end,
    getUserGroup = function(self, groupName)
      for _, group in pairs(self.__class.groups) do
        if group.name == groupName then
          return group
        end
      end
    end,
    serialize = function(self)
      local groups = { }
      for _, group in pairs(self.__class.groups) do
        table.insert(groups, {
          uuid = group.uuid,
          name = group.name,
          inherits = group.parent and group.parent.uuid,
          restrictions = (function()
            local _tbl_0 = { }
            for k, v in pairs(group.restrictions) do
              _tbl_0[k] = v.allowances
            end
            return _tbl_0
          end)()
        })
      end
      return json.encode(groups)
    end,
    deserialize = function(self, data)
      local decodedData = json.decode(data)
      local onLoaded = { }
      for _, groupData in pairs(decodedData) do
        local parent = groupData.inherits and self.__class.groups[groupData.inherits]
        local newGroup = UserGroup(groupData.name, parent, groupData.uuid)
        for restrictionType, allowances in pairs(groupData.restrictions) do
          local restrictionGroup = newGroup.restrictions[restrictionType]
          restrictionGroup.allowances = allowances
        end
        if not parent and groupData.inherits then
          onLoaded[groupData.inherits] = function(parent)
            return newGroup:setParent(parent)
          end
        end
        if onLoaded[newGroup.uuid] then
          onLoaded[newGroup.uuid](newGroup)
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "UserGroups"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.groups = { }
  UserGroups = _class_0
end
do
  local _class_0
  local _base_0 = {
    setParent = function(self, parent)
      self.parent = parent
    end,
    setRestricted = function(self, restrictionType, itemName, restricted)
      local restrictionsGroup = self.restrictions[restrictionType]
      if not (restrictionsGroup) then
        return 
      end
      return restrictionsGroup:setRestricted(itemName, restricted)
    end,
    isAllowed = function(self, restrictionType, itemName)
      local restrictionsGroup = self.restrictions[restrictionType]
      if not (restrictionsGroup) then
        return 
      end
      local isAllowed = restrictionsGroup:isAllowed(itemName)
      if not (isAllowed == nil) then
        return isAllowed
      end
      if not (self.parent == nil) then
        return self.parent:isAllowed(restrictionType, itemName)
      end
    end,
    getRestrictions = function(self)
      local parentRestrictions = self.parent and self.parent:getRestrictions()
      return tableMerge(parentRestrictions or { }, self.restrictions)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, parent, uuid)
      if uuid == nil then
        uuid = newUUID()
      end
      self.name, self.parent, self.uuid = name, parent, uuid
      self.restrictions = newRestrictionGroupSet()
      return UserGroups:register(self.uuid, self)
    end,
    __base = _base_0,
    __name = "UserGroup"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  UserGroup = _class_0
end
local exampleDeserialize
exampleDeserialize = function()
  UserGroups:deserialize(exampleJson)
  local groups = {
    "1",
    "2",
    "3",
    "4"
  }
  for _index_0 = 1, #groups do
    local uuid = groups[_index_0]
    local group = UserGroups.groups[uuid]
    local groupName = group.name
    for restrictionType, allowances in pairs(group:getRestrictions()) do
      print(groupName, restrictionType)
      for name, isAllowed in pairs(allowances.allowances) do
        print("  " .. tostring(name) .. ": " .. tostring(isAllowed))
      end
      print("")
    end
    print("")
    print("-------------------------------------------------------")
    print("")
  end
end
local exampleGroupCreation
exampleGroupCreation = function()
  local user = UserGroup("user")
  user:setRestricted("WEAPON", "m9k_davy_crocket", false)
  user:setRestricted("WEAPON", "m9k_minigun", false)
  local regular = UserGroup("regular", user)
  regular:setRestricted("WEAPON", "m9k_minigun", true)
  print("regular minigun", regular:isAllowed("WEAPON", "m9k_minigun"))
  print("regular davy crocket", regular:isAllowed("WEAPON", "m9k_davy_crocket"))
  print("regular random gun", regular:isAllowed("WEAPON", "random_gun"))
  return print(UserGroups:serialize())
end
return exampleGroupCreation()
