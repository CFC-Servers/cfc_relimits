import Merge, insert, Copy from table
import JSONToTable, TableToJSON from util
import Read, CreateDir, Write from file
import Logger from ReLimits
import newUUID from ReLimits.Utils

DATA_FILENAME = "relimits/limits.json"
DEFAULT_GROUP_NAME = "_DEFAULT"

class ReLimits.UserGroupManager
    @groups: {}
    @nameLookup: {}

    Register: (uuid, group) =>
        Logger\debug "Registering '#{uuid}':", group
        @groups[uuid] = group
        @nameLookup[group.name] = group

        @Save!

    GetPlayerLimits: (ply) =>
        group = @GetUserGroup @GetUserGroupName ply
        group or= @GetUserGroup DEFAULT_GROUP_NAME

        group and group\getLimits!

    GetUserGroupName: (ply) =>
        ply\GetUserGroup!

    GetUserGroup: (groupIdentifier) =>
        @groups[groupIdentifier] or @nameLookup[groupIdentifier]

    Save: () =>
        data = @Serialize!

        splitFilename = string.Split DATA_FILENAME
        splitFilename[#splitFilename] = nil

        dataDirectory = table.concat splitFilename, "/"

        CreateDir dataDirectory
        Write DATA_FILENAME, @Serialize!

    Load: () =>
        data = Read DATA_FILENAME, "DATA"
        @Deserialize data if data

        if not @GetUserGroup DEFAULT_GROUP_NAME
            ReLimits.UserGroup DEFAULT_GROUP_NAME

    Serialize: () =>
        groups = {}

        for _, group in pairs @groups
            insert groups, {
                uuid: group.uuid
                name: group.name
                inherits: group.parent and group.parent.uuid
                limits: { k, v.limits for k, v in pairs group.limits }
            }

        serialized = TableToJSON groups
        Logger\debug "Serialized:", serialized

        serialized

    Deserialize: (data) =>
        decodedData = JSONToTable data
        Logger\debug "Data:", data
        Logger\debug "Decoded Data:", decodedData

        onLoaded = {}

        for _, groupData in pairs decodedData
            parent = groupData.inherits and @groups[groupData.inherits]
            newGroup = ReLimits.UserGroup groupData.name, parent, groupData.uuid

            -- load limits
            for limitType, limits in pairs groupData.limits
                limitGroup = newGroup.limits[limitType]
                limitGroup.limits = limits

            -- handle parent not being loaded
            if not parent and groupData.inherits
                onLoaded[groupData.inherits] = (parent) ->
                    newGroup\setParent parent

            if onLoaded[newGroup.uuid]
                onLoaded[newGroup.uuid] newGroup

        Logger\debug "Deserialized:", onLoaded
        onLoaded

hook.Add "Initialize", "CFC_ReLimits_LoadLimits", ReLimits.UserGroupManager\Load

class ReLimits.UserGroup
    new: (@name, @parent, @uuid=newUUID!, @limits=@generateLimits!) =>
        ReLimits.UserGroupManager\Register @uuid, self
        @compiledLimitsData = nil

    generateLimits: =>
        -- TODO: Give these to the user group on creation - it shouldn't have to do this
        { limitType, ReLimits.LimitGroup limitType for limitType in pairs ReLimits.LimitGroup.limitTypes }

    setParent: (parent) =>
        @parent = parent
        @parent.children or= {}
        insert @parent.children, self

    updateLimits: (limitType, limits) =>
        limitGroup = @limits[limitType]
        return unless limitGroup

        limitGroup\updateLimits limits

        @clearCompiled!
        ReLimits.UserGroupManager\Save!

    addLimit: (limitType, identifier, limit) =>
        Logger\debug "Attempting to add limit '#{limitType}' with identifier: #{identifier}:", limit

        limitGroup = @limits[limitType]
        return unless limitGroup

        Logger\debug "Adding limit '#{limitType}' with identifier: #{identifier}"

        limitGroup\addLimit limit, identifier

        @clearCompiled!
        ReLimits.UserGroupManager\Save!

    clearCompiled: () ->
        return unless @children

        for child in *@children
            child.compiledLimitsData = nil

    generateCompiledLimitsList: (limitsMap) =>
        out = {}

        for limitType, limitGroup in pairs limitsMap
            newLimitData = {}

            for identifier, limits in pairs limitGroup.limits
                newLimitData[identifier] = [ v for _, v in pairs limits ]

            out[limitType] = newLimitData

        out

    getLimitsRaw: () =>
        {
            map: @limits,
            list: @generateCompiledLimitsList @limits
        }

    getLimitsData: () =>
        return @compiledLimitsData if @compiledLimitsData

        parentLimitsData = @parent and @parent\getLimitsData!
        parentLimitsDataMap = parentLimitsData and parentLimitsData.map or {}

        compiledLimitsMap = Merge (Copy parentLimitsDataMap), @limits
        compiledLimitsList = @generateCompiledLimitsList compiledLimitsMap

        @compiledLimitsData =
            map: compiledLimitsMap
            list: compiledLimitsList

        return compiledLimitsData

    getLimits: () =>
        @getLimitsData!.list
