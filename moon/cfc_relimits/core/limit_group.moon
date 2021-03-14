import Logger from ReLimits

class ReLimits.LimitGroup
    @limitTypes = {}

    LT: (current, max) -> current < max
    LE: (current, max) -> current <= max
    GT: (current, max) -> current > max
    GE: (current, max) -> current >= max

    Register: (limitType, comparator=@LT, default=true) =>
        Logger\debug "Registering limit type '#{limitType}'"
        @limitTypes[limitType] = :comparator, :default

    new: (@limitType) =>
        @limits = {}

    updateLimits: (limits) =>
        Logger\debug "Updating limits. Current: ", @limits, "Next: ", limits

        for uuid, limit in pairs limits
            limit.uuid = uuid

        @limits = tableMerge @limits, limits

    updateLimit: (limit, itemName) =>
        @limits[itemName] or= {}

        Logger\debug "Updating limit '#{itemName}'. Current: #{@limits[itemName]}", "Next: ", limit

        limit.uuid or= ReLimits.Utils.newUUID!
        @limits[itemName][limit.uuid] = limit

    getLimit: (itemName) =>
        -- {uuid : { max: int, timeFrame: seconds }}
        @limits[itemName]
