//RNG AI by Toksa
_unit=_this select 0;
_firer=_this select 1;
_disabled=_unit getvariable ["RNG_disabled",false];
_off=missionnamespace getvariable ["RNG_off",false];
if (isplayer _unit or {_disabled or {_off}}) exitwith {};
_unit setvariable ["RNG_incombat",true];
[_unit] spawn RNG_fnc_turning;
_exit=false;
_orderInterrupt=false;
_suppressed=false;
_group=group _unit;
_types=["AGR","DFS","RND","FRM","CVR","FLW"];
if (isplayer (leader _unit)) then {_types=["FLW","FLW","FLW","FLW","FLW","FLW"];};
_weight=[1,0.8,0.8,0.8,0,0.8];
_type=_types selectRandomWeighted _weight;
_suppression=0;
_pos=[0,0,0];
_unit disableai "PATH";
_unit disableai "MOVE";
_unit disableai "COVER";
_unit disableai "FSM";
_unit disableai "AIMINGERROR";
_target=objNull;
_anims=RNG_ANIM_Tact;
_line = [];
_targetpos=[0,0,0];
_infront=objNull;
_weapon=currentweapon _unit;
_starttime=time;
_cancrouch=true;
_targettimeout=time;
_dodge=false;
_skill=((1 - (_unit skillfinal "general")) * 5);
private _minVis = RNG_minVisTarget;

if (!isNull _firer && {([_unit, "FIRE",_firer] checkVisibility [aimpos _unit, aimpos _firer]) > _minVis}) then {_target=_firer};

if (!(unitPos _unit isEqualTo "AUTO")) then {_cancrouch=false;};
sleep (random 0.5);

_wpCount=count waypoints _group;
_wpCurrent=currentWaypoint _group;
_wpPos=if (_wpCount > 0) then { waypointPosition [_group, _wpCurrent] } else { [0,0,0] };
_expDest=(expectedDestination _unit) select 0;

