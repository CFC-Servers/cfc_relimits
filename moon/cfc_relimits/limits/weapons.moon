LimitGroup.Register "WEAPON", (current, max) -> current < max, true

canUseWeapon = (ply, weaponClass) ->
    return unless IsValid ply
    tracker = ply.TrackerManager\getTracker "WEAPON"

    allowed = tracker\isAllowed weaponClass
    allowedWild = tracker\isAllowed "*"
    return false if not (allowed or allowedWild)

    return nil

hook.Add "PlayerCanPickupWeapon", "ReLimits_CanPickup", (wep, ply) ->
    canUseWeapon ply, wep\GetClass!

hook.Add "WeaponEquip", "ReLimits_IncrWeapon", (wep, ply) ->
    return unless IsValid ply
    weaponClass = ply\GetClass!

    trackers = ply.TrackerManager\getTracker "WEAPON"
    for uuid, tracker in pairs trackers
        tracker\incr weaponClass
