if brawl.menu and IsValid( brawl.menu.pnl ) then brawl.menu.pnl:Remove() end

brawl.menu = {}

local fonts = {
	tabButton = "brawl.menu.normal",
	menuButton = "brawl.menu.semismall",
	headers = "brawl.menu.semilarge",
	menuText = "brawl.menu.semismall",
}

local function tabCurGame()

	local pnl = vgui.Create( "DPanel", brawl.menu.pnl )
	pnl.Paint = brawl.paint.tabPanel
	pnl:Dock( FILL )
	local tab = brawl.menu.pnl:AddSheet( "Game", pnl )
	tab.Tab.Paint = brawl.paint.tabButton
	tab.Tab:SetFont( fonts.tabButton )

	-- build right menu
	local menu = brawl.DPanel{
		parent = pnl,
		pos = { 500, 0 },
		size = { 150, 600 },
		paint = brawl.paint.menuPanel
	}

	local y = 0
	local function button( txt, callback )
		brawl.DButton{
			parent = menu,
			pos = { 0, y },
			size = { 150, 40 },
			txt = "",
			data = { txt = txt, font = fonts.menuButton },
			onselect = callback,
			paint = brawl.paint.menuButton
		}
		y = y + 40
	end

	button( "Game options", function( self )
		gui.ActivateGameUI()
		RunConsoleCommand( "gamemenucommand", "openoptionsdialog" )
	end)

	local mode = GetGlobalString( "brawl.mode" )
	if brawl.modes.registered[ mode ].teams then
		button( "Change team", function( self )
			RunConsoleCommand( "brawl_switchteam" )
		end)
	end

	button( "Spectate", function( self )
		if LocalPlayer():GetNWBool( "SpectateOnly" ) then
			self.txt = "Spectate"
		else
			self.txt = "Join game"
		end
		RunConsoleCommand( "brawl_spectate" )
	end)

	if LocalPlayer():IsSuperAdmin() then
		button( "Changelog", function( self )
			RunConsoleCommand( "changelog" )
		end)
	end

	button( "Reconnect", function( self )
		RunConsoleCommand( "retry" )
	end)

	button( "Disconnect", function( self )
		RunConsoleCommand( "disconnect" )
	end)

	-- button( "Quit game", function( self )
	--	 RunConsoleCommand( "gamemenucommand", "quit" )
	-- end)

	-- currently playing
	local lCurPlaying = brawl.DLabel{
		parent = pnl,
		txt = "Currently playing",
		font = fonts.headers,
		pos = { 20, 15 },
		size = { 460, 30 },
		col = Color( 220,220,220 ),
		align = 4,
	}

	local gameInfo = vgui.Create( "DPanel", pnl )
	gameInfo:SetSize( 460, 130 )
	gameInfo:SetPos( 20, 50 )
	gameInfo.Paint = brawl.paint.gameInfoPanel

	local url = brawl.config.maps[ string.lower(game.GetMap()) ].img
	local img = vgui.Create( "DHTML", gameInfo )
	img:SetSize( 128, 128 )
	img:SetPos( 1, 1 )
	img:SetHTML([[<style>
		body {
			background-image: url(]] .. url .. [[);
			background-size: auto 100%;
			background-position: center;
		}
	</style>
	<body></body>]])

	-- currently playing
	local lDevNoteHeader = brawl.DLabel{
		parent = pnl,
		txt = "A note from Ruko",
		font = fonts.headers,
		pos = { 20, 200 },
		size = { 460, 30 },
		col = Color( 220,220,220 ),
		align = 4,
	}

	local lDevNote = brawl.DLabel{
		parent = pnl,
		txt =
[[Hello and welcome!

First of all I'm very glad that you are helping me test this gamemode. However I should warn you that it is being actively developed so things may change vastly over time. This is the reason to periodically erase our database. Thus we hope you understand if you lose experience, levels and items obtained through the game. Also, sometimes things may be totally broken because we develop something new so expect many bugs while playing here.

Anyway, enjoy Girls Frontline: Operation Binary!]],
		font = fonts.menuText,
		pos = { 20, 235 },
		size = { 460, 200 },
		col = Color( 220,220,220 ),
		align = 7,
	}
	lDevNote:SetWrap( true )

end

