function brawl.points.add( type, t )

	if not t or not t.pos then return end

	if not brawl.points.data[ type ] then brawl.points.data[ type ] = {} end

	table.insert( brawl.points.data[ type ], t )
	brawl.points.update()

end

function brawl.points.remove( type, id )

	if not brawl.points.data[ type ] then return end

	table.remove( brawl.points.data[ type ], id )
	if #brawl.points.data[ type ] < 1 then brawl.points.data[ type ] = nil end

	brawl.points.update()

end

function brawl.points.update( ply )

	brawl.points.save()

	net.Start( "brawl.points.send" )
		net.WriteTable( brawl.points.data )
	if IsValid(ply) then
		net.Send( ply )
	else
		net.Broadcast()
	end

end

function brawl.points.findFarthestSpawn( ply )

	if not IsValid( ply ) then return end

	local plys = {}
	for k, pl in pairs( player.GetAll() ) do
		if pl == ply or not pl:Alive() or pl:GetNWBool("Spectating") then continue end
		table.insert( plys, pl:GetPos() )
	end

	if table.Count( plys ) < 1 then
		return table.Random( brawl.points.data.spawn )
	end

	local farthest, maxDist = table.Random( brawl.points.data.spawn ), 0
	math.randomseed( CurTime() )
	for k1, sp in RandomPairs( brawl.points.data.spawn ) do
		local minDist
		for k2, plyPos in pairs( plys ) do
			local dist = sp.pos:DistToSqr( plyPos )
			minDist = math.min( minDist or dist, dist )
		end
		if minDist > maxDist then
			maxDist = minDist
			farthest = sp
		end
	end

	return farthest

end

function brawl.points.findNearestSpawn( ply )

	if not IsValid( ply ) then return end

	local tID = ply:Team()
	local plys = {}
	for k, pl in pairs( player.GetAll() ) do
		if pl == ply or ply:Team() ~= tID or not pl:Alive() or pl:GetNWBool("Spectating") then continue end
		table.insert( plys, pl:GetPos() )
	end

	if table.Count( plys ) < 1 then
		return brawl.points.findFarthestSpawn( ply )
	end

	local nearest, minDist2 = table.Random( brawl.points.data.spawn ), math.huge
	for k1, sp in RandomPairs( brawl.points.data.spawn ) do
		local minDist
		for k2, plyPos in pairs( plys ) do
			local dist = sp.pos:DistToSqr( plyPos )
			minDist = math.min( minDist or dist, dist )
		end
		if minDist < minDist2 then
			minDist2 = minDist
			nearest = { pos = util.FindPosition( sp.pos, ply, { around = 50, above = 0 } ), ang = sp.ang }
		end
	end

	return nearest

end

function brawl.points.findNearestTeamSpawn( ply )

	local tID = ply:Team()
	local plys = {}
	for k, pl in pairs( player.GetAll() ) do
		if pl == ply or pl:Team() ~= tID or not pl:Alive() or pl:GetNWBool("Spectating") then continue end
		if pl.lastHit and CurTime() < pl.lastHit + 15 then continue end

		local dir = pl:GetAimVector()
		dir.z = -0.1
		table.insert( plys, pl:GetPos() - dir:GetNormalized() * 50 )
	end

	for k, pos in RandomPairs( plys ) do
		local foundPos = util.FindPosition( pos, ply, { around = 50, above = 0 } )
		if foundPos then return { pos = foundPos, ang = (foundPos - pos):Angle() } end
	end

	return brawl.points.findFarthestSpawn( ply )

end

function brawl.points.initData()

	-- MySQLite.query([[
	--	 CREATE TABLE IF NOT EXISTS brawl_points (
	--		 map VARCHAR(50) NOT NULL,
	--		 name VARCHAR(50) NOT NULL,
	--		 data TEXT NOT NULL
	--	 )
	-- ]])

	if not file.Exists( "brawl_points", "DATA" ) then
		file.CreateDir( "brawl_points" )
	end

end

function brawl.points.save( name )

	name = name or "default"
	local map = string.lower( game.GetMap() )
	local data = util.TableToJSON( brawl.points.data )

	-- MySQLite.query(string.format("SELECT * FROM brawl_points WHERE map = %s AND name = %s",
	--	 MySQLite.SQLStr( map ), MySQLite.SQLStr( name )
	-- ), function( res )
	-- 	if not res or #res < 1 then
	-- 		MySQLite.query(string.format([[
	-- 			INSERT INTO brawl_points( map, name, data )
	-- 			VALUES ( %s, %s, %s )
	-- 			]], MySQLite.SQLStr( map ), MySQLite.SQLStr( name ), MySQLite.SQLStr( data )
	-- 		))
	-- 	else
	-- 		MySQLite.query(string.format([[
	-- 			UPDATE brawl_points
	-- 			SET data = %s WHERE map = %s AND name = %s
	--			 ]], MySQLite.SQLStr( data ), MySQLite.SQLStr( map ), MySQLite.SQLStr( name )
	-- 		))
	--
	-- 	end
	--
	--	 brawl.msg( "Saved spawnpoints for %s (%s)", brawl.config.maps[map].name or map, name )
	-- end)

	local fname = "brawl_points/" .. map .. "_" .. name .. ".dat"
	file.Write( fname, data )
	brawl.msg( "Saved spawnpoints for %s (%s)", brawl.config.maps[map].name or map, name )

end

function brawl.points.load( name )

	name = name or "default"
	local map = string.lower( game.GetMap() )

	-- MySQLite.query(string.format("SELECT * FROM brawl_points WHERE map = %s AND name = %s",
	--	 MySQLite.SQLStr( map ), MySQLite.SQLStr( name )
	-- ), function( res )
	--	 if res and res[1] then
	--		 local data = util.JSONToTable( res[1].data )
	--		 brawl.points = data
	--
	--		 brawl.msg( "Loaded spawnpoints for %s (%s)", brawl.config.maps[ res[1].map ].name or res[1].map, res[1].name )
	--		 brawl.points.update()
	--	 end
	-- end)

	local fname = "brawl_points/" .. map .. "_" .. name .. ".dat"
	if file.Exists( "data/" .. fname, "GAME" ) then
		local data = util.JSONToTable( file.Read( "data/" .. fname, "GAME" ) )
		brawl.points.data = data

		brawl.msg( "Loaded spawnpoints for %s (%s)", brawl.config.maps[ map ].name or map, name )
		brawl.points.update()
	else
		brawl.msg( "No spawnpoints found for %s", brawl.config.maps[ map ].name or map )
	end

end

-- ULib.ucl.registerAccess( "brawl_edit_points", ULib.ACCESS_SUPERADMIN, "Edit Brawl points", "Brawl" )

concommand.Add( "brawl_points_add",function( ply, cmd, args, argStr )

	if not brawl.points.isAllowed( ply ) then return end

	local type = args[1]
	if not type then return end

	local pos = ply:GetEyeTrace().HitPos
	local ang = ply:EyeAngles()
	ang.p, ang.r = 0, 0

	brawl.points.add( type, {
		pos = pos,
		ang = ang
	})

end)

concommand.Add( "brawl_points_remove",function( ply, cmd, args, argStr )

	if not brawl.points.isAllowed( ply ) then return end

	local type = args[1]
	if not type then return end

	local id = tonumber( args[2] )
	if not id then return end

	brawl.points.remove( type, id )

end)

concommand.Add( "brawl_points_reload", function( ply, cmd, arg, argStr )

	brawl.points.load()

end)
