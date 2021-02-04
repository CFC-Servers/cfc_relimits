-- TODO: Set up the trackers on player spawn

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

    set: (identifier, value) =>
        @counts[identifier] = value

    change: (identifier, amount) =>
        @counts[identifier] or= 0

        if @counts[identifier] + amount <= 0
            return @counts[identifier] = 0

        @counts[identifier] += amount

    incr: (identifier) =>
        @change identifier, 1

    decr: (identifier) =>
        @change identifier, -1

    getCounts: (identifier) =>
        max: @manager\getLimit @limitType, identifier
        current: @counts[identifier] or 0

