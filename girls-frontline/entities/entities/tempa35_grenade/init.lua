AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/items/ar2_grenade.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	util.PrecacheSound("weapons/A35CW/40mm_explode.wav")
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

end

local exp

function ENT:PhysicsCollide(data, physobj)

	if data.Speed > 75 and data.DeltaTime > 0.3 then
			local LSpeed = data.OurOldVelocity:Length()
			local NVelocity = physobj:GetVelocity()
			local TVelocity = NVelocity + (LSpeed*0.2)*NVelocity:GetNormalized()
			physobj:SetVelocity(TVelocity)
			self:Explosion()
			self.Entity:Remove()
	end
end

function ENT:HitEffect()
	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 600 ) ) do
		if v:IsValid() && v:IsPlayer() then
		end
	end
end

function ENT:Explosion()

	-- local explod = ents.Create( "env_explosion" )
	-- 	explod:SetOwner( self.GrenadeOwner )
	-- 	explod:SetPos( self.Entity:GetPos() )
	-- 	explod:SetKeyValue( "iMagnitude", "0" )
	-- 	explod:Spawn()
	-- 	explod:Activate()
	-- 	explod:Fire( "Explode", "", 0 )

	local ef = EffectData()
	ef:SetOrigin(self.Entity:GetPos())
	ef:SetMagnitude(1)
	util.Effect("Explosion", ef)
	util.BlastDamage(self, self.GrenadeOwner, self.Entity:GetPos(), 384, 100)

	local shake = ents.Create( "env_shake" )
		shake:SetOwner( self.GrenadeOwner )
		shake:SetPos( self.Entity:GetPos() )
		shake:SetKeyValue( "amplitude", "200" )
		shake:SetKeyValue( "radius", "800" )
		shake:SetKeyValue( "duration", "2" )
		shake:SetKeyValue( "frequency", "255" )
		shake:SetKeyValue( "spawnflags", "4" )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )


	local smoke = ents.Create("env_ar2explosion")
		smoke:SetOwner(self.Owner)
		smoke:SetPos(self.Entity:GetPos())
		smoke:Spawn()
		smoke:Activate()
		smoke:Fire("Explode", "", 0)
		//Weed everyday
		self.Entity:EmitSound(Sound("weapons/A35CW/40mm_explode.wav", 100, 100))

	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 250 ) ) do
		v:Fire( "EnableMotion", "", math.random( 0, 0.5 ) )
	end

end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:Use( activator, caller, type, value )
end

function ENT:StartTouch( entity )
end

function ENT:EndTouch( entity )
end

function ENT:Touch( entity )
end
