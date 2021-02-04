 canTool = (ply, _, toolName) ->
    return unless IsValid ply
    tracker = ply.TrackerManager\getTracker "TOOL"

    counts = tracker\getCounts toolName
    if counts.max and counts.current >= counts.max
        return false

    tracker\incr toolName

    return nil

hook.Add "CanTool", "ReLimits_CanTool", canTool, HOOK_LOW
