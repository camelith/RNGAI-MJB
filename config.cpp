class CfgPatches
{
	class RNG_mod
	{
		name="Run and Gun AI";
		author="Toksa";
		units[]=
		{
			"RNG_ModuleDisable",
			"RNG_ModuleEnable"
		};
		weapons[]={};
		magazines[]={};
		ammo[]={};
		requiredAddons[]=
		{
			"A3_Data_F",
			"A3_Ui_F",
			"A3_Editor_F",
			"A3_Modules_F",
			"A3_Modules_F_Curator"
		};
	};
};
class CfgFunctions
{
	class RNG
	{
		class functions
		{
			class unit_init
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_unit_init.sqf";
			};
			class react
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_react.sqf";
			};
			class combat
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_combat.sqf";
			};
			class cover
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_cover.sqf";
			};
			class turning
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_turning.sqf";
			};
			class moduleDisable
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_moduleDisable.sqf";
			};
			class moduleEnable
			{
				tag="RNG";
				file="\RNG_AI\scripts\fn_moduleEnable.sqf";
			};
		};
	};
};
class CfgFactionClasses
{
	class NO_CATEGORY;
	class RNG_Category: NO_CATEGORY
	{
		displayName="RNG AI";
		priority=3;
		side=7;
	};
};
class CfgVehicles
{
	class Logic;
	class Module_F: Logic
	{
		class ArgumentsBaseUnits;
	};
	class RNG_ModuleBase: Module_F
	{
		scope=1;
		scopeCurator=2;
		displayName="RNG AI";
		category="RNG_Category";
		functionPriority=1;
		isGlobal=0;
		isTriggerActivated=0;
		is3DEN=0;
		curatorCanAttach=1;
		canSetArea=0;
		canSetAreaShape=0;
		icon="\a3\ui_f\data\igui\cfg\simpletasks\types\repair_ca.paa";
		class Arguments: ArgumentsBaseUnits
		{
		};
	};
	class RNG_ModuleDisable: RNG_ModuleBase
	{
		displayName="Disable RNG on Group";
		function="RNG_fnc_moduleDisable";
	};
	class RNG_ModuleEnable: RNG_ModuleBase
	{
		displayName="Enable RNG on Group";
		function="RNG_fnc_moduleEnable";
	};
};
class Extended_PreInit_EventHandlers
{
	class RNG_init
	{
		init="call compile preprocessFileLineNumbers '\RNG_AI\scripts\RNG_init.sqf'";
	};
};
class Extended_PostInit_EventHandlers
{
	class RNG_mod
	{
		init="call compile preprocessFileLineNumbers '\RNG_AI\XEH_postInit.sqf'";
	};
};
class Extended_InitPost_EventHandlers
{
	class CAManBase
	{
		class RNG_postunits
		{
			init="[RNG_fnc_unit_init, [_this select 0], 1] call CBA_fnc_waitAndExecute";
		};
	};
};