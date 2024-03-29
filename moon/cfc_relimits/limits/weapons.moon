ReLimits.LimitGroup\Register "WEAPON"

canUseWeapon = (ply, weaponClass) ->
    return unless IsValid ply
    tracker = ply.TrackerManager\getTracker "WEAPON"

    allowed = tracker\isAllowedWild weaponClass
    return false if not allowed

    return nil

hook.Add "PlayerCanPickupWeapon", "ReLimits_CanPickup", (ply, wep) ->
    canUseWeapon ply, wep\GetClass!

hook.Add "WeaponEquip", "ReLimits_IncrWeapon", (wep, ply) ->
    return unless IsValid ply
    weaponClass = ply\GetClass!

    tracker = ply.TrackerManager\getTracker "WEAPON"
    tracker\incr weaponClass
