local hide = {
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudBattery = true,
	CHudDeathNotice = true,
	CHudGeiger = true,
	CHudHealth = true,
	CHudCrosshair = true,
	CHudDamageIndicator = true,

	CHudWeapon = true,
	CHudWeaponSelection = true,
}

function GM:HUDShouldDraw( name )

	return not hide[ name ]

end

RunConsoleCommand( "hud_draw_fixed_reticle", "0" )

local offsetID = 40
function GM:HUDDrawTargetID()

	if LocalPlayer():GetNWBool( "Spectating" ) then return end

	local tr = LocalPlayer():GetEyeTrace()
	if IsValid( tr.Entity ) and tr.Entity:IsPlayer() then
		local tgt = tr.Entity
		local col = tgt:Team() ~= 1001 and team.GetColor( tgt:Team() ) or Color( 220,220,220 )

		draw.Text({
			text = tgt:Name(),
			font = "brawl.hud.normal",
			pos = { ScrW() / 2, ScrH() / 2 + offsetID },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = col
		})

		draw.Text({
			text = tgt:GetHealthStatus(),
			font = "brawl.hud.small",
			pos = { ScrW() / 2, ScrH() / 2 + 25 + offsetID },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = col
		})
	end

end

local showScoreboard = false
function GM:ScoreboardShow() showScoreboard = true end
function GM:ScoreboardHide() showScoreboard = false end
function GM:HUDDrawScoreBoard() end

brawl.hud = {}

function brawl.hud.draw()

	if not IsValid( LocalPlayer() ) then return end

	brawl.hud.drawHitMarker()
	brawl.hud.drawLevelUp()
	brawl.hud.drawStamina()
	brawl.hud.drawAmmo()
	brawl.hud.drawScoreboard()
	brawl.hud.drawNotifications()
	brawl.hud.drawRoundOverlay()

	if LocalPlayer():GetNWBool( "Spectating" ) then
		brawl.hud.drawSpectate()
	else
		brawl.hud.drawEXP()
	end

	local mode = GetGlobalString( "brawl.mode" )
	if brawl.modes.registered[ mode ] and brawl.modes.registered[ mode ].hud then
		brawl.modes.registered[ mode ]:hud()
	end

	brawl.hud.drawDevPreview()

end
hook.Add( "HUDPaint", "brawl.hud", brawl.hud.draw )

local blur = Material( "pp/blurscreen" )
hook.Remove( "RenderScreenspaceEffects", "brawl.round.overlay" )
hook.Add( "PreDrawViewModel", "brawl.round.overlay", function()

	if not brawl.modes.overlay or not brawl.modes.overlay.outTime then return end

	if CurTime() - brawl.modes.overlay.outTime < 0 then
		local a = math.Clamp( math.TimeFraction( brawl.modes.overlay.outTime - 0.25, brawl.modes.overlay.outTime, CurTime() ), 0, 1 )

		DrawColorModify({
			[ "$pp_colour_brightness" ] = a,
			[ "$pp_colour_contrast" ] = 1.5 - a,
			[ "$pp_colour_colour" ] = 0,
		})

		cam.Start2D()
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetMaterial( blur )

			for i = 1, 3 do
				blur:SetFloat( "$blur", i * 2 )
				blur:Recompute()

				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )
			end
		cam.End2D()
	else
		local a = 1 - math.Clamp( math.TimeFraction( brawl.modes.overlay.outTime, brawl.modes.overlay.outTime + 0.75, CurTime() ), 0, 1 )
		DrawColorModify({
			[ "$pp_colour_brightness" ] = a,
			[ "$pp_colour_contrast" ] = 1 - a * 0.5,
			[ "$pp_colour_colour" ] = 1 - a,
		})
	end

end)

