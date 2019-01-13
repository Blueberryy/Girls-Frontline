MODE.name = "Bomb Defuse"
MODE.teams = { 1, 2 }

function MODE:hud()

	local myTeam = LocalPlayer():Team()
	for k, ply in pairs( team.GetPlayers(myTeam) ) do
		if not ply:Alive() or ply == LocalPlayer() then continue end


		local pos = ply:GetPos() + Vector( 0, 0, 40 )
		local scrPos = pos:ToScreen()
		local col = team.GetColor(myTeam)
		col.a = 100
		draw.RoundedBox( 4, scrPos.x, scrPos.y, 8, 8, col )
		draw.Text({
			font = "brawl.hud.small",
			text = ply:Name(),
			pos = { scrPos.x + 4, scrPos.y + 10 },
			color = col,
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
		})
	end

end
