includeShared = (file) ->
    AddCSLuaFile file
    include file

includeShared "cfc_relimits/group_restrictions.moon"

include "cfc_relimits/sv_hooks.lua" if SERVER


