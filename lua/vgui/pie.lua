local PANEL = {}

function PANEL:Init()
	
	self.gdata = {}
	self.backg = {}
	self.showname = false
	self.numsum = 0
	self.proc = 361
	self.pani = 101
	self.radius1 = 20
	self.radius2 = 40
	self.speed = 5
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
						surface.DrawTexturedRectRotated( (seg.cir1[1].x + seg.cir2[1].x) / 2, (seg.cir1[1].y + seg.cir2[1].y) / 2, self.backthick, self.radius2-self.radius1-1, seg.ang1 )
					end
				end
			end
		end
		if self.drawback == true and self.backthick > 1 then
			surface.DrawRect( w/2 + self.radius1, h / 2, self.radius2-self.radius1-1, self.backthick )
		end
	end
	
end

function PANEL:AddData( data, colour )

	colour = colour or HSVToColor( math.Rand( 0, 12 )*30, 1, 1 )
	
	table.insert( self.gdata, {data = tonumber(data), col = colour, ang1 = 0, ang2 = 0} )
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

function PANEL:Animate()
	
	if self.proc >= 360 then
		self.pani = 0
		for k, entry in ipairs( self.gdata ) do
			local csw = entry.ang1 - entry.ang2				-- current width
			local tsw = ( entry.data / self.numsum ) * 360	-- target width
			self.gdata[k].csw = csw
			self.gdata[k].dsw = ( tsw - csw ) / 100
		end
	end
	
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

function PANEL:ThinkEvaPos( proc, w, h )
	
	local pos = 0
	for k, entry in ipairs( self.gdata ) do
		local sw = ( entry.data / self.numsum ) * proc -- degrees of segment
		if self.drawback then
			self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1 + self.backthick, self.radius2 - self.backthick, pos, pos + sw )
		else
			self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + sw )
		end
		self.gdata[k].ang1 = -pos + 90 
		pos = pos + sw
		self.gdata[k].ang2 = -pos + 90 
	end
	if self.drawback then
		self.backg.cir1, self.backg.cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, 0, pos )
	end
	
end

function PANEL:ThinkAddPos( proc, w, h )
	
	local pos = 0
	for k, entry in ipairs( self.gdata ) do
		local dsw = entry.csw + proc * entry.dsw -- difference between -> movement
		
		if self.drawback then
			self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1 + self.backthick, self.radius2 - self.backthick, pos, pos + dsw )
		else
			self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + dsw )
		end
		
		self.gdata[k].ang1 = -pos + 90 
		pos = pos + dsw
		self.gdata[k].ang2 = -pos + 90 
	end
	
end

function PANEL:Think()
	
	if self.thinktick < CurTime() then
		self.thinktick = CurTime() + 0.0167 -- ~60 fps
		local w, h = self:GetWide()/2, self:GetTall()/2 -- center
		
		if self.proc < 360 then
			self.proc = math.min( self.proc + ( self.speed * 3.6 ), 360 )
			self:ThinkEvaPos( self.proc, w, h )
		elseif self.proc > 360 then
			self.proc = 360
			self:ThinkEvaPos( 360, w, h )
		else
			if self.pani < 100 then
				self.pani = math.min( self.pani + self.speed, 100 )
				self:ThinkAddPos( self.pani, w, h )
			elseif self.pani > 100 then
				self.pani = 100
				self:ThinkEvaPos( 360, w, h )
			end
		end
	end
	
end

vgui.Register( "GPie", PANEL, "EditablePanel" )
print("GPie vgui element by Cptn.Sheep. https://github.com/akersda" )