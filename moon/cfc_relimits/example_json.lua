local theJson = [[
[

	{
		"inherits": "",
		"uuid": "1",
		"name": "Devotee",
		"restrictions": {
			"WEAPON": {
				"weapon_m9": true
			},
			"TOOL": {
				"adv_dupe_2": false
			},
			"ENTITY": {
				"exploding_barrel_lel": true
			},
			"MODEL": {
				"gman": false
			}
		}
	},
	{
		"inherits": "1",
		"uuid": "2",
		"name": "Nerds",
		"restrictions": {
			"WEAPON": {
				"weapon_m9": false,
				"weapon_m8": true
			},
			"TOOL": {
				"adv_dupe_2": true
			},
			"ENTITY": {
			},
			"MODEL": {
				"gman": false
			}
		}
	},
	{
		"inherits": "2",
		"uuid": "3",
		"name": "Exalted",
		"restrictions": {
			"WEAPON": {
			    "weapon_m9": true
			},
			"TOOL": {
			    "simfphys_filler": true
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
		"restrictions": {
			"WEAPON": {
			    "weapon_nuke": false
			},
			"TOOL": {
			    "wire_adv": false
			},
			"ENTITY": {
			    "sent_nuke": false
			},
			"MODEL": {
			    "phxbomb.mdl": false,
			    "gman": true
			}
		}
	}
]
]]

return theJson
