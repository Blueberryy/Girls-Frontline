function MODE:Think()

	if GetGlobalInt( "brawl.RoundState" ) < 3 then
		for k, ply in pairs( player.GetAll() ) do
			if not IsValid( ply ) then continue end
			if ply:Frags() >= self.maxKills then
				brawl.EndRound({
					winner = ply
				})
			end
		end
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

		ply:AddXP( 1000, "Round winner" )
	end

end

function MODE:NewRound( type )

	local delay = 6.1

	game.CleanUpMap()
	brawl.CleanUpMap()

	for k, ply in pairs( player.GetAll() ) do
		if not ply:GetNWBool( "SpectateOnly" ) then
			ply:SetFrags( 0 )
			ply:SetDeaths( 0 )
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

	if CurTime() >= spawnTime then
		if ply:GetNWBool( "SpectateOnly" ) then
			ply:StartSpectating()
		else
			ply:Spawn()
		end
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

	timer.Simple(0, function()
		local delay = 6.1

		ply:KillSilent()
		ply:SetNWFloat( "RespawnTime", CurTime() + delay )
		ply:SetTeam( 1001 )
		ply:SetScore( -1 )

		net.Start( "brawl.round.start" )
			net.WriteFloat( delay )
			net.WriteString( self.name )
			net.WriteString( self.agenda )
		net.Send( ply )
	end)

end

function MODE:PlayerDeath( ply )

	ply:SetNWFloat( "RespawnTime", CurTime() + 8 )

end
