if SERVER then AddCSLuaFile() end

--[[-------------------------------------------------------------------------
SERVER FUNCTIONS
---------------------------------------------------------------------------]]
if SERVER then

--[[-------------------------------------------------------------------------
AddCSLuaFolder
	sends all .lua files inside folder to client

parameters
	path: string
		path to the folder
---------------------------------------------------------------------------]]
function AddCSLuaFolder( path )
	local fs, _ = file.Find( path .."/*.lua", "LUA" )
	for _,f in pairs( fs ) do
		AddCSLuaFile( path .."/".. f )
	end
end

end
--[[-------------------------------------------------------------------------
CLIENT FUNCTIONS
---------------------------------------------------------------------------]]
if CLIENT then

--[[-------------------------------------------------------------------------
vgui elements shortcuts
---------------------------------------------------------------------------]]
function brawl.DPanel( d )
	local p = vgui.Create( "DPanel", d.parent )
	if d.pos then p:SetPos( d.pos[1], d.pos[2] ) end
	if d.size
		then p:SetSize( d.size[1], d.size[2] )
		else p:SizeToContents()
	end
	if d.paint then p.Paint = d.paint end
	if istable( d.data ) then for k,v in pairs( d.data ) do p[k] = v end end
	return p
end

function brawl.DLabel( d )
	local p = vgui.Create( "DLabel", d.parent )
	if d.pos then p:SetPos( d.pos[1], d.pos[2] ) end
	if d.txt then p:SetText( d.txt ) end
	if d.font then p:SetFont( d.font ) end
	if d.col then p:SetTextColor( d.col ) end
	if d.align then p:SetContentAlignment( d.align ) end
	if d.size
		then p:SetSize( d.size[1], d.size[2] )
		else p:SizeToContents()
	end
	if d.paint then p.Paint = d.paint end
	if istable( d.data ) then for k,v in pairs( d.data ) do p[k] = v end end
	return p
end

function brawl.DButton( d )
	local p = vgui.Create( "DButton", d.parent )
	if d.pos then p:SetPos( d.pos[1], d.pos[2] ) end
	if d.txt then p:SetText( d.txt ) end
	if d.font then p:SetFont( d.font ) end
	if d.col then p:SetTextColor( d.col ) end
	if d.align then p:SetContentAlignment( d.align ) end
	if d.size
		then p:SetSize( d.size[1], d.size[2] )
		else p:SizeToContents()
	end
	if d.onselect then p.DoClick = d.onselect end
	if d.paint then p.Paint = d.paint end
	if d.img then p:SetImage( d.img ) end
	p:SetEnabled( !d.disabled )
	if istable( d.data ) then for k,v in pairs( d.data ) do p[k] = v end end
	return p
end

function brawl.DComboBox( d )
	local p = vgui.Create( "DComboBox", d.parent )
	if d.pos then p:SetPos( d.pos[1], d.pos[2] ) end
	if d.val then p:SetValue( d.val ) end
	if d.size
		then p:SetSize( d.size[1], d.size[2] )
		else p:SizeToContents()
	end
	if d.data then
		for _,v in pairs(d.data) do
			p:AddChoice( v )
		end
	end
	if d.onselect then p.OnSelect = d.onselect end
	p:SetEnabled( !d.disabled )
	if istable( d.data ) then for k,v in pairs( d.data ) do p[k] = v end end
	return p
end

function brawl.DTextEntry( d )
	local p = vgui.Create( "DTextEntry", d.parent )
	if d.pos then p:SetPos( d.pos[1], d.pos[2] ) end
	if d.txt then p:SetText( d.txt ) end
	if d.align then p:SetContentAlignment( d.align ) end
	if d.multiline then p:SetMultiline( true ) end
	if d.size
		then p:SetSize( d.size[1], d.size[2] )
		else p:SizeToContents()
	end
	if d.paint then p.Paint = d.paint end
	p:SetEnabled( !d.disabled )
	if istable( d.data ) then for k,v in pairs( d.data ) do p[k] = v end end
	return p
