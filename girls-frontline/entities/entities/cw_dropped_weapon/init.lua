AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("CW_DROPPED_WEAPON_ATTACHMENTS")

local attachmentPresetTable = {} -- this is where all the attachments will go to

function ENT:Initialize()
end

function ENT:Use(activator, caller)
	if hook.Call("CW20_PreventCWWeaponPickup", nil, self, activator) then
		return
	end
	
	if not GAMEMODE:PlayerCanPickupWeaponClass( self:GetWepClass() ) then return end

	local pos = self:GetPos() - activator:GetShootPos()
	local pickupDotProduct = activator:EyeAngles():Forward():Dot(pos) / pos:Length()
		
	if pickupDotProduct < self.pickupDotProduct then
		return
	end
	
	-- if use key is down we restrict picking the weapon up, because we might be wanting to throw a grenade, and if we throw + pick up the weapon - nothing will happen, because weapons will be switched
	if CurTime() < self.useDelay then
		return
	end
	
	local curWep = activator:GetActiveWeapon()
	
	-- can't pick up a weapon if we're performing an action of some kind
	if IsValid(curWep) and curWep.CW20Weapon and curWep.dt.State == CW_ACTION then
		return
	end
	
	local canGetWeapon, canGetAttachments = self:canPickup(activator)
	local wep = nil
	
	if canGetWeapon then -- give the weapon if possible
		local newcat = self:GetNWString( "WeaponCategory" )

		for k, v in pairs( activator:GetWeapons() ) do
			local oldcat = v:GetNWString( "WeaponCategory" )
			if newcat == oldcat then
				if v.disableDropping then
					return
				else
					activator:DropWeapon( v )
				end
			end
		end
		wep = activator:Give(self:GetWepClass())
		wep:SetNWString( "WeaponCategory", newcat )
		hook.Call("CW20_PickedUpCW20Weapon", nil, activator, self, wep)
		wep.disableDropping = true -- we set this variable to true so that the player can not drop the weapon using the cw_dropweapon command until attachments are applied
	else 
		activator:GetWeapon(self:GetWepClass()):SetClip1( activator:GetWeapon(self:GetWepClass()):Clip1() + self.magSize )
		self:Remove()
	end
	
	--[[if canGetAttachments then -- give attachments if possible
		CustomizableWeaponry.giveAttachments(activator, self.stringAttachmentIDs)
	end]]
	
	local attachments = self.containedAttachments
	local magSize = self.magSize
	local m203Chamber = self.M203Chamber
	
	if wep then -- if we were given a weapon, load up the attachments on it
		timer.Simple(0.3, function()
			if not IsValid(wep) then
				return
			end

			wep:SetClip1(0) -- set magsize to 0 before loading attachments, because some of them unload the mag and that way we can cheat ammo (by dropping and picking up again)
			
			wep:SetClip1(magSize) -- set the mag size only after we've attached everything
			wep.disableDropping = false -- set it to false, now we can drop it
			
			hook.Call("CW20_FinishedPickingUpCW20Weapon", nil, activator, wep)
		end)
	end
	
	if canGetWeapon or canGetAttachments then
		self:Remove()
	end
end

function ENT:setWeapon(wep)
	self:SetWepClass(wep:GetClass())
	self:SetNWString( "WeaponCategory", wep:GetNWString( "WeaponCategory" ))
	self:SetNWString( "WeaponClass", wep:GetClass() )
	self.magSize = wep:Clip1()
	self.containedAttachments = {} -- for shit like loading them onto a weapon
	self.stringAttachmentIDs = {} -- for shit like displaying the attachment names and giving them to the player upon pickup
	self.useDelay = CurTime() + 1
	
	self:SetModel(wep.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
	
	for key, data in pairs(wep.Attachments) do
		if data.last then
			self.containedAttachments[key] = data.last
			self.stringAttachmentIDs[#self.stringAttachmentIDs + 1] = data.atts[data.last]
		end
	end
	
	self.M203Chamber = wep.M203Chamber
end

function ENT:sendWepData(target)
	target = target or player.GetAll()
	
	net.Start("CW_DROPPED_WEAPON_ATTACHMENTS")
		net.WriteEntity(self)
		net.WriteTable(self.stringAttachmentIDs)
	net.Send(target)
end

concommand.Add("cw_request_wep_data", function(ply, com, args)
	local entityID = args[1]
	
	if not entityID then
		return
	end
	
	entityID = tonumber(entityID)
	local entity = ents.GetByIndex(entityID)
	
	if IsValid(entity) and entity:GetClass() == "cw_dropped_weapon" then
		entity:sendWepData(ply)
	end
end)