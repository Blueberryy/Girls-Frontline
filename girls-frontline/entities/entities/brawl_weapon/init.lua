AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
--[[
	self.WeaponClass = ""
	self.Ammo1 = 0
	self.Ammo2 = 0

	self:SetUseType( SIMPLE_USE )]]

end

--[[function ENT:SetWeapon( wep )

	if not IsValid( wep ) then return end

	self:SetNWString( "WeaponClass", wep:GetClass() )
	self:SetNWString( "WeaponCategory", wep:GetNWString( "WeaponCategory" ) )
	self.AmmoType1 = wep:GetPrimaryAmmoType()
	self.AmmoType2 = wep:GetSecondaryAmmoType()
	self.Ammo1 = IsValid(wep.Owner) and wep.Owner:GetAmmoCount( self.AmmoType1 ) or 0
	self.Clip1 = wep:Clip1()
	self.Ammo2 = IsValid(wep.Owner) and wep.Owner:GetAmmoCount( self.AmmoType2 ) or 0
	self.Clip2 = wep:Clip2()
	
	self:SetModel( wep.WorldModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self.M203Chamber = wep.M203Chamber

end]]


--[[function ENT:Use( ply, caller )

	if not ply:IsPlayer() then return end

	local oldAmmo1 = ply:GetAmmoCount( self.AmmoType1 )
	local oldAmmo2 = ply:GetAmmoCount( self.AmmoType2 )


	local newclass = self:GetNWString( "WeaponClass" )
	local newcat = self:GetNWString( "WeaponCategory" )
	if not GAMEMODE:PlayerCanPickupWeaponClass( newclass ) then return end

	if not ply:HasWeapon( newclass ) then
		for k, wep in pairs( ply:GetWeapons() ) do
			local oldcat = wep:GetNWString( "WeaponCategory" )
			if newcat == oldcat then
				ply:DropWeapon( wep )
			end
		end

		local wep = ply:Give( newclass, true )
		ply:SetAmmo( oldAmmo1 + self.Ammo1, self.AmmoType1 )
		ply:SetAmmo( oldAmmo2 + self.Ammo2, self.AmmoType2 )
		wep:SetClip1( self.Clip1 )
		wep:SetClip2( self.Clip2 )
		wep:SetNWString( "WeaponCategory", newcat )
	else
		ply:SetAmmo( oldAmmo1 + self.Ammo1 + self.Clip1, self.AmmoType1 )
		ply:SetAmmo( oldAmmo2 + self.Ammo2 + self.Clip2, self.AmmoType2 )
	end

	self:Remove()

end]]
