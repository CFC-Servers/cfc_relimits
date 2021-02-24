LimitGroup.Register "MODEL", (current, max) -> current < max, true

hook.Add "PlayerSpawnObject", "ReLimits_CanSpawn", (ply, model) ->
    return unless model

    tracker = ply.TrackerManager\getTracker "MODEL"

    --TODO: Does the end user do this themselves? or does isAllowed check "*" implicitly
    allowed = tracker\isAllowed model
    allowedWild = tracker\isAllowed "*"

    return false if not (allowed and allowedWild)

    return nil

hook.Add "OnEntityCreated", "ReLimits_IncrementModels", (ent) ->
    timer.Simple 0, ->
        return unless IsValid ent

        ply = ent\CPPIGetOwner!
        return unless IsValid ply

        model = ent\GetModel!
        return unless model

        trackers = ply.TrackerManager\getTracker "MODEL"
        for tracker in *trackers
            tracker\incr model

        ent\CallOnRemove "ReLimits_IncrementModels", ->
            for tracker in *trackers
                tracker\decr model

    return nil
