local Logger
Logger = ReLimits.Logger
local mathMin = math.min
do
  local _class_0
  local _base_0 = {
    addTracker = function(self, trackerType, tracker)
      self.typeTrackers[trackerType] = tracker
    end,
    getTracker = function(self, trackerType)
      return self.typeTrackers[trackerType]
    end,
    getLimitData = function(self, limitType, identifier)
      identifier = string.lower(identifier)
      return ReLimits.UserGroupManager:GetPlayerLimits(self.ply)[limitType][identifier]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, ply)
      self.ply = ply
      if self.ply.TrackerManager then
        Logger:error("Attempted to add second tracker manager to player " .. tostring(ply))
      end
      self.ply.TrackerManager = self
      self.typeTrackers = { }
    end,
    __base = _base_0,
    __name = "LimitTypeTrackerManager"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ReLimits.LimitTypeTrackerManager = _class_0
end
do
  local _class_0
  local _base_0 = {
    set = function(self, identifier, value)
      identifier = string.lower(identifier)
      local limitDataList = self:getLimitData(identifier)
      if not (limitDataList) then
        return 
      end
      local currentCounts = self.counts[identifier] or { }
      for i = 1, #limitDataList do
        currentCounts[i] = value
      end
      self.counts[identifier] = currentCounts
    end,
    change = function(self, identifier, amount)
      identifier = string.lower(identifier)
      if amount == 0 then
        return 
      end
      self.counts[identifier] = self.counts[identifier] or { }
      local curTime = CurTime()
      local limitDataList = self:getLimitData(identifier)
      if not (limitDataList) then
        return 
      end
      local currentCounts = self.counts[identifier]
      for i = 1, #limitDataList do
        local currentCount = currentCounts[i] or 0
        local newCount = currentCount + amount
        if newCount <= 0 then
          currentCounts[i] = 0
        else
          if currentCount == 0 then
            self.timeFrameStarts[identifier] = self.timeFrameStarts[identifier] or { }
            self.timeFrameStarts[identifier][i] = curTime
          end
          currentCounts[i] = newCount
        end
      end
    end,
    incr = function(self, identifier)
      return self:change(identifier, 1)
    end,
    decr = function(self, identifier)
      return self:change(identifier, -1)
    end,
    getLimitData = function(self, identifier)
      identifier = string.lower(identifier)
      return self.manager:getLimitData(self.limitType, identifier)
    end,
    isAllowed = function(self, identifier)
      identifier = string.lower(identifier)
      local limitDataList = self:getLimitData(identifier)
      local comparator, default
      do
        local _obj_0 = ReLimits.LimitGroup.limitTypes[self.limitType]
        comparator, default = _obj_0.comparator, _obj_0.default
      end
      if not (limitDataList) then
        return default
      end
      local currents = self.counts[identifier] or { }
      local timeFrameStarts = self.timeFrameStarts[identifier] or { }
      local allowed = nil
      local curTime = CurTime()
      for i = 1, #limitDataList do
        local limitData = limitDataList[i]
        local timeFrame, maxCount
        timeFrame, maxCount = limitData.timeFrame, limitData.max
        local current = currents[i] or 0
        local timeFrameStart = timeFrameStarts[i] or 0
        if timeFrame > 0 and curTime > timeFrameStart + timeFrame then
          current = 0
          currents[i] = 0
        end
        allowed = comparator((mathMin(current, maxCount)), maxCount)
        if not allowed then
          return false
        end
      end
      return allowed or default
    end,
    isAllowedWild = function(self, identifier)
      return self:isAllowed(identifier) and self:isAllowed("*")
    end,
    getCounts = function(self, identifier)
      identifier = string.lower(identifier)
      local limitDataList = self:getLimitData(identifier)
      if not (limitDataList) then
        return 
      end
      local currents = self.counts[identifier] or { }
      local timeFrameStarts = self.timeFrameStarts[identifier] or { }
      local curTime = CurTime()
      local out = { }
      for i, limitData in pairs(limitDataList) do
        local timeFrame, maxCount
        timeFrame, maxCount = limitData.timeFrame, limitData.max
        local current = currents[i] or 0
        local timeFrameStart = timeFrameStarts[i] or 0
        if timeFrame > 0 and curTime > timeFrameStart + timeFrame then
          current = 0
          currents[i] = 0
        end
        out[i] = {
          current = (mathMin(current, maxCount)),
          max = maxCount,
          limitData = limitData
        }
      end
      return out
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, limitType, manager)
      self.limitType, self.manager = limitType, manager
      self.counts = { }
      self.timeFrameStarts = { }
      return self.manager:addTracker(self.limitType, self)
    end,
    __base = _base_0,
    __name = "LimitTypeTracker"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ReLimits.LimitTypeTracker = _class_0
end
return hook.Add("PlayerInitialSpawn", "ReLimits_CreateTrackerManager", function(ply)
  local manager = ReLimits.LimitTypeTrackerManager(ply)
  for limitType in pairs(ReLimits.LimitGroup.limitTypes) do
    ReLimits.LimitTypeTracker(limitType, manager)
  end
end)
