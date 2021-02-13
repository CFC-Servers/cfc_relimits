mathMin = math.min

class LimitTypeTrackerManager
    new: (@ply) =>
        if ply.TrackerManager
            error "Attempted to add second tracker manager to player " .. tostring ply
        ply.TrackerManager = @
        @typeTrackers = {}

    -- TODO: Should these getters/setters have "tracker" in the name?
    -- Is this doing too much?
    -- Stinky code smell?
    addTracker: (trackerType, tracker) =>
        @typeTrackers[trackerType] = tracker

    getTracker: (trackerType) =>
        @typeTrackers[trackerType]

    getLimit: (limitType, identifier) =>
        UserGroupManager\GetPlayerLimits(@ply)\getLimits![limitType][identifier]

class LimitTypeTracker
    new: (@limitType, @manager) =>
        @counts = {}
        @timeFrameStarts = {}
        @manager\addTracker @limitType, @

    set: (identifier, value) =>
        limitDataList = @getLimitData!
        currentCounts = @counts[identifier] or {}
        for i = 1, #limitDataList
            currentCounts[i] = value
        @counts[identifier] = currentCounts

    change: (identifier, amount) =>
        return if amount == 0
        @counts[identifier] or= {}

        curTime = CurTime!

        limitDataList = @getLimitData!

        currentCounts = @counts[identifier]
        for i = 1, #limitDataList
            currentCount = currentCounts[i] or 0
            newCount = currentCount + amount

            if newCount <= 0
                currentCounts[i] = 0
            else
                if currentCount == 0
                    @timeFrameStarts[identifier] or= {}
                    @timeFrameStarts[identifier][i] = curTime
                currentCounts[i] = newCount

    incr: (identifier) =>
        @change identifier, 1

    decr: (identifier) =>
        @change identifier, -1

    getLimitData: (identifier) =>
        @manager\getLimitData @limitType, identifier

    isAllowed: (identifier) =>
        limitDataList = @getLimitData!

        :comparator, :default = LimitGroup.limitTypes[@limitType]

        currents = @counts[identifier] or {}
        timeFrameStarts = @timeFrameStarts[identifier] or {}

        allowed = nil

        curTime = CurTime!

        for i = 1, #limitDataList
            limitData = limitDataList[i]

            :timeFrame, max: maxCount = limitData
            current = currents[i] or 0
            timeFrameStart = timeFrameStarts[i] or 0

            if timeFrame > 0 and curTime > timeFrameStart + timeFrame
                current = 0
                currents[i] = 0

            allowed = comparator (mathMin current, maxCount), maxCount

            false if not allowed

        allowed or default

    getCounts: (identifier) =>
        limitDataList = @getLimitData!

        currents = @counts[identifier] or {}
        timeFrameStarts = @timeFrameStarts[identifier] or {}

        curTime = CurTime!

        out = {}

        for i, limitData in pairs limitDataList do
            :timeFrame, max: maxCount = limitData
            current = currents[i] or 0
            timeFrameStart = timeFrameStarts[i] or 0

            if timeFrame > 0 and curTime > timeFrameStart + timeFrame
                current = 0
                currents[i] = 0

            out[i] = current: (mathMin current, maxCount), max: maxCount

        out

hook.Add "PlayerInitialSpawn", "ReLimits_CreateTrackerManager", (ply) ->
    manager = LimitTypeTrackerManager ply

    for limitType in pairs LimitGroup.limitTypes
        LimitTypeTracker limitType, manager
