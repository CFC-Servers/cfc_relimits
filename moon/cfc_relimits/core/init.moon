import format from string
import floor, randomseed, random from math
import time from os

randomseed time!

export ReLimits = {}
ReLimits.Utils =
    newUUID: ->
        bytes = {}
        for i = 1, 16 do
            bytes[i] = random 1, 256

        return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], math.floor((bytes[7] / 16) + 64), bytes[8],
            floor((bytes[9] / 4) + 128), bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16])
