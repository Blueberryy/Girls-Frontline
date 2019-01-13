brawl = brawl or
{
	version = 0.1,
	ui = {},
}

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

function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end


function brawl.init()

	brawl.loadConfig()
	brawl.loadFiles()

end

include( "sh_init.lua" )
