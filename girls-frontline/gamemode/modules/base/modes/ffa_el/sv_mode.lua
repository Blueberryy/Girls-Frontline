function MODE:Think()

	local plys = player.GetAll()
	if table.Count( plys ) < 2 then
		SetGlobalInt( "brawl.RoundState", 0 )
		return
	elseif GetGlobalInt( "brawl.RoundState" ) == 0 then
		brawl.NewRound()
	end

	local alive, spectating = {}, {}
	for k, ply in pairs( plys ) do
		if not IsValid( ply ) then continue end
		if ply:Alive() then
			table.insert( alive, ply )
		elseif ply:GetNWBool( "SpectateOnly" ) then
			table.insert( spectating, ply )
		end
	end

	if table.Count( alive ) <= 1
	and GetGlobalInt( "brawl.RoundState" ) < 3 then
		brawl.EndRound({
			winner = alive[1]
		})
	end

end

local intermissionTime = 10
function MODE:EndRound( data )

	if data.winner then
		local ply = data.winner
		if not IsValid( ply ) then return end

		timer.Simple( intermissionTime, brawl.NewRound )
		SetGlobalFloat( "RoundStart", CurTime() + intermissionTime )

		SetGlobalInt( "brawl.RoundState", 3 )
		brawl.NotifyAll({
			Color(255,212,50), ply:Name(),
			color_white, " won the round!"
		})
		ply:AddScore( 1 )

		ply:AddXP( 250, "Round winner" )
	else
		timer.Simple( intermissionTime, brawl.NewRound )
		SetGlobalFloat( "RoundStart", CurTime() + intermissionTime )

		SetGlobalInt( "brawl.RoundState", 3 )
		brawl.NotifyAll( "Nobody won the round!" )
	end

end

function MODE:NewRound( type )

	local delay = 6.1

	game.CleanUpMap()
	brawl.CleanUpMap()

	for k, ply in pairs( player.GetAll() ) do
		if not ply:GetNWBool( "SpectateOnly" ) then
			ply:KillSilent()
			ply:UnSpectate()
			ply:SetNWBool( "Spectating", false )
			ply:Spawn()
			ply:Freeze( true )

			net.Start( "brawl.round.start" )
				net.WriteFloat( delay )
				net.WriteString( self.name )
				net.WriteString( self.agenda )
			net.Send( ply )
		end
	end

	SetGlobalInt( "brawl.RoundState", 1 )

	timer.Simple( delay, function()
		for k, ply in pairs( player.GetAll() ) do
			ply:Freeze( false )
		end

		SetGlobalInt( "brawl.RoundState", 2 )
		brawl.NotifyAll( "A new round has started!" )
	end)

end

function MODE:PlayerSpawn( ply )

	local spawn = brawl.points.findFarthestSpawn( ply )
	if spawn.pos then ply:SetPos( spawn.pos + Vector(0,0,5) ) end
	if spawn.ang then ply:SetEyeAngles( spawn.ang ) end

	ply:LoadModel()
	ply:LoadWeapons()
	ply:LoadSkills()

end

function MODE:DeathThink( ply )

	local spawnTime = ply:GetNWFloat( "RespawnTime" )
	local spectateTime = ply:GetNWFloat( "SpectateTime" )

	if CurTime() > spectateTime and spectateTime ~= 0 and not ply:GetNWBool( "Spectating" ) then
		ply:StartSpectating()
	-- elseif CurTime() > spawnTime and spawnTime ~= 0 then
	--	 ply:Spawn()
	end

	return false

end

function MODE:PlayerCanTalkTo( listener, talker, team, text )

	return true

end

function MODE:PlayerCanSpectate( ply, ent )

	return true

end

function MODE:PlayerInitialSpawn( ply )

	if table.Count( player.GetAll() ) > 1 and GetGlobalInt( "brawl.RoundState" ) ~= 0 then
		timer.Simple(0, function()
			ply:KillSilent()
			ply:SetScore( 0 )
			ply:SetTeam( 1001 )
			ply:StartSpectating()
		end)
	end

end

function MODE:PlayerDeath( ply )

	local plys = player.GetAll()
	if table.Count( plys ) < 2 then
		ply:SetNWFloat( "RespawnTime", CurTime() + 8 )
	else
		ply:SetNWFloat( "SpectateTime", CurTime() + 8 )
	end

end
