local PANEL = {}

function PANEL:Init()
	
	-- setup variables
	self.gdata = {}						-- graph data
	self.backg = {}						-- background circle
	self.numsum = 0						-- total sum of data
	self.trot = 0						-- total rotation 
	self.pani = 100						-- percentage of animation
	self.radius1 = 20					-- inner radius of pie (def)
	self.radius2 = 40					-- outer radius of pie (def)
	self.speed = 5						-- animation speed (def)
	self.drawback = false				-- should draw background (def)
	self.backcol = Color( 0,0,0,255 )	-- background colour (def)
	self.backthick = 1					-- background thickness (def)
	
	self.thinktick = CurTime()
	
end

function PANEL:Paint( w, h )
	
	draw.NoTexture()
	
	-- draw background
	if !table.IsEmpty(self.backg) and self.drawback == true then
		surface.SetDrawColor(self.backcol)
		draw.PartCircle( self.backg.cir1, self.backg.cir2 ) -- see draw_func.lua
	end
	
	-- draw data segments
	if !table.IsEmpty(self.gdata) then
		for k, seg in ipairs( self.gdata ) do
			if seg.cir1 != nil and !table.IsEmpty(seg.cir1) then
				surface.SetDrawColor(seg.col)
				draw.PartCircle( seg.cir1, seg.cir2 ) -- see draw_func.lua
				if self.drawback then
					surface.SetDrawColor(self.backcol)
					if self.backthick > 1 then -- draw lines between segments
						surface.DrawTexturedRectRotated( (seg.cir1[1].x + seg.cir2[1].x) / 2, (seg.cir1[1].y + seg.cir2[1].y) / 2, self.radius2-self.radius1-1, self.backthick, -seg.ang1 )
					else
						surface.DrawLine( seg.cir1[1].x, seg.cir1[1].y, seg.cir2[1].x, seg.cir2[1].y )
						surface.DrawLine( seg.cir1[#seg.cir1].x, seg.cir1[#seg.cir1].y, seg.cir2[#seg.cir2].x, seg.cir2[#seg.cir2].y )
					end
				end
			end
		end
		if self.drawback == true and self.backthick > 1 then
			surface.DrawRect( w/2 + self.radius1, h / 2, self.radius2-self.radius1-1, self.backthick ) -- last line
		end
	end
	
end

function PANEL:AddData( data, colour )

	colour = colour or HSVToColor( math.Rand( 0, 12 )*30, 1, 1 )
	
	table.insert( self.gdata, {data = tonumber(data), col = colour, ang1 = 0, ang2 = 0, csw = 0, dsw = 0} )
	self.numsum = self.numsum + tonumber(data)
	
end

function PANEL:ClearData()
	
	self.gdata = {}
	self.numsum = 0
	
end

function PANEL:Animate()
	
	self.pani = 0
	for k, entry in ipairs( self.gdata ) do
		local csw = entry.ang2 - entry.ang1							-- current segment width
		local tsw = ( entry.data / self.numsum ) * 360				-- target segment width (degrees)
		self.gdata[k].csw = csw										-- save csw
		self.gdata[k].dsw = ( tsw - csw ) / ( 100 / self.speed )	-- delta segment width
	end
	
end

function PANEL:Plot()
	
	self.pani = 99.99
	for k, entry in ipairs( self.gdata ) do
		local csw = entry.ang2 - entry.ang1
		local tsw = ( entry.data / self.numsum ) * 360
		self.gdata[k].csw = csw
		self.gdata[k].dsw = ( tsw - csw ) / ( 100 / self.speed )
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
	
	if col == nil or col == false then
		self.drawback = false
	elseif IsColor(col) then
		self.drawback = true
		self.backcol = ColorAlpha( col, 255 )
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
		self.thinktick = CurTime() + 0.0167 -- ~60 fps
		local w, h = self:GetWide()/2, self:GetTall()/2 -- center
		
		if self.pani < 100 then
			self.pani = self.pani + self.speed
			local pos = 0
			if self.pani < 100 then
				for k, entry in ipairs( self.gdata ) do
					local dsw = entry.csw + self.pani * entry.dsw -- difference between -> movement
					
					if self.drawback then
						self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1 + self.backthick, self.radius2 - self.backthick, pos, pos + dsw )
					else
						self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + dsw )
					end
					
					self.gdata[k].ang1 = pos
					pos = pos + dsw
					self.gdata[k].ang2 = pos
				end
				if self.drawback then
					self.backg.cir1, self.backg.cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, 0, math.max(self.trot,pos) )
				end
			else
				self.pani = 100
				for k, entry in ipairs( self.gdata ) do
					local dsw = ( entry.data / self.numsum ) * 360 -- 100% movement
					
					if self.drawback then
						self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1 + self.backthick, self.radius2 - self.backthick, pos, pos + dsw )
					else
						self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + dsw )
					end
					
					self.gdata[k].ang1 = pos
					pos = pos + dsw
					self.gdata[k].ang2 = pos
				end
				if self.drawback then
					self.backg.cir1, self.backg.cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, 0, 360 )
				end
			end
			self.trot = pos
		end
	end
	
end

vgui.Register( "GPie", PANEL, "EditablePanel" )
print("GPie vgui element by Cptn.Sheep. https://github.com/akersda" )