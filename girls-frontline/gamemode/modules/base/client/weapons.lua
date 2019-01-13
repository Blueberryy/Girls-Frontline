local cats = {
	[1] = {
		name = "melee",
		icon = Material( "icons/melee.png", "noclamp smooth" ),
		anim = 0,
	},
	[2] = {
		name = "secondary",
		icon = Material( "icons/secondary.png", "noclamp smooth" ),
		anim = 0,
	},
	[3] = {
		name = "primary",
		icon = Material( "icons/primary.png", "noclamp smooth" ),
		anim = 0,
	},
	[4] = {
		name = "extra",
		icon = Material( "icons/extra.png", "noclamp smooth" ),
		anim = 0,
	},
}

if IsValid( brawl.weaponDrawer ) then brawl.weaponDrawer:Remove() end

brawl.weaponDrawer = vgui.Create( "DPanel" )
brawl.weaponDrawer:SetSize( 400, 400 )
brawl.weaponDrawer:Center()
brawl.weaponDrawer:SetMouseInputEnabled( false )
brawl.weaponDrawer:SetKeyboardInputEnabled( false )

brawl.weaponDrawer.al = 0
brawl.weaponDrawer.mx = 0
brawl.weaponDrawer.my = 0
brawl.weaponDrawer.Paint = function( self, w, h )

	local st = ease.quadOut( self.al, 0, 1, 1 )

	draw.NoTexture()
	surface.SetDrawColor( 35,35,35, st * 150)

	if st > 0 then
		local selected = 0
		if brawl.weaponDrawer.mx ~= 0 or brawl.weaponDrawer.my ~= 0 then
			local ang = math.atan2( brawl.weaponDrawer.my, brawl.weaponDrawer.mx ) / math.pi + 1.25
			if ang < 0.5 or ang > 2 then
				selected = 2
			elseif ang < 1 then
				selected = 3
			elseif ang < 1.5 then
				selected = 4
			else
				selected = 1
			end
		end
		self.selected = selected

		local arcW = 100
		for i = 1, 4 do
			local wep, bgcol, wcol, gap = LocalPlayer():GetWeaponByCategory( cats[i].name )
			if wep then
				local st2 = cats[i].anim
				bgcol = Color( 35 + 35 * st2, 35 + 55 * st2, 35 + 85 * st2, 150 * st )
				wcol = Color( 180 + 75 * st2, 180 + 75 * st2, 180 + 75 * st2, 100 * st * st )
				gap = 5 - 3 * st2

				if i == selected then
					draw.SimpleText(
						wep.PrintName, "brawl.hud.normal", 201, 201,
						Color( 0,0,0, 50 * st ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
					)
					draw.SimpleText(
						wep.PrintName, "brawl.hud.normal", 200, 200,
						Color( 220,220,220, 255 * st ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
					)
				end
			else
				bgcol = Color( 80,80,80, 50 * st )
				wcol = Color( 100,100,100, 50 * st * st )
				gap = 5
			end

			local ang2 = math.pi / 2 * i - math.pi / 4
			local center = {
				x = 200 + (i == 2 and -1 or i == 4 and 1 or 0) * gap,
				y = 200 + (i == 3 and -1 or i == 1 and 1 or 0) * gap
			}

			draw.NoTexture()
			surface.SetDrawColor( bgcol.r, bgcol.g, bgcol.b, bgcol.a )
			local segs, p = 20, {}
			for i2 = 0, segs do
				p[i2] = -i2 / segs * math.pi / 2 - ang2
			end
			for i2 = 1, segs do
				local r1, r2 = (200 - gap) * st, math.max((200 - gap) * st - arcW, 0)
				local v1, v2 = p[i2 - 1], p[i2]
				local c1, c2 = math.cos( v1 ), math.cos( v2 )
				local s1, s2 = math.sin( v1 ), math.sin( v2 )
				surface.DrawPoly{
					{ x = center.x + c1 * r2, y = center.y - s1 * r2 },
					{ x = center.x + c1 * r1, y = center.y - s1 * r1 },
					{ x = center.x + c2 * r1, y = center.y - s2 * r1 },
					{ x = center.x + c2 * r2, y = center.y - s2 * r2 },
				}
			end

			local iconSize = 64 + st * 64
			surface.SetMaterial( cats[i].icon )
			surface.SetDrawColor( wcol.r, wcol.g, wcol.b, wcol.a )
			surface.DrawTexturedRect(
				200 - iconSize / 2 + (i == 2 and -1 or i == 4 and 1 or 0) * 150 * st,
				200 - iconSize / 2 + (i == 3 and -1 or i == 1 and 1 or 0) * 150 * st,
				iconSize,
				iconSize
			)
		end
	end

end
brawl.weaponDrawer.Think = function( self )

	self.al = math.Approach( self.al, self.active and 1 or 0, FrameTime() / 0.3 )
	for i = 1, 4 do
		if self.selected == i and brawl.weaponDrawer.active then
			cats[ i ].anim = math.Approach( cats[ i ].anim, 1, FrameTime() / 0.1 )
		else
			cats[ i ].anim = math.Approach( cats[ i ].anim, 0, FrameTime() / 0.3 )
		end
	end

	if self.closeTime and self.closeTime < CurTime() then
		self.active = false
		self.closeTime = nil
	end

end

local blur = Material( "pp/blurscreen" )
hook.Add( "RenderScreenspaceEffects", "brawl.weapons", function()

	local state = brawl.weaponDrawer.al
	local a = 1 - math.pow( 1 - state, 2 )

	if a > 0 then
		DrawColorModify({
			[ "$pp_colour_brightness" ] = 0,
			[ "$pp_colour_contrast" ] = 1 + 0.5 * a,
			[ "$pp_colour_colour" ] = 1 - a,
		})

		surface.SetDrawColor( 255, 255, 255, a * 255 )
		surface.SetMaterial( blur )

		for i = 1, 3 do
			blur:SetFloat( "$blur", a * i * 2 )
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )
		end
	end

end)

hook.Add( "InputMouseApply", "brawl.weapons", function( cmd, x, y, ang )

	if brawl.weaponDrawer.holding then
		if x ~= 0 or y ~= 0 then
			local v = Vector( brawl.weaponDrawer.mx + x, brawl.weaponDrawer.my + y, 0 )
			if v:LengthSqr() > 10000 then
				v = v:GetNormalized() * 100
			end

			brawl.weaponDrawer.mx = v.x
			brawl.weaponDrawer.my = v.y
		end

		cmd:SetMouseX( 0 )
		cmd:SetMouseY( 0 )

		return true
	end

end)


local function dropSelectedWeapon()
	if brawl.weaponDrawer.selected ~= 0 then
		local cat = cats[ brawl.weaponDrawer.selected ].name
		net.Start( "brawl.dropWeapon" )
		net.WriteString( cat )
		net.SendToServer()
		--LocalPlayer():DropWeapon( LocalPlayer():GetWeaponByCategory( cat ))
	end
end

hook.Add( "CreateMove", "brawl.weapons", function( cmd )

	if brawl.weaponDrawer.holding then
		if cmd:KeyDown( IN_ATTACK2 ) then
			dropSelectedWeapon()
		end
		cmd:RemoveKey( IN_ATTACK )
		cmd:RemoveKey( IN_ATTACK2 )
	end

end)

concommand.Add( "+menu", function()

	if not LocalPlayer():Alive() then return end

	brawl.weaponDrawer.active = true
	brawl.weaponDrawer.holding = true
	brawl.weaponDrawer.closeTime = nil
	brawl.weaponDrawer.mx = 0
	brawl.weaponDrawer.my = 0

end)

concommand.Add( "-menu", function()

	if not brawl.weaponDrawer.active then return end
	brawl.weaponDrawer.active = false
	brawl.weaponDrawer.holding = false

	if brawl.weaponDrawer.selected ~= 0 then
		local cat = cats[ brawl.weaponDrawer.selected ].name
		LocalPlayer():SelectWeaponByCategory( cat )
	end

end)

local function switchWeapon( delta )

	if not LocalPlayer() or table.Count( LocalPlayer():GetWeapons() ) < 2 then return end
	local wep, curCat = LocalPlayer():GetActiveWeapon(), 0
	for i = 1, 4 do
		if wep:GetNWString( "WeaponCategory" ) == cats[i].name then
			curCat = i
		end
	end

	newCat = curCat + delta
	while true do
		if newCat > 4 then newCat = 1 end
		if newCat < 1 then newCat = 4 end

		local wep2 = LocalPlayer():GetWeaponByCategory( cats[ newCat ].name )
		if not wep2 then
			newCat = newCat + delta
		else
			LocalPlayer():SelectWeapon( wep2:GetClass() )
			break
		end
	end

end

local binds = {
	invnext = function()
		switchWeapon( 1 )
	end,
	invprev = function()
		switchWeapon( -1 )
	end,
	slot1 = function()
		LocalPlayer():SelectWeaponByCategory( cats[ 1 ].name )
		brawl.weaponDrawer.active = true
		brawl.weaponDrawer.closeTime = CurTime() + 0.5
		brawl.weaponDrawer.my = 10
		brawl.weaponDrawer.mx = 0
	end,
	slot2 = function()
		LocalPlayer():SelectWeaponByCategory( cats[ 2 ].name )
		brawl.weaponDrawer.active = true
		brawl.weaponDrawer.closeTime = CurTime() + 0.5
		brawl.weaponDrawer.my = 0
		brawl.weaponDrawer.mx = -10
	end,
	slot3 = function()
		LocalPlayer():SelectWeaponByCategory( cats[ 3 ].name )
		brawl.weaponDrawer.active = true
		brawl.weaponDrawer.closeTime = CurTime() + 0.5
		brawl.weaponDrawer.my = -10
		brawl.weaponDrawer.mx = 0
	end,
	slot4 = function()
		LocalPlayer():SelectWeaponByCategory( cats[ 4 ].name )
		brawl.weaponDrawer.active = true
		brawl.weaponDrawer.closeTime = CurTime() + 0.5
		brawl.weaponDrawer.my = 0
		brawl.weaponDrawer.mx = 10
	end,
}

hook.Add( "PlayerBindPress", "octorp.mobile", function( ply, bind, pressed )

	local wep = ply:GetActiveWeapon()
	if not (wep and wep.dt and wep.dt.State == CW_CUSTOMIZE) then
		if binds[ bind ] and pressed then
			binds[ bind ]()
		end
	end

end)
