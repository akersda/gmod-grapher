local PANEL = {}

function PANEL:Init()
	
	self.gdata = {}
	self.backg = {}
	self.showname = false
	self.numsum = 0
	self.proc = 361
	self.radius1 = 20
	self.radius2 = 40
	self.speed = 15
	self.drawback = false
	self.backcol = Color( 0,0,0,255 )
	self.backthick = 1
	
	self.thinktick = CurTime()
	
end

function PANEL:Paint( w, h )
	
	draw.NoTexture()
	
	if !table.IsEmpty(self.backg) and self.drawback == true then
		surface.SetDrawColor(self.backcol)
		draw.PartCircle( self.backg.cir1, self.backg.cir2 )
	end
	
	if !table.IsEmpty(self.gdata) then
		for k, seg in ipairs( self.gdata ) do
			if seg.cir1 != nil and !table.IsEmpty(seg.cir1) then
				surface.SetDrawColor(seg.col)
				draw.PartCircle( seg.cir1, seg.cir2 )
				if self.drawback then
					surface.SetDrawColor(self.backcol)
					surface.DrawLine( seg.cir1[1].x, seg.cir1[1].y, seg.cir2[1].x, seg.cir2[1].y )
					surface.DrawLine( seg.cir1[#seg.cir1].x, seg.cir1[#seg.cir1].y, seg.cir2[#seg.cir2].x, seg.cir2[#seg.cir2].y )
					if self.backthick > 1 then
						surface.DrawTexturedRectRotated( (seg.cir1[1].x + seg.cir2[1].x) / 2, (seg.cir1[1].y + seg.cir2[1].y) / 2, self.backthick, self.radius2-self.radius1, seg.ang )
					end
				end
			end
		end
	end
	
end

function PANEL:AddData( data, name, colour )
	
	if name == nil or !isstring(name) then name = "unknown" end
	if colour == nil or !IsColor(colour) then colour = HSVToColor( #self.gdata*30, 1, 1 ) end
	
	table.insert( self.gdata, {data = tonumber(data), name = name, col = colour} )
	self.numsum = self.numsum + tonumber(data)
	
end

function PANEL:ClearData()
	
	self.gdata = {}
	self.numsum = 0
	self.proc = 361
	
end

function PANEL:StartAnim()
	
	self.proc = 0
	
end

function PANEL:SetSpeed( num )
	
	self.speed = tonumber(num)
	
end

function PANEL:SetRadius( num )
	
	local thick = self.radius2 - self.radius1
	self.radius1 = tonumber(num)
	self.radius2 = tonumber(num) + thick
	
end

function PANEL:SetThick( num )
	
	self.radius2 = self.radius1 + tonumber(num)
	
end

function PANEL:SetBackground( col )
	
	if col == nil then
		self.drawback = false
	elseif IsColor(col) then
		self.drawback = true
		self.backcol = col
	else
		self.drawback = true
		self.backcol = Color( 0,0,0,255 )
	end
	
end

function PANEL:SetBackThick( num )
	
	self.backthick = tonumber( num )
	
end

function PANEL:Think()
	
	if self.thinktick < CurTime() then
		self.thinktick = CurTime() + 0.0333 -- ~30 fps
		local w, h = self:GetWide()/2, self:GetTall()/2 -- center
		
		if self.proc <= 360 then
			local pos = 0
			for k, entry in ipairs( self.gdata ) do
				local sw = ( entry.data / self.numsum ) * self.proc -- degrees of segment
				if self.drawback then
					self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1 + self.backthick, self.radius2 - self.backthick, pos, pos + sw )
				else
					self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + sw )
				end
				self.gdata[k].ang = -pos + 90 
				pos = pos + sw
			end
			if self.drawback then
				self.backg.cir1, self.backg.cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, 0, pos )
			end
			self.proc = self.proc + self.speed
		end
	end
	
end

vgui.Register( "GPie", PANEL, "EditablePanel" )
print("GPie vgui element by Cptn.Sheep. https://github.com/akersda" )