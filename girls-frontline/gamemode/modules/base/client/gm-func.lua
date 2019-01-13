GM = GM or GAMEMODE

local CMoveData = FindMetaTable( "CMoveData" )

function CMoveData:RemoveKeys( keys )
	local newbuttons = bit.band( self:GetButtons(), bit.bnot( keys ) )
	self:SetButtons( newbuttons )
end

hook.Add( "SetupMove", "brawl.jump", function( ply, mvd, cmd )

	if mvd:KeyPressed( IN_JUMP ) then
		if ply:GetStamina() < brawl.config.player.staminaJumpCost then mvd:RemoveKeys( IN_JUMP ) end
	end

end)

local meta = FindMetaTable "Player"

function meta:SelectWeapon( class )

	if not self:HasWeapon( class ) then return end
	self.DoWeaponSwitch = self:GetWeapon( class )

end

net.Receive( "brawl.selectWeapon", function()

	local class = net.ReadString()

	local function doIt()
		if LocalPlayer and LocalPlayer().SelectWeapon then
			LocalPlayer():SelectWeapon( class )
		else
			timer.Simple( 0.5, doIt )
		end
	end
	doIt()

end)

hook.Add( "CreateMove", "WeaponSwitch", function( cmd )

	if not IsValid( LocalPlayer().DoWeaponSwitch ) then return end

	cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )
	if LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch then
		LocalPlayer().DoWeaponSwitch = nil
	end

end)

net.Receive( "brawl.myModel", function( len )

	brawl.myModel = net.ReadString()
	brawl.mySkin = net.ReadUInt(8)

end)

hook.Add( "InitPostEntity", "brawl.precacheModels", function()

	for _, l in pairs(brawl.config.playerModels) do
		for _, mdls in ipairs(l) do
			if istable(mdls) then
				for _, mdl in ipairs(mdls) do util.PrecacheModel(mdl) end
			else
				util.PrecacheModel(mdls)
			end
		end
	end

end)
