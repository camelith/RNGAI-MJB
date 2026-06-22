params ["_logic", "_units", "_activated"];

if (!_activated || {!local _logic}) exitWith {};

private _target = attachedTo _logic;
if (isNull _target) then {
	private _synced = synchronizedObjects _logic;
	if (count _synced > 0) then { _target = _synced select 0; };
};

if (isNull _target) exitWith {
	systemChat "Module must be placed on a unit.";
	deleteVehicle _logic;
};

private _grp = group _target;
if (isNull _grp) exitWith { deleteVehicle _logic; };

{
	if (alive _x) then {
		_x setVariable ["RNG_disabled", true, true];
	};
} forEach (units _grp);

deleteVehicle _logic;
