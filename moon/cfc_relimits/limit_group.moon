class LimitGroup
    -- TODO: Put this on a global table
    -- TODO: Ideally _not_ define these here, have them added as-needed by users
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
        -- { max: int, timeFrame: seconds }
        @limits[itemName]
