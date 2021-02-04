-- Serialization Tests

exampleJson = require "example_json"
exampleDeserialize = () ->
    -- UserGroupManager\deserialize [==[
    -- [{"uuid":"394383","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":true}},"name":"regular","inherits":"840188"},{"uuid":"840188","name":"user","restrictions":{"ENTITY":[],"TOOL":[],"WEAPON":{"m9k_minigun":false,"m9k_davy_crocket":false}}}]
    -- ]==]
    UserGroupManager\deserialize exampleJson

    groups = { "1", "2", "3", "4" }

    for uuid in *groups
        group = UserGroupManager.groups[uuid]
        groupName = group.name

        for limitType, allowances in pairs group\getLimits!
            print groupName, limitType

            for name, isAllowed in pairs allowances.allowances
                print "  #{name}: #{isAllowed}"

            print ""

        print ""
        print "-------------------------------------------------------"
        print ""

exampleGroupCreation = () ->
    user = UserGroup "user"
    user\setRestricted  "WEAPON", "m9k_davy_crocket", false
    user\setRestricted "WEAPON", "m9k_minigun", false

    regular = UserGroup "regular", user
    regular\setRestricted "WEAPON", "m9k_minigun", true

    print "regular minigun", regular\isAllowed "WEAPON", "m9k_minigun"
    print "regular davy crocket", regular\isAllowed "WEAPON", "m9k_davy_crocket"
    print "regular random gun", regular\isAllowed "WEAPON", "random_gun"

    print UserGroupManager\serialize!

-- exampleGroupCreation!
exampleDeserialize!

