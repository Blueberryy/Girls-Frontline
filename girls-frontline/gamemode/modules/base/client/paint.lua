brawl.paint = {}

brawl.paint.tabButton = function( self, w, h )

	if not self:IsActive() then return end

	draw.RoundedBox( 0, 0, 0, w, h, Color( 90,90,100 ) )
	for i = 1, 4 do
		draw.RoundedBox( 0, w-i, 0, i, h, Color( 0,0,0, 40 / i ) )
	end

end

brawl.paint.tabSheet = function( self, w, h )

	local y, h = 24, h-24 -- srsly, wtf is wrong with these panels?
	draw.RoundedBox( 0, 0, y, w, h, Color( 80,80,90 ) )

	local w = 150
	draw.RoundedBox( 0, 0, y, w, h, Color( 80,80,90 ) )

	for i = 1, 4 do
		draw.RoundedBox( 0, w-i, y, i, h, Color( 0,0,0, 40 / i ) )
	end

end

brawl.paint.tabPanel = function( self, w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color( 100,100,110 ) )

end

brawl.paint.menuPanel = function( self, w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color( 90,90,100 ) )

	for i = 1, 4 do
		draw.RoundedBox( 0, 0, 0, i, h, Color( 0,0,0, 40 / i ) )
	end

end

brawl.paint.menuButton = function( self, w, h )

	local col = self:IsHovered() and Color( 220,220,255,8 ) or Color( 0,0,0,0 )
	draw.RoundedBox( 0, 0, 0, w, h, col )

	local txtcol = self:IsHovered() and Color( 255,255,255 ) or Color( 200,200,200 )
	draw.Text({
		text = self.txt,
		font = self.font,
		pos = { w / 2, h / 2 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
		color = txtcol
	})

end

brawl.paint.gameInfoPanel = function( self, w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color( 84,84,94 ) )
	draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 90,90,100 ) )

	local txtData = {}
	txtData.xalign = TEXT_ALIGN_RIGHT
	txtData.yalign = TEXT_ALIGN_CENTER
	txtData.color = Color( 220,220,220 )

	local mode = GetGlobalString( "brawl.mode" )
	txtData.text = brawl.modes.registered[ mode ].name
	txtData.pos = { 445, 20 }
	txtData.font = "brawl.menu.large"
	draw.Text(txtData)

	local map = string.lower( game.GetMap() )
	txtData.text = "on " .. brawl.config.maps[ map ].name
	txtData.pos = { 445, 40 }
	txtData.font = "brawl.menu.normal"
	draw.Text(txtData)

	local num = #player.GetAll()
	txtData.text = "with " .. num .. " player" .. (num > 1 and "s" or "")
	txtData.pos = { 445, 90 }
	txtData.font = "brawl.menu.normal"
	draw.Text(txtData)

	txtData.text = "server ping is " .. LocalPlayer():Ping() .. "ms"
	txtData.pos = { 445, 110 }
	txtData.font = "brawl.menu.normal"
	draw.Text(txtData)

end

brawl.paint.currentLevelPanel = function( self, w, h )

	local curXP = LocalPlayer():GetXP()
	local nextXP = brawl.exp.calculateLevelEXP( LocalPlayer():GetLevel() + 1 )

	draw.RoundedBox( 0, 0, 30, w, h - 60, Color( 84,84,94 ) )
	draw.RoundedBox( 0, 1, 31, w-2, h-2 - 60, Color( 90,90,100 ) )
	draw.RoundedBox( 0, 1, 31, (w-2) * (curXP / nextXP), h-2 - 60, Color( 220,220,220 ) )

	local txtData = {}
	txtData.color = Color( 220,220,220 )

	txtData.yalign = TEXT_ALIGN_TOP
	txtData.xalign = TEXT_ALIGN_LEFT
	txtData.font = "brawl.menu.semilarge"
	txtData.text = "Level " .. LocalPlayer():GetLevel()
	txtData.pos = { 0, 0 }
	draw.Text( txtData )

	txtData.yalign = TEXT_ALIGN_CENTER
	txtData.font = "brawl.menu.normal"

	txtData.xalign = TEXT_ALIGN_LEFT
	txtData.text = curXP .. "XP"
	txtData.pos = { 2, 65 }
	draw.Text( txtData )

	txtData.xalign = TEXT_ALIGN_RIGHT
	txtData.text = nextXP .. "XP"
	txtData.pos = { w-2, 65 }
	draw.Text( txtData )

end
