--TODO: Fix inheritance for multiple limits
--provide an interface for adding a limit, which will ensure a uuid is specified for that limit
--when the compiledLimits table is created, merge over that uuid (using the uuid as the key),
--this will mean changing any code that uses the limits list, or discard the uuid after the limits are compiled (but still store the uuid in the limit)

-- uh oh, cant do above as we need the uuid until the end, instead change trackers
-- trackers will now need to iterate the limits using pairs, which is slow, so perhaps instead we cache the keys somewhere so we can use a numeric iterator?
-- who knows
-- :)

import Merge, insert from table
import TableToJSON from util

class ReLimits.UserGroupManager
    @groups: {}
    @nameLookup: {}

    Register: (uuid, group) =>
        @groups[uuid] = group
        @nameLookup[group.name] = group

    GetPlayerLimits: (ply) =>
        --TODO: What do we do if we don't have a group object for this team, fallback to user? ensure it never happens?
        group = @GetUserGroup @GetUserGroupName ply
        group and group\getLimits!

    GetUserGroupName: (ply) =>
        ply\GetUserGroup!

    GetUserGroup: (groupIdentifier) =>
        @groups[groupIdentifier] or @nameLookup[groupIdentifier]

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
        decodedData = json.decode data

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

class ReLimits.UserGroup
    new: (@name, @parent, @uuid=newUUID!, @limits=@generateLimits!) =>
        ReLimits.UserGroupManager\Register @uuid, self
        @compiledLimits = nil

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

    addLimit: (limitType, identifier, limit) =>
        limitGroup = @limits[limitType]
        return unless limitGroup

        limitGroup\addLimit limit, identifier

        @clearCompiled!

    clearCompiled: () ->
        return unless @children

        for child in *@children
            child.compiledLimits = nil

    getLimits: () =>
        return @compiledLimits if @compiledLimits

        parentLimits = @parent and @parent\getLimits!
        compiledLimits = Merge (parentLimits or {}), @limits

        @compiledLimits = compiledLimits

        return compiledLimits