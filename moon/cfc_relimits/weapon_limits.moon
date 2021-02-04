canUseWeapon = (ply, weaponClass) ->
    return unless IsValid ply
    tracker = ply.TrackerManager\getTracker "WEAPON"

    counts = tracker\getCounts weaponClass
    if counts.max and counts.current >= counts.max
        return false

    return nil

hook.Add "PlayerCanPickupWeapon", "ReLimits_CanPickup", (wep, ply) ->
    canUseWeapon ply, wep\GetClass!

hook.Add "WeaponEquip", "ReLimits_IncrWeapon", (wep, ply) ->
    return unless IsValid ply
    weaponClass = ply\GetClass!

    tracker = ply.TrackerManager\getTracker "WEAPON"
    tracker\incr weaponClass
