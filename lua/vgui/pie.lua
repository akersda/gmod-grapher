local PANEL = {}

function PANEL:Init()
	
	self.gdata = {}
	self.showname = false
	self.numsum = 0
	self.proc = 361
	self.radius1 = 100
	self.radius2 = 200
	self.speed = 15
	
	self.thinktick = CurTime()
	
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

function PANEL:Think()
	
	if self.thinktick < CurTime() then
		self.thinktick = CurTime() + 0.0333 -- 30 fps
		local w, h = self:GetWide()/2, self:GetTall()/2
		
		if self.proc <= 360 then
			local pos = 0
			for k, entry in ipairs( self.gdata ) do
				local sw = ( entry.data / self.numsum ) * self.proc
				self.gdata[k].cir1, self.gdata[k].cir2 = draw.CalcVertsPartCir( w, h, self.radius1, self.radius2, pos, pos + sw )
				pos = pos + sw
			end
			self.proc = self.proc + self.speed
		end
	end
	
end

vgui.Register( "GPie", PANEL, "EditablePanel" )
print("GPie vgui element by Cptn.Sheep. https://github.com/akersda" )