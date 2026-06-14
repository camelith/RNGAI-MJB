if (isClass(configFile >> "CfgPatches" >> "cba_main")) then {
	["RNG_off", "CHECKBOX", ["Disable RNG AI", "Disables it"], "RNG", false,1] call CBA_fnc_addSetting;
	["RNG_playergroup", "CHECKBOX", ["Disable RNG AI on player groups", "Disables it on players group"], "RNG", true,1] call CBA_fnc_addSetting;
	["RNG_range", "SLIDER",   ["Activation range for RNG",   "Reaction distance from AI to activate RNG behaviour"], "RNG", [10, 2000, 550, 0],1] call CBA_fnc_addSetting;
	["RNG_sides", "LIST",     ["RNG AI active on side",     "Select sides that have RNG AI enabled"], "RNG", [["ALL","EAST","WEST","GUER"], ["ALL","ONLY OPFOR","ONLY BLUFOR","ONLY INDEPENDENT"], 0],1] call CBA_fnc_addSetting;
	["RNG_order_cooldown_duration", "SLIDER", ["Order Cooldown", "Sets RNG cooldown period after issuing an order, in seconds"], "RNG", [0, 120, 30, 0], 1] call CBA_fnc_addSetting;
	["RNG_civilians", "CHECKBOX", ["Enable RNG on civilians", "Applies RNG to civilians"], "RNG", false, 1] call CBA_fnc_addSetting;
	[	"RNG_disableAccuracy",
		"CHECKBOX",
		["Disable RNG Accuracy","Disables artificial MoA applied to AI shots."],
		["RNG","MJB Tweaks"],
		true,
		true,
		{},
		true
	] call CBA_fnc_addSetting;

	[	"RNG_dontKnowsAbout",
		"CHECKBOX",
		["Prevent LoS-less knowledge","Caps knowsAbout when out of direct Line of Sight."],
		["RNG","MJB Tweaks"],
		false,
		true,
		{},
		true
	] call CBA_fnc_addSetting;

	[	"RNG_dontKnowsCap",
		"SLIDER",
		["Max LoS-less knowledge","Cap for knowsAbout when out of direct Line of Sight."],
		["RNG","MJB Tweaks"],
		[0,4,1,2],
		true
	] call CBA_fnc_addSetting;

	[	"RNG_minVisTarget",
		"SLIDER",
		["Minimum Visibility to Target","Visiblility threshold for knowsAbout limiting and engaging the target. Lower numbers more likely to target through smoke."],
		["RNG","MJB Tweaks"],
		[0,1,0.01,2],
		true
	] call CBA_fnc_addSetting;

	[	"RNG_groupReactDelayMax",
		"SLIDER",
		["Max Group React Delay","Randomizes react delay when a group's EnemyDetected handler is triggered preventing all units simultaneously engaging."],
		["RNG","MJB Tweaks"],
		[0,10,2.2,2],
		true
	] call CBA_fnc_addSetting;

	[	"RNG_allyReactChance",
		"SLIDER",
		["React to Allies Chance","Chance for AI to react to nearby allies firing."],
		["RNG","MJB Tweaks"],
		[0,1,0,3],
		true
	] call CBA_fnc_addSetting;

	[	"RNG_allyCD",
		"CHECKBOX",
		["Enable Ally CD","Triggers RNG Cooldown when ally shots are ignored."],
		["RNG","MJB Tweaks"],
		false,
		true
	] call CBA_fnc_addSetting;
} else {
	RNG_off = false;
	RNG_sides = "ALL";
	RNG_range = 550;
	RNG_playergroup = true;
	RNG_order_cooldown_duration = 30;
	RNG_civilians = false;
};