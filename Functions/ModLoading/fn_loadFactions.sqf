scriptName "LND\functions\LoadMods\fn_loadFactions.sqf";
/*
	Author:
		Landric

	Description:
		Initialises types of unit (e.g. Infantry, AA, Vehicles) as a faction provided in description.ext

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_loadFactions;
*/

try {
	switch((["BLUFORFaction", 0] call BIS_fnc_getParamValue)) do {
		default {
			LND_bluforInfantry = [
				(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad")
			];
 		};
	};
}
catch {
	LND_bluforInfantry = [
		(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad")
	];
};

try {
	switch((["OPFORFaction", 0] call BIS_fnc_getParamValue)) do {

		// AAF
		case 1: {
			LND_opforAAA = ["I_LT_01_AA_F"];
			LND_opforSAM = [];
			LND_opforRADAR = [];
			
			LND_opforCAP = ["I_Plane_Fighter_04_F"];
			LND_opforCAS = ["I_Plane_Fighter_03_dynamicLoadout_F"];
			LND_opforTransportPlane = [];
			LND_opforTransportHelo = ["I_Heli_Transport_02_F", "I_Heli_light_03_unarmed_F"];
			LND_opforHeloLight = ["I_Heli_light_03_dynamicLoadout_F"];
			LND_opforHeloAttack = [];

	    };
	    // MDF
	    case 2: {
	    	if(!isClass(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O")) then {
	    		throw "3CB not loaded!"
	    	};
			LND_opforAAA = ["UK3CB_MDF_O_Stinger_AA_pod", "UK3CB_MDF_O_MTVR_Zu23"];
			LND_opforSAM = [];
			LND_opforRADAR = [];

			LND_opforCAP = ["UK3CB_MDF_O_Mystere_AA1_NAVY", "UK3CB_MDF_O_Mystere_AA1"];
			LND_opforCAS = ["UK3CB_MDF_O_Mystere_CAS1", "UK3CB_MDF_O_Mystere_CAS1_NAVY", "UK3CB_MDF_O_Cessna_T41_Armed"];
			LND_opforTransportPlane = ["UK3CB_MDF_O_AC500", "UK3CB_MDF_O_AC500_NAVY", "UK3CB_MDF_O_C130J", "UK3CB_MDF_O_C130J_NAVY_CARGO"];
			LND_opforTransportHelo = ["UK3CB_MDF_O_UH1H_NAVY", "UK3CB_MDF_O_UH1H"];
			LND_opforHeloLight = ["UK3CB_MDF_O_UH1H_GUNSHIP_NAVY", "UK3CB_MDF_O_UH1H_GUNSHIP"];
			LND_opforHeloAttack = ["UK3CB_MDF_O_AH1Z_NAVY"];


	    };
	    // AFRF
	    case 3: {
	    	if(!isClass(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv")) then {
	    		throw "RHS not loaded!"
	    	};

			LND_opforAAA = ["RHS_ZU23_MSV","RHS_Ural_Zu23_MSV_01","rhs_zsu234_aa"];
			LND_opforSAM = [];
			LND_opforRADAR = [];

 			LND_opforCAP = ["rhssaf_airforce_o_l_18_101", "RHS_T50_vvs_generic_ext"];
			LND_opforCAS = ["RHS_Su25SM_vvsc"];
			LND_opforTransportPlane = ["RHS_TU95MS_vvs_old"];
			LND_opforTransportHelo = ["RHS_Mi8mt_Cargo_vvsc"];
			LND_opforHeloLight = [];
			LND_opforHeloAttack = ["RHS_Ka52_vvsc", "RHS_Mi8AMTSh_vvsc", "RHS_Mi24V_vvsc"];

	    };
	    // CSAT
		default {

			LND_opforAAA = ["O_APC_Tracked_02_AA_F"];
			LND_opforSAM = ["O_SAM_System_04_F"];
			LND_opforRADAR = ["O_Radar_System_02_F"];
			
			LND_opforCAP = ["O_Plane_Fighter_02_F"];
			LND_opforCAS = ["O_Plane_CAS_02_dynamicLoadout_F"];
			LND_opforTransportPlane = [];
			LND_opforTransportHelo = ["O_Heli_Transport_04_covered_F","O_Heli_Light_02_unarmed_F","O_Heli_Transport_04_bench_F"];
			LND_opforHeloLight = ["O_Heli_Light_02_dynamicLoadout_F"];
			LND_opforHeloAttack = ["O_Heli_Attack_02_dynamicLoadout_F"];

 		};
	};
}
// If something goes wrong (e.g. if the correct mod isn't loaded), default to vanilla CSAT
catch {
	systemChat str _exception;
	systemChat "Defaulting to OPFOR: CSAT";

	LND_opforAAA = ["O_APC_Tracked_02_AA_F"];
	LND_opforSAM = ["O_SAM_System_04_F"];
	LND_opforRADAR = ["O_Radar_System_02_F"];
	
	LND_opforCAP = ["O_Plane_Fighter_02_F"];
	LND_opforCAS = ["O_Plane_CAS_02_dynamicLoadout_F"];
	LND_opforTransportPlane = [];
	LND_opforTransportHelo = ["O_Heli_Transport_04_covered_F","O_Heli_Light_02_unarmed_F","O_Heli_Light_02_dynamicLoadout_F","O_Heli_Transport_04_bench_F"];
	LND_opforHeloLight = ["O_Heli_Light_02_dynamicLoadout_F"];
	LND_opforHeloAttack = ["O_Heli_Attack_02_dynamicLoadout_F"];
};