scopeName "main";
while {alive _unit && {local _unit}} do {
	if (
		(count waypoints _group) isNotEqualTo _wpCount
		|| { (currentWaypoint _group) isNotEqualTo _wpCurrent
		|| { !((if ((count waypoints _group) > 0) then { waypointPosition [_group, currentWaypoint _group] } else { [0,0,0] }) isEqualTo _wpPos)
		|| { !(((expectedDestination _unit) select 0) isEqualTo _expDest)
		|| { (_unit getVariable ["RNG_break",false]) }}}}
	) exitWith {
		_unit setVariable ["RNG_break",false];
		_orderInterrupt=true;
	};
	if (getSuppression _unit > 0.9 && {_target distance _unit > 30}) then {_cooldown=_unit getvariable ["RNG_cooldown",(time -1)]; if (time > _cooldown) then {_suppressed=true;_exit=true};};
	if (!alive _unit OR { captive _unit OR { _exit OR { !(isNull (objectParent _unit)) OR { (lifestate _unit isEqualTo "INCAPACITATED") OR {isplayer _unit }}}}}) exitwith { };
	if (!(currentweapon _unit isEqualTo _weapon)) then {sleep 2;_weapon = currentweapon _unit};
	if ((time - _starttime) % 5 > 4) then {
		_weight set [4,((getsuppression _unit) max 0)];
		_type=_types selectRandomWeighted _weight;
	};
	if ( (time - _starttime) % 30 > 29 ) then {
		_sortedtargets=[];
		_alltargets=_unit targets [true,300];
		_sortedtargets = [_alltargets,[],{_unit distance _x},"ASCEND",{([_unit, "FIRE",_x] checkVisibility [aimpos _unit, aimpos _x]) > 0}] call BIS_fnc_sortBy;
		sleep 0.1;
		if (!isnil "_sortedtargets" && {count _sortedtargets isEqualTo 0}) then {
			breakTo "main";
		};
	};
	if ( (time - _starttime) % 1 > 0.5 ) then {
		_alltargets=_unit targets [true,300];
		_targets = [_alltargets,[],{_unit distance _x},"ASCEND",{([_unit, "FIRE",_x] checkVisibility [aimpos _unit, aimpos _x]) > 0}] call BIS_fnc_sortBy;
		sleep 0.02;
		if (count _targets > 0) then {
			_target = _targets select 0;
			_unit dotarget _target;
			_unit dowatch _target;
			_unit lookat _target;
			_targettimeout=time + 5;
		} else {
			if ((time > _targettimeout) OR { !alive _target }) then {
				_target=objNull;
			};
		};
	};
	
	if ( (time - _starttime) % 4 > 3.5 ) then {
		if (_cancrouch) then {
			_stance=selectrandom ["UP","MIDDLE"];
			if (!isNull _target && {_target distance2D _unit > 150}) then {_stance=["UP","MIDDLE","DOWN"] selectRandomWeighted [1,1,0.2];};
			if ((unitpos _unit) isNotEqualTo _stance) then {
				_unit playactionnow _stance;
			};
			switch (_stance) do {
				case "MIDDLE" : {_unit setunitpos "MIDDLE";};
				case "UP" : {_unit setunitpos "UP";};
				case "DOWN" : {
					_unit setunitpos "DOWN";
					private _proneEnd = time + ((random 5) + 3);
					while {alive _unit && {time < _proneEnd}} do {
						if (
							(count waypoints _group) != _wpCount
							|| (currentWaypoint _group) != _wpCurrent
							|| !((if ((count waypoints _group) > 0) then { waypointPosition [_group, currentWaypoint _group] } else { [0,0,0] }) isEqualTo _wpPos)
							|| !(((expectedDestination _unit) select 0) isEqualTo _expDest)
							|| (_unit getVariable ["RNG_break",false])
						) exitWith {};
						sleep 0.25;
					};
				};
				default {};
			};
		};
	};
	_objectsDyn=nearestObjects [_unit, ["Wall","fence","Strategic","NonStrategic","house","Land"], 60];
	_objects=nearestTerrainObjects [_unit, ["Tree", "Bush","Wall","fence","Rock","house","Static","Thing","Building"], 60];
	_objects append _objectsDyn;
	if (count _objects < 1) exitWith {};
	_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;
	switch (_type) do {
		case "AGR" : {_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;};
		case "RND" : {if (count _objects > 2) then {_targetpos = _objects select 1;} else {_targetpos = _objects select 0;};};
		case "DFS" : {
			if (!isNull _target) then {
				_sortedobjects= [_objects,[],{_unit distance _x},"ASCEND",{([_target, "FIRE",_x] checkVisibility [aimpos _target, getposasl _x]) < 1}] call BIS_fnc_sortBy;
				if (count _sortedobjects > 0) then {
					_targetpos=_sortedobjects select 0;
				};
				} else {_type=_types selectRandomWeighted _weight;};
		};
		case "CVR" : {	if (!isnull _target) then {
				_sortedobjects= [_objects,[],{_unit distance _x},"ASCEND",{_target distance _x > _unit distance _x}] call BIS_fnc_sortBy;
				if (count _sortedobjects > 0) then {
					_targetpos=_sortedobjects select 0;
				};
			} else {
				_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;
			};};
		case "FRM" : {_targetpos=[_objects,((expectedDestination _unit) select 0)] call BIS_fnc_nearestPosition;};
		case "FLW" : {_unit dofollow leader _unit;_targetpos=[_objects,formationposition _unit] call BIS_fnc_nearestPosition;};
		default {};
	};
	if (_targetpos isEqualType objNull) then {
		_line=lineIntersectsSurfaces [[(aimpos _unit) select 0,(aimpos _unit) select 1,((aimpos _unit) select 2) - 0.5], getposASL _targetpos, _unit, objNull, true, 1,"FIRE"];
	} else {
		_line=lineIntersectsSurfaces [[(aimpos _unit) select 0,(aimpos _unit) select 1,((aimpos _unit) select 2) - 0.5],_targetpos, _unit, objNull, true, 1,"FIRE"];
	};
	sleep 0.02;
	if (!((count _line) isEqualTo 0)) then {
		_pos=(_line select 0) select 0; 
	};
	
	////Leaning
	if ((time - _starttime) % 1 > 0.8) then {
		_center=getposasl _unit; 
		_centerPos=[_center select 0, _center select 1,(_center select 2) + 0.8];
		_leanLeft=(_unit getRelPos [0.6, 270]); 
		_leanLeftPos=AGLToASL [_leanLeft select 0, _leanLeft select 1,(_leanLeft select 2) + 0.8];
		_leanRight=(_unit getRelPos [0.6,90]); 
		_leanRightPos=AGLToASL [_leanRight select 0, _leanRight select 1,(_leanRight select 2) + 0.8];
		private _poseUp = pose _unit isNotEqualTo "Lying";
		switch (true) do {
			case (_poseUp && {(count (lineIntersectsSurfaces [_leanLeftPos, aimpos _target, _unit, _target, true, -1]) isEqualTo 0) && {!(count (lineIntersectsSurfaces [_centerPos, aimpos _target, _unit, _target, true, 1,"FIRE"]) isEqualTo 0) && {!(needreload _unit isEqualTo 1)}}}) : {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];sleep 0.1;_unit playactionnow "AdjustL";sleep 1;_unit playactionnow "AdjustR";};
			case (_poseUp && {(count (lineIntersectsSurfaces [_leanRightPos, aimpos _target, _unit, _target, true, -1]) isEqualTo 0) && {!(count (lineIntersectsSurfaces [_centerPos, aimpos _target, _unit, _target, true,  1,"FIRE"]) isEqualTo 0) && {!(needreload _unit isEqualTo 1)}}}) : {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];sleep 0.1;_unit playactionnow "AdjustR";sleep 1;_unit playactionnow "AdjustL";};
			default {};
		};
	};
	////Fail safe return
	if ("aadj" in animationstate _unit && {"left" in animationstate _unit}) then {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];sleep 0.2;_unit playactionnow "AdjustR";sleep 0.5};
	if ("aadj" in animationstate _unit && {"right" in animationstate _unit}) then {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];sleep 0.2;_unit playactionnow "AdjustL";sleep 0.5};
	
	_reldir=_unit getreldir getpos _target;
	if (!isNull _target && { ( ([_unit, "VIEW",_target] checkVisibility [eyepos _unit, aimpos _target]) > _minVis OR { ([_unit, "VIEW",_target] checkVisibility [aimpos _unit, eyepos _target]) > _minVis } ) } ) then {
		_anims=RNG_ANIM_Tact;
	} else {
		if ((time > (_targettimeout - 2)) OR {!alive _target}) then {
			_anims=RNG_ANIM_Run;
		};
	};
	
	///dodgin
	
	_dodge=false;
	if (!isNull _target && {(time - _starttime) % 3 > 2.5}) then {
		_targetdir=_target getreldir getpos _unit;
		if ((_targetdir) < 2.6 OR {(_targetdir) > 358.5} ) then {
			_dodge=true;
		};
	};
	if (_dodge OR {isnil "_pos" OR {((_unit distance2D _pos) > 70)}}) then {
		_leftpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,270])), _unit, objNull, true, 1,"FIRE"];
		_rightpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [20,90])), _unit, objNull, true, 1,"FIRE"];
		switch (true) do {
			case (_dodge) : {_pos = selectrandom [((_leftpos select 0) select 0),((_rightpos select 0) select 0)];};
			case ((((_leftpos select 0) select 0) distance2D  _unit) > (((_rightpos select 0) select 0) distance2d _unit)) : {_pos=((_rightpos select 0) select 0);};
			case ((((_leftpos select 0) select 0) distance2D  _unit) < (((_rightpos select 0) select 0) distance2d _unit)) : {_pos=((_leftpos select 0) select 0);};
			default {};
		};
	};
	if (!isnil "_pos" && {((_unit distance2D _pos) < 70)}) then {
		
		///debug pos - ar1 setPosASL [_pos select 0,_pos select 1,(_pos select 2) + 2.5];
		private _relDir = (_unit getreldir _pos);
		switch (true) do {
			case ((_unit distance2D _pos)< (1.5 + (vectorMagnitude (velocityModelSpace _unit))*0.25)): {if ((vectorMagnitude (velocityModelSpace _unit)) > 0.2) then {_unit playactionnow "stop";};_unit setVelocity [0, 0, 0];};
			case (_relDir < 67.5 && {_relDir > 22.5}): {_unit playactionnow (_anims select 0)};
			case (_relDir < 342.5 && {_relDir > 297.5}): {_unit playactionnow (_anims select 1);};
			case (_relDir < 22.5 OR _relDir > 342.5): {_unit playactionnow (_anims select 2);};
			case (_relDir < 202.5 && {_relDir > 157.5}): {_unit playactionnow (_anims select 3);};
			case (_relDir < 157.5 && {_relDir > 112.5}): {_unit playactionnow (_anims select 4);};
			case (_relDir < 247.5 && {_relDir > 202.5}): {_unit playactionnow (_anims select 5);};
			case (_relDir < 112.5 && {_relDir > 67.5}): {_unit playactionnow (_anims select 6);};
			case (_relDir < 292.5 && {_relDir > 247.5}): {_unit playactionnow (_anims select 7);};
			default {};
		};
	} else {
		_unit playactionnow "stop";
		_unit setVelocity [0, 0, 0];
	};
	if ((time - _starttime) % 1 > 0.5) then {
		private _anim = animationState _unit;
		if (("tacs" in _anim OR {"run" in _anim OR {"evas" in _anim}}) && {((vectorMagnitude (velocityModelSpace _unit)) < 1.5)}) then {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];_type=_types selectRandomWeighted _weight;};
		if ((_unit ammo currentweapon _unit < 2) && {_cancrouch && {!("reload" in (gesturestate _unit))}}) then {
			_stance=["MIDDLE","DOWN"] selectRandomWeighted [1,0.2];
			if (!((unitpos _unit) isEqualTo _stance)) then {
				_unit playactionnow _stance;
			};
			if (_stance isEqualTo "MIDDLE") then {
				_unit setunitpos "MIDDLE";
			} else {
				_unit setunitpos "DOWN";
			};
			
		};
	};
	private _randomstop=random 15;
	if (_randomstop > (15 - _skill)) then {_unit playactionnow "stop";_unit setVelocity [0, 0, 0];sleep (_skill/10)};
	if (( animationstate _unit isEqualTo "amovpercmstpsraswrfldnon" OR { animationstate _unit isEqualTo "amovpknlmstpsraswrfldnon" } ) && {((vectorMagnitude (velocityModelSpace _unit)) < 1)}) then {_unit setVelocity [0, 0, 0];};
	_unit setvariable ["RNG_target", _target];
	sleep 0.02;
};

