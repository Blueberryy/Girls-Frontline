-- leave this line as is
brawl.config = brawl.config or {}

--[[-------------------------------------------------------------------------
CUSTOM CONFIGURATION FILE
	Here you can set your gamemode for you.
	There's not much info here but it's only for now.
---------------------------------------------------------------------------]]

-- basic server configuration
brawl.config.server = {

	name = "Girls Frontline: Operation Binary (v" .. brawl.version .. ")",
	password = "",
	loadingURL = "",

	-- these commands will be executed by server during map loading
	runCommands = {
		"net_maxfilesize 64",
	},

	-- this is CLIENT content, thus it will NOT be downloaded by server
	-- place here any models, materials etc. content INSTEAD of telling players to subscribe to addons
	workshop = {
		-- DO NOT delete these addons, they are required by gamemode
		"1095528851",
		"1095539006",
		"1095542254",
		"1095545406",
		"1095548291",

		-- you can add here more addons, however you should leave these ones here if you use default player models
		"297516501", -- Insurgency bullet holes
	},

}

-- various player settings
brawl.config.player = {
	baseWalkSpeed = 200,
	baseRunSpeed = 300,

	staminaRegenDelay = 2,
	staminaRegenRate = 30,
	staminaSprintCost = 25,
	staminaJumpCost = 5,
	healthRegenDelay = 5,
	healthRegenRate = 2,
}

