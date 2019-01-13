local meta = FindMetaTable "Player"

function meta:LoadWeapons()

	brawl.PlayerLoadWeapons( self )

end

function meta:SelectWeapon( class )

	net.Start( "brawl.selectWeapon" )
		net.WriteString( class )
	net.Send( self )

end

function meta:GiveWeapon( class, clips )

	local cat = brawl.GetWeaponCategory( class )
	if not cat then return end

	local wep = self:Give( class )
	wep:SetNWString( "WeaponCategory", cat )

	if clips then self:AddAmmoClips( wep, clips ) end

	return wep

end

function meta:AddAmmoClips( wep, num, secondary )

	brawl.AddWeaponClips( self, wep, num, secondary )

end

function meta:LoadModel()

	local level =  math.Clamp( math.floor( self:GetLevel() / 3 ) * 3, 1, 33 )
	local mdls = table.Random( brawl.config.playerModels[ level ] )

	local mdl
	if istable( mdls ) then
		mdl = mdls[1]
		self.models = mdls
	else
		mdl = mdls
		self.models = { mdl }
	end

	self:SetModel( mdl )
	net.Start( "brawl.myModel" )
		net.WriteString( mdl )
		net.WriteUInt( 1, 8 )
	net.Send( self )

	-- local col = brawl.modes.active.teams and team.GetColor( self:Team() ) or Color( 255,0,0 )
	-- self:SetColor( col )

end

function meta:LoadSkills()

	self:SetWalkSpeed( brawl.config.player.baseWalkSpeed )
	self:SetRunSpeed( brawl.config.player.baseRunSpeed )
	self:SetCanZoom( false )

	self:SetStamina( 100 )
	self.staminaLastUse = CurTime()
	self.canSprint = true
	self.canJump = true
	self.attacks = {}
	self.killStreak = 0
	self.killsThisLife = 0

	local uid = self:UserID()
	timer.Create( "killStreakReset" .. uid, 5, 0, function()
		if not IsValid(self) then return timer.Remove( "killStreakReset" .. uid ) end

		self.killStreak = 0
		timer.Stop( "killStreakReset" .. uid )
	end)

	self.healthRegenTemp = 0
	self:SetNWFloat( "LastHit", CurTime() )

end

function meta:SetStamina( val )

	self:SetNWFloat( "Stamina", val )

end

function meta:TakeStamina( val )

	self:SetNWFloat( "Stamina", math.Clamp( self:GetStamina() - val, 0, 100 ) )
	self.staminaLastUse = CurTime()

end

hook.Add( "Think", "brawl.regen", function()

	for k, ply in pairs( player.GetAll() ) do
		if not IsValid( ply ) or not ply:Alive() then continue end

		-- handle stamina
		local vel = ply:GetVelocity():Length()
		local stam = ply:GetStamina()

		if ply:KeyDown( IN_SPEED ) and vel ~= 0 and ply:OnGround() and ply.canSprint then
			local take = math.Clamp( FrameTime() * brawl.config.player.staminaSprintCost, 0, 100 )
			if take ~= 0 then ply:TakeStamina( take ) end
		elseif ply.staminaLastUse and ply.staminaLastUse + brawl.config.player.staminaRegenDelay <= CurTime() then
			local mul = (not ply:OnGround() and 0) or (vel > 100 and 100 / vel or 1)
			local newStam = math.Clamp( stam + FrameTime() * brawl.config.player.staminaRegenRate * mul, 0, 100 )
			if newStam ~= stam then ply:SetStamina( newStam ) end
		end

		stam = ply:GetStamina()

		if stam < brawl.config.player.staminaJumpCost then
			ply.canJump = false
			ply:SetJumpPower( 0 )
		elseif not ply.canJump or ply:GetJumpPower() == 0 then
			ply.canJump = true
			ply:SetJumpPower( 160 )
		end

		if stam <= 0 then
			ply.canSprint = false
			ply:SetRunSpeed( brawl.config.player.baseWalkSpeed )
		elseif stam > 10 and (not ply.canSprint or ply:GetRunSpeed() == brawl.config.player.baseWalkSpeed) then
			ply.canSprint = true
			ply:SetRunSpeed( brawl.config.player.baseRunSpeed )
		end

		-- handle health
		ply.healthRegenTemp = ply.healthRegenTemp or 0
		if ply:GetNWFloat( "LastHit" ) + brawl.config.player.healthRegenDelay <= CurTime() then
			ply.healthRegenTemp = ply.healthRegenTemp + FrameTime() * brawl.config.player.healthRegenRate
			local delta = math.floor( ply.healthRegenTemp )
			local hl = math.max( math.Clamp( ply:Health() + delta, 0, 100 ), ply:Health() )
			ply.healthRegenTemp = ply.healthRegenTemp - delta
			ply:SetHealth( hl )
		end
	end

end)

hook.Add( "SetupMove", "brawl.jump", function( ply, mvd, cmd )

	if mvd:KeyPressed( IN_JUMP ) and ply:OnGround() and ply:GetStamina() >= brawl.config.player.staminaJumpCost then
		ply:TakeStamina( brawl.config.player.staminaJumpCost )
	end

end)

