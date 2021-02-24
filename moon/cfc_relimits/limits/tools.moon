canTool = (ply, _, toolName) ->
    return unless IsValid ply
    trackers = ply.TrackerManager\getTracker "TOOL"

    for tracker in *trackers
        counts = tracker\getCounts toolName
        if counts.max and counts.current >= counts.max
            return false

    for tracker in *trackers
        tracker\incr toolName

    return nil

hook.Add "CanTool", "ReLimits_CanTool", canTool, HOOK_LOW
