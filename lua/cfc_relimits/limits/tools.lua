ReLimits.LimitGroup:Register("TOOL")
local canTool
canTool = function(ply, _, toolName)
  if not (IsValid(ply)) then
    return 
  end
  local tracker = ply.TrackerManager:getTracker("TOOL")
  if not (tracker:isAllowed(toolName)) then
    return false
  end
  tracker:incr(toolName)
  return nil
end
return hook.Add("CanTool", "ReLimits_CanTool", canTool, HOOK_LOW)
