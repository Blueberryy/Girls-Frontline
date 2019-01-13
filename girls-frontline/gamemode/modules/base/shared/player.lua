local meta = FindMetaTable "Player"

function meta:GetStamina( val )

	return self:GetNWInt( "Stamina", val )

end

function meta:GetHealthStatus()

	local health, status = self:Health(), nil
	if health == 100 then
		status = "healthy"
	elseif health > 75 then
		status = "almost healthy"
	elseif health > 50 then
		status = "wounded"
	elseif health > 25 then
		status = "heavily wounded"
	elseif health > 0 then
		status = "nearly dead"
	else
		status = "dead"
	end

	return status

end

function meta:GetScore()

	return self:GetNWInt( "brawl.score" )

end

function meta:GetWeaponByCategory( cat )

	for k, wep in pairs( self:GetWeapons() ) do
		if wep.noCategory then continue end

		local curCat = wep:GetNWString( "WeaponCategory" )
		if not curCat or curCat == "" then
			brawl.msg( "Fixing category for %s (\"%s\" -> \"%s\")", wep:GetClass(), wep:GetNWString( "WeaponCategory" ), wep:GetWeaponCategory() )
			wep:SetNWString( "WeaponCategory", wep:GetWeaponCategory() )
		end

		if curCat == cat then
			return wep
		end
	end

end

function meta:SelectWeaponByCategory( cat )

	local wep = self:GetWeaponByCategory( cat )
	if wep then self:SelectWeapon( wep:GetClass() ) end

end

function meta:GetTeamColor()

	local t = self:Team()
	if t < 1 or t > 999 then return Color(255,212,50) end

	return team.GetColor(t)

end

hook.Add( "PlayerFootstep", "brawl.step", function( ply )

	if ply:GetAbsVelocity():LengthSqr() < 16900 then
		return true
	end

end)
