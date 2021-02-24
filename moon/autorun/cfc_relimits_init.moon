require "cfclogger"

export ReLimits = {}
ReLimits.Logger = CFCLogger "ReLimits"

includeShared = (file) ->
    AddCSLuaFile file
    include file

if SERVER
    for f in *Find "cfc_relimits/core/*.lua", "LUA"
        include f

    for f in *Find "cfc_relimits/limits/*.lua", "LUA"
        include f
