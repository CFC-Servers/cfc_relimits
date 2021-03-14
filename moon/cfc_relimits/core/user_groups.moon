import Merge, insert from table
import JSONToTable, TableToJSON from util
import Read, CreateDir, Write from file

DATA_FILENAME = "relimits/limits.json"

class ReLimits.UserGroupManager
    @groups: {}
    @nameLookup: {}

    Register: (uuid, group) =>
        @groups[uuid] = group
        @nameLookup[group.name] = group

    GetPlayerLimits: (ply) =>
        --TODO: What do we do if we don't have a group object for this team, fallback to user? ensure it never happens?
        group = @GetUserGroup @GetUserGroupName ply

        if not group
            ReLimits.Logger\error "Found no group associated with player:", ply
            error!

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
        return unless content

        @Deserialzie data

    Serialize: () =>
        groups = {}

        for _, group in pairs @groups
            insert groups, {
                uuid: group.uuid
                name: group.name
                inherits: group.parent and group.parent.uuid
                limits: { k, v.limits for k, v in pairs group.limits }
            }

        TableToJSON groups

    Deserialize: (data) =>
        decodedData = JSONToTable data

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
        limitGroup = @limits[limitType]
        return unless limitGroup

        limitGroup\addLimit limit, identifier

        @clearCompiled!
        ReLimits.UserGroupManager\Save!

    clearCompiled: () ->
        return unless @children

        for child in *@children
            child.compiledLimitsData = nil

    generateCompiledLimitsList: (limitsMap) =>
        -- we need to make all limits at limitsMap[limitType][identifier] into a sequential list of limits
        --      rather than a limitsMap[limitType][identifier][uuid] = limit structure
        -- this will be slow, but this part of the function only occurs if limits change, so is on demand
        -- This is essentially a clone + conversion in one, for efficiency
        out = {}
        for limitType, limitData in pairs limitsMap
            newLimitData = {}
            for identifier, limits in pairs limitData
                newLimitData[identifier] = [ v for _, v in pairs limits ]
            out[limitType] = newLimitData
        out

    getLimitsData: () =>
        return @compiledLimitsData if @compiledLimitsData

        parentLimitsData = @parent and @parent\getLimitsRaw!
        -- TODO, limits here is a map from limitType to limitGroup, but here we're treating it like a map from limitType to limitGroup.limits
        -- needs fixing somehow 
        compiledLimitsMap = Merge (parentLimitsData.map or {}), @limits
        compiledLimitsList = @generateCompiledLimitsList compiledLimitsMap

        @compiledLimitsData =
            map: compiledLimitsMap
            list: compiledLimitsList

        return compiledLimitsData

    getLimits: () =>
        @getLimitsData!.list