function brawl.hud.drawRoundOverlay()

	if not brawl.modes.overlay then return end

	if not brawl.modes.overlay.started then
		surface.PlaySound(table.Random({
		"girls-frontline/round-start.mp3",
		"girls-frontline/round-start2.mp3",
		"girls-frontline/round-start3.mp3",
		"girls-frontline/round-start4.mp3",
		"girls-frontline/round-start5.mp3",
		"girls-frontline/round-start6.mp3",
	}))
		brawl.modes.overlay.outTime = CurTime() + brawl.modes.overlay.delay
		brawl.modes.overlay.started = true
	end

	if CurTime() < brawl.modes.overlay.outTime then
		local x, y = ScrW() / 2, ScrH() / 2 - 150
		draw.Text({
			text = brawl.modes.overlay.title,
			font = "brawl.hud.large",
			pos = { x, y },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = Color( 255,255,255 )
		}) draw.Text({
			text = brawl.modes.overlay.title,
			font = "brawl.hud.large",
			pos = { x + 1, y + 1 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = Color( 0,0,0, 50 )
		})

		local x2, y2 = ScrW() / 2, ScrH() / 2 - 110
		draw.Text({
			text = brawl.modes.overlay.subtitle,
			font = "brawl.hud.normal",
			pos = { x2, y2 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = Color( 255,255,255 )
		}) draw.Text({
			text = brawl.modes.overlay.subtitle,
			font = "brawl.hud.normal",
			pos = { x2 + 1, y2 + 1 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = Color( 0,0,0, 50 )
		})
	end

	if CurTime() > brawl.modes.overlay.outTime + 2 then
		brawl.modes.overlay = nil
	end

end

function brawl.hud.drawSpectate()

	if brawl.menu.active then return end

	draw.Text({
		text = "Spectating",
		font = "brawl.hud.normal",
		pos = { ScrW() / 2, 10 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_TOP,
		color = Color( 255,255,255, 150 )
	})

	local ply = LocalPlayer():GetObserverTarget()
	if not IsValid( ply ) then return end

	draw.Text({
		text = ply:Name(),
		font = "brawl.hud.normal",
		pos = { ScrW() / 2, ScrH() - 55 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_TOP,
		color = Color( 255,255,255, 150 )
	})

	draw.Text({
		text = ply:GetHealthStatus(),
		font = "brawl.hud.small",
		pos = { ScrW() / 2, ScrH() - 30 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_TOP,
		color = Color( 255,255,255, 150 )
	})

	brawl.hud.drawStamina( ply )
	brawl.hud.drawAmmo( ply )

end

function brawl.hud.drawDevPreview()

	draw.Text({
		font = "brawl.hud.large",
		text = "Girls Frontline: Operation Binary V" .. brawl.version,
		pos = { 9, 5 },
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_TOP,
	})

	draw.Text({
		font = "brawl.hud.small",
		text = "early development preview",
		pos = { 10, 38 },
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_TOP,
	})

	for k, ply in pairs( player.GetAll() ) do
		if ply:SteamID() == "STEAM_0:0:20521653" then
			draw.Text({
				font = "brawl.hud.small",
				text = "Developer in the server,",
				pos = { 10, ScrH() - 20 },
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_BOTTOM,
				color = Color( 200,200,200, (math.sin( CurTime() ) + 1) * 100 )
			})
			draw.Text({
				font = "brawl.hud.small",
				text = "things may behave weird",
				pos = { 10, ScrH() - 5 },
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_BOTTOM,
				color = Color( 200,200,200, (math.sin( CurTime() ) + 1) * 100 )
			})
			break
		end
	end

end

local hitMarkAlpha = 0
local hitMarkSize = 30
function brawl.hud.drawHitMarker()

	hitMarkAlpha = math.Approach( hitMarkAlpha, 0, FrameTime() * 2 )

	if hitMarkAlpha > 0 then
		local center = { x = ScrW() / 2, y = ScrH() / 2 }
		surface.SetDrawColor( 255,255,255, math.Clamp( hitMarkAlpha * 255, 0, 255 ) )
		for k,v in pairs({{1,1},{1,-1},{-1,-1},{-1,1}}) do
			local p = {
				{ x = hitMarkSize * v[1], y = hitMarkSize * v[2] },
				{ x = (hitMarkSize + 1) * v[1], y = (hitMarkSize - 1) * v[2] },
				{ x = (hitMarkSize - 1) * v[1] * 0.5, y = (hitMarkSize - 1) * v[2] * 0.5 },
				{ x = (hitMarkSize + 1) * v[1] * 0.5, y = (hitMarkSize + 1) * v[2] * 0.5 },
				{ x = (hitMarkSize - 1) * v[1], y = (hitMarkSize + 1 ) * v[2] },
			}

			for k,v in pairs( p ) do
				v.x = v.x + center.x
				v.y = v.y + center.y
			end

			surface.DrawPoly( p )
		end
	end

end

hook.Add( "brawl.hit", "brawl.hud", function( data )

	if data.attacker == LocalPlayer() then
		hitMarkAlpha = hitMarkAlpha + data.damage / 30
	end

end)

local expMsgs, expAl, curXP, expHideTime = {}, 0, 0, 0
function brawl.hud.drawEXP()

	for k, msg in pairs( expMsgs ) do
		-- TODO: make msg background?
		-- surface.SetFont( "brawl.hud.normal" )
		-- local tw, th = surface.GetTextSize( "+" .. msg.val )
		-- surface.SetFont( "brawl.hud.small" )
		-- local tw2, th2 = surface.GetTextSize( msg.txt )

		-- draw.RoundedBox( 4, ScrW() / 2 - 10 - tw, ,number width,number height,table color)

		draw.Text({
			font = "brawl.hud.normal",
			text = "+" .. msg.val,
			pos = { ScrW() / 2 - 5, ScrH() - 100 + msg.y },
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 220,220,220, msg.a )
		})

		draw.Text({
			font = "brawl.hud.small",
			text = msg.txt,
			pos = { ScrW() / 2 + 5, ScrH() - 100 + msg.y },
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 220,220,220, msg.a )
		})

		msg.y = msg.y + FrameTime() * 20
		if msg.y < 60 then
			msg.a = math.Approach( msg.a, 255, FrameTime() * 500 )
		else
			msg.a = math.Approach( msg.a, 0, FrameTime() * 500 )
		end
		if msg.a <= 0 then expMsgs[ k ] = nil end

		if msg.y < 25 then break end
	end

	local tgtXP = LocalPlayer():GetXP()
	if curXP == 0 or curXP > tgtXP then curXP = tgtXP end
	if curXP ~= tgtXP then expHideTime = CurTime() + 3 end

	expAl = math.Approach( expAl, expHideTime > CurTime() and 255 or 0, FrameTime() * 500 )
	curXP = math.Approach(
		curXP, tgtXP,
		math.Clamp(
			(tgtXP - curXP) * FrameTime() * 4,
			FrameTime() * 5,
			FrameTime() * 500
		)
	)

	local nextXP = brawl.exp.calculateLevelEXP( LocalPlayer():GetLevel() + 1 )
	local w, h = 600, 8
	local x = (ScrW() - w) / 2
	local w2 = (w-2) * (curXP / nextXP)
	local y = ScrH() + 5 - h - (expAl/255) * 13
	draw.RoundedBox( h/2, x, y, w, h, Color( 100,100,100, 50 ) )
	draw.RoundedBox( (h-2)/2, x+1, y + 1, w-2, h-2, Color( 0,0,0, 200 ) )
	draw.RoundedBox( w2 >= h and (h/2) or 0, x+1, y + 1, w2 >= h and w2 or 0, h-2, Color( 220,220,220 ) )

	if expAl > 0 then
		local txtData = {}
		txtData.color = Color( 220,220,220, expAl )

		txtData.yalign = TEXT_ALIGN_BOTTOM
		-- txtData.xalign = TEXT_ALIGN_CENTER
		-- txtData.font = "brawl.menu.semilarge"
		-- txtData.text = "Level " .. LocalPlayer():GetLevel()
		-- txtData.pos = { x + w / 2, h + 15 }
		-- draw.Text( txtData )

		txtData.font = "brawl.menu.normal"

		txtData.xalign = TEXT_ALIGN_LEFT
		txtData.text = math.floor( curXP ) .. "XP"
		txtData.pos = { x + 2, y - h }
		draw.Text( txtData )

		txtData.xalign = TEXT_ALIGN_RIGHT
		txtData.text = nextXP .. "XP"
		txtData.pos = { x + w-2, y - h }
		draw.Text( txtData )
	end

end

net.Receive( "brawl.exp.add", function( len )

	table.insert( expMsgs, {
		val = net.ReadUInt( 16 ),
		txt = net.ReadString(),
		a = 0,
		y = 0
	})

end)

local lUpStart, lUpAl, lUpTxt = 0, 0, "level name here"
function brawl.hud.drawLevelUp()

	if CurTime() - lUpStart < 5 then
		lUpAl = math.Approach( lUpAl, 255, FrameTime() * 255 )
	else
		lUpAl = math.Approach( lUpAl, 0, FrameTime() * 100 )
	end

	if lUpAl <= 0 then return end
	draw.Text({
		font = "brawl.hud.large",
		text = "Level up!",
		pos = { ScrW() / 2, ScrH() - 40 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_BOTTOM,
		color = Color( 220,220,220, lUpAl )
	})

	draw.Text({
		font = "brawl.hud.normal",
		text = lUpTxt,
		pos = { ScrW() / 2, ScrH() - 40 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_TOP,
		color = Color( 220,220,220, lUpAl )
	})

end

net.Receive( "brawl.exp.levelUp", function( len )

	lUpStart = CurTime()
	lUpTxt = net.ReadString()

	timer.Simple( 0.2, function()
		surface.PlaySound( "girls-frontline/exp-levelup.mp3" )
	end)

end)

local stAlpha = 255
local stTgtAlpha = 0
local stSmooth = 100
local stFadeFrom
function brawl.hud.drawStamina( ply )

	if brawl.menu.active then return end

	ply = ply or LocalPlayer()

	if not ply:Alive() then return end
	local st = ply:GetStamina()

	if stAlpha == 255 and not stFadeFrom then stFadeFrom = CurTime() + 2 end
	if st ~= 100 then
		stTgtAlpha = 255
		stFadeFrom = nil
	elseif stFadeFrom and CurTime() > stFadeFrom then
		stTgtAlpha = 0
	end

	stSmooth = math.Approach( stSmooth, st, 25 * FrameTime() * (stTgtAlpha > stAlpha and 1 or -1) )
	if math.abs( stSmooth - st ) > 5 then stSmooth = st end

	stAlpha = math.Approach( stAlpha, stTgtAlpha, 300 * FrameTime() * (stTgtAlpha > stAlpha and 1 or -1) )


	h = 8
	local w = stSmooth / 100 * 148
	local colcomp = math.Clamp( w * 2, 0, 100 )
	draw.RoundedBox( h/2, ScrW() - 173, ScrH() - 57, 150, h, Color( 100, colcomp, colcomp, stAlpha / 255 * 50 ) )
	draw.RoundedBox( (h-2)/2, ScrW() - 172, ScrH() - 56, 148, h-2, Color( 0,0,0, stAlpha / 255 * 200  ) )
	draw.RoundedBox( w >= h and ((h-2)/2) or 0, ScrW() - 172, ScrH() - 56, w >= h and w or 0, h-2, Color( 220,220,220, stAlpha ) )

end

local lastAmmo, lastx, ammoAl = 0, 0, 1
function brawl.hud.drawAmmo( ply )

	if brawl.menu.active then return end

	ply = ply or LocalPlayer()

	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) then
		local clip1 = wep:Clip1()
		local maxClip1 = wep.Primary.ClipSize_Orig or wep:GetMaxClip1()

		if lastAmmo ~= clip1 then lastChange = CurTime() end
		if maxClip1 < 1 then return end

		local fadeOut = (CurTime() - lastChange > 2) and (clip1 >= maxClip1)
		ammoAl = math.Approach( ammoAl, fadeOut and 0 or 1, (fadeOut and 1 or 4) * FrameTime() )

		local x1, w1 = ScrW() - math.min( maxClip1, 41 ) * 7 - 28, math.min( maxClip1, 41 ) * 7 + 5
		local x2 = x1 + 1
		if clip1 > maxClip1 and clip1 <= 41 then
			w1 = w1 + 9
			x1 = x1 - 9
		end

		if maxClip1 <= 40 then
			draw.RoundedBox( 5, x1, ScrH() - 44, w1, 28, Color( 100,100,100, 50 * ammoAl ) )
			draw.RoundedBox( 4, x2, ScrH() - 43, math.min( maxClip1, 41 ) * 7 + 3, 26, Color( 0,0,0, 200 * ammoAl ) )
		else
			x1 = ScrW() - 41 * 7 - 15
			draw.RoundedBoxEx( 5, x1, ScrH() - 44, 41 * 7 - 7, 28, Color( 100,100,100, 50 * ammoAl ), false, true, false, true )
			draw.RoundedBoxEx( 4, x1, ScrH() - 43, 41 * 7 - 8, 26, Color( 0,0,0, 200 * ammoAl ), false, true, false, true )
			for i = 1,10 do
				draw.RoundedBox( 0, x1 - i, ScrH() - 44, 1, 28, Color( 100,100,100, 50 * (ammoAl - i / 10) ) )
				draw.RoundedBox( 0, x1 - i, ScrH() - 43, 1, 26, Color( 0,0,0, 200 * (ammoAl - i / 10) ) )
			end
		end

		surface.SetDrawColor( 255,255,255, 150 * ammoAl )
		draw.NoTexture()
		local x2
		for i = 1, math.min( clip1, 41 ) do
			if clip1 > maxClip1 and i == clip1 then
				x2 = ScrW() - (7 * i) - 23
			else
				x2 = ScrW() - (7 * i) - 20
			end

			if i == 41 then surface.SetDrawColor( 255,255,255, 10 * ammoAl ) end
			if i == 40 then surface.SetDrawColor( 255,255,255, 35 * ammoAl ) end
			surface.DrawPoly({
				{ x = x2 - 2, y = ScrH() - 40 },
				{ x = x2, y = ScrH() - 30 },
				{ x = x2, y = ScrH() - 20 },
				{ x = x2 - 4, y = ScrH() - 20 },
				{ x = x2 - 4, y = ScrH() - 30 },
			})
		end

		if clip1 < lastAmmo then
			surface.SetDrawColor( 255,0,0, 255 )
			surface.DrawPoly({
				{ x = lastx - 2, y = ScrH() - 40 },
				{ x = lastx, y = ScrH() - 30 },
				{ x = lastx, y = ScrH() - 20 },
				{ x = lastx - 4, y = ScrH() - 20 },
				{ x = lastx - 4, y = ScrH() - 30 },
			})
		end

		lastx = x2
		lastAmmo = clip1
	end

end

local sbAlpha = 0
function brawl.hud.drawScoreboard()

	local mode = brawl.modes.registered[ GetGlobalString( "brawl.mode" ) ]
	sbAlpha = math.Approach( sbAlpha, showScoreboard and 255 or 0, FrameTime() * 1000 )

	if sbAlpha == 0 then return end
	if mode.teams then
		local t = {}
		local total = 0
		for k, ply in pairs( player.GetAll() ) do
			local tID = ply:Team()
			t[ tID ] = t[ tID ] or {
				score = team.GetScore( tID ),
				plys = {},
				name = "Team " .. team.GetName( tID )
			}
			t[ tID ].plys[ ply ] = {
				score = ply:Frags(),
				deaths = ply:Deaths()
			}
			total = total + 1
		end
		brawl.hud.drawTeamScoreboard( t, mode, total )
	else
		local plys = {}
		for k, ply in pairs( player.GetAll() ) do
			local score = ply:GetScore()
			plys[ ply ] = {
				score = score ~= -1 and score or ply:Frags(),
				deaths = ply:Deaths()
			}
		end
		brawl.hud.drawFFAScoreboard( plys, mode )
	end

end

function brawl.hud.drawTeamScoreboard( teams, mode, total )

	local y = ScrH() / 2 - table.Count( teams ) * 25 - total * 20
	local txtData = {
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_TOP,
		color = Color( 255,255,255, sbAlpha )
	}

	if mode ~= "" then
		txtData.text = mode.name
		txtData.font = "brawl.hud.scoreboard.large"
		txtData.pos = { ScrW() / 2, y - 30 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		txtData.text = GetGlobalString( "brawl.mode.agenda" )
		txtData.font = "brawl.hud.small"
		txtData.pos = { ScrW() / 2, y }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )
	end

	y = y + 30

	for tID, data in SortedPairsByMemberValue( teams, "score", true ) do
		local tName = team.GetName( tID )
		local tCol = team.GetColor( tID )
		tCol.a = sbAlpha

		txtData.yalign = TEXT_ALIGN_CENTER
		txtData.font = "brawl.hud.scoreboard.normal"
		txtData.color = tCol

		txtData.xalign = TEXT_ALIGN_CENTER
			txtData.text = "Level"
			txtData.pos = { ScrW() / 2 - 275, y + 15 }
			draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		txtData.xalign = TEXT_ALIGN_LEFT
			txtData.text = "Name"
			txtData.pos = { ScrW() / 2 - 240, y + 15 }
			draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		txtData.xalign = TEXT_ALIGN_CENTER

			txtData.text = "Score"
			txtData.pos = { ScrW() / 2 + 210, y + 15 }
			draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

			-- txtData.text = "Deaths"
			-- txtData.pos = { ScrW() / 2 + 210, y + 15 }
			-- draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

			txtData.text = "Ping"
			txtData.pos = { ScrW() / 2 + 275, y + 15 }
			draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		y = y + 30

		for ply, data in SortedPairsByMemberValue( data.plys, "score", true ) do
			local col = Color( 255,255,255, sbAlpha )
			if not ply:Alive() then
				col.r = col.r * 0.5
				col.g = col.g * 0.5
				col.b = col.b * 0.5
			end
			txtData.color = col

			local bgCol = table.Copy( tCol )
			bgCol.a = sbAlpha / 255 * (ply:Alive() and 50 or 15)
			draw.RoundedBox( 5, ScrW() / 2 - 301, y, 602, 32, bgCol )
			draw.RoundedBox( 4, ScrW() / 2 - 300, y+1, 600, 30, Color( 0, 0, 0, sbAlpha / 255 * (ply:Alive() and 200 or 100) ) )

			txtData.xalign = TEXT_ALIGN_CENTER
			txtData.text = ply:GetLevel()
			txtData.font = "brawl.hud.scoreboard.normal"
			txtData.pos = { ScrW() / 2 - 275, y + 15 }
			draw.Text( txtData )

			txtData.xalign = TEXT_ALIGN_LEFT

			txtData.text = ply:Name()
			txtData.font = "brawl.hud.scoreboard.normal"
			txtData.pos = { ScrW() / 2 - 240, y + 15 }
			draw.Text( txtData )

			txtData.xalign = TEXT_ALIGN_CENTER

			txtData.text = data.score
			txtData.font = "brawl.hud.scoreboard.normal"
			txtData.pos = { ScrW() / 2 + 210, y + 15 }
			draw.Text( txtData )

			-- txtData.text = data.deaths
			-- txtData.font = "brawl.hud.scoreboard.normal"
			-- txtData.pos = { ScrW() / 2 + 210, y + 15 }
			-- draw.Text( txtData )

			txtData.text = ply:Ping()
			txtData.font = "brawl.hud.scoreboard.normal"
			txtData.pos = { ScrW() / 2 + 275, y + 15 }
			draw.Text( txtData )

			y = y + 40
		end

		txtData.font = "brawl.hud.scoreboard.large"
		txtData.text = data.score
		txtData.pos = { ScrW() / 2 - 320, y - table.Count(data.plys) * 20 - 5 }
		txtData.xalign = TEXT_ALIGN_RIGHT
		txtData.color = tCol
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )
	end

	txtData.color = Color( 255,255,255, sbAlpha )
	txtData.text = "Round #" .. GetGlobalInt( "brawl.Rounds" )
	txtData.pos = { ScrW() / 2, y + 10 }
	txtData.xalign = TEXT_ALIGN_CENTER
	txtData.yalign = TEXT_ALIGN_TOP
	draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

end

function brawl.hud.drawFFAScoreboard( plys, mode )

	local y = ScrH() / 2 - table.Count( plys ) * 20
	local txtData = {
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_TOP,
		color = Color( 255,255,255, sbAlpha )
	}

	if mode ~= "" then
		txtData.text = mode.name
		txtData.font = "brawl.hud.scoreboard.large"
		txtData.pos = { ScrW() / 2, y - 50 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		txtData.text = GetGlobalString( "brawl.mode.agenda" )
		txtData.font = "brawl.hud.small"
		txtData.pos = { ScrW() / 2, y - 20 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )
	end

	txtData.yalign = TEXT_ALIGN_CENTER
	txtData.font = "brawl.hud.scoreboard.normal"

	txtData.xalign = TEXT_ALIGN_CENTER
		txtData.text = "Level"
		txtData.pos = { ScrW() / 2 - 275, y + 15 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

	txtData.xalign = TEXT_ALIGN_LEFT
		txtData.text = "Name"
		txtData.pos = { ScrW() / 2 - 240, y + 15 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

	txtData.xalign = TEXT_ALIGN_CENTER

		txtData.text = "Score"
		txtData.pos = { ScrW() / 2 + 210, y + 15 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		-- txtData.text = "Deaths"
		-- txtData.pos = { ScrW() / 2 + 210, y + 15 }
		-- draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

		txtData.text = "Ping"
		txtData.pos = { ScrW() / 2 + 275, y + 15 }
		draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

	y = y + 30

	for ply, data in SortedPairsByMemberValue( plys, "score", true ) do
		local col = ply:Team() ~= 1001 and team.GetColor( ply:Team() ) or Color( 255,255,255 )
		col.a = sbAlpha

		if not ply:Alive() then
			col.r = col.r * 0.5
			col.g = col.g * 0.5
			col.b = col.b * 0.5
		end

		draw.RoundedBox( 5, ScrW() / 2 - 301, y, 602, 32, Color( 100, 100, 100, sbAlpha / 255 * 50 ) )
		draw.RoundedBox( 4, ScrW() / 2 - 300, y+1, 600, 30, Color( 0, 0, 0, sbAlpha / 255 * (ply:Alive() and 200 or 100) ) )

		txtData.yalign = TEXT_ALIGN_CENTER

		txtData.xalign = TEXT_ALIGN_CENTER
		txtData.text = ply:GetLevel()
		txtData.font = "brawl.hud.scoreboard.normal"
		txtData.pos = { ScrW() / 2 - 275, y + 15 }
		draw.Text( txtData )

		txtData.xalign = TEXT_ALIGN_LEFT

		txtData.text = ply:Name()
		txtData.font = "brawl.hud.scoreboard.normal"
		txtData.pos = { ScrW() / 2 - 240, y + 15 }
		draw.Text( txtData )

		txtData.xalign = TEXT_ALIGN_CENTER

		txtData.text = data.score
		txtData.font = "brawl.hud.scoreboard.normal"
		txtData.pos = { ScrW() / 2 + 210, y + 15 }
		draw.Text( txtData )

		-- txtData.text = data.deaths
		-- txtData.font = "brawl.hud.scoreboard.normal"
		-- txtData.pos = { ScrW() / 2 + 210, y + 15 }
		-- draw.Text( txtData )

		txtData.text = ply:Ping()
		txtData.font = "brawl.hud.scoreboard.normal"
		txtData.pos = { ScrW() / 2 + 275, y + 15 }
		draw.Text( txtData )

		y = y + 40
	end

	txtData.color = Color( 255,255,255, sbAlpha )
	txtData.text = "Round #" .. GetGlobalInt( "brawl.Rounds" )
	txtData.pos = { ScrW() / 2, y + 10 }
	txtData.yalign = TEXT_ALIGN_TOP
	draw.TextShadow( txtData, 1, sbAlpha / 255 * 120 )

end

local nColors = {
	join = Color( 100,200,100 ),
	leave = Color( 200,100,100 ),
	error = Color( 200,100,100 ),
	other = Color( 200,200,100 ),
}

brawl.hud.notifications = {}
local notificationW = 200
function brawl.hud.drawNotifications()

	local curY = 0
	for k1, v in pairs( brawl.hud.notifications ) do
		if CurTime() > v.removeTime then
			table.remove( brawl.hud.notifications, k1 )
		else
			local w, h = v.text:GetWidth(), v.text:GetHeight()
			local al = 1 - math.TimeFraction( v.removeTime - 1, v.removeTime, CurTime() )
			al = math.pow( math.Clamp( al, 0, 1 ), 2 )

			local offset = 1 - math.TimeFraction( v.addTime, v.addTime + 0.5, CurTime() )
			offset = math.pow( math.Clamp( offset, 0, 1 ), 2 ) * (-200)

			local col = Color( 100,100,100 )
			if nColors[ v.type ] then col = nColors[ v.type ] end
			col.a = 50 * al

			draw.RoundedBox( 5, offset + 10, 70 + curY, w + 20, h + 20, col )
			draw.RoundedBox( 4, offset + 11, 71 + curY, w + 18, h + 20 - 2, Color( 0,0,0, 200 * al ) )

			v.text:Draw( offset + 20, 80 + curY, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 255 * al )

			curY = curY + (h + 25) * al
		end

	end

end

function brawl.hud.addNotification( data, t )

	table.insert(brawl.hud.notifications, {
		text = markup.Parse( string.composeMarkup( {font = "brawl.hud.notification"}, unpack(data) ), notificationW - 20 ),
		type = t,
		addTime = CurTime(),
		removeTime = CurTime() + 10
	})

	MsgC( "NOTIFICATION: ", unpack(data) )
	Msg( "\n" ) -- I have no idea why I can't put it as last arg in function above

	if not IsValid( LocalPlayer() ) then return end
	LocalPlayer():EmitSound( "cw/selector.wav" )

end

net.Receive( "brawl.hit", function( len )

	local data = net.ReadTable()
	hook.Run( "brawl.hit", data )

end)

net.Receive( "brawl.killfeed", function( len )

	local data = net.ReadTable()
	if not data.victim:IsPlayer() then return end

	local important = false

	local killer = data.attacker:IsPlayer() and data.attacker:Name() or "World"
	if data.attacker == LocalPlayer() then
		killer = "You"
		important = true
	end
	local victim = data.victim:Name()
	if data.victim == LocalPlayer() then
		victim = "you"
		important = true
	end
	local killerCol = data.attacker:IsPlayer() and data.attacker:GetTeamColor() or color_white
	local victimCol = data.victim:GetTeamColor() or color_white
	local wep = data.inflictor or data.attacker or Entity(0)
	if IsValid( wep ) and wep:GetClass() == "player" then
		local awep = data.inflictor:GetActiveWeapon()
		wep = IsValid( awep ) and awep
	end
	wepName = IsValid( wep ) and (wep.PrintName or wep:GetClass()) or "something"

	if data.attacker ~= data.victim then
		brawl.hud.addNotification({
			killerCol, killer,
			color_white, " killed ",
			victimCol, victim,
			color_white, " with ",
			wepName
		}, important and "other" or nil)
	else
		brawl.hud.addNotification({
			killerCol, killer,
			color_white, " committed suicide"
		}, important and "other" or nil)
	end

end)

net.Receive( "brawl.notify", function( len, ply )

	local d = net.ReadTable()
	brawl.hud.addNotification( d.data, d.type )

end)