end

function brawl.WrapText( text, width, font, bConcat )
	local lines = {}
	surface.SetFont( font or "Default" )

	local line
	local textTbl = string.Explode( " ", text )
	for k, word in pairs( textTbl ) do
		if k == 1 then line = word continue end

		local wordSize = surface.GetTextSize( word )
		local lineSize = surface.GetTextSize( line )
		if lineSize + wordSize < width then
			line = line .. " " .. word
		else
			table.insert( lines, line )
			line = word
		end
	end
	table.insert( lines, line )

	return bConcat and string.Implode( "\n", lines ) or lines
end

function brawl.FontHeight( font )
	surface.SetFont( font )
	local w,h = surface.GetTextSize( "Aq" )
	return h
end

function brawl.TextWidth( t, font )
	surface.SetFont( font )
	if isstring( t ) then t = {t} end

	local maxWidth = 0
	for k,v in pairs( t ) do
		maxWidth = math.max( maxWidth, surface.GetTextSize( t[k] ) )
	end

	return maxWidth
end

function brawl.icon( name )
	return Material( "icon16/" .. name .. ".png" )
end

function draw.Circle( x, y, radius, seg )

	local cir = {}

	table.insert( cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, {
			x = x + math.sin( a ) * radius,
			y = y + math.cos( a ) * radius,
			u = math.sin( a ) / 2 + 0.5,
			v = math.cos( a ) / 2 + 0.5
		})
	end

	local a = math.rad( 0 )
	table.insert( cir, {
		x = x + math.sin( a ) * radius,
		y = y + math.cos( a ) * radius,
		u = math.sin( a ) / 2 + 0.5,
		v = math.cos( a ) / 2 + 0.5
	})

	surface.DrawPoly( cir )

end

--[[-------------------------------------------------------------------------
string extension
---------------------------------------------------------------------------]]

function string.composeMarkup( default, ... )

	local args, out = {...}, ""
	local curCol, curFont
	if not istable(default) then
		table.insert( args, 1, default )
		default = {}
	end
	if #args == 0 then return "" end

	local function openColor( c )
		out = out .. string.format( "<colour=%d, %d, %d, %d>", c.r, c.g, c.b, c.a )
		curCol = c
	end

	local function closeColor()
		out = out .. "</colour>"
	end

	local function openFont( f )
		out = out .. string.format( "<font=%s>", f )
		curFont = f
	end

	local function closeFont()
		out = out .. "</font>"
	end

	for k,v in pairs( args ) do
		if IsColor(v) then
			if curCol then closeColor() end
			openColor( v )
		elseif isstring(v) then
			if string.sub( v, 1, 5 ) == "font_" then
				local font = string.sub( v, 6 )
				if curFont then closeFont() end
				openFont( font )
			else
				if not curFont then openFont( default.font or "Default" ) end
				if not curCol then openColor( default.color or Color(255,255,255, 255) ) end
				out = out .. v
			end
		end
	end

	closeColor()
	closeFont()

	return out

end

end
--[[-------------------------------------------------------------------------
SHARED FUNCTIONS
---------------------------------------------------------------------------]]

--[[-------------------------------------------------------------------------
includeFolder
	includes all .lua files inside folder

parameters
	path: string
		path to the folder
---------------------------------------------------------------------------]]
function includeFolder( path )
	local fs, _ = file.Find( path .."/*.lua", "LUA" )
	for _,f in pairs( fs ) do
		include( path .."/".. f )
	end
end

--[[-------------------------------------------------------------------------
brawl.getModulePath
	gets path to the module folder

parameters
	name: string
		name of the module to look for
	core: bool
		whether this module is core (pre-installed)
---------------------------------------------------------------------------]]
function brawl.getModulePath( name, core )
	local path
	if core
		then path = GAMEMODE.FolderName .."/gamemode/modules/".. name
		else path = "girls-frontline/modules/".. name
	end
	return path
end

