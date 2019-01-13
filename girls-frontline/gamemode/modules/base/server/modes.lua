CreateConVar( "brawl_nextmode", "", { FCVAR_REPLICATED, FCVAR_GAMEDLL, FCVAR_ARCHIVE } )

local oldMode =  GetGlobalString( "brawl.mode" )
local pendingMode = GetConVar( "brawl_nextmode" ):GetString()

function brawl.modes.select( name )

	if not brawl.modes.registered[ name ] then
		brawl.msg( "[ERROR] No such mode: %s!", name )
		return
	end

	if brawl.modes.active then
		brawl.modes.pending = name
		brawl.NotifyAll({
			color_white, "Changing gamemode to ",
			Color(255,212,50), brawl.modes.registered[ name ].name,
			color_white, " next round"
		})
		return
	end

	brawl.modes.active = brawl.modes.registered[ name ]
	brawl.NotifyAll({
		color_white, "Gamemode set to ",
		Color(255,212,50), brawl.modes.active.name
	})

	SetGlobalString( "brawl.mode", name )
	SetGlobalString( "brawl.mode.agenda", brawl.modes.active.agenda )
	SetGlobalInt( "brawl.Rounds", 0 )
	SetGlobalInt( "brawl.KillsThisMode", 0 )
	brawl.NewRound()

end

SetGlobalInt( "brawl.RoundState", GetGlobalInt( "brawl.RoundState", 0 ) )
SetGlobalInt( "brawl.Rounds", GetGlobalInt( "brawl.Rounds", 0 ) )

function brawl.RoundThink()

	if not brawl.modes.active then return end

	if not brawl.modes.active.Think then
		brawl.msg( "ERROR: Mode has no Think logic!" )
		return
	end

	brawl.modes.active:Think()

end
hook.Add( "Think", "brawl.RoundThink", brawl.RoundThink )

function brawl.EndRound( data )

	if not brawl.modes.active then return end

	if not brawl.modes.active.EndRound then
		brawl.msg( "ERROR: Mode has no EndRound logic!" )
		return
	end

	brawl.modes.active:EndRound( data )

	net.Start( "brawl.round.end" )
		net.WriteTable( data )
	net.Broadcast()

end

function brawl.NewRound()

	SetGlobalInt( "brawl.Rounds", GetGlobalInt( "brawl.Rounds" ) + 1 )
	SetGlobalInt( "brawl.KillsThisRound", 0 )
	if math.random(10) == 1 then
		SetGlobalString( "brawl.mode.category", "none" )
	else
		local _, cat = table.Random( brawl.config.weapons.primary )
		SetGlobalString( "brawl.mode.category", cat )
	end

	if GetGlobalInt( "brawl.Rounds" ) > (brawl.modes.active.maxRounds or brawl.config.modes.maxRounds) then
		brawl.VoteStart()
		return
	end

	if brawl.modes.pending then
		brawl.modes.active = nil
		brawl.modes.select( brawl.modes.pending )
	end

	brawl.msg( "Starting round #%d.", GetGlobalInt( "brawl.Rounds" ) )

	if not brawl.modes.active.NewRound then
		brawl.msg( "ERROR: Mode has no NewRound logic!" )
		return
	end

	brawl.modes.active:NewRound()
	SetGlobalString( "brawl.mode.agenda", brawl.modes.active.agenda )

end

function brawl.PlayerLoadWeapons( ply )

	if not brawl.modes.active then return end

	if not brawl.modes.active.PlayerLoadWeapons then
		ply:StripWeapons()

		local melee = table.Random( brawl.config.weapons.melee )
		local secondary = table.Random( brawl.config.weapons.secondary )

		ply:GiveWeapon( melee )
		ply:GiveWeapon( secondary, 2 )
		if math.random( 4 ) == 1 then
			local extra = table.Random( brawl.config.weapons.extra )
			ply:GiveWeapon( extra )
		end

		local cat = GetGlobalString("brawl.mode.category")
		if cat ~= "none" then
			local primary = table.Random( brawl.config.weapons.primary[ cat ] )
			ply:GiveWeapon( primary, 2 )
			ply:SelectWeaponByCategory( "primary" )
		else
			ply:SelectWeaponByCategory( "secondary" )
		end

		return true
	end

	return brawl.modes.active:PlayerLoadWeapons( ply )

