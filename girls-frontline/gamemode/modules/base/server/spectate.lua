brawl.spectate = {}
local alivePlayers = {}

hook.Add( "KeyPress", "brawl.spectate", function( ply, key )

	if ply:GetNWBool("Spectating") then
		if key == IN_ATTACK then
			local target = util.GetNextAlivePlayer( ply:GetObserverTarget() )
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity( target )
		end
	end

end)

function brawl.spectate.update()

	alivePlayers = {}

	for k, ply in pairs( player.GetAll() ) do
		if IsValid( ply ) and ply:Alive() then
			table.insert( alivePlayers, ply )
		end
	end

end
hook.Add( "PlayerDeath", "brawl.spectate", brawl.spectate.update )
hook.Add( "PlayerSilentDeath", "brawl.spectate", brawl.spectate.update )
hook.Add( "PlayerSpawn", "brawl.spectate", brawl.spectate.update )
hook.Add( "PlayerDisconnected", "brawl.spectate", brawl.spectate.update )
brawl.spectate.update()

local meta = FindMetaTable "Player"

function meta:StartSpectating( ent )

	if not IsValid(ent) or not ent:IsPlayer() then
		for k, ply in pairs( player.GetAll() ) do
			if ply ~= self and ply:Alive() and brawl.PlayerCanSpectate( self, ent ) then
				ent = ply
				break
			end
		end
	end

	self:StripWeapons()
	self:Spectate( OBS_MODE_CHASE )
	self:SpectateEntity( ent )

	self:SetNWBool( "Spectating", true )
	self.spectatee = ent
	
end

concommand.Add( "brawl_spectate", function(ply, cmd, args, argStr)

	if ply.nextSwitchSpec and ply.nextSwitchSpec > CurTime() then
		ply:Notify( "Hold on for a sec", "error" )
		return
	end
	ply.nextSwitchSpec = CurTime() + 5

	state = args[1] and (args[1] == "1" and true or false) or not ply:GetNWBool( "SpectateOnly" )
	if state then
		ply:KillSilent()
		ply:StartSpectating()
		ply:SetNWBool( "SpectateOnly", true )
		brawl.NotifyAll({
			team.GetColor( ply:Team() ), ply:Name(),
			color_white, " is now spectating"
		})
	else
		ply:SetNWBool( "SpectateOnly", false )
		ply:SetNWBool( "Spectating", false )
		ply:KillSilent()
		ply:UnSpectate()
		ply:SetNWFloat( "RespawnTime", CurTime() )
		brawl.NotifyAll({
			team.GetColor( ply:Team() ), ply:Name(),
			color_white, " is now playing"
		})
	end

end)
