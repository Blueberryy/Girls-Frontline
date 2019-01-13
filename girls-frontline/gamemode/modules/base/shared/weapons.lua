local meta = FindMetaTable "Entity"

-- make table for quick check for category
brawl.weapons = {}
for k1, cat in pairs( brawl.config.weapons ) do
	brawl.weapons[ k1 ] = {}
	for k2, wep in pairs( cat ) do
		if istable( wep ) then
			brawl.weapons[ k1 ][ k2 ] = {}
			for k3, wep2 in pairs( wep ) do
				brawl.weapons[ k1 ][ k2 ][ wep2 ] = true
			end
		else
			brawl.weapons[ k1 ][ wep ] = true
		end
	end
end

function brawl.GetWeaponCategory( class )

	for cat, data in pairs( brawl.weapons ) do
		if data[ class ] == true then
			return cat
		else
			for cat2, data2 in pairs( data ) do
				if not istable( data2 ) then break end
				if data2[ class ] then
					return cat
				end
			end
		end
	end

end

function meta:GetWeaponCategory()

	if not self:IsWeapon() then return end
	return brawl.GetWeaponCategory( self:GetClass() )

end
