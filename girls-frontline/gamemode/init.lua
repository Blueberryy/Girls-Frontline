brawl = brawl or {}

-- include libraries
include "lib/mysqlite.lua"
AddCSLuaFile "lib/misc.lua"

function brawl.msg( text, ... )

	local args = {...}

	local time = os.date( "(%H:%M:%S)", os.time() )
	local msg = args and string.format( text, unpack(args) ) or text

	print( string.format( "[#] %s - %s", time, msg ) )

end

function brawl.debugmsg( text, ... )

	if brawl.getDebugEnabled() then
		brawl.msg( text, ... )
	end

end

function brawl.initDB()

	-- brawl.config.db = {
	--
	--	 EnableMySQL = true,
	--	 Host = "127.0.0.1",
	--	 Username = "gmod",
	--	 Password = "ohThatGMod",
	--	 Database_name = "brawl",
	--	 Database_port = 3306,
	--	 Preferred_module = "tmysql4",
	--
	-- }

	brawl.config.db = {

		EnableMySQL = false,
		Host = "",
		Username = "",
		Password = "",
		Database_name = "",
		Database_port = 3306,
		Preferred_module = "mysqloo",

	}

	MySQLite.initialize( brawl.config.db )

end

function brawl.initConCommands()

	-- basic server confing
	local data = brawl.config.server
	RunConsoleCommand( "hostname", data.name )
	RunConsoleCommand( "sv_password", data.password )
	RunConsoleCommand( "sv_loadingurl", data.loadingURL )

	-- workshop
	for _, id in pairs( brawl.config.server.workshop ) do
		resource.AddWorkshop( id )
	end

	local map = string.lower( game.GetMap() )
	if not brawl.config.maps[ map ] then error( "The map is not in config, please follow instructions here on how to add the map to gamemode: https://github.com/chelog/brawl" ) end

	local mapID = brawl.config.maps[ map ].workshop
	if mapID then
		resource.AddWorkshop( mapID )
		brawl.msg( "Added workshop download for %s (%s)", brawl.config.maps[ map ].name, mapID )
	end

	-- startup commands
	for _, entry in pairs( data.runCommands ) do
		local args = string.Explode( " ", entry )
		local cmd = table.remove( args, 1 )
		RunConsoleCommand( cmd, unpack( args ) )
	end

	brawl.setDebugEnabled( brawl.config.debug )

end

function brawl.setDebugEnabled( val )

	SetGlobalBool( "brawl.debug", val )

end

function brawl.init()

	brawl.loadConfig()
	brawl.initDB()
	brawl.loadFiles()
	brawl.initConCommands()

end

-- begin loading
AddCSLuaFile( "cl_init.lua" )
include( "sh_init.lua" )
