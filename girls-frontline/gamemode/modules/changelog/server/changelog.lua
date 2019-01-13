-- ULib.ucl.registerAccess( "changelog", ULib.ACCESS_SUPERADMIN, "Ability to edit changelog entries", "Octothorp Team" )

net.Receive( "changelog.add", function( len, ply )

	if not ply:IsSuperAdmin() then
		return ply:Notify( "You have no permission to do that!", "error" )
	end

	local t = net.ReadTable()
	MySQLite.query(string.format([[
			INSERT INTO changelog.brawl (type, time, title]] .. (t.desc and ", description" or "") .. [[)
			VALUES (%s, %d, %s]] .. (t.desc and ", %s" or "") .. [[)
		]],
		MySQLite.SQLStr( t.type ), t.time, MySQLite.SQLStr( t.title ), t.desc and MySQLite.SQLStr( t.desc )
	))

end)

net.Receive( "changelog.remove", function( ply, len )

	if not ply:IsSuperAdmin() then
		return ply:Notify( "You have no permission to do that!", "error" )
	end

	local id = net.ReadInt( 16 )
	MySQLite.query([[
		DELETE FROM changelog.brawl
		WHERE id = ]] .. id
	)

end)
