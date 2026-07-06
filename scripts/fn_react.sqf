//RNG AI by Toksa
params ["_unit", "_firer"];
if (captive _unit) exitwith {};
_range=missionnamespace getvariable ["RNG_range",550];
if ((missionnamespace getvariable ["RNG_playergroup",true]) && {isPlayer (leader _unit)}) exitwith {};
if (!(_unit getvariable ["RNG_incombat",false]) && { isNull (objectParent _unit) && {!(lifestate _unit isEqualTo "INCAPACITATED") && {(_unit checkAIFeature "PATH") && {(_unit checkAIFeature "MOVE")}}}}) then {
	_alltargets=_unit targets [true,_range];
	/*
	_sortedtargets = [_alltargets,[],{_unit distance _x},"ASCEND"] call BIS_fnc_sortBy;
	*/
	_orderCD=_unit getvariable ["RNG_order_cooldown",(time - 1)];
	if (time < _orderCD && {(count (waypoints _unit)) > 0}) exitwith {};
	_cooldown=_unit getvariable ["RNG_cooldown",(time - 1)];
	if (count _alltargets > 0) then {
		if (currentWeapon _unit isEqualTo binocular _unit) then {
			_unit selectWeapon primaryWeapon _unit;
		};
		if ((behaviour _unit isEqualTo "SAFE" OR { behaviour _unit isEqualTo "AWARE" { OR count _alltargets isEqualTo 0 OR { _firer distance _unit > 100 OR { vehicle _firer iskindof "Tank" }}}}) && { !(side _firer isEqualTo side _unit) && { time > _cooldown && { getsuppression _unit > 0.5 }}}) then {
			[_unit,_firer] spawn RNG_fnc_cover;
		} else {
			[_unit,_firer] spawn RNG_fnc_combat;
			if (!isNull _firer) then {
				_unit setvariable ["RNG_target", _firer];
			};
			_friendly=_unit nearEntities ["Man", 100];
			{
				_man=_x;
				if (side _man isEqualTo side _unit) then {
					{
						_man reveal [_x, 1.5];
					} foreach (_unit targets [true,100]);
				};
			} foreach _friendly;
		};
	};
};