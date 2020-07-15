local PANEL = {}

function PANEL:Init()
	
	self.gdata = {}
	self.showname = false
	self.numsum = 0
	self.proc = 360
	self.radius1 = 100
	self.radius2 = 200
	
end

function PANEL:Paint( w, h )
	
	if !table.IsEmpty(self.gdata) then
		draw.NoTexture()
		for k, seg in ipairs( self.gdata ) do
			if seg.cir1 != nil and !table.IsEmpty(seg.cir1) then
				surface.SetDrawColor(seg.col)
				draw.PartCircle( seg.cir1, seg.cir2 )
			end
		end
	end
	
end

function PANEL:AddData( data, name, colour )
	
	if type(data) != "number" then 
		print( "error: unexpected data entry in pie graph element" )
	else
		if name == nil or type(name) != "string" then name = "unknown" end
		if colour == nil or !IsColor(colour) then colour = HSVToColor( #self.gdata*30, 1, 1 ) end
		
		table.insert( self.gdata, {data = data, name = name, col = colour} )
		self.numsum = self.numsum + data
	end
	
end

function PANEL:RunCalc()
	
	self.proc = 0
	
end

function PANEL:SetRadius( num )
	
	if type(num) != "number" then 
		print( "error: unexpected radius entry in pie graph element" )
	else
		local thick = self.radius2 - self.radius1
		self.radius1 = num
		self.radius2 = num + thick
	end
	
end

function PANEL:SetThick( num )
	
	if type(num) != "number" then 
		print( "error: unexpected radius entry in pie graph element" )
	else
		self.radius2 = self.radius1 + num
	end
	
end

function PANEL:Think()
	
	local w, h = self:GetWide()/2, self:GetTall()/2
	
	if self.proc <= 360 then
		local pos = 0
		for k, entry in ipairs( self.gdata ) do
			local sw = ( entry.data / self.numsum ) * self.proc
			self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + sw )
			pos = pos + sw
		end
		self.proc = self.proc + 1
	end
	
end

vgui.Register( "GPie", PANEL, "EditablePanel" )