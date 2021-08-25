require("logger")
local Find
Find = file.Find
ReLimits = { }
ReLimits.Logger = Logger("ReLimits")
ReLimits.Logger:on("error"):call(error)
local includeShared
includeShared = function(file)
  AddCSLuaFile(file)
  return include(file)
end
if SERVER then
  local scopes = {
    "cfc_relimits/core",
    "cfc_relimits/limits"
  }
  for _index_0 = 1, #scopes do
    local scope = scopes[_index_0]
    local _list_0 = Find(tostring(scope) .. "/*.lua", "LUA")
    for _index_1 = 1, #_list_0 do
      local f = _list_0[_index_1]
      include(tostring(scope) .. "/" .. tostring(f))
    end
  end
end
