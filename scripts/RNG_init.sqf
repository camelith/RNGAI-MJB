if (isClass(configFile >> "CfgPatches" >> "cba_main")) then {
	["RNG_off", "CHECKBOX", ["Disable RNG AI", "Disables it"], "RNG", false,1] call CBA_fnc_addSetting;
	["RNG_playergroup", "CHECKBOX", ["Disable RNG AI on player groups", "Disables it on players group"], "RNG", true,1] call CBA_fnc_addSetting;
	["RNG_range", "SLIDER",   ["Activation range for RNG",   "Reaction distance from AI to activate RNG behaviour"], "RNG", [10, 2000, 550, 0],1] call CBA_fnc_addSetting;
	["RNG_sides", "LIST",     ["RNG AI active on side",     "Select sides that have RNG AI enabled"], "RNG", [["ALL","EAST","WEST","GUER"], ["ALL","ONLY OPFOR","ONLY BLUFOR","ONLY INDEPENDENT"], 0],1] call CBA_fnc_addSetting;
	["RNG_order_cooldown_duration", "SLIDER", ["Order Cooldown", "Sets RNG cooldown period after issuing an order, in seconds"], "RNG", [0, 120, 30, 0], 1] call CBA_fnc_addSetting;
	["RNG_civilians", "CHECKBOX", ["Enable RNG on civilians", "Applies RNG to civilians"], "RNG", false, 1] call CBA_fnc_addSetting;
} else {
	RNG_off = false;
	RNG_sides = "ALL";
	RNG_range = 550;
	RNG_playergroup = true;
	RNG_order_cooldown_duration = 30;
	RNG_civilians = false;
};