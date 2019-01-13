afkkick = afkkick or {}
afkkick.idleTime = 0

local blur = Material( "pp/blurscreen" )
local function blurryThingie( layers, density, alpha )
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
	end
end

surface.CreateFont( "afkkick_Title", {
	font = "Roboto Light",
	size = 96,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "afkkick_Text", {
	font = "Roboto Light",
	size = 24,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "afkkick_Timer", {
	font = "Roboto Light",
	size = 128,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "afkkick_TimerGlow", {
	font = "Roboto Light",
	size = 128,
	weight = 500,
	antialias = true,
	blursize = 12
} )

--
-- the code
--

function afkkick.init()
	if timer.Exists( "afkkick_check" ) then timer.Remove( "afkkick_check" ) end
	timer.Create( "afkkick_check", 1, 0, function()
		afkkick.idleTime = afkkick.idleTime + 1
	end)

	hook.Add( "HUDPaint", "afkkick_hud", afkkick.draw )
	hook.Add( "Think", "afkkick_think", afkkick.think )
	hook.Add( "PlayerButtonDown", "afkkick_notidle", afkkick.iamnotidle )
end

function afkkick.iamnotidle( ply, but )
	if ply == LocalPlayer() then
		afkkick.idleTime = 0
	end
end

local timeLeft, nextThink = 0, 0
function afkkick.think()
	if CurTime() < nextThink then return end

	timeLeft = math.Clamp( 300 - afkkick.idleTime, 0, math.huge )
	if LocalPlayer():GetNWBool( "SpectateOnly" ) then return end

	if timeLeft <= 0 then
		nextThink = CurTime() + 5
		RunConsoleCommand( "brawl_spectate" )
	end
end

function afkkick.draw()
	if LocalPlayer():GetNWBool( "SpectateOnly" ) then return end

	if timeLeft <= 120 then
		-- background
		blurryThingie( 10, 20, 255 )
		draw.RoundedBox( 0, 0, ScrH()/2 - 125, ScrW(), 250, Color(30,30,30,200) )

		-- info
		draw.SimpleText( "You are idle", "afkkick_Title", ScrW()/2, ScrH()/2 - 60, Color(220,220,220), 1, 1 )
		draw.SimpleText( "and will go spectating in", "afkkick_Text", ScrW()/2, ScrH()/2 - 15, Color(220,220,220), 1, 1 )

		-- timer
		if timeLeft < 60 then
			local glow = timer.TimeLeft( "afkkick_check" )
			draw.SimpleText( string.ToMinutesSeconds(timeLeft), "afkkick_TimerGlow", ScrW()/2, ScrH()/2 + 65, Color(200,15,50, 180*glow), 1, 1 )
		end

		draw.SimpleText( string.ToMinutesSeconds(timeLeft), "afkkick_Timer", ScrW()/2, ScrH()/2 + 65, Color(220,220,220), 1, 1 )
	end

	-- draw.SimpleText( afkkick.idleTime or "error", "TargetID", 10, 10, Color(255,255,255), 0, 0 )
end



afkkick.init()
