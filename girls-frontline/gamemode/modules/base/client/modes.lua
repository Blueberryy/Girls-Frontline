net.Receive( "brawl.round.end", function( len )

	local data = net.ReadTable()

	LocalPlayer():EmitSound( "girls-frontline/round-end.ogg", 100 )

end)

net.Receive( "brawl.round.start", function( len )

	brawl.modes.overlay = {
		delay = net.ReadFloat(),
		title = net.ReadString(),
		subtitle = net.ReadString(),
	}

end)
