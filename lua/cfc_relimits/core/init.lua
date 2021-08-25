local format
format = string.format
local floor, randomseed, random
do
  local _obj_0 = math
  floor, randomseed, random = _obj_0.floor, _obj_0.randomseed, _obj_0.random
end
local time
time = os.time
randomseed(time())
ReLimits = ReLimits or ReLimits
ReLimits.Utils = {
  newUUID = function()
    local bytes = { }
    for i = 1, 16 do
      bytes[i] = random(1, 256)
    end
    return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], math.floor((bytes[7] / 16) + 64), bytes[8], floor((bytes[9] / 4) + 128), bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16])
  end
}
