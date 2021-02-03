json = require "json"
exampleJson = require "example_json"

math.randomseed(os.time())

istable = (v) -> type(v) == "table"

newUUID = ->
    bytes = {}
    for i = 1, 16 do
        bytes[i] = math.random(1, 256)

    return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
        bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], math.floor((bytes[7] / 16) + 64), bytes[8],
        math.floor((bytes[9] / 4) + 128), bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16])

tableMerge = ( dest, source ) ->
    for k, v in pairs( source )
        if ( istable( v ) and istable( dest[ k ] ) ) then
            tableMerge( dest[ k ], v )
        else
            dest[ k ] = v

    return dest

class LimitationGroup
    @limitTypes =
        "WEAPON"
        "TOOL"
        "ENTITY"
        "MODEL"

    new: (@limitType) =>
        @limits = {}

    updateLimits: (limits) =>
        @limits = tableMerge @limits, limits

    getLimit: (itemName) =>
        @limits[itemName]

class UserGroupManager
    @groups: {}

    register: (uuid, group) =>
        @@groups[uuid] = group

    getUserGroup: (groupName) =>
        for _, group in pairs @@groups
            if group.name == groupName
                return group

    serialize: () =>
        groups = {}

        for _, group in pairs @@groups
            table.insert groups, {
                uuid: group.uuid
                name: group.name
                inherits: group.parent and group.parent.uuid
                limits: { k, v.limits for k, v in pairs group.limits }
            }

        json.encode groups

    deserialize: (data) =>
        decodedData = json.decode data

        onLoaded = {}

        for _, groupData in pairs decodedData
            parent = groupData.inherits and @@groups[groupData.inherits]
            newGroup = UserGroup groupData.name, parent, groupData.uuid

            -- load limits
            for limitType, limits in pairs groupData.limits
                limitationGroup = newGroup.limits[limitType]
                limitationGroup.limits = limits

            -- handle parent not being loaded
            if not parent and groupData.inherits
                onLoaded[groupData.inherits] = (parent) ->
                    newGroup\setParent parent

            if onLoaded[newGroup.uuid]
                onLoaded[newGroup.uuid] newGroup

class UserGroup
    new: (@name, @parent, @uuid=newUUID!, @limits=@generateLimits!) =>
        UserGroupManager\register @uuid, self
        @compiledLimits = nil

    generateLimits: =>
        { limitType, LimitationGroup(limitType) for limitType in *LimitationGroup.limitTypes }

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

-- example

exampleDeserialize = () ->
    -- UserGroupManager\deserialize [==[
    -- [{"uuid":"394383","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":true}},"name":"regular","inherits":"840188"},{"uuid":"840188","name":"user","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":false,"m9k_davy_crocket":false}}}]
    -- ]==]
    UserGroupManager\deserialize exampleJson

    groups = { "1", "2", "3", "4" }

    for uuid in *groups
        group = UserGroupManager.groups[uuid]
        groupName = group.name

        for limitType, allowances in pairs group\getLimits!
            print groupName, limitType

            for name, isAllowed in pairs allowances.allowances
                print "  #{name}: #{isAllowed}"

            print ""

        print ""
        print "-------------------------------------------------------"
        print ""

exampleGroupCreation = () ->
    user = UserGroup "user"
    user\setRestricted  "WEAPON", "m9k_davy_crocket", false
    user\setRestricted "WEAPON", "m9k_minigun", false

    regular = UserGroup "regular", user
    regular\setRestricted "WEAPON", "m9k_minigun", true

    print "regular minigun", regular\isAllowed "WEAPON", "m9k_minigun"
    print "regular davy crocket", regular\isAllowed "WEAPON", "m9k_davy_crocket"
    print "regular random gun", regular\isAllowed "WEAPON", "random_gun"

    print UserGroupManager\serialize!

-- exampleGroupCreation!
exampleDeserialize!

