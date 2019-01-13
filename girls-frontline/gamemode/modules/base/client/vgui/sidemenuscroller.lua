
local PANEL = {}

function PANEL:Init()

	self.Panels = {}
	self.OffsetX = 0
	self.FrameTime = 0

	self.pnlCanvas = vgui.Create( "DDragBase", self )
	self.pnlCanvas:SetDropPos( "6" )
	self.pnlCanvas:SetUseLiveDrag( false )
	self.pnlCanvas.OnModified = function() self:OnDragModified() end

	self.pnlCanvas.UpdateDropTarget = function( Canvas, drop, pnl )
		if ( !self:GetShowDropTargets() ) then return end
		DDragBase.UpdateDropTarget( Canvas, drop, pnl )
	end

	self.pnlCanvas.OnChildAdded = function( Canvas, child )

		local dn = Canvas:GetDnD()
		if ( dn ) then

			child:Droppable( dn )
			child.OnDrop = function()

				local x, y = Canvas:LocalCursorPos()
				local closest, id = self.pnlCanvas:GetClosestChild( x, Canvas:GetTall() / 2 ), 0

				for k, v in pairs( self.Panels ) do
					if ( v == closest ) then id = k break end
				end

				table.RemoveByValue( self.Panels, child )
				table.insert( self.Panels, id, child )

				self:InvalidateLayout()

				return child

			end
		end

	end

	self:SetOverlap( 0 )

end

function PANEL:OnMouseWheeled( dlta )

	self.OffsetX = self.OffsetX + dlta * -30
	self:InvalidateLayout( true )

	return true

end

function PANEL:Think()

	-- Hmm.. This needs to really just be done in one place
	-- and made available to everyone.
	local FrameRate = VGUIFrameTime() - self.FrameTime
	self.FrameTime = VGUIFrameTime()

	if ( self.btnRight:IsDown() ) then
		self.OffsetX = self.OffsetX + (500 * FrameRate)
		self:InvalidateLayout( true )
	end

	if ( self.btnLeft:IsDown() ) then
		self.OffsetX = self.OffsetX - (500 * FrameRate)
		self:InvalidateLayout( true )
	end

	if ( dragndrop.IsDragging() ) then

		local x, y = self:LocalCursorPos()

		if ( x < 30 ) then
			self.OffsetX = self.OffsetX - (350 * FrameRate)
		elseif ( x > self:GetWide() - 30 ) then
			self.OffsetX = self.OffsetX + (350 * FrameRate)
		end

		self:InvalidateLayout( true )

	end

end

function PANEL:PerformLayout()

	local w, h = self:GetSize()

	self.pnlCanvas:SetWide( w )

	local y = 0

	for k, v in pairs( self.Panels ) do

		v:SetPos( 0, y )
		v:SetWide( w )
		v:ApplySchemeSettings()

		y = y + v:GetTall() - self.m_iOverlap

	end

	self.pnlCanvas:SetTall( y + self.m_iOverlap )

	if ( w < self.pnlCanvas:GetWide() ) then
		self.OffsetX = math.Clamp( self.OffsetX, 0, self.pnlCanvas:GetWide() - self:GetWide() )
	else
		self.OffsetX = 0
	end

	self.pnlCanvas.x = self.OffsetX * -1

	self.btnLeft:SetSize( 15, 15 )
	self.btnLeft:AlignLeft( 4 )
	self.btnLeft:AlignBottom( 5 )

	self.btnRight:SetSize( 15, 15 )
	self.btnRight:AlignRight( 4 )
	self.btnRight:AlignBottom( 5 )

	self.btnLeft:SetVisible( self.pnlCanvas.x < 0 )
	self.btnRight:SetVisible( self.pnlCanvas.x + self.pnlCanvas:GetWide() > self:GetWide() )

end

vgui.Register( "SideMenuScroller", PANEL, "DHorizontalScroller" )
