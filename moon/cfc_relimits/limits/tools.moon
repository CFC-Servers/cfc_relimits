canTool = (ply, _, toolName) ->
    return unless IsValid ply
    tracker = ply.TrackerManager\getTracker "TOOL"

    return false unless tracker\isAllowed toolName

    tracker\incr toolName

    return nil

hook.Add "CanTool", "ReLimits_CanTool", canTool, HOOK_LOW
