//RNG AI by Toksa
RNG_ANIM_Tact=[
"TactRF",
"TactLF",
"TactF",
"TactB",
"TactRB",
"TactLB",
"TactR",
"TactL"];
RNG_ANIM_Run=[
"FastRF",
"FastLF",
"FastF",
"FastB",
"FastRB",
"FastLB",
"FastR",
"FastL"];
_man = _this select 0;
_group = group _man;

_sideman = str (side _man);

if (((missionnamespace getvariable ["RNG_sides","ALL"]) == "ALL") OR RNG_sides == _sideman) && {(_sideman != "CIV") || (missionnamespace getvariable ["RNG_civilians", false])}) then {
	
_man setvariable ["RNG_active",true];

_man addEventHandler ["FiredNear", {
	params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
	[_unit,_firer] call RNG_fnc_react;
}];
if (!(isClass(configFile >> "CfgPatches" >> "ace_medical_engine"))) then {
_man addEventHandler ["HandleDamage", { 
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"]; 
	if ((isNull _instigator && _source == _unit) OR (!(isplayer _source) && !(side _source == sideEnemy) && (side _unit == side _source))) then {_damage = 0};
	_damage;
}];
};

_man addEventHandler ["Suppressed", {
	params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
	[_unit,_shooter] call RNG_fnc_react;
	
}];

if (!(_group getvariable ["RNG_group_active",false])) then {
_group setvariable ["RNG_group_active",true];
_group addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	{[_x,_newTarget] call RNG_fnc_react;} foreach units _group;
}];
};

_man addMPEventHandler ["MPRespawn", {
	params ["_unit", "_corpse"];
				_unit enableai "PATH";
				_unit enableai "MOVE";
				_unit enableai "FSM";
				_unit enableai "COVER";
				_unit enableai "AIMINGERROR";
				_unit setvariable ["RNG_incombat",false];
				_unit setvariable ["RNG_cover",false];
}];

_man addEventHandler ["Fired", { 
 params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"]; 
 if (!isplayer _unit && {!(missionnamespace getvariable ["RNG_off",false]) && {!(_unit getvariable ["RNG_disabled",false])}}) then { 
 _amount=0.1 - ((_unit skillFinal "aimingAccuracy")*0.1); 
 _speed=(velocityModelSpace _projectile) select 1; 
 _projectile setVectorDirAndUp [[((vectordir _projectile) select 0) + (random _amount) - (random _amount),((vectordir _projectile) select 1) + (random _amount) - (random _amount),((vectordir _projectile) select 2)  + (random _amount) - (random _amount)], [((vectorup _projectile) select 0)  + (random _amount) - (random _amount),((vectorup _projectile) select 1)   + (random _amount) - (random _amount),((vectorup _projectile) select 2)   + (random _amount) - (random _amount)]]; 
 _projectile setVelocityModelSpace [0,_speed,0]; 
 }; 
}]; 
}; 
