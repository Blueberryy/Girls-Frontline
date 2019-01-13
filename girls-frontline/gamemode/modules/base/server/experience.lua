brawl.exp = brawl.exp or {}

local meta = FindMetaTable "Player"

function meta:SetXP( val )

	self:SetNWInt( "XP", tonumber(val) )
	self:CheckLevel()

end

function meta:AddXP( val, t )

	self:SetNWInt( "XP", self:GetXP() + val )

	if val > 0 then
		net.Start( "brawl.exp.add" )
			net.WriteUInt( val, 16 )
			net.WriteString( t or "something" )
		net.Send( self )
	end

	self:CheckLevel()

end

function meta:SetLevel( val )

	self:SetNWInt( "Level", tonumber(val) )

end

function meta:LevelUp()

	local newLevel = self:GetLevel() + 1
	self:SetLevel( newLevel )

	net.Start( "brawl.exp.levelUp" )
		net.WriteString( "You've reached level " .. newLevel )
	net.Send( self )

end

function meta:CheckLevel()

	local expForLevelUp = brawl.exp.calculateLevelEXP( self:GetLevel() + 1 )
	if self:GetXP() >= expForLevelUp then
		self:AddXP( -expForLevelUp )
		self:LevelUp()
	end

end

local killStreakRewards = {
	[2] = {100, "Double kill", "%s made double kill"},
	[3] = {100, "Multi kill", "%s made multi kill"},
	[4] = {100, "Ultra kill", "%s made ultra kill"},
	[5] = {500, "MONSTER KILL", "%s MADE MONSTER KILL"},
}

local killsThisLifeRewards = {
	[5] = {100, "Killing spree", "%s is on killing spree!"},
	[10] = {250, "Dominating", "%s is dominating!"},
	[15] = {500, "Unstoppable", "%s is unstoppable!"},
	[20] = {1000, "Godlike", "%s IS GODLIKE!"},
}

hook.Add( "DoPlayerDeath", "brawl.exp", function( victim, attacker, dmg )

	for ply, data in pairs( victim.attacks ) do
		if ply ~= attacker and CurTime() < data.lastHit + 15 then
			if IsValid( ply ) then
				if not ply:IsPlayer() or brawl.modes.active.teams and ply:Team() == victim:Team() then continue end
				ply:AddXP( math.Round( data.dmg ), "Assist" )
			end
		end
	end
	victim.attacks = nil

	if attacker:IsPlayer() and victim ~= attacker then
		if brawl.modes.active.teams and attacker:Team() == victim:Team() then return end
		attacker.killStreak = attacker.killStreak + 1
		attacker.killsThisLife = attacker.killsThisLife + 1
		timer.Stop( "killStreakReset" .. attacker:UserID() )
		timer.Start( "killStreakReset" .. attacker:UserID() )
		attacker:AddXP( 100, "Kill" )

		if GetGlobalInt( "brawl.KillsThisRound" ) == 0 then
			attacker:AddXP( 50, "First blood" )
		end

		local killStreak = killStreakRewards[ math.min(  attacker.killStreak, 5 ) ]
		if killStreak then
			attacker:AddXP( killStreak[1], killStreak[2] )
		end

		local killsThisLife = killsThisLifeRewards[ attacker.killsThisLife ]
		if killsThisLife then
			attacker:AddXP( killsThisLife[1], killsThisLife[2] )
			brawl.NotifyAll( killsThisLife[3]:format( attacker:Name() ) )
		end

		local wep = attacker:GetActiveWeapon()
		if IsValid( wep ) and table.HasValue( brawl.config.weapons.melee, wep:GetClass() ) then
			attacker:AddXP( 100, "Melee kill" )
		else
			if victim.lastHitGroup == 1 then -- headshot
				attacker:AddXP( 50, "Headshot" )
			end

			if victim:GetPos():DistToSqr( attacker:GetPos() ) > 4000000 then
				attacker:AddXP( 50, "Long shot" )
			end
		end
	end

end)

--
-- DATABASE
--

local function migrate()

	local A_I = MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"

	MySQLite.query([[
			CREATE TABLE IF NOT EXISTS brawl_users (
			steamID VARCHAR(30) NOT NULL ,
			nick VARCHAR(50) NOT NULL ,
			connects INT NOT NULL ,
			playtime INT NOT NULL ,
			level INT NOT NULL ,
			exp INT NOT NULL ,
			PRIMARY KEY (steamID)
		)
	]])

end
if MySQLite.isMySQL() then
	hook.Add( "DatabaseInitialized", "MigrateUsers", migrate )
else
	timer.Simple( 0, migrate )
end

hook.Add( "PlayerAuthed", "brawl.CheckUserData", function( ply, steamID, uID )

	MySQLite.query(string.format("SELECT * FROM brawl_users WHERE steamID = %s", MySQLite.SQLStr( steamID )), function( res )
		if not res or #res < 1 then
			MySQLite.query(string.format([[
				INSERT INTO brawl_users( steamID, nick, connects, playtime, level, exp )
				VALUES ( %s, %s, %d, %d, %d, %d )
				]], MySQLite.SQLStr( steamID ), MySQLite.SQLStr( ply:Name() ), 1, 0, 1, 0
			))

			ply:SetLevel( 1 )
			ply:SetXP( 0 )

			if brawl.debug then
				brawl.msg( "%s (%s) joined first time, adding to users table", ply:Name(), ply:SteamID() )
			end
		else
			MySQLite.query(string.format([[
				UPDATE brawl_users
				SET nick = %s, connects = connects + 1 WHERE steamID = %s
				]], MySQLite.SQLStr( ply:Name() ), MySQLite.SQLStr( steamID )
			))

			ply:SetLevel( res[1].level )
			ply:SetXP( res[1].exp )

			if brawl.debug then
				brawl.msg( "%s's (%s) entry updated in users table", ply:Name(), ply:SteamID() )
			end
		end
	end)

end)

local function saveUser( ply )

	MySQLite.query(string.format([[
		UPDATE brawl_users
		SET
			playtime = playtime + %d,
			level = %d,
			exp = %d
		WHERE steamID = %s
		]], math.floor( ply:TimeConnected() ), ply:GetLevel(), ply:GetXP(), MySQLite.SQLStr( ply:SteamID() )
	))

	if brawl.debug then
		brawl.msg( "%s's (%s) entry updated in users table", ply:Name(), ply:SteamID() )
	end

end

hook.Add( "PlayerDisconnected", "brawl.SaveUserData", function( ply )

	saveUser( ply )

end)

hook.Add( "ShutDown", "brawl.SaveUserData", function( ply )

	for k, ply in pairs( player.GetAll() ) do
		saveUser( ply )
	end

end)
