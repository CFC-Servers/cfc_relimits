includeShared = (file) ->
    AddCSLuaFile file
    include file

includeShared "cfc_relimits/types.lua"

include "cfc_relimits/sv_hooks.lua" if SERVER


