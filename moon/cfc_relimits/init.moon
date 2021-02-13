math.randomseed(os.time())

export ReLimits = {}
ReLimits.Utils =
    json: require "json"

    istable: (v) -> type(v) == "table"

    newUUID: ->
        bytes = {}
        for i = 1, 16 do
            bytes[i] = math.random(1, 256)

        return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], math.floor((bytes[7] / 16) + 64), bytes[8],
            math.floor((bytes[9] / 4) + 128), bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16])

    tableMerge: ( dest, source ) ->
        for k, v in pairs( source )
            if ( istable( v ) and istable( dest[ k ] ) ) then
                tableMerge( dest[ k ], v )
            else
                dest[ k ] = v

        return dest
