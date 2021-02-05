local theJson = [[
[

	{
		"inherits": "", "uuid": "1",
		"name": "Devotee",
		"limits": {
			"WEAPON": {
				"weapon_m9": 0
			},
			"TOOL": {
				"adv_dupe_2": 0
			},
			"ENTITY": {
				"sent_explosive": 50
			},
			"MODEL": {
				"gman.mdl": 0
			}
		}
	},
	{
		"inherits": "1",
		"uuid": "2",
		"name": "Nerds",
		"limits": {
			"WEAPON": {
				"weapon_m9": 1
			},
			"TOOL": {
				"adv_dupe_2": 1
			},
			"ENTITY": {
			},
			"MODEL": {
				"gman.mdl": 0
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
