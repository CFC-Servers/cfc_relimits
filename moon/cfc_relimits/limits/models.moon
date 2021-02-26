LimitGroup.Register "MODEL", (current, max) -> current < max, true

hook.Add "PlayerSpawnObject", "ReLimits_CanSpawn", (ply, model) ->
    return unless model

    tracker = ply.TrackerManager\getTracker "MODEL"

    allowed = tracker\isAllowedWild model

    return false if not allowed

    return nil

hook.Add "OnEntityCreated", "ReLimits_IncrementModels", (ent) ->
    timer.Simple 0, ->
        return unless IsValid ent

        ply = ent\CPPIGetOwner!
        return unless IsValid ply

        model = ent\GetModel!
        return unless model

        tracker = ply.TrackerManager\getTracker "MODEL"
        tracker\incr model

        ent\CallOnRemove "ReLimits_IncrementModels", ->
            tracker\decr model

    return nil
