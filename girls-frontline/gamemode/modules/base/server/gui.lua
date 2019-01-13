function brawl.Notify( ply, data, t )

	if not istable(data) then data = {data} end

	if not IsValid( ply ) then brawl.NotifyAll( data, t ) end
	net.Start( "brawl.notify" )
	net.WriteTable({
		data = data,
		type = t or "info"
	})
	net.Send( ply )

end

function brawl.NotifyAll( data, t )

	for k, ply in pairs( player.GetAll() ) do
		brawl.Notify( ply, data, t )
	end

	local msg = ""
	if istable(data) then
		for k,v in pairs(data) do
			if isstring(v) and v:sub( 1, 5 ) ~= "font_" then msg = msg .. v end
		end
	elseif isstring(data) then
		msg = data
	end

	if msg then brawl.msg( "[NotifyAll] %s", msg ) end

end

local meta = FindMetaTable "Player"

function meta:Notify( data, t )

	brawl.Notify( self, data, t )

end

concommand.Add( "brawl_notify", function( ply, cmd, args, argStr )

	if not ply:IsSuperAdmin() then
		brawl.Notify( ply, "You need to be superadmin for that", "error" )
		return
	end

	brawl.NotifyAll( argStr, "other" )

end)

local path = brawl.getModulePath( "base", true )
AddCSLuaFolder( path .. "/client/vgui" )
