
local PANEL = {}

function PANEL:Init()

	self:SetMouseInputEnabled( true )
	self:SetContentAlignment( 4 )
	self:SetTextInset( 15, 0 )

end

function PANEL:ApplySchemeSettings()

	local w, h = self:GetContentSize()
	h = 40

	self:SetSize( self:GetWide(), h )

	DLabel.ApplySchemeSettings( self )

end

vgui.Register( "SideTab", PANEL, "DTab" )

--[[---------------------------------------------------------
	SideMenu
-----------------------------------------------------------]]

local PANEL = {}

function PANEL:Init()

	self:SetShowIcons( true )

	self.tabScroller = vgui.Create( "SideMenuScroller", self )
	self.tabScroller:SetOverlap( 0 )
	self.tabScroller:SetSize( 150, 0 )
	self.tabScroller:Dock( LEFT )

	self:SetFadeTime( 0.2 )
	-- self:SetPadding( 8 )

	self.animFade = Derma_Anim( "Fade", self, self.CrossFade )

	self.Items = {}

end

function PANEL:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}

	Sheet.Name = label

	Sheet.Tab = vgui.Create( "SideTab", self )
	Sheet.Tab:SetTooltip( Tooltip )
	Sheet.Tab:Setup( label, self, panel, material )

	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetPos( self:GetPadding(), self:GetPadding() )
	Sheet.Panel:SetVisible( false )

	panel:SetParent( self )

	table.insert( self.Items, Sheet )

	if ( !self:GetActiveTab() ) then
		self:SetActiveTab( Sheet.Tab )
		Sheet.Panel:SetVisible( true )
	end

	self.tabScroller:AddPanel( Sheet.Tab )

	return Sheet

end

function PANEL:PerformLayout()

	local ActiveTab = self:GetActiveTab()
	local Padding = self:GetPadding()

	if ( !IsValid( ActiveTab ) ) then return end

	ActiveTab:InvalidateLayout( true )

	local ActivePanel = ActiveTab:GetPanel()

	for k, v in pairs( self.Items ) do

		if ( v.Tab:GetPanel() == ActivePanel ) then

			v.Tab:GetPanel():SetVisible( true )
			v.Tab:SetZPos( 100 )

		else

			v.Tab:GetPanel():SetVisible( false )
			v.Tab:SetZPos( 1 )

		end

		v.Tab:ApplySchemeSettings()

	end

	if ( !ActivePanel.NoStretchX ) then
		ActivePanel:SetWide( self:GetWide() - Padding * 2 )
	else
		ActivePanel:CenterHorizontal()
	end

	if ( !ActivePanel.NoStretchY ) then
		local _, y = ActivePanel:GetPos()
		ActivePanel:SetTall( self:GetTall() - y - Padding )
	else
		ActivePanel:CenterVertical()
	end

	ActivePanel:InvalidateLayout()

	-- Give the animation a chance
	self.animFade:Run()

end

function PANEL:SizeToContentWidth()

	local wide = 0

	for k, v in pairs( self.Items ) do

		if ( IsValid( v.Panel ) ) then
			v.Panel:InvalidateLayout( true )
			wide = math.max( wide, v.Panel:GetWide() + self.m_iPadding * 2 )
		end

	end

	self:SetWide( wide )

end

vgui.Register( "SideMenu", PANEL, "DPropertySheet" )
