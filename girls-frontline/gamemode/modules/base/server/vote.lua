brawl.vote = { data = {}, active = false }
function brawl.VoteStart()

	SetGlobalInt( "brawl.RoundState", 101 )

	local mapsLeft, i = 6, 1
	for map, data in RandomPairs( brawl.config.maps ) do
		if mapsLeft <= 0 then break end
		if map == string.lower( game.GetMap() ) then continue end
		brawl.vote.data[i] = { map = map, mode = table.Random(data.modes), votes = 0 }

		mapsLeft = mapsLeft - 1
		i = i + 1
	end

	for k, ply in pairs( player.GetAll() ) do
		ply.lastVote = nil
	end

	net.Start( "brawl.vote.start" )
		net.WriteTable( brawl.vote.data )
	net.Broadcast()

	timer.Simple( 31, brawl.VoteEnd )
	brawl.vote.active = true

end

function brawl.VoteEnd()

	local winner = table.GetWinningByMember( brawl.vote.data, "votes" )
	local mapData, id = table.Random( winner )

	net.Start( "brawl.vote.finish" )
		net.WriteString( mapData.map )
		net.WriteString( mapData.mode )
	net.Broadcast()

	GetConVar( "brawl_nextmode" ):SetString( mapData.mode )
	timer.Simple( 5, function() RunConsoleCommand( "changelevel", mapData.map ) end)

	brawl.vote.active = false

end

-- ULib.ucl.registerAccess( "brawl_double_vote", ULib.ACCESS_SUPERADMIN, "Double weight in votes", "Brawl" )
net.Receive( "brawl.vote.update", function( len, ply )

	if not brawl.vote.active then return end

	local choise = net.ReadUInt(8)

	local data = {}
	local function send()
		net.Start( "brawl.vote.update" )
			net.WriteTable( data )
		net.Broadcast()
	end

	local voteWeight = ply:GetVoteWeight()
	local lastChoise = ply.lastMapVote
	if lastChoise then
		brawl.vote.data[ lastChoise ].votes = brawl.vote.data[ lastChoise ].votes - voteWeight
		data[ lastChoise ] = brawl.vote.data[ lastChoise ].votes
		if lastChoise == choise then
			ply.lastMapVote = nil
			send()
			return
		end
	end

	brawl.vote.data[ choise ].votes = brawl.vote.data[ choise ].votes + voteWeight
	data[ choise ] = brawl.vote.data[ choise ].votes
	ply.lastMapVote = choise

	send()

end)

local meta = FindMetaTable "Player"

function meta:GetVoteWeight()

	return 1 + math.floor( self:GetLevel() / 10 )

end

concommand.Add( "brawl_vote", function( ply, cmd, args, argStr )

	if not ply:IsSuperAdmin() then
		brawl.Notify( ply, "You need to be superadmin for that", "error" )
		return
	end

	brawl.VoteStart()

end)
