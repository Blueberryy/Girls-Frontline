brawl.exp = brawl.exp or {}

function brawl.exp.calculateLevelEXP( level )

	return math.Round( math.pow( level, 1.25 ) * 1000 )

end

local meta = FindMetaTable "Player"

function meta:GetXP()

	return self:GetNWInt( "XP" )

end

function meta:GetLevel()

	return self:GetNWInt( "Level" )

end
