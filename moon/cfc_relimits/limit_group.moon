class LimitGroup
    @limitTypes = {}

    Register: (limitType, comparator, default) =>
        @limitTypes[limitType] = :comparator, :default

    new: (@limitType) =>
        @limits = {}

    updateLimits: (limits) =>
        @limits = tableMerge @limits, limits

    getLimit: (itemName) =>
        -- [{ max: int, timeFrame: seconds }]
        @limits[itemName]
