class UserGroupManager
    @groups: {}
    @nameLookup: {}

    Register: (uuid, group) =>
        @groups[uuid] = group
        @nameLookup[group.name] = group

    GetPlayerLimits: (ply) =>
        --TODO: What do we do if we don't have a group object for this team, fallback to user? ensure it ever happens?
        group = @nameLookup[ply\GetUserGroup!]
        group and group\getLimits!

    FindUserGroup: (groupName) =>
        for _, group in pairs @groups
            if group.name == groupName
                return group

    GetUserGroup: (uuid) =>
        @groups

    Serialize: () =>
        groups = {}

        for _, group in pairs @groups
            table.insert groups, {
                uuid: group.uuid
                name: group.name
                inherits: group.parent and group.parent.uuid
                limits: { k, v.limits for k, v in pairs group.limits }
            }

        json.encode groups

    Deserialize: (data) =>
        decodedData = json.decode data

        onLoaded = {}

        for _, groupData in pairs decodedData
            parent = groupData.inherits and @groups[groupData.inherits]
            newGroup = UserGroup groupData.name, parent, groupData.uuid

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

class UserGroup
    new: (@name, @parent, @uuid=newUUID!, @limits=@generateLimits!) =>
        UserGroupManager\Register @uuid, self
        @compiledLimits = nil

    generateLimits: =>
        -- TODO: Give these to the user group on creation - it shouldn't have to do this
        { limitType, LimitGroup limitType for limitType in pairs LimitGroup.limitTypes }

    setParent: (parent) =>
        @parent = parent
        @parent.children or= {}
        table.insert @parent.children, self

    updateLimits: (limitType, limits) =>
        limitGroups = @limits[limitType]
        return unless limitGroups

        limitGroups\updateLimits limits

        return unless @children

        for child in *@children
            child.compiledLimits = nil

    getLimits: () =>
        return @compiledLimits if @compiledLimits

        parentLimits = @parent and @parent\getLimits!
        compiledLimits = tableMerge (parentLimits or {}), @limits
        @compiledLimits = compiledLimits

        return compiledLimits
