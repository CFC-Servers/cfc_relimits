includeShared = (file) ->
    AddCSLuaFile file
    include file

includeShared "cfc_relimits/group_limits.moon"

include "cfc_relimits/sv_hooks.lua" if SERVER


