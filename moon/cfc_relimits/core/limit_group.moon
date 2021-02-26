class ReLimits.LimitGroup
    @limitTypes = {}

    LT: (current, max) -> current < max
    LE: (current, max) -> current <= max
    GT: (current, max) -> current > max
    GE: (current, max) -> current >= max

    Register: (limitType, comparator=@LT, default=true) =>
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
