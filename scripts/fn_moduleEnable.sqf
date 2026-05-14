params ["_logic", "_units", "_activated"];

if (!_activated) exitWith {};
if (!isServer) exitWith { deleteVehicle _logic; };

private _target = attachedTo _logic;
if (isNull _target) then {
	private _synced = synchronizedObjects _logic;
	if (count _synced > 0) then { _target = _synced select 0; };
};

if (isNull _target) exitWith {
	["Modules must be placed on a unit."] remoteExec ["systemChat", 0];
	deleteVehicle _logic;
};

private _grp = group _target;
if (isNull _grp) exitWith { deleteVehicle _logic; };

{
	if (alive _x) then {
		_x setVariable ["RNG_disabled", false, true];
	};
} forEach (units _grp);

deleteVehicle _logic;
