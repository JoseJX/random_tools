at1 = nil
at2 = nil
at3 = nil

-- Setup the actors
at1 = Actor:create(nil, nil, nil, "at1")
at2 = Actor:create(nil, nil, nil, "at2")
at3 = Actor:create(nil, nil, nil, "at3")

at1:setpos(1,4,5)
at1:setrot(5, 15, 25)

at2:setpos(3, -2, -1)
at2:setrot(15, 25, 35)

at1:attach(at2, nil)

at3:setpos(-3, -4, 2)
at3:setrot(12, 16, 18)

at2:attach(at3, nil)

-- Dump Actor Positions
DAP = function()
	local p1 = at1:getpos()
	dd = "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = at2:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = at3:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
end

-- Dump Actor World-Positions
DAW = function()
	local p1 = at1:getworldpos()
	dd = "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = at2:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = at3:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
end

-- Dump Actor Rotation
DAR = function()
	local p1 = at1:getrot()
	dd = "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = at2:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = at3:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
end