local maxWeapons = 10
function meta:DoPlayerDeath( attacker, dmg )

	self:CreateRagdoll( attacker, dmg )

	local weps = self:GetWeapons()

	local mapWeps = ents.FindByClass( "brawl_weapon" )
	local numToRemove = table.Count( mapWeps ) - maxWeapons
	for i=1, numToRemove do
		mapWeps[i]:Remove()
	end

	for k, wep in pairs( weps ) do
		self:DropWeapon( wep )
	end

	self:AddDeaths( 1 )
	if attacker ~= self and attacker:IsPlayer() then
		attacker:AddFrags( 1 )
	end

	if self.TeamSwitch then
		self.TeamSwitch = nil
	else 
		SetGlobalInt( "brawl.KillsThisRound", GetGlobalInt( "brawl.KillsThisRound" ) + 1 )
		SetGlobalInt( "brawl.KillsThisMode", GetGlobalInt( "brawl.KillsThisMode" ) + 1 )
	end

	local data = {
		victim = self,
		attacker = dmg:GetAttacker(),
		inflictor = dmg:GetInflictor(),
		damage = dmg:GetDamage(),
		pos = dmg:GetDamagePosition(),
		type = dmg:GetDamageType()
	}

	net.Start( "brawl.killfeed" )
		net.WriteTable( data )
	net.Broadcast()

	brawl.msg( "[KillFeed] %s -> %s (%s)", tostring(data.attacker), tostring(data.victim), tostring(inflictor) )

end

function meta:DropWeapon( wep )

	if isstring( wep ) then
		wep = self:GetWeapon( wep )
	end

	if not IsValid( wep ) then return end
	if brawl.weapons.melee[ wep:GetClass() ] then return end

	local drop = ents.Create( "brawl_weapon" )
	drop:Spawn()
	drop:setWeapon( wep )
	drop:SetPos( self:GetShootPos() )

	local phys = drop:GetPhysicsObject()
	if phys then
		phys:SetVelocity( self:GetAimVector() * 200 )
	end

	self:StripWeapon( wep:GetClass() )

end

maxCorpses = 25
corpseLifetime = 120
brawl.corpses = brawl.corpses or {}

local bones = {
	[1] = "ValveBiped.Bip01_Head1",
	[2] = "ValveBiped.Bip01_Spine2",
	[3] = "ValveBiped.Bip01_Pelvis",
	[4] = "ValveBiped.Bip01_L_Clavicle",
	[5] = "ValveBiped.Bip01_R_Clavicle",
	[6] = "ValveBiped.Bip01_L_Calf",
	[7] = "ValveBiped.Bip01_R_Calf",
}

function meta:CreateRagdoll( attacker, dmg )

	local oldCorpse = self:GetNWEntity( "Corpse" )

	-- remove old corpses
	local corpses = 1
	for k,corpse in pairs( brawl.corpses ) do
		if IsValid( corpse ) then
			corpses = corpses + 1
		else
			brawl.corpses[k] = nil
		end
	end

	if maxCorpses >= 0 && corpses > maxCorpses then
		for i = 0, corpses do
			if corpses > maxCorpses then
				if IsValid( brawl.corpses[1] ) then
					brawl.corpses[1]:Remove()
				end
				table.remove( brawl.corpses, 1 )
				corpses = corpses - 1
			else
				break
			end
		end
	end

	-- create new corpse
	local data = duplicator.CopyEntTable( self )
	local corpse = ents.Create( "prop_ragdoll" )
		duplicator.DoGeneric( corpse, data )
	corpse:Spawn()
	corpse:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	corpse:Fire("kill","", corpseLifetime )

	if corpse.SetPlayerColor then
		corpse:SetPlayerColor( self:GetPlayerColor() )
	end
	corpse:SetNWEntity( "Owner", self )

	local force = dmg:GetDamageForce()
	local vel = self:GetVelocity()
	local phyObjNum = corpse:GetPhysicsObjectCount()
	for id = 0, phyObjNum - 1 do

		local PhysObj = corpse:GetPhysicsObjectNum( id )
		if IsValid( PhysObj ) then

			local bone = corpse:TranslatePhysBoneToBone( id )
			local pos, ang = self:GetBonePosition( bone )
			PhysObj:SetPos( pos )
			PhysObj:SetAngles( ang )
			PhysObj:AddVelocity( vel )

			if not self.lastHitGroup then continue end
			if bones[ self.lastHitGroup ] == self:GetBoneName( bone ) then
				PhysObj:AddVelocity( force * 2 / PhysObj:GetMass() )
			end

		end

	end

	corpse:SetColor( self:GetColor() )

	-- finish up
	self:SetNWEntity( "Corpse", corpse )
	table.insert( brawl.corpses, corpse )

end

function meta:SetScore( score )

	self:SetNWInt( "brawl.score", score )

end

function meta:AddScore( score )

	self:SetNWInt( "brawl.score", self:GetNWInt( "brawl.score" ) + score )

end
