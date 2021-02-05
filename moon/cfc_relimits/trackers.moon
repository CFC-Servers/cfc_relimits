-- TODO: Set/lua/betterchat/shared/sh_util.hc up the trackers on player spawn
import min from math

min: mathMin = math

class LimitTypeTrackerManager =>
    -- TODO: Should this get the group from the player?
    new: (@ply, @group) =>
        -- TODO: Make sure there's only one of these
        -- TODO: Store this on the player
        @typeTrackers = {}

    plyGroup: =>
        @ply\GetUserGroup!

    -- TODO: Should these getters/setters have "tracker" in the name?
    -- Is this doing too much?
    -- Stinky code smell?
    addTracker: (trackerType, tracker) =>
        @typeTrackers[trackerType] = tracker

    getTracker: (trackerType) =>
        @typeTrackers[trackerType]

    getLimit: (limitType, identifier) =>
        @group\getLimits![limitType][identifier]

class LimitTypeTracker
    new: (@limitType, @manager) =>
        @counts = {}
        @timeFrameStarts = {}

    set: (identifier, value) =>
        @counts[identifier] = value

    change: (identifier, amount) =>
        return if amount == 0
        @counts[identifier] or= 0

        currentCount = @counts[identifier]
        newCount = currentCount + amount

        if newCount <= 0
            @counts[identifier] = 0
            return

        if currentCount == 0
            @timeFrameStarts[identifier] = CurTime!

        @counts[identifier] = newCount

    incr: (identifier) =>
        @change identifier, 1

    decr: (identifier) =>
        @change identifier, -1

    getLimitData: (identifier) =>
        @manager\getLimitData @limitType, identifier

    getCounts: (identifier) =>
        limitData = @getLimitData!
        :timeFrame, max: maxCount = limitData

        current = @counts[identifier] or 0
        timeFrameStart = @timeFrameStarts[identifier] or 0

        if CurTime! > timeFrameStart + timeFrame
            current = 0
            @counts[identifier] = 0

        current = mathMin current, maxCount
        :current, :max, :limitData
