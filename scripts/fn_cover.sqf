//RNG AI by Toksa
_unit=_this select 0;
_firer=_this select 1;
if (isplayer _unit OR {(_unit getvariable ["RNG_disabled",false]) OR {(missionnamespace getvariable ["RNG_off",false])}}) exitwith {};
_unit setvariable ["RNG_incombat",true];
_unit setvariable ["RNG_cover",true];
_exit=false;
_orderInterrupt=false;
_group=group _unit;
_types=["AGR","DFS","RND","FRM"];
_type=selectrandom _types;
_pos=[0,0,0];
_unit disableai "PATH";
_unit disableai "MOVE";
_unit disableai "ANIM";
_unit disableai "COVER";
_unit disableai "FSM";
_unit disableai "AIMINGERROR";
_target=_firer;
_anims=RNG_ANIM_Run;
_objects=[];
_starttime=time;
_cancrouch=true;
if (!(unitPos _unit isEqualTo "Auto")) then {_cancrouch=false;};
if (_cancrouch) then {
_stance=selectrandom ["Up","Crouch","Down"];
if (!((unitpos _unit) isEqualTo _stance)) then {
_unit playactionnow _stance;
};
	switch (_stance) do {
	  case ("Up"): {_unit setunitpos "Up"};
    case ("Crouch"): {_unit setunitpos "Middle"};
	case ("Down"): {_unit setunitpos "Down"};
	};
};
_time=time + 4;
_unit playactionnow (_anims select 0);
//// Find Pos
	_targetpos= objNull;
	_objectsDyn=nearestObjects [_unit, ["Wall","fence","Strategic","house"], 60];
	_objects=nearestTerrainObjects [_unit, ["Tree", "Bush","Wall","fence","Rock","house","Static","Thing","Building"], 60];
	_objects append _objectsDyn;
	if (!isnull _target) then {
		_sortedobjects= [_objects,[],{_unit distance _x},"ASCEND",{_target distance _x > _unit distance _x}] call BIS_fnc_sortBy;
		if (count _sortedobjects > 0) then {
			_targetpos=_sortedobjects select 0;
		};
	} else {
	_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;
	};
	if (_targetpos isEqualTo [0,0,0]) exitWith {
		_unit setvariable ["RNG_incombat",false];
		_unit setvariable ["RNG_cover",false];
		_unit setvariable ["RNG_cooldown",(time + 3)];
	};
	_line=lineIntersectsSurfaces [[(aimpos _unit) select 0,(aimpos _unit) select 1,((aimpos _unit) select 2) - 0.5], getposASL _targetpos, _unit, objNull, true, 1,"FIRE"];