local function tabSoldier()

	local pnl = vgui.Create( "DPanel", brawl.menu.pnl )
	pnl.Paint = brawl.paint.tabPanel
	pnl:Dock( FILL )
	local tab = brawl.menu.pnl:AddSheet( "Soldier", pnl )
	tab.Tab.Paint = brawl.paint.tabButton
	tab.Tab:SetFont( fonts.tabButton )

	-- build right menu
	local menu = brawl.DPanel{
		parent = pnl,
		pos = { 500, 0 },
		size = { 150, 600 },
		paint = brawl.paint.menuPanel
	}

	local y = 0
	local function button( txt, callback )
		brawl.DButton{
			parent = menu,
			pos = { 0, y },
			size = { 150, 40 },
			txt = "",
			data = { txt = txt, font = fonts.menuButton },
			onselect = callback,
			paint = brawl.paint.menuButton
		}
		y = y + 40
	end

	local mdl = LocalPlayer():GetModel()
	if mdl then
		pnl.view = vgui.Create( "DModelPanel", pnl )
		pnl.view:SetSize( 400, 650 )
		pnl.view:SetModel( brawl.myModel )
		pnl.view.Entity:SetSkin( brawl.mySkin )
		local anim = pnl.view.Entity:LookupSequence( "sit_zen" )
		pnl.view.Entity:SetSequence( anim )
		-- PrintTable( pnl.view.Entity:GetSequenceList() )
		-- pnl.view.Entity:
		pnl.view:SetFOV( 25 )
		pnl.view:SetCursor( "none" )
		pnl.view.LayoutEntity = function( self, ent )
			ent:SetPos( Vector(-1,0,20) )
			ent:SetAngles( Angle(0,45,0) )

			if ent:GetCycle() == 1 then
				ent:SetCycle( 0 )
			end

			self:RunAnimation()
		end
	end

	local curLevel = vgui.Create( "DPanel", pnl )
	curLevel:SetSize( 460, 80 )
	curLevel:SetPos( 20, 20 )
	curLevel.Paint = brawl.paint.currentLevelPanel

end

local function tabOptions()

	local pnl = vgui.Create( "DPanel", brawl.menu.pnl )
	pnl.Paint = brawl.paint.tabPanel
	pnl:Dock( FILL )
	local tab = brawl.menu.pnl:AddSheet( "Options", pnl )
	tab.Tab.Paint = brawl.paint.tabButton
	tab.Tab:SetFont( fonts.tabButton )

end

local function tabCharacters()

	local pnl = vgui.Create( "DPanel", brawl.menu.pnl )
	pnl.Paint = brawl.paint.tabPanel
	pnl:Dock( FILL )
	local tab = brawl.menu.pnl:AddSheet( "T-Dolls", pnl )
	tab.Tab.Paint = brawl.paint.tabButton
	tab.Tab:SetFont( fonts.tabButton )
	
	-- build right menu
	local menu = brawl.DPanel{
		parent = pnl,
		pos = { 500, 0 },
		size = { 150, 600 },
		paint = brawl.paint.menuPanel
	}

	local y = 0
	local function button( txt, callback )
		brawl.DButton{
			parent = menu,
			pos = { 0, y },
			size = { 150, 40 },
			txt = "",
			data = { txt = txt, font = fonts.menuButton },
			onselect = callback,
			paint = brawl.paint.menuButton
		}
		y = y + 40
	end

end

function brawl.menu.toggle( ply, cmd, args, argStr )

	if not IsValid( brawl.menu.pnl ) then
		brawl.menu.pnl = vgui.Create( "SideMenu" )
		local menu = brawl.menu.pnl
		menu.Paint = brawl.paint.tabSheet
		menu:SetSize( 800, 600 )
		menu:SetFadeTime( 0.2 )
		menu:Center()
		menu:MakePopup()

		tabCurGame()
		tabSoldier()
		tabOptions()
		tabCharacters()

		brawl.menu.active = true
		surface.PlaySound( "girls-frontline/menu-open.ogg" )
	else
		brawl.menu.active = not brawl.menu.active
		brawl.menu.pnl:SetVisible( brawl.menu.active )
		if brawl.menu.active then surface.PlaySound( "girls-frontline/menu-open.ogg" ) end
	end

end

local state = 0
local blur = Material( "pp/blurscreen" )
hook.Add( "RenderScreenspaceEffects", "brawl.menu", function()

	state = math.Approach( state, brawl.menu.active and 1 or 0, FrameTime() * 3 )
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

function brawl.menu.autocomplete( cmd, argStr )

	local t = {}
	return t

end

concommand.Add( "brawl_menu", brawl.menu.toggle, brawl.menu.autocomplete, "Opens Brawl menu interface" )