--[[-------------------------------------------------------------------------
brawl.includeModuleFolders
	processes both client and server files of the module (sends and includes
	them) based on default configuration:
	client: modules/[module]/client
	server: modules/[module]/server
	shared: modules/[module]/shared

parameters
	name: string
		name of the module to look for
	core: bool
		whether this module is core (pre-installed)
---------------------------------------------------------------------------]]
function brawl.includeModuleFolders( name, core )
	local path = brawl.getModulePath( name, core )
	includeFolder( path .."/shared" )
	if SERVER then
		includeFolder( path .."/server" )
		AddCSLuaFolder( path .."/client" )
		AddCSLuaFolder( path .."/shared" )
	else
		includeFolder( path .."/client" )
	end
end

function math.randomSign()

	return math.random(2) * 2 - 3

end

function util.GetAlivePlayers()
   local alive = {}
   for k, p in pairs(player.GetAll()) do
	  if IsValid(p) and p:Alive() then
		 table.insert(alive, p)
	  end
   end

   return alive
end

function util.GetNextAlivePlayer(ply)
   local alive = util.GetAlivePlayers()

   if #alive < 1 then return nil end

   local prev = nil
   local choice = nil

   if IsValid(ply) then
	  for k,p in pairs(alive) do
		 if prev == ply then
			choice = p
		 end

		 prev = p
	  end
   end

   if not IsValid(choice) then
	  choice = alive[1]
   end

   return choice
end

function util.FindPosition( pos, ent, dist, filter )
	local function checkPos( pos )
		local trace = { start = pos, endpos = pos, filter = filter }
		local tr = util.TraceEntity( trace, ent )

		return !tr.Hit
	end

	if checkPos( pos ) then return pos end

	local testpos
	for i = 0, 300, 60 do
		testpos = pos + Angle( 0, i, 0):Forward() * dist.around
		local tr = util.TraceLine({
			start = testpos,
			endpos = testpos + Vector(0,0,-100)
		})
		if not tr.Hit then continue end
		if checkPos( testpos ) then return testpos end
	end

	testpos = pos + Vector( 0, 0, dist.above )
	if checkPos( pos + Vector( 0, 0, dist.above ) ) then return testpos end

	return false
end

function team.BestAutoJoinTeam( ply )
	if not brawl.modes.active.teams then return 1001 end

	local minTeam = 1
	local minPlayers = math.huge

	for _, k in pairs( brawl.modes.active.teams ) do
		local num = team.NumPlayers(k) - (k == ply:Team() and 1 or 0)
		if num < minPlayers then
			minTeam = k
			minPlayers = num
		end
	end

	return minTeam
end

function team.GetAlivePlayers( k )
	local alive = {}
	for k, p in pairs( team.GetPlayers(k) ) do
	   if IsValid(p) and p:Alive() then
		  table.insert(alive, p)
	   end
	end

	return alive
end

function table.GetWinningByMember( t, key, check )
	local res, max = {}, nil

	for k, v in SortedPairsByMemberValue( t, key, true ) do
		if not max then max = v[ key ] end
		if isfunction( check ) and not check( k, v ) then continue end
		if v[ key ] < max then break end

		res[ k ] = v
	end

	return res
end

function table.GetLosingByMember( t, key, check )
	local res, min = {}, nil

	for k, v in SortedPairsByMemberValue( t, key ) do
		if not min then min = v[ key ] end
		if isfunction( check ) and not check( k, v ) then continue end
		if v[ key ] > min then break end

		res[ k ] = v
	end

	return res
end

ease = ease or {}
function ease.expInOut( t, b, c, d )

	t = t * 2 / d
	if t < 1 then return c/2 * math.pow( 2, 10 * (t - 1) ) + b end
	t = t - 1
	return c/2 * ( -math.pow( 2, -10 * t) + 2 ) + b

end

function ease.quadOut( t, b, c, d )

	t = t / d;
	return -c * t * (t - 2) + b

end

function ease.quadInOut( t, b, c, d )

	t = t * 2 / d
	if t < 1 then return c/2*t*t + b end
	t = t - 1
	return -c/2 * (t*(t-2) - 1) + b

end
