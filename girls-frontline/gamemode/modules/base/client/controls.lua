-- local meta = FindMetaTable( "Player" )
--
-- function meta:SelectWeapon( class )
--
-- 	if ( !self:HasWeapon( class ) ) then return end
-- 	self.DoWeaponSwitch = self:GetWeapon( class )
--
-- end
--
-- hook.Add( "CreateMove", "brawl.controls", function( cmd )
--
-- 	if ( !IsValid( LocalPlayer().DoWeaponSwitch ) ) then return end
--
-- 	cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )
--
-- 	if ( LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch ) then
-- 		LocalPlayer().DoWeaponSwitch = nil
-- 	end
--
-- end)

local escPressed = false
hook.Add( "Think", "brawl.controls", function()

	if input.IsKeyDown( KEY_ESCAPE ) then
		if LocalPlayer():IsTyping() then escPressed = true end
		-- if not gui.IsConsoleVisible() then escPressed = true end
		if not escPressed then
			gui.HideGameUI()
			RunConsoleCommand( "brawl_menu" )
			escPressed = true
		end
	else
		escPressed = false
	end

end)

hook.Add( "PlayerBindPress", "brawl.controls", function( ply, bind, press )

	-- whatever

end)
