GM = GM or GAMEMODE

function GM:InitPostEntity ()

	brawl.CleanUpMap()

end

hook.Add( "ChatText", "hide_joinleave", function( index, name, text, typ )
	if ( typ == "joinleave" ) then return true end
end)

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")
hook.Add("player_connect", "ShowConnect", function( data )

	local steamID = data.networkid
	local name = data.name
	brawl.NotifyAll( name .. " joined the game!", "join" )

end)

hook.Add("player_disconnect", "ShowDisconnect", function( data )

	local steamID = data.networkid
	local name = data.name
	brawl.NotifyAll( name .. " left the game", "leave" )

end)

function brawl.CleanUpMap()

	brawl.msg( "Cleaning up map" )
	for k, ent in pairs( ents.GetAll() ) do

		local class = ent:GetClass()
		if class and string.StartWith( class, "item" ) or string.StartWith( class, "weapon" ) then
			ent:Remove()
		end

	end

end

function GM:PlayerInitialSpawn( ply )

	brawl.PlayerInitialSpawn( ply )

end

function GM:PlayerSpawn( ply )

	if not IsValid(ply) then return end
	
	brawl.modes.active:PlayerSpawn( ply )

	ply.BabyGod = true
	timer.Simple( 3, function()
		if not IsValid(ply) then return end
		ply.BabyGod = false
	end)
	ply:SetupHands()

end

function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function GM:DoPlayerDeath( victim, attacker, dmg )

	victim:DoPlayerDeath( attacker, dmg )
	brawl.DoPlayerDeath( victim, attacker, dmg )

end

function GM:PlayerDeath( ply )

	brawl.PlayerDeath( ply )

end

function GM:PlayerCanHearPlayersVoice( listener, talker )

	return brawl.PlayerCanTalkTo( listener, talker, true )

end

function GM:PlayerCanSeePlayersChat( text, team, listener, talker )

	if talker == NULL then return true end
	return brawl.PlayerCanTalkTo( listener, talker, team, text )

end

local damage = {
	[1] = 2.5,
	[2] = 1.5,
	[3] = 1,
	[4] = 0.5,
	[5] = 0.5,
	[6] = 0.5,
	[7] = 0.5
}

function GM:ScalePlayerDamage( ply, hitGroup, dmg )

	ply.lastHitGroup = hitGroup
	ply:SetNWFloat( "LastHit", CurTime() )

	dmg:ScaleDamage( damage[ hitGroup ] or 1 )

end

function GM:EntityTakeDamage( ent, dmg )

	if ent.ULXHasGod or ent.BabyGod then
		dmg:SetDamage( 0 )
		return
	end

	local damage = dmg:GetDamage()

	local attacker = dmg:GetAttacker()
	if ent:IsPlayer() then
		net.Start( "brawl.hit" )
			net.WriteTable({
				victim = ent,
				attacker = attacker,
				inflictor = dmg:GetInflictor(),
				damage = damage,
				pos = dmg:GetDamagePosition(),
				type = dmg:GetDamageType()
			})
		net.Send({ attacker:IsPlayer() and attacker, ent })
	end

	ent:SetHealth( ent:Health() - damage )
	if ent:IsPlayer() then
		ent:ViewPunch( Angle(
			math.random( -damage, damage ) / 3,
			math.random( -damage, damage ) / 3,
			math.random( -damage, damage ) / 6
		))
	end

	if not ent.attacks then ent.attacks = {} end
	if IsValid( attacker ) then
		ent.attacks[ attacker ] = ent.attacks[ attacker ] or {}
		local data = ent.attacks[ attacker ]
		data.lastHit = CurTime()
		data.dmg = data.dmg and (data.dmg + damage) or damage
	end

	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ent then ent.lastHit = CurTime() end
	dmg:SetDamage( 0 )

end

function GM:GetFallDamage( ply, vel )

	return vel / 6

end

function GM:PlayerCanPickupWeapon( ply, wep )

	if brawl.modes.active.PlayerCanPickupWeapon then
		return brawl.modes.active.PlayerCanPickupWeapon( ply, wep )
	end

	return true

end

function GM:PlayerCanPickupWeaponClass( ply, class )

	if brawl.modes.active.PlayerCanPickupWeaponClass then
		return brawl.modes.active.PlayerCanPickupWeaponClass( ply, class )
	end

	return true

end

function GM:PlayerCanDropWeapon( ply, wep )

	if not IsValid(wep) then return false end

	if brawl.modes.active.PlayerCanDropWeapon then
		return brawl.modes.active.PlayerCanDropWeapon( ply, wep )
	end

	return wep:GetWeaponCategory() ~= "melee"

end

function GM:PlayerDeathThink( ply )

	brawl.DeathThink( ply )

end

function GM:PlayerDeathSound()

	return true

end
