local Logger
Logger = ReLimits.Logger
do
  local _class_0
  local _base_0 = {
    LT = function(current, max)
      return current < max
    end,
    LE = function(current, max)
      return current <= max
    end,
    GT = function(current, max)
      return current > max
    end,
    GE = function(current, max)
      return current >= max
    end,
    Register = function(self, limitType, comparator, default)
      if comparator == nil then
        comparator = self.LT
      end
      if default == nil then
        default = true
      end
      Logger:debug("Registering limit type '" .. tostring(limitType) .. "'")
      self.limitTypes[limitType] = {
        comparator = comparator,
        default = default
      }
    end,
    updateLimits = function(self, limits)
      Logger:debug("Updating limits. Current: ", self.limits, "Next: ", limits)
      for uuid, limit in pairs(limits) do
        limit.uuid = uuid
      end
      self.limits = tableMerge(self.limits, limits)
    end,
    updateLimit = function(self, identifier, limit)
      identifier = string.lower(identifier)
      self.limits[identifier] = self.limits[identifier] or { }
      Logger:debug("Updating limit '" .. tostring(identifier) .. "'. Current: " .. tostring(self.limits[identifier]), "Next: ", limit)
      limit.uuid = limit.uuid or ReLimits.Utils.newUUID()
      self.limits[identifier][limit.uuid] = limit
    end,
    getLimit = function(self, identifier)
      identifier = string.lower(identifier)
      return self.limits[identifier]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, limitType)
      self.limitType = limitType
      self.limits = { }
    end,
    __base = _base_0,
    __name = "LimitGroup"
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
  self.limitTypes = { }
  ReLimits.LimitGroup = _class_0
  return _class_0
end
