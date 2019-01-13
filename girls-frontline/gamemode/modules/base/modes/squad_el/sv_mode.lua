function MODE:Think()

	if GetGlobalInt( "brawl.RoundState" ) == 0 then
		SetGlobalInt( "brawl.Rounds", 0 )
		brawl.NewRound()
	end

	if table.Count(player.GetAll()) > 1 and GetGlobalInt( "brawl.RoundState" ) < 3 then
		local existingTeams, aliveTeams = {}, {}
		for _, k in pairs( self.teams ) do
			aliveTeams[ k ] = table.Count( team.GetAlivePlayers( k ) ) > 0 and true or nil
			for _, ply in pairs( team.GetPlayers( k ) ) do
				if not ply:GetNWBool( "SpectateOnly" ) then
					existingTeams[ k ] = true
					break
				end
			end
		end
		if table.Count( aliveTeams ) <= 1 and table.Count( existingTeams ) > 1 then
			local legit = table.Count( aliveTeams ) == 1 and GetGlobalInt( "brawl.KillsThisRound" ) > 0
			brawl.EndRound({ winner = legit and table.GetFirstKey(aliveTeams) or nil })
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

		team.AddScore( data.winner, 1 )
		SetGlobalInt( "brawl.RoundState", 3 )
		brawl.NotifyAll({
			team.GetColor( data.winner ), team.GetName( data.winner ) .. " squad",
			color_white, " won the round!"
		})

		for k, ply in pairs( team.GetPlayers(t) ) do
			ply:AddXP( 200, "Round winner" )
		end
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

	local spawn = brawl.points.findNearestTeamSpawn( ply )
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

function MODE:PlayerCanTalkTo( listener, talker, t, text )

	if not talker:Alive() then return false end
	return true, listener:Team() ~= talker:Team()

end

function MODE:PlayerCanSpectate( ply, ent )

	return true

end

function MODE:PlayerInitialSpawn( ply )

	if table.Count( player.GetAll() ) > 1 and GetGlobalInt( "brawl.RoundState" ) ~= 0 then
		timer.Simple(0, function()
			ply:KillSilent()
			ply:SetScore( -1 )
			ply:StartSpectating()
		end)
	end

	timer.Simple(0,function()
		local t = team.BestAutoJoinTeam( ply )
		ply:SetTeam( t )
		brawl.NotifyAll({
			team.GetColor(t), ply:Name(),
			color_white, " joined ",
			team.GetColor(t), team.GetName(t) .. " squad"
		})
	end)

end

function MODE:PlayerDeath( ply )

	local plys = player.GetAll()
	if table.Count( plys ) < 2 then
		ply:SetNWFloat( "RespawnTime", CurTime() + 8 )
	else
		ply:SetNWFloat( "SpectateTime", CurTime() + 8 )
	end

end
