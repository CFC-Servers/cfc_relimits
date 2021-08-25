ReLimits.LimitGroup:Register("MODEL")
hook.Add("PlayerSpawnObject", "ReLimits_CanSpawn", function(ply, model)
  if not (model) then
    return 
  end
  local tracker = ply.TrackerManager:getTracker("MODEL")
  local allowed = tracker:isAllowedWild(model)
  if not allowed then
    return false
  end
  return nil
end)
return hook.Add("OnEntityCreated", "ReLimits_IncrementModels", function(ent)
  timer.Simple(0, function()
    if not (IsValid(ent)) then
      return 
    end
    local ply = ent:CPPIGetOwner()
    if not (IsValid(ply)) then
      return 
    end
    local model = ent:GetModel()
    if not (model) then
      return 
    end
    local tracker = ply.TrackerManager:getTracker("MODEL")
    tracker:incr(model)
    return ent:CallOnRemove("ReLimits_IncrementModels", function()
      return tracker:decr(model)
    end)
  end)
  return nil
end)
