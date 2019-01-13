include('shared.lua')

ENT.hintAl = 0

function ENT:Initialize()
	--print( self.GetAttachments() )
end

function ENT:Draw()

	local pos = self:GetPos()
	local fadeIn = LocalPlayer():GetShootPos():DistToSqr( pos ) < 9000
	self.hintAl = math.Approach( self.hintAl, fadeIn and 255 or 0, FrameTime() * 1000 )

	self:DrawModel()

	if not self.weaponName then
		local data = weapons.GetStored( self:GetNWString( "WeaponClass" ) )
		self.weaponName = data and data.PrintName
	end

	local dir = LocalPlayer():GetPos() - pos
	local ang = Angle( 0, LocalPlayer():GetAngles().y - 90, 0)
	local minB, maxB = self:GetRenderBounds()
	if self.weaponName and self.hintAl > 0 then
		cam.Start3D2D( pos + Vector( 0,0,5 ), ang, 0.1 )
			draw.SimpleText( self.weaponName, "brawl.hud.large", 1, 1, Color( 0,0,0, self.hintAl ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( self.weaponName, "brawl.hud.large", 0, 0, Color( 220,220,220, self.hintAl ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
		--[[for k, v in ipairs(self.attachmentNames) do
				draw.ShadowText(v.display, baseFont, 0, v.vertPos, self:getAttachmentColor(), black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end]]
	end

end
