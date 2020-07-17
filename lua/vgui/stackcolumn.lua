local PANEL = {}

function PANEL:Init()
	
	self.gdata = {}
	self.numsum = 0
	
	self.thinktick = CurTime()
	
end

function PANEL:Paint( w, h )
	
	draw.NoTexture()
	
end

function PANEL:AddData( data, name, colour )
	
	if name == nil or !isstring(name) then name = "unknown" end
	if colour == nil or !IsColor(colour) then colour = HSVToColor( #self.gdata*30, 1, 1 ) end
	
	table.insert( self.gdata, {data = tonumber(data), name = name, col = colour} )
	self.numsum = self.numsum + tonumber(data)
	
end

function PANEL:Think()
	
	if self.thinktick < CurTime() then
		self.thinktick = CurTime() + 0.0333 -- ~30 fps
	end
	
end

vgui.Register( "GStackColumn", PANEL, "EditablePanel" )
print("GStackColumn vgui element by Cptn.Sheep. https://github.com/akersda" )