[_unit,_suppressed,_cancrouch,_orderInterrupt] spawn {
	params ["_unit","_suppressed","_cancrouch","_orderInterrupt"];
	if (!_orderInterrupt) then {
		_unit playactionnow "STOP";
		dostop _unit;
	};
	if (_suppressed && {!_orderInterrupt}) then {
	_unit setvariable ["RNG_incombat",false];
	[_unit,objNull] spawn RNG_fnc_cover;
	} else {
		if (!_orderInterrupt) then {
			dostop _unit;
			_unit domove getpos _unit;
		} else {
			_unit setvariable ["RNG_order_cooldown",(time + (missionNamespace getVariable ["RNG_order_cooldown_duration", 30]))];
		};
		_unit enableai "PATH";
		_unit enableai "MOVE";
		_unit enableai "FSM";
		_unit enableai "COVER";
		if (!_orderInterrupt) then { _unit dofollow leader _unit; };
		_unit enableai "AIMINGERROR";
		if (_cancrouch) then {_unit setunitpos "AUTO"};
		_unit setvariable ["RNG_incombat",false];
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
				private _end = _unit getvariable ["RNG_order_cooldown",0];
				while {alive _unit && {time < _end}} do {
					if !((behaviour _unit) in ["AWARE","SAFE","CARELESS"]) then {
						_unit setBehaviour "AWARE";
					};
					sleep 1;
				};
				_unit setvariable ["RNG_order_cooldown",nil];
				if (alive _unit) then {
					_unit enableAI "AUTOCOMBAT";
					_unit enableAI "SUPPRESSION";
				};
			};
		};
		sleep 0.1;
	};
};