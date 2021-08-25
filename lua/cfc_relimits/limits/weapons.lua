ReLimits.LimitGroup:Register("WEAPON")
local canUseWeapon
canUseWeapon = function(ply, weaponClass)
  if not (IsValid(ply)) then
    return 
  end
  local tracker = ply.TrackerManager:getTracker("WEAPON")
  local allowed = tracker:isAllowedWild(weaponClass)
  if not allowed then
    return false
  end
  return nil
end
hook.Add("PlayerCanPickupWeapon", "ReLimits_CanPickup", function(ply, wep)
  return canUseWeapon(ply, wep:GetClass())
end)
return hook.Add("WeaponEquip", "ReLimits_IncrWeapon", function(wep, ply)
  if not (IsValid(ply)) then
    return 
  end
  local weaponClass = ply:GetClass()
  local tracker = ply.TrackerManager:getTracker("WEAPON")
  return tracker:incr(weaponClass)
end)