if (!((count _line) isEqualTo 0)) then {
	_pos=(_line select 0) select 0; 
};
if (isNil "_pos" OR {(_pos isequalto [0,0,0])}) then {
			_leftpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,270])), _unit, objNull, true, 1,"FIRE"];
			_rightpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,90])), _unit, objNull, true, 1,"FIRE"];
			_backpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,180])), _unit, objNull, true, 1,"FIRE"];
			_backposleft=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,225])), _unit, objNull, true, 1,"FIRE"];
			_backposright=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,135])), _unit, objNull, true, 1,"FIRE"];
			_pos = selectrandom [((_leftpos select 0) select 0),((_rightpos select 0) select 0),((_backpos select 0) select 0),((_backposright select 0) select 0),((_backposleft select 0) select 0)];	
};
_wpCount=count waypoints _group;
_wpCurrent=currentWaypoint _group;
_wpPos=if (_wpCount > 0) then { waypointPosition [_group, _wpCurrent] } else { [0,0,0] };
_expDest=(expectedDestination _unit) select 0;
while {alive _unit && {local _unit}} do {
	if (
		(count waypoints _group) != _wpCount
		|| (currentWaypoint _group) isNotEqualTo _wpCurrent
		|| !((if ((count waypoints _group) > 0) then { waypointPosition [_group, currentWaypoint _group] } else { [0,0,0] }) isEqualTo _wpPos)
		|| ((expectedDestination _unit) select 0) isNotEqualTo _expDest
		|| (_unit getVariable ["RNG_break",false])
	) then {
		_unit setVariable ["RNG_break",false];
		_orderInterrupt=true;
		_exit=true;
	};
	if (time > _time) then {_exit=true};
	if (_exit OR {(lifestate _unit isEqualTo"INCAPACITATED") OR {!(isNull (objectParent _unit)) OR {isplayer _unit}}}) exitwith {
		[_unit,_cancrouch,_target,_orderInterrupt] spawn {
			params ["_unit","_cancrouch","_target","_orderInterrupt"];
			if (!_orderInterrupt) then {
				_unit playactionnow "STOP";
				dostop _unit;
				_unit domove getpos _unit;
			} else {
				_unit setvariable ["RNG_order_cooldown",(time + (missionNamespace getVariable ["RNG_order_cooldown_duration", 30]))];
			};
			_unit enableai "PATH";
			_unit enableai "MOVE";
			_unit enableai "ANIM";
			_unit enableai "FSM";
			_unit enableai "COVER";
			if (!_orderInterrupt) then { _unit dofollow leader _unit; };
			_unit enableai "AIMINGERROR";
			if (_cancrouch) then {_unit setunitpos "Auto"};
			_unit setvariable ["RNG_incombat",false];
			_unit setvariable ["RNG_cover",false];
			if (_orderInterrupt) then {
				_unit doWatch objNull;
				_unit doTarget objNull;
				_unit lookAt objNull;
				_unit setBehaviour "AWARE";
				_unit setCombatMode "YELLOW";
				_unit disableAI "AUTOCOMBAT";
				_unit disableAI "SUPPRESSION";
				[_unit] spawn {
					params ["_unit"];
					private _end = _unit getvariable ["RNG_order_cooldown",time];
					while {alive _unit && {time < _end}} do {
						if !((behaviour _unit) in ["AWARE","SAFE","CARELESS"]) then {
							_unit setBehaviour "AWARE";
						};
						sleep 1;
					};
					if (alive _unit) then {
						_unit enableAI "AUTOCOMBAT";
						_unit enableAI "SUPPRESSION";
					};
				};
			} else {
				_unit setvariable ["RNG_cooldown",(time + 6)];
				if (!isNull _target && {vehicle _target iskindof "Tank"}) then {
					_unit setvariable ["RNG_cooldown",(time + 4)];
				};
			};
			sleep 1;
		};
	};
	if (!isNil "_pos" && { _pos isNotEqualTo [0,0,0] }) then {
		private _safeZ = if ((getposATL _unit select 2) > 0.3) then { 0 } else { -1 };
		for "_i" from 1 to 10 do {
			private _vel = velocity _unit;
			private _pos = atltoasl (getposatl _unit);
			_unit setVelocityTransformation
			[
				_pos,
				_pos,
				_vel,
				[_vel select 0,_vel select 1,_safeZ],
				vectorDirVisual _unit,
				getPosASL _unit vectorFromTo _pos,
				[0,0,1],
				[0,0,1],
				(_i*0.1)
			];
			_unit setvectorup [0,0,1];
			sleep 0.08;
		};
	};

	if (!isNil "_pos" && {((_unit distance2D _pos) < 100)}) then {
		private _relDir = (_unit getreldir _pos);
		switch (true) do {
			case ((_unit distance2D _pos)< 2.5): {_unit playactionnow "stop";_exit=true;};
			case (_relDir < 67.5 && {_relDir > 22.5}): {_unit playactionnow (_anims select 0)};
			case (_relDir < 342.5 && {_relDir > 297.5}): {_unit playactionnow (_anims select 1);};
			case (_relDir < 22.5 OR _relDir > 342.5): {_unit playactionnow (_anims select 2);};
			case (_relDir < 202.5 && {_relDir > 157.5}): {_unit playactionnow (_anims select 3);};
			case (_relDir < 157.5 && {_relDir > 112.5}): {_unit playactionnow (_anims select 4);};
			case (_relDir < 247.5 && {_relDir > 202.5}): {_unit playactionnow (_anims select 5);};
			case (_relDir < 112.5 && {_relDir > 67.5}): {_unit playactionnow (_anims select 6);};
			case (_relDir < 292.5 && {_relDir > 247.5}): {_unit playactionnow (_anims select 7);};
		};
	} else {
		_unit playactionnow "stop";
		_unit setVelocity [0, 0, 0];
	};
	if ((time - _starttime) % 1 > 0.5) then {
		if (("run" in animationstate _unit OR {"evas" in animationstate _unit}) && {((vectorMagnitude (velocityModelSpace _unit)) < 1)}) then {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];};
	};

	sleep 0.02;
};
if !(alive _unit) then {
	_unit setvariable ["RNG_incombat",nil];
	_unit setvariable ["RNG_cover",nil];
	_unit setvariable ["RNG_cooldown",nil];
	_unit setvariable ["RNG_active",nil];
};