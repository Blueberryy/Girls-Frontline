brawl.points = brawl.points or { data = {} }

function brawl.points.isAllowed( ply )

	return ply:IsSuperAdmin()

end

hook.Add("PlayerInitialSpawn", "brawl.points.send", function( ply )

	if not IsValid(ply) then return end

	brawl.points.update(ply)

end)
