brawl.bodyView = brawl.bodyView or {}
brawl.bodyView.mods = {}

function brawl.bodyView.setModifier( name, data )

	if not istable( data ) then return end
	brawl.bodyView.mods[ name ] = data

end

function brawl.bodyView.removeModifier( name )

	brawl.bodyView.mods[ name ] = nil

end

local lastRoll, lastFOV = 0, 1
hook.Add( "CalcView", "brawl", function( ply, pos, angles, fov )

	local view = {
		origin = pos,
		angles = angles,
		fov = fov,
		znear = 1
	}

	local mods = {
		origin = Vector(0,0,0),
		angles = Angle(0,0,0),
		fov = 1,
		znear = 0
	}

	for k,mod in pairs( brawl.bodyView.mods ) do
		if mod.origin then mods.origin = mods.origin + mod.origin end
		if mod.angles then mods.angles = mods.angles + mod.angles end
		if mod.fov then mods.fov = mods.fov * mod.fov end
		if mod.znear then mods.znear = mods.znear + mod.znear end
	end

	local corpse = ply:GetNWEntity( "Corpse" )
	if not ply:GetNWBool("Spectating") and IsValid( corpse ) then
		local hat = corpse:LookupBone("ValveBiped.Bip01_Head1") or 6
		if not ply:Alive() then
			corpse:ManipulateBoneScale( hat, Vector( 0, 0, 0) )

			local eyes = corpse:GetAttachment( corpse:LookupAttachment( "eyes" ) )
			view = {
				origin = eyes.Pos - eyes.Ang:Forward() * 6,
				angles = eyes.Ang,
				fov = 90,
				znear = 1
			}
		else
			corpse:ManipulateBoneScale(hat, Vector(1, 1, 1))
		end
	end

	if ply:Alive() then
		local ang = ply:GetVelocity():Dot( ply:GetRight() ) / 100
		local roll = math.Clamp( math.Approach( lastRoll, ang, FrameTime() * 10 ), -90, 90 )

		local speed = LocalPlayer():GetVelocity():LengthSqr()
		local curFOV = math.Approach( lastFOV, 1 + math.Clamp( speed - 55000, 0, 40000 ) / 20000 * 0.1, FrameTime() / 2 )
		lastFOV = curFOV

		brawl.bodyView.setModifier( "move", {
			angles = Angle( 0, 0, roll ),
			fov = curFOV,
		})
		lastRoll = roll
	else
		brawl.bodyView.removeModifier( "move" )
	end

	-- apply modifiers
	view.origin = view.origin + mods.origin
	view.angles = view.angles + mods.angles
	view.fov = view.fov * mods.fov
	view.znear = view.znear + mods.znear

end)

local blur = Material( "pp/blurscreen" )
local curState, dmgBlur = 0, 0
hook.Add( "RenderScreenspaceEffects", "brawl", function()

	-- apply effects
	if curState ~= 0 and not brawl.menu.active then
		local deathColors = {
			[ "$pp_colour_addr" ] = 0,
			[ "$pp_colour_addg" ] = 0,
			[ "$pp_colour_addb" ] = 0,
			[ "$pp_colour_brightness" ] = curState * 0.2,
			[ "$pp_colour_contrast" ] = 1 - curState * 0.5,
			[ "$pp_colour_colour" ] = 1 - curState,
			[ "$pp_colour_mulr" ] = 0,
			[ "$pp_colour_mulg" ] = 0,
			[ "$pp_colour_mulb" ] = 0
		}
		DrawColorModify( deathColors )

		local _prc = (curState > .5 and (curState-.5)/.5 or 0)
		DrawBloom( 0.1, (_prc^(3))*1, 6, 6, 1, 0.25, 1, 1, 1 )
		DrawMotionBlur( (1 - (_prc^(.13))*.8), (_prc^(.13))*(.8), 0.01 )
	end

	if dmgBlur ~= 0 then
		surface.SetDrawColor( 255, 255, 255, dmgBlur * 255 )
		surface.SetMaterial( blur )

		for i = 1, 3 do
			blur:SetFloat( "$blur", dmgBlur * i * 3 )
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )
		end
	end

	setDSP( curState )

end)

hook.Add( "brawl.hit", "brawl.camera", function( data )

	if data.victim == LocalPlayer() then
		dmgBlur = dmgBlur + data.damage / 100

		if LocalPlayer().lhSnd then LocalPlayer().lhSnd:Stop() end
		local snd = CreateSound( LocalPlayer(), "girls-frontline/low-health.ogg" )
		snd:ChangeVolume(1)
		snd:SetDSP(0)
		snd:Play()
		LocalPlayer().lhSnd = snd
	end

end)

hook.Add( "Think", "brawl.camera", function()

	if LocalPlayer():GetNWBool("Spectating") then
		curState = 0
	else
		local tgtState
		if LocalPlayer():Alive() then
			tgtState = 1 - math.Clamp((LocalPlayer():Health() or 0) / LocalPlayer():GetMaxHealth(), 0, 1)
		else
			tgtState = 1
		end

		-- interpolate the value
		local delta = (tgtState - curState) * FrameTime() * 4
		curState = math.Approach( curState, tgtState, delta )
	end

	local delta2 = dmgBlur * FrameTime() / 4
	dmgBlur = math.Approach( dmgBlur, 0, delta2 )
	if LocalPlayer().lhSnd then
		LocalPlayer().lhSnd:ChangeVolume( dmgBlur )
	end

end)

function setDSP( curState )

	local dsp = 1
	if curState > .9 then
		dsp = 16
	elseif curState > .8 then
		dsp = 15
	elseif curState > .75 then
		dsp = 14
	end
	LocalPlayer():SetDSP( dsp )

end
