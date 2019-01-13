function MODE:Think()

	if GetGlobalInt( "brawl.RoundState" ) == 0 then
		SetGlobalInt( "brawl.Rounds", 0 )
		brawl.NewRound()
	end

	if GetGlobalInt( "brawl.RoundState" ) < 3 then
		for _, k in pairs( self.teams ) do
			if team.GetScore( k ) >= self.maxKills then
				brawl.EndRound({
					winner = k
				})
			end
		end
	end

end

local intermissionTime = 10
function MODE:EndRound( data )

	if data.winner then
		local t = data.winner
		if not t then return end

		timer.Simple( intermissionTime, brawl.NewRound )
		SetGlobalFloat( "RoundStart", CurTime() + intermissionTime )

		SetGlobalInt( "brawl.RoundState", 3 )
		brawl.NotifyAll({
			team.GetColor( data.winner ), team.GetName( data.winner ) .. " squad",
			color_white, " won the round!"
		})

		for k, ply in pairs( team.GetPlayers(t) ) do
			ply:AddXP( 750, "Round winner" )
		end
	end

end

function MODE:NewRound( type )

	local delay = 6.1

	game.CleanUpMap()
	brawl.CleanUpMap()

	for k, ply in RandomPairs( player.GetAll() ) do
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

	local spawn = brawl.points.findNearestTeamSpawn( ply )
	if spawn.pos then ply:SetPos( spawn.pos + Vector(0,0,5) ) end
	if spawn.ang then ply:SetEyeAngles( spawn.ang ) end

	ply:LoadModel()
	ply:LoadWeapons()
	ply:LoadSkills()

end

function MODE:DeathThink( ply )

	local spawnTime = ply:GetNWFloat( "RespawnTime" )

	if CurTime() > spawnTime then
		if ply:GetNWBool( "SpectateOnly" ) then
			ply:StartSpectating()
		else
			ply:Spawn()
		end
	end

	return false

end

function MODE:PlayerCanTalkTo( listener, talker, t, text )

	return true, listener:Team() ~= talker:Team()

end

function MODE:PlayerCanSpectate( ply, ent )

	return true

end

function MODE:PlayerInitialSpawn( ply )

	timer.Simple(0, function()
		local delay = 6.1

		ply:KillSilent()
		ply:SetNWFloat( "RespawnTime", CurTime() + delay )

		net.Start( "brawl.round.start" )
			net.WriteFloat( delay )
			net.WriteString( self.name )
			net.WriteString( self.agenda )
		net.Send( ply )

		local t = team.BestAutoJoinTeam( ply )
		ply:SetTeam( t )
		brawl.NotifyAll({
			team.GetColor( t ), ply:Name(),
			color_white, " joined ",
			team.GetColor( t ), team.GetName(t) .. " squad"
		})
	end)

end

function MODE:PlayerDeath( ply )

	ply:SetNWFloat( "RespawnTime", CurTime() + 8 )

end

function MODE:DoPlayerDeath( victim, attacker, dmg )

	if not attacker:IsPlayer() then return end

	local victimTeam = victim:Team()
	local killerTeam = attacker:Team()
	team.AddScore( killerTeam, victimTeam ~= killerTeam and 1 or -1 )

end
