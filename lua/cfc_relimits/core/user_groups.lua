local Merge, insert, Copy, RemoveByValue
do
  local _obj_0 = table
  Merge, insert, Copy, RemoveByValue = _obj_0.Merge, _obj_0.insert, _obj_0.Copy, _obj_0.RemoveByValue
end
local JSONToTable, TableToJSON
do
  local _obj_0 = util
  JSONToTable, TableToJSON = _obj_0.JSONToTable, _obj_0.TableToJSON
end
local Read, CreateDir, Write
do
  local _obj_0 = file
  Read, CreateDir, Write = _obj_0.Read, _obj_0.CreateDir, _obj_0.Write
end
local Logger
Logger = ReLimits.Logger
local newUUID
newUUID = ReLimits.Utils.newUUID
local DATA_FILENAME = "relimits/limits.json"
local DEFAULT_GROUP_NAME = "_DEFAULT"
do
  local _class_0
  local _base_0 = {
    Register = function(self, uuid, group)
      Logger:debug("Registering '" .. tostring(uuid) .. "':", group)
      local old = self.nameLookup[group.name]
      if old then
        old:remove()
      end
      self.groups[uuid] = group
      self.nameLookup[group.name] = group
      return self:Save()
    end,
    Remove = function(self, uuid)
      local group = self.groups[uuid]
      if not (group) then
        return 
      end
      group:clearCompiled()
      local children = group.children or { }
      for _index_0 = 1, #children do
        local child = children[_index_0]
        child:setParent(group.parent)
      end
      self.groups[uuid] = nil
      self.nameLookup[group.name] = nil
    end,
    GetPlayerLimits = function(self, ply)
      local group = self:GetUserGroup(self:GetUserGroupName(ply))
      group = group or self:GetUserGroup(DEFAULT_GROUP_NAME)
      return group and group:getLimits()
    end,
    GetUserGroupName = function(self, ply)
      return ply:GetUserGroup()
    end,
    GetUserGroup = function(self, groupIdentifier)
      return self.groups[groupIdentifier] or self.nameLookup[groupIdentifier]
    end,
    Save = function(self)
      local data = self:Serialize()
      local splitFilename = string.Split(DATA_FILENAME, "/")
      splitFilename[#splitFilename] = nil
      local dataDirectory = table.concat(splitFilename, "/")
      CreateDir(dataDirectory)
      return Write(DATA_FILENAME, self:Serialize())
    end,
    Load = function(self)
      local data = Read(DATA_FILENAME, "DATA")
      if data then
        self:Deserialize(data)
      end
      if not self:GetUserGroup(DEFAULT_GROUP_NAME) then
        return ReLimits.UserGroup(DEFAULT_GROUP_NAME)
      end
    end,
    Serialize = function(self)
      local groups = { }
      for _, group in pairs(self.groups) do
        insert(groups, {
          uuid = group.uuid,
          name = group.name,
          inherits = group.parent and group.parent.uuid,
          limits = (function()
            local _tbl_0 = { }
            for k, v in pairs(group.limits) do
              _tbl_0[k] = v.limits
            end
            return _tbl_0
          end)()
        })
      end
      local serialized = TableToJSON(groups, true)
      Logger:debug("Serialized:", serialized)
      return serialized
    end,
    Deserialize = function(self, data)
      local decodedData = JSONToTable(data)
      Logger:debug("Data:", data)
      Logger:debug("Decoded Data:", decodedData)
      local onLoaded = { }
      for _, groupData in pairs(decodedData) do
        local parent = groupData.inherits and self.groups[groupData.inherits]
        local newGroup = ReLimits.UserGroup(groupData.name, parent, groupData.uuid)
        for limitType, limits in pairs(groupData.limits) do
          local limitGroup = newGroup.limits[limitType]
          limitGroup.limits = limits
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
      Logger:debug("Deserialized:", onLoaded)
      return onLoaded
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "UserGroupManager"
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
  self.nameLookup = { }
  ReLimits.UserGroupManager = _class_0
end
hook.Add("Initialize", "CFC_ReLimits_LoadLimits", (function()
  local _base_0 = ReLimits.UserGroupManager
  local _fn_0 = _base_0.Load
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
do
  local _class_0
  local _base_0 = {
    remove = function(self)
      return ReLimits.UserGroupManager:Remove(self.uuid)
    end,
    generateLimits = function(self)
      local _tbl_0 = { }
      for limitType in pairs(ReLimits.LimitGroup.limitTypes) do
        _tbl_0[limitType] = ReLimits.LimitGroup(limitType)
      end
      return _tbl_0
    end,
    setParent = function(self, parent)
      if self.parent then
        RemoveByValue(self.parent.children, self)
      end
      self.parent = parent
      if not (parent) then
        return 
      end
      self.parent.children = self.parent.children or { }
      return insert(self.parent.children, self)
    end,
    updateLimits = function(self, limitType, limits)
      local limitGroup = self.limits[limitType]
      if not (limitGroup) then
        return 
      end
      limitGroup:updateLimits(limits)
      self:clearCompiled()
      return ReLimits.UserGroupManager:Save()
    end,
    addLimit = function(self, limitType, identifier, limit)
      identifier = string.lower(identifier)
      Logger:debug("Attempting to add limit '" .. tostring(limitType) .. "' with identifier: " .. tostring(identifier) .. ":", limit)
      local limitGroup = self.limits[limitType]
      if not (limitGroup) then
        return 
      end
      Logger:debug("Adding limit '" .. tostring(limitType) .. "' with identifier: " .. tostring(identifier))
      limitGroup:updateLimit(identifier, limit)
      self:clearCompiled()
      return ReLimits.UserGroupManager:Save()
    end,
    clearCompiled = function(self)
      self.compiledLimitsData = nil
      if not (self.children) then
        return 
      end
      local _list_0 = self.children
      for _index_0 = 1, #_list_0 do
        local child = _list_0[_index_0]
        child.compiledLimitsData = nil
      end
    end,
    generateCompiledLimitsList = function(self, limitsMap)
      local out = { }
      for limitType, limitGroup in pairs(limitsMap) do
        local newLimitData = { }
        for identifier, limits in pairs(limitGroup.limits) do
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _, v in pairs(limits) do
              _accum_0[_len_0] = v
              _len_0 = _len_0 + 1
            end
            newLimitData[identifier] = _accum_0
          end
        end
        out[limitType] = newLimitData
      end
      return out
    end,
    getLimitsRaw = function(self)
      return {
        map = self.limits,
        list = self:generateCompiledLimitsList(self.limits)
      }
    end,
    getLimitsData = function(self)
      if self.compiledLimitsData then
        return self.compiledLimitsData
      end
      local parentLimitsData = self.parent and self.parent:getLimitsData()
      local parentLimitsDataMap = parentLimitsData and parentLimitsData.map or { }
      local compiledLimitsMap = Merge((Copy(parentLimitsDataMap)), self.limits)
      local compiledLimitsList = self:generateCompiledLimitsList(compiledLimitsMap)
      self.compiledLimitsData = {
        map = compiledLimitsMap,
        list = compiledLimitsList
      }
      return self.compiledLimitsData
    end,
    getLimits = function(self)
      return self:getLimitsData().list
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, parent, uuid, limits)
      if uuid == nil then
        uuid = newUUID()
      end
      if limits == nil then
        limits = self:generateLimits()
      end
      self.name, self.parent, self.uuid, self.limits = name, parent, uuid, limits
      ReLimits.UserGroupManager:Register(self.uuid, self)
      self.compiledLimitsData = nil
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
  ReLimits.UserGroup = _class_0
  return _class_0
end
