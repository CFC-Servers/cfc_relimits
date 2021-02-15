class LimitGroup
    @limitTypes = {}

    Register: (limitType, comparator, default) =>
        @limitTypes[limitType] = :comparator, :default

    new: (@limitType) =>
        @limits = {}

    updateLimits: (limits) =>
        for uuid, limit in pairs limits
            limit.uuid = uuid
        @limits = tableMerge @limits, limits

    updateLimit: (limit, itemName) =>
        @limits[itemName] or= {}
        limit.uuid or= ReLimits.Utils.newUUID!
        @limits[itemName][limit.uuid] = limit

    getLimit: (itemName) =>
        -- {uuid : { max: int, timeFrame: seconds }}
        @limits[itemName]
