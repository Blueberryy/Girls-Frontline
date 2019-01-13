if SERVER then AddCSLuaFile() end

GM.Name = "Girls Frontline:Operation binary"
GM.Author = "Ruko"
GM.Email = "ruko"
GM.Website = "N/A"

brawl.version = "0.20"

include "lib/misc.lua"

team.SetUp( 1, "Blue", Color( 41,182,246 ) )
team.SetUp( 2, "Orange", Color( 255,152,0 ) )
team.SetUp( 3, "Green", Color( 139,195,74 ) )
team.SetUp( 4, "Purple", Color( 171,71,188 ) )

function brawl.getDebugEnabled()

	return GetGlobalBool( "brawl.debug", false )

end

function brawl.loadConfig()

	-- load default config
	local name = GAMEMODE.FolderName .. "/gamemode/config.lua"
	if SERVER then AddCSLuaFile( name ) end
	include( name )

	-- override by custom config
	if file.Exists( "girls-frontline/config.lua", "LUA" ) then
		if SERVER then AddCSLuaFile( "girls-frontline/config.lua" ) end
		include( "girls-frontline/config.lua" )
	end

	hook.Run( "brawl.ConfigLoaded" )

end


function brawl.loadFiles()

	brawl.includeModuleFolders( "base", true )
	brawl.includeModuleFolders( "changelog", true )

	if CLIENT then
		local path = brawl.getModulePath( "base", true )
		includeFolder( path .. "/client/vgui" )
	end

end

function GM:Initialize()

	brawl.msg( "=====================================" )
	brawl.msg( "Initializing gamemode." )

	brawl.init()
	self:CreateTeams()

	brawl.msg( "Gamemode init successful." )
	brawl.msg( "=====================================" )

end

if brawl.getDebugEnabled() then

	brawl.init()

end