end

function brawl.PlayerCanSpectate( ply, ent )

	if not brawl.modes.active then return end

	if not brawl.modes.active.PlayerCanSpectate then
		return true
	end

	brawl.modes.active:PlayerCanSpectate( ply, ent )

end

function brawl.PlayerCanTalkTo( listener, talker, team, text )

	if not brawl.modes.active then return end

	if not brawl.modes.active.PlayerCanTalkTo then
		return true
	end

	return brawl.modes.active:PlayerCanTalkTo( listener, talker, team, text )

end

function brawl.DeathThink( ply )

	if not brawl.modes.active then return end

	if not brawl.modes.active.DeathThink then
		return true
	end

	brawl.modes.active:DeathThink( ply )

end

function brawl.PlayerInitialSpawn( ply )

	if not brawl.modes.active then return end

	if not brawl.modes.active.PlayerInitialSpawn then
		ply:Spawn()
	end

	brawl.modes.active:PlayerInitialSpawn( ply )
	SetGlobalString( "brawl.mode.agenda", brawl.modes.active.agenda )

end

function brawl.PlayerDeath( ply )

	if not brawl.modes.active then return end

	if brawl.modes.active.PlayerDeath then
		brawl.modes.active:PlayerDeath( ply )
	end

end

function brawl.DoPlayerDeath( victim, attacker, dmg )

	if not brawl.modes.active then return end

	if brawl.modes.active.DoPlayerDeath then
		brawl.modes.active:DoPlayerDeath( victim, attacker, dmg )
	end

end

function brawl.SwitchTeam( ply, tID, force )

	if not brawl.modes.active then return end
	if ply.nextSwitchTeam and ply.nextSwitchTeam > CurTime() then
		ply:Notify( "Hold on for a sec", "error" )
		return
	end

	local allowedTeams = {}
	local minNumber = math.huge
	for _, k in pairs( brawl.modes.active.teams ) do
		if k == ply:Team() then continue end
		if team.NumPlayers( k ) < minNumber then
			minNumber = team.NumPlayers( k )
			allowedTeams = { [k] = true }
		elseif team.NumPlayers( k ) == minNumber then
			allowedTeams[ k ] = true
		end
	end

	if tID and tID == ply:Team() then
		ply:Notify( "You are already in this team", "error" )
		return
	end

	local t, k = table.Random( allowedTeams )
	tID = tID or k
	print(tID)

	if tID == ply:Team() then
		ply:Notify( "You cannot change team at this moment", "error" )
		return
	end

	if not team.Valid( tID ) then
		ply:Notify( "This team does not exist", "error" )
		return
	end

	if not force and not allowedTeams[ tID ] then
		ply:Notify( "You cannot join this team", "error" )
		return
	end

	ply.TeamSwitch = true
	ply:KillSilent()
	ply:SetTeam( tID )
	brawl.NotifyAll({
		team.GetColor(tID), ply:Name(),
		color_white, " joined team ",
		team.GetColor(tID), team.GetName( tID )
	})

	ply.nextSwitchTeam = CurTime() + 5

end

concommand.Add( "brawl_switchteam", function( ply, cmd, args, argStr )

	local tID = tonumber(args[1])
	brawl.SwitchTeam( ply, tID )

end)

local _, mode = table.Random( brawl.modes.registered )
if pendingMode ~= "" then
	mode = pendingMode
	GetConVar( "brawl_nextmode" ):SetString( "" )
elseif oldMode ~= "" then
	mode = oldMode
end
brawl.modes.select( mode )
