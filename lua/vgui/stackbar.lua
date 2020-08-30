local PANEL = {}

function PANEL:Init()
	
	self.gdata = {}						-- graph data
	self.numsum = 0						-- total sum of data
	self.cwsum = 0						-- total current width
	self.pani = 100						-- percentage of animation
	self.speed = 1						-- animation speed (def)
	self.drawback = false				-- should draw background (def)
	self.backcol = Color( 0,0,0,255 )	-- background colour (def)
	self.backthick = 1					-- background thickness (def)
	
	self.thinktick = CurTime()
	
end

function PANEL:Paint( w, h )
	
	draw.NoTexture()
	local posx = 0
	local offset = 0
	
	-- draw background
	if self.drawback == true then
		surface.SetDrawColor(self.backcol)
		surface.DrawRect(0,0,self.cwsum,h)
		posx = self.backthick
		offset = self.backthick
	end
	
	-- draw data segments
	if !table.IsEmpty(self.gdata) then
		for k, sec in ipairs( self.gdata ) do
			local swidth = math.Round(sec.cw)
			surface.SetDrawColor(sec.col)
			surface.DrawRect(posx,offset,swidth,h-2*offset)
			posx = posx + swidth
		end
	end
	
end

function PANEL:AddData( data, name, colour )
	
	name = tostring(name) or "unknown"
	colour = colour or HSVToColor( math.Rand( 0, 12 )*30, 1, 1 )
	
	table.insert( self.gdata, {data = tonumber(data), name = name, col = colour, cw = 0, dw = 0} )
	self.numsum = self.numsum + tonumber(data)
	
end

function PANEL:ClearData()
	
	self.gdata = {}
	self.numsum = 0
	
end

function PANEL:Animate()
	
	self.pani = 0
	for k, entry in ipairs( self.gdata ) do
		local tw = ( entry.data / self.numsum )						-- target width %
		self.gdata[k].dw = ( tw - entry.cw ) / ( 100 / self.speed )	-- delta width (cw is current width) %
	end
	
end

function PANEL:Plot()
	
	self.pani = 99.99
	for k, entry in ipairs( self.gdata ) do
		local tw = ( entry.data / self.numsum ) * 100
		self.gdata[k].dw = ( tw - entry.cw ) / ( 100 / self.speed )
	end
	
end

function PANEL:SetSpeed( num )
	
	self.speed = tonumber(num)
	
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
		if self.pani < 100 then
			self.pani = self.pani + self.speed
			if self.pani >= 100 then 
				local width = self:GetWide()
				self.cwsum = width
				if self.drawback == true then width = width - 2*self.backthick end
				for k, dat in ipairs(self.gdata) do
					self.gdata[k].cw = ( dat.data / self.numsum ) * width
				end
			else
				local width = self:GetWide()
				local cdw = 0
				if self.drawback == true then 
					width = width - 2*self.backthick 
					cdw = cdw + 2*self.backthick 
				end
				for k, dat in ipairs(self.gdata) do
					local new_w = dat.cw + dat.dw * width
					self.gdata[k].cw = new_w
					cdw = cdw + new_w
				end
				self.cwsum = cdw
			end
		end
	end
	
end

vgui.Register( "GStackBar", PANEL, "EditablePanel" )
print("GStackBar vgui element by Cptn.Sheep. https://github.com/akersda" )