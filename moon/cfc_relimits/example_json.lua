local theJson = [[
[

	{
		"inherits": "", "uuid": "1",
		"name": "Devotee",
		"limits": {
			"WEAPON": {
				"weapon_m9": {
					{ "max": 5, "timeFrame": 60 }
				}
				"*": {
					{ "max": 10, "timeFrame": 60 }
				}
			},
			"ENTITY": {
				"prop_physics": {
					"aiwudhauwd": { "max": 100, "timeFrame": 0 },
					"0o9quwdpoiajend0aeif": { "max": 5, "timeFrame": 1 }
				}
			}
		}
	},
	{
		"inherits": "1",
		"uuid": "2",
		"name": "Nerds",
		"limits": {
			"ENTITY": {
				"prop_physics": {
					"0o9quwdpoiajend0aeif": { "max": 100000 }
				}
			}
		}
	},
	{
		"inherits": "2",
		"uuid": "3",
		"name": "Exalted",
		"limits": {
			"WEAPON": {
			    "weapon_m9": 1
			},
			"TOOL": {
			    "simfphys_filler": 1
			},
			"ENTITY": {
			},
			"MODEL": {
			}
		}
	},
	{
		"inherits": "2",
		"uuid": "4",
		"name": "Super",
		"limits": {
			"WEAPON": {
			    "weapon_nuke": 0
			},
			"TOOL": {
			    "wire_adv": 0
			},
			"ENTITY": {
			    "sent_nuke": 0
			},
			"MODEL": {
			    "phxbomb.mdl": 0,
			    "gman.mdl": true
			}
		}
	}
]
]]

return theJson
