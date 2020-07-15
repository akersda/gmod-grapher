function draw.CalcVertsPartCir( a, b, inrad, outrad, stdeg, endeg )
	
	-- dont bother if too small
	if (endeg - stdeg) < 1 then return {} end
	
	-- setup circle 1 and 2
	local cir1 = {}
	local cir2 = {}
	
	-- calculate number of points
	local numverts = 2 + math.floor( (endeg - stdeg) / 6 )
	
	-- convert to radians
	stdeg = math.rad(stdeg)
	endeg = math.rad(endeg)
	
	local porot = stdeg -- point rotation (radians)
	local diffrot = (endeg - stdeg) / (numverts - 1) -- difference in rotation of points (radians)
	
	-- calc x,y points
	for i = 1,numverts do
	
		local cosdeg = math.cos(porot) -- triangular width
		local sindeg = math.sin(porot) -- triangular height
		
		table.insert( cir1, { x = outrad * cosdeg + a , y = outrad * sindeg + b } ) -- outer circle
		table.insert( cir2, { x = inrad * cosdeg + a , y = inrad * sindeg + b } ) -- inner circle
		
		porot = porot + diffrot -- reposition rotation
		
	end
	
	-- output
	return cir1, cir2
	
end

function draw.PartCircle( cir1, cir2 )
	
	for i = 2,#cir1 do
		surface.DrawPoly( {
			[1] = cir1[i-1],
			[2] = cir1[i],
			[3] = cir2[i],
			[4] = cir2[i-1]
		})
	end

end