-- map list, maps MUST be setup here before
brawl.config.maps = {
	dm_basebunker = {
		name = "Base Bunker", workshop = "812797510",
		img = "http://images.akamai.steamusercontent.com/ugc/105103266291569905/B36E449E2CEEA7806542A3C1741399681DB606F3/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	ahl2_fishdock = {
		name = "Fish Docks", workshop = "914554901",
		img = "https://steamuserimages-a.akamaihd.net/ugc/817810804115581770/224BB5D5C35C8B2D72DEB408C10E834014D1221B/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_island18_night = {
		name = "Island 18", workshop = "284612894",
		img = "https://steamuserimages-a.akamaihd.net/ugc/577901446709652492/0E3F2454B9E1AE67A8CCC22F284B1183F02DF155/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_torque = {
		name = "Torque", workshop = "442990905",
		img = "http://images.akamai.steamusercontent.com/ugc/544152440190283835/F6E77E18AD0A573938CD33380B427DE2C3811C2D/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_streetwar_b1 = {
		name = "Streetwar", workshop = "446039435",
		img = "https://steamuserimages-a.akamaihd.net/ugc/540775374405727353/1982CA9E54A819E09EB2DFCFAD6C679D12BA8E62/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_drift = {
		name = "Drift", workshop = "837801728",
		img = "https://steamuserimages-a.akamaihd.net/ugc/98351028244622841/63D32956715BFAFC440D13D9E942739DC05BFB33/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_railyard = {
		name = "Railyard", workshop = "128029375",
		img = "https://steamuserimages-a.akamaihd.net/ugc/1117161388864327502/CD43A240D52A5B1120FF5370A85C45C3AC949B08/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	ahl2_snowmax = {
		name = "SnowMax", workshop = "914563424",
		img = "https://steamuserimages-a.akamaihd.net/ugc/817810804115660796/92935CAF7ABC9E2EE5B744E2B8B7D236DF6CFEFB/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_mines = {
		name = "Mines", workshop = "660390276",
		img = "https://steamuserimages-a.akamaihd.net/ugc/456361914572272301/38F42B71F3FBA53B1BAC646501887E75B4DDB151/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	dm_construction = {
		name = "Construction", workshop = "863985236",
		img = "https://steamuserimages-a.akamaihd.net/ugc/89347071775451938/FDCE7BC93A97DC65461B6162486C8513A0D0D38E/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_ghost_ctg = {
		name = "I.O.P Manufacture", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960855654192860610/C2BE9A931330E4B420C501259F37498667669447/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_transit_ctg = {
		name = "S09 Transit Area", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960855654193475497/68CAD8D4B3BB6F7CBA279E5AB530190D37003A03/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_isolation_ctg = {
		name = "Operation:Arctic Warfare", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856082265236677/86F78FECB8D31027515CEF24309329117066D2A9/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_disengage_ctg = {
		name = "Sangvis Encounter", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856082265236972/AA52AC4175B781378C606EC6BE31346D72B670C7/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_decom_ctg = {
		name = "16-LABS", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856082265237163/A1AC3B1712DBEC3D84A66D4EB209485CC4A60F5B/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_ballistrade_ctg = {
		name = "Night Cross-Fire", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856316456232289/9802ECFFD3E628BE7A8983762706F2FBC932F6E7/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_marketa_ctg = {
		name = "S07 Market", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856316459512726/59437E08A58ED71CF32EAE8C200409E98650D73C/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_redlight_ctg = {
		name = "Operation: Blacklight", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856534594742106/EDC200EE2D08FFA9CE0C802ABD807B169E09E759/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_saitama_ctg = {
		name = "Sangvis Manufacture Facility", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960856720978837756/B05F4B9160FF28682EE7029841544EA7692554BF/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},	
	nt_oilstain_ctg = {
		name = "Griffon & Kyruger Facility", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960857170317053178/0B78DAC9C49693F9CE9BC7055A2577EFA73A5946/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_pissalley_ctg = {
		name = "S09 Combat Zone", workshop = "512401711",
		img = "https://steamuserimages-a.akamaihd.net/ugc/960857170317075635/B43CF025CD1D5D7FCC9944B9DAC48C5442BEB89B/",
		modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},
	nt_ridgeline_ctg = {
          name = "Reversal Sequence", workshop = "512401711",
	  img = "https://steamuserimages-a.akamaihd.net/ugc/960857516894219733/276DF887BE061C09A41221AECD9EAE04B6B911BB/",
	  modes = { "ffa_dm", "ffa_el", "squad_dm", "squad_el", "team_dm", "team_el", "gg" },
	},	


	-- add more maps by using this template

	-- MAP_NAME_WITHOUT_BSP = {
	-- 	name = "NICE MAP NAME", workshop = "WORKSHOP ID",
	-- 	img = "URL TO SCREENSHOT",
	-- 	modes = { "ALLOWED", "MODES", "SEE", "EXAMPLES", "ABOVE" },
	-- },
}

-- player models, level needed for models is in brackets
-- one random model out of this list will be chosen
brawl.config.playerModels = {

	[1] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[3] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[6] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[9] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[12] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[15] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[18] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[21] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[24] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[27] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[30] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

	[33] = {
		"models/player/dewobedil/girls_frontline/hk416/default_p.mdl",
		"models/pacagma/girls_frontline/m1918/m1918_player.mdl",
		"models/player/dewobedil/girls_frontline/m4_sopmod_ii/default_p.mdl",
		"models/player/girls_frontline_ump45.mdl",
		"models/pacagma/girls_frontline/g11/g11_player.mdl",
		"models/pacagma/girls_frontline/ak12/ak12_player.mdl",
	},

}

-- weapon classes (better leave them default)
brawl.config.weapons = {

	melee = {
		"tfa_l4d2_talaxe",
		"tfa_cso2_defaultknifecamo1",
		"tfa_cso2_huntknife_monkey",
		"tfa_cso2_huntknife_gold",
		"tfa_cso2_huntknife",
		"tfa_cso2_knife",
		"tfa_cso2_knife_chicken",
		"tfa_cso2_m9bayonet",
		"tfa_cso2_taserknife",
		"tfa_cso2_survivorknife",
		"tfa_cso2_athenaknife",
	},

	secondary = {
		"tfa_l4d2_vp70",
		"tfa_ins2_qsz92",
		"tfa_ins2_usp45",
		"tfa_ins2_p226",
		"tfa_ins2_p220",
		"tfa_ins2_swmodel10",
		"tfa_ins2_thanez_cobra",
		"tfa_l4d2_falcon2",
		"tfa_l4d2_calico",
		"tfa_ins2_m9",
		"tfa_ins2_glock_19",
		"tfa_ins2_fiveseven",
		"tfa_ins2_deagle",
		"tfa_cso2_elites",
		"tfa_cso2_k5",
		"tfa_cso2_m1911a1",
	},

	primary = {
		smgs = {
			"tfa_l4d2_rocky_scarh",
			"robotnik_mw2_m79",
			"robotnik_mw2_rpg",
			"robotnik_mw2_rpd",
			"robotnik_mw2_mg4",
			"robotnik_mw2_240",
			"robotnik_mw2_lsw",
			"robotnik_mw2_at4",
			"tfa_ins2_mp7",
			"tfa_ins2_arx160",
			"tfa_ins2_m1a",
			"tfa_ins2_akz",
			"tfa_ins2_rfb",
			"tfa_ins2_codol_msr",
			"tfa_nam_m79",
			"tfa_nam_ppsh41",
			"tfa_doim3greasegun",
			"tfa_doimp40",
			"tfa_doiowen",
			"tfa_doisten",
			"tfa_doithompsonm1928",
			"tfa_doithompsonm1a1",
			"tfa_ins2_acr",
			"tfa_ins2_ak400",
			"tfa_ins2_abakan",
			"tfa_ins2_aug",
			"tfa_ins2_c7e",
			"tfa_ins2_cz805",
			"tfa_ins2_famas",
			"tfa_ins2_fort500",
			"tfa_ins2_fas2_g36c",
			"tfa_ins2_gol",
			"tfa_ins2_sai_gry",
			"tfa_ins2_416c",
			"tfa_ins2_417",
			"tfa_ins2_k98",
			"tfa_ins2_krissv",
			"tfa_ins2_ksg",
			"tfa_ins2_cq300",
			"tfa_ins2_m14retro",
			"tfa_ins2_m1a",
			"tfa_ins2_m500",
			"tfa_ins2_minimi",
			"tfa_ins2_mk14ebr",
			"tfa_ins2_mk18",
			"tfa_ins2_mp5k",
			"tfa_ins2_nova",
			"tfa_ins2_groza",
			"tfa_ins2_rpg",
			"tfa_ins2_l85a2",
			"tfa_ins2_spas12",
			"tfa_ins2_spectre",
			"tfa_ins2_ump45",
			"tfa_ins2_wa2000",
			"tfa_l4d2_ctm200",
			"tfa_l4d2_skorpion",
			"tfa_l4d2_rocky_sarmod",
			"tfa_l4d2_m1887",
			"tfa_l4d2_kf2_p90",
			"tfa_cso2_mac10",
			"tfa_cso2_k1a",
			"tfa_cso2_tmp",
			"tfa_cso2_mx4",
			"blast_tfa_g11",
			"blast_tfa_caws",
		        "tfa_l4d2_rocky_ro2bar",
		},

		shotguns = {
			"tfa_l4d2_rocky_scarh",
			"robotnik_mw2_m79",
			"robotnik_mw2_rpg",
			"robotnik_mw2_rpd",
			"robotnik_mw2_mg4",
			"robotnik_mw2_240",
			"robotnik_mw2_lsw",
			"robotnik_mw2_at4",
			"tfa_ins2_mp7",
			"tfa_ins2_arx160",
			"tfa_ins2_m1a",
			"tfa_ins2_akz",
			"tfa_ins2_rfb",
			"tfa_ins2_codol_msr",
			"tfa_nam_m79",
			"tfa_nam_ppsh41",
			"tfa_doim3greasegun",
			"tfa_doimp40",
			"tfa_doiowen",
			"tfa_doisten",
			"tfa_doithompsonm1928",
			"tfa_doithompsonm1a1",
			"tfa_ins2_acr",
			"tfa_ins2_ak400",
			"tfa_ins2_abakan",
			"tfa_ins2_aug",
			"tfa_ins2_c7e",
			"tfa_ins2_cz805",
			"tfa_ins2_famas",
			"tfa_ins2_fort500",
			"tfa_ins2_fas2_g36c",
			"tfa_ins2_gol",
			"tfa_ins2_sai_gry",
			"tfa_ins2_416c",
			"tfa_ins2_417",
			"tfa_ins2_k98",
			"tfa_ins2_krissv",
			"tfa_ins2_ksg",
			"tfa_ins2_cq300",
			"tfa_ins2_m14retro",
			"tfa_ins2_m1a",
			"tfa_ins2_m500",
			"tfa_ins2_minimi",
			"tfa_ins2_mk14ebr",
			"tfa_ins2_mk18",
			"tfa_ins2_mp5k",
			"tfa_ins2_nova",
			"tfa_ins2_groza",
			"tfa_ins2_rpg",
			"tfa_ins2_l85a2",
			"tfa_ins2_spas12",
			"tfa_ins2_spectre",
			"tfa_ins2_ump45",
			"tfa_ins2_wa2000",
			"tfa_l4d2_ctm200",
			"tfa_l4d2_skorpion",
			"tfa_l4d2_rocky_sarmod",
			"tfa_l4d2_m1887",
			"tfa_l4d2_kf2_p90",
			"tfa_cso2_mac10",
			"tfa_cso2_k1a",
			"tfa_cso2_mx4",
			"blast_tfa_g11",
			"blast_tfa_caws",
			"tfa_l4d2_rocky_ro2bar",
		},

		rifles = {
			"tfa_l4d2_rocky_scarh",
			"robotnik_mw2_m79",
			"robotnik_mw2_rpg",
			"robotnik_mw2_rpd",
			"robotnik_mw2_mg4",
			"robotnik_mw2_240",
			"robotnik_mw2_lsw",
			"robotnik_mw2_at4",
			"tfa_ins2_mp7",
			"tfa_ins2_arx160",
			"tfa_ins2_m1a",
			"tfa_ins2_akz",
			"tfa_ins2_rfb",
			"tfa_ins2_codol_msr",
			"tfa_nam_m79",
			"tfa_nam_ppsh41",
			"tfa_doim3greasegun",
			"tfa_doimp40",
			"tfa_doiowen",
			"tfa_doisten",
			"tfa_doithompsonm1928",
			"tfa_doithompsonm1a1",
			"tfa_ins2_acr",
			"tfa_ins2_ak400",
			"tfa_ins2_abakan",
			"tfa_ins2_aug",
			"tfa_ins2_c7e",
			"tfa_ins2_cz805",
			"tfa_ins2_famas",
			"tfa_ins2_fort500",
			"tfa_ins2_fas2_g36c",
			"tfa_ins2_gol",
			"tfa_ins2_sai_gry",
			"tfa_ins2_416c",
			"tfa_ins2_417",
			"tfa_ins2_k98",
			"tfa_ins2_krissv",
			"tfa_ins2_ksg",
			"tfa_ins2_cq300",
			"tfa_ins2_m14retro",
			"tfa_ins2_m1a",
			"tfa_ins2_m500",
			"tfa_ins2_minimi",
			"tfa_ins2_mk14ebr",
			"tfa_ins2_mk18",
			"tfa_ins2_mp5k",
			"tfa_ins2_nova",
			"tfa_ins2_groza",
			"tfa_ins2_rpg",
			"tfa_ins2_l85a2",
			"tfa_ins2_spas12",
			"tfa_ins2_spectre",
			"tfa_ins2_ump45",
			"tfa_ins2_wa2000",
			"tfa_l4d2_ctm200",
			"tfa_l4d2_skorpion",
			"tfa_l4d2_rocky_sarmod",
			"tfa_l4d2_m1887",
			"tfa_l4d2_kf2_p90",
			"tfa_cso2_mac10",
			"tfa_cso2_k1a",
			"tfa_cso2_tmp",
			"tfa_cso2_mx4",
			"blast_tfa_g11",
			"blast_tfa_caws",
			"tfa_l4d2_rocky_ro2bar",
		},

		snipers = {
			"tfa_l4d2_rocky_scarh",
			"robotnik_mw2_m79",
			"robotnik_mw2_rpg",
			"robotnik_mw2_rpd",
			"robotnik_mw2_mg4",
			"robotnik_mw2_240",
			"robotnik_mw2_lsw",
			"robotnik_mw2_at4",
			"tfa_ins2_mp7",
			"tfa_ins2_arx160",
			"tfa_ins2_m1a",
			"tfa_ins2_akz",
			"tfa_ins2_rfb",
			"tfa_ins2_codol_msr",
			"tfa_nam_m79",
			"tfa_nam_ppsh41",
			"tfa_doim3greasegun",
			"tfa_doimp40",
			"tfa_doiowen",
			"tfa_doisten",
			"tfa_doithompsonm1928",
			"tfa_doithompsonm1a1",
			"tfa_ins2_acr",
			"tfa_ins2_ak400",
			"tfa_ins2_abakan",
			"tfa_ins2_aug",
			"tfa_ins2_c7e",
			"tfa_ins2_cz805",
			"tfa_ins2_famas",
			"tfa_ins2_fort500",
			"tfa_ins2_fas2_g36c",
			"tfa_ins2_gol",
			"tfa_ins2_sai_gry",
			"tfa_ins2_416c",
			"tfa_ins2_417",
			"tfa_ins2_k98",
			"tfa_ins2_krissv",
			"tfa_ins2_ksg",
			"tfa_ins2_cq300",
			"tfa_ins2_m14retro",
			"tfa_ins2_m1a",
			"tfa_ins2_m500",
			"tfa_ins2_minimi",
			"tfa_ins2_mk14ebr",
			"tfa_ins2_mk18",
			"tfa_ins2_mp5k",
			"tfa_ins2_nova",
			"tfa_ins2_groza",
			"tfa_ins2_rpg",
			"tfa_ins2_l85a2",
			"tfa_ins2_spas12",
			"tfa_ins2_spectre",
			"tfa_ins2_ump45",
			"tfa_ins2_wa2000",
			"tfa_l4d2_ctm200",
			"tfa_l4d2_skorpion",
			"tfa_l4d2_rocky_sarmod",
			"tfa_l4d2_m1887",
			"tfa_l4d2_kf2_p90",
			"tfa_cso2_mac10",
			"tfa_cso2_k1a",
			"tfa_cso2_tmp",
			"tfa_cso2_mx4",
			"blast_tfa_g11",
			"blast_tfa_caws",
			"tfa_l4d2_rocky_ro2bar",
		},

		heavy = {
			"tfa_l4d2_rocky_scarh",
			"robotnik_mw2_m79",
			"robotnik_mw2_rpg",
			"robotnik_mw2_rpd",
			"robotnik_mw2_mg4",
			"robotnik_mw2_240",
			"robotnik_mw2_lsw",
			"robotnik_mw2_at4",
			"tfa_ins2_mp7",
			"tfa_ins2_arx160",
			"tfa_ins2_m1a",
			"tfa_ins2_akz",
			"tfa_ins2_rfb",
			"tfa_ins2_codol_msr",
			"tfa_nam_m79",
			"tfa_nam_ppsh41",
			"tfa_doim3greasegun",
			"tfa_doimp40",
			"tfa_doiowen",
			"tfa_doisten",
			"tfa_doithompsonm1928",
			"tfa_doithompsonm1a1",
			"tfa_ins2_acr",
			"tfa_ins2_ak400",
			"tfa_ins2_abakan",
			"tfa_ins2_aug",
			"tfa_ins2_c7e",
			"tfa_ins2_cz805",
			"tfa_ins2_famas",
			"tfa_ins2_fort500",
			"tfa_ins2_fas2_g36c",
			"tfa_ins2_gol",
			"tfa_ins2_sai_gry",
			"tfa_ins2_416c",
			"tfa_ins2_417",
			"tfa_ins2_k98",
			"tfa_ins2_krissv",
			"tfa_ins2_ksg",
			"tfa_ins2_cq300",
			"tfa_ins2_m14retro",
			"tfa_ins2_m1a",
			"tfa_ins2_m500",
			"tfa_ins2_minimi",
			"tfa_ins2_mk14ebr",
			"tfa_ins2_mk18",
			"tfa_ins2_mp5k",
			"tfa_ins2_nova",
			"tfa_ins2_groza",
			"tfa_ins2_rpg",
			"tfa_ins2_l85a2",
			"tfa_ins2_spas12",
			"tfa_ins2_spectre",
			"tfa_ins2_ump45",
			"tfa_ins2_wa2000",
			"tfa_l4d2_ctm200",
			"tfa_l4d2_skorpion",
			"tfa_l4d2_rocky_sarmod",
			"tfa_l4d2_m1887",
			"tfa_l4d2_kf2_p90",
                        "tfa_cso2_mac10",
			"tfa_cso2_k1a",
			"tfa_cso2_tmp",
			"tfa_cso2_mx4",
			"blast_tfa_g11",
			"blast_tfa_caws",
			"tfa_l4d2_rocky_ro2bar",
		},
	},

	extra = {
	 	"tfa_cso2_smokegrenade",
		"tfa_cso2_frag",
		"tfa_cso2_flashbang",
	},

}

-- debug mode (for developers)
brawl.config.debug = false
