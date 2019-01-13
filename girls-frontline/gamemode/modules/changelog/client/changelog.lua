local f

local function refresh( reset )

	if reset then
		f.page = 1
		f.prev:SetEnabled( false )
	end

	local t, p = f.type:GetValue(), f.page
	http.Fetch( "http://www.octothorp.team/changelog/fetch.php?s=brawl&t="..t.."&p="..p, function( body, size, headers, code )
		if code ~= 200 then return end
		local data = util.JSONToTable( body )

		f.list:Clear()
		f.next:SetEnabled( table.Count( data ) == 10 )
		for k, v in pairs( data ) do
			local line = f.list:AddLine( v.id, os.date("%d/%m/%y - %H:%M",v.time), v.title )
		end
	end)

end

local function newEntry()

	local d = vgui.Create( "DFrame" )
	d:SetSize( 400, 400 )
	d:SetTitle( "New entry in '" .. f.type:GetValue() .. "'" )
	d:Center()
	d:MakePopup()

	d.title = brawl.DTextEntry{
		parent = d,
		pos = { 5, 30 },
		size = { 390, 65 },
		multiline = true,
	}

	d.desc = brawl.DTextEntry{
		parent = d,
		pos = { 5, 100 },
		size = { 390, 260 },
		multiline = true,
	}

	d.add = brawl.DButton{
		parent = d,
		pos = { 320, 370 },
		size = { 75, 25 },
		txt = "Add",
		onselect = function()
			net.Start( "changelog.add" )
				net.WriteTable({
					type = f.type:GetValue(),
					time = os.time(),
					title = d.title:GetValue(),
					desc = d.desc:GetValue() ~= "" and d.desc:GetValue() or nil,
				})
			net.SendToServer()
			d:Close()
		end
	}

end

concommand.Add( "changelog", function()

	if IsValid( f ) then
		f:SetVisible( not f:IsVisible() )
	else
		f = vgui.Create( "DFrame" )
		f:SetSize( 600, 400 )
		f:SetTitle( "Changelog editor" )
		f:Center()
		f:MakePopup()

		f.list = vgui.Create( "DListView", f )
		f.list:SetPos( 5, 30 )
		f.list:SetSize( 590, 336 )
		f.list:SetDataHeight( 32 )
		local col = f.list:AddColumn( "id" )
		col:SetWidth( 40 )
		col = f.list:AddColumn( "Time" )
		col:SetWidth( 95 )
		col = f.list:AddColumn( "Title" )
		col:SetWidth( 470 )

		f.type = brawl.DComboBox{
			parent = f,
			pos = { 475, 3 },
			size = { 90, 18 },
			data = { "dev", "event", "other" },
			val = "dev",
			onselect = refresh,
		}

		f.add = brawl.DButton{
			parent = f,
			pos = { 5, 370 },
			size = { 75, 25 },
			txt = "New",
			onselect = function()
				newEntry()
			end
		}

		f.refresh = brawl.DButton{
			parent = f,
			pos = { 85, 370 },
			size = { 75, 25 },
			txt = "Refresh",
			onselect = function()
				refresh()
			end
		}


		f.next = brawl.DButton{
			parent = f,
			pos = { 520, 370 },
			size = { 75, 25 },
			txt = "Next",
			onselect = function()
				f.page = f.page + 1
				f.prev:SetEnabled( true )
				refresh()
			end
		}

		f.prev = brawl.DButton{
			parent = f,
			pos = { 440, 370 },
			size = { 75, 25 },
			txt = "Back",
			onselect = function( self )
				f.page = f.page - 1
				if f.page == 1 then self:SetEnabled( false ) end
				f.next:SetEnabled( true )
				refresh()
			end
		}

		refresh( true )
	end

end)
