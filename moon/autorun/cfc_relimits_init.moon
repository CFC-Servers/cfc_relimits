require "logger"
import Find from file

export ReLimits = {}
ReLimits.Logger = Logger "ReLimits"
ReLimits.Logger\on("error")\call(error)

includeShared = (file) ->
    AddCSLuaFile file
    include file

if SERVER
    scopes = {
        "cfc_relimits/core"
        "cfc_relimits/limits"
    }

    for scope in *scopes
        for f in *Find "#{scope}/*.lua", "LUA"
            include "#{scope}/#{f}"
