//RNG AI by Toksa
_unit = _this select 0;
_infront=objNull;
while {alive _unit && {_unit getvariable ["RNG_incombat",false] && {!(_unit getvariable ["RNG_cover",false])}}} do {
	_target=_unit getvariable ["RNG_target",objNull];
	if ( animationstate _unit isEqualTo "amovpercmstpsraswrfldnon" OR {animationstate _unit isEqualTo "amovpknlmstpsraswrfldnon"} ) then {_unit setvelocity [0,0,0]};
	_safeZ = if ((getposATL _unit select 2) > 0.3) then { 0 } else { -1 };
	if (!(isNull _target)) then {
		for "_i" from 1 to 10 do {
			private _vel = velocity _unit;
			private _pos = atltoasl (getposatl _unit);
			_unit setVelocityTransformation
			[
			_pos,
			_pos,
			[_vel select 0,_vel select 1,_safeZ],
			[_vel select 0,_vel select 1,_safeZ],
			vectordirvisual _unit,
			(((aimpos _unit) vectorfromto (aimpos _target)) vectoradd ((vectordir _unit) vectorDiff (_unit weaponDirection currentWeapon _unit))),
			vectorup _unit,
			vectorup _unit,
			(_i*0.1)
			];
			_unit setvectorup [0,0,1];
			sleep 0.06;
		};
	} else {
		for "_i" from 1 to 10 do {
			private _vel = velocity _unit;
			private _pos = atltoasl (getposatl _unit);
			_unit setVelocityTransformation
			[
			_pos,
			_pos,
			[_vel select 0,_vel select 1,_safeZ],
			[_vel select 0,_vel select 1,_safeZ],
			vectordirvisual _unit,
			vectordirvisual _unit,
			[0,0,1],
			[0,0,1],
			(_i*0.1)
			];
			_unit setvectorup [0,0,1];
			sleep 0.06;
		};
	}; 
	
	////Firing
	_reldir=_unit getreldir _target;
	if ((!isNull _target && {((_reldir) < 25.55555555555 OR {(_reldir) > 335.555555555})}) && {( ([_unit, "VIEW",_target] checkVisibility [eyepos _unit, aimpos _target]) > 0 OR { ([_unit, "VIEW",_target] checkVisibility [aimpos _unit, eyepos _target]) > 0 } )}) then {
		_infrontline=lineIntersectsSurfaces [eyePos _unit,((eyepos _unit) vectorAdd (_unit weaponDirection currentWeapon _unit vectorMultiply 30)), _unit, objNull, true, 1];
		if (count _infrontline > 0) then {
			_infront=(_infrontline select 0) select 2;
		} else {
			_infront=objNull;
		};
		if (!(unitCombatMode _unit isEqualTo "BLUE") && { [side _infront, side _unit] call BIS_fnc_sideIsFriendly && {!(side _infront isEqualTo civilian && {(_infront isKindOf 'CAManBase' || {count crew _infront > 0}) && {currentWeapon _infront isEqualTo "" || { [side _unit, civilian] call BIS_fnc_sideIsFriendly } } } ) }  }) then {
			for "_i" from 1 to (round (random 20)) do {
				[_unit, currentmuzzle _unit] call BIS_fnc_fire;
				sleep 0.01;
			};
		} else {sleep 0.5;};
	};
sleep 0.01;	
};		