function brawl.AddWeaponClips( ply, wep, num, secondary )

	if isstring( wep ) then wep = ply:GetWeapon( wep ) end
	if not IsValid( ply ) or not IsValid( wep ) then return end

	local ammoType, amount
	if not secondary then
		ammoType = wep:GetPrimaryAmmoType()
		amount = wep:GetMaxClip1() * num
	else
		ammoType = wep:GetSecondaryAmmoType()
		amount = wep:GetMaxClip2() * num
	end

	ply:SetAmmo( ply:GetAmmoCount( ammoType ) + amount, ammoType )

end

concommand.Add( "dropweapon", function( ply, cmd, arg, argStr)

	local wep = ply:GetActiveWeapon()
	if not GAMEMODE:PlayerCanDropWeapon( ply, wep ) then return end
	ply:DropWeapon( wep )

end)

net.Receive( "brawl.dropWeapon", function( len, ply )

	local cat = net.ReadString()
	local wep = ply:GetWeaponByCategory( cat )

	if not GAMEMODE:PlayerCanDropWeapon( ply, wep ) then return end
	ply:DropWeapon( wep )

end)
