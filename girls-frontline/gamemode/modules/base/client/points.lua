hook.Add( "HUDPaint", "brawl.points", function()

	if not brawl.config.debug then return end

	for type, data in pairs( brawl.points.data ) do
		for id, p in pairs( data ) do
			 local pos = p.pos:ToScreen()
			 if pos.visible then
				 draw.RoundedBox( 2, pos.x, pos.y, 4, 4, Color(255,255,255, 100) )
				 draw.Text({
					 font = "brawl.hud.small",
					 text = type .. "#" .. id,
					 pos = { pos.x, pos.y + 5 },
					 color = Color(255,255,255, 100),
					 xalign = TEXT_ALIGN_CENTER,
					 yalign = TEXT_ALIGN_TOP,
				 })
			 end
		end
	end

end)

net.Receive( "brawl.points.send", function( len )

	local data = net.ReadTable()
	brawl.points.data = data

end)
