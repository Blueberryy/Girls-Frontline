brawl.modes = {
	registered = {}
}

function brawl.modes.register( name, t )

	if not brawl.modes.registered[ name ] then
		brawl.modes.registered[ name ] = t
		brawl.msg( "Registered mode: %s", name )
	else
		brawl.msg( "[ERROR] Mode %s is already registered!", name )
	end

end

local fls, fds = file.Find( brawl.getModulePath("base", true) .. "/modes/*", "LUA" )
for k, fd in pairs(fds) do
	MODE = {}
	local path = brawl.getModulePath("base", true) .. "/modes/" .. fd .. "/"

	local fl = path .. "sh_mode.lua"
	if file.Exists( fl, "LUA" ) then
		if SERVER then AddCSLuaFile( fl ) end
		include( fl )
	end

	if SERVER then
		fl = path .. "sv_mode.lua"
		if file.Exists( fl, "LUA" )
			then include( fl )
			else brawl.msg( "[ERROR] Mode '%s' does not have sv_mode.lua!", fd ) return
		end
	end

	fl = path .. "cl_mode.lua"
	if file.Exists( fl, "LUA" ) then
		if SERVER
			then AddCSLuaFile( fl )
			else include( fl )
		end
	end

	brawl.modes.register( fd, MODE )
	MODE = nil
end
