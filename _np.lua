a1 = nil
a2 = nil
a3 = nil
a4 = nil
a5 = nil
a6 = nil
a7 = nil
a8 = nil
a9 = nil
a10 = nil
a11 = nil
a12 = nil

-- xxxx
a1 = Actor:create(nil, nil, nil, "a1")
a2 = Actor:create(nil, nil, nil, "a2")

a1:setpos(1,4,5)
a1:setrot(90, 0, 0)

a2:setpos(3, -2, -1);
a1:attach(a2, nil);

-- xxxx
a3 = Actor:create(nil, nil, nil, "a3")
a4 = Actor:create(nil, nil, nil, "a4")

a3:setpos(1, 4, 5)
a3:setrot(-90, 0, 0)

a4:setpos(3, -2, -1);
a3:attach(a4, nil);

-- xxxx
a5 = Actor:create(nil, nil, nil, "a5")
a6 = Actor:create(nil, nil, nil, "a6")

a5:setpos(1, 4, 5)
a5:setrot(0, 90, 0)

a6:setpos(3, -2, -1);
a5:attach(a6, nil);

-- xxxx
a7 = Actor:create(nil, nil, nil, "a7")
a8 = Actor:create(nil, nil, nil, "a8")

a7:setpos(1, 4, 5)
a7:setrot(0, -90, 0)

a8:setpos(3, -2, -1);
a7:attach(a8, nil);

-- xxxx
a9 = Actor:create(nil, nil, nil, "a9")
a10 = Actor:create(nil, nil, nil, "a10")

a9:setpos(1, 4, 5)
a9:setrot(0, 0, 90)

a10:setpos(3, -2, -1);
a9:attach(a10, nil);

-- xxxx
a11 = Actor:create(nil, nil, nil, "a11")
a12 = Actor:create(nil, nil, nil, "a12")

a11:setpos(1, 4, 5)
a11:setrot(0, 0, -90)

a12:setpos(3, -2, -1);
a11:attach(a12, nil);

dbg_actr_pos = function()
	local p1 = a2:getpos()
	dd = "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a4:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a6:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a8:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a10:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a12:getpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
end

dbg_actr_wpos = function()
	local p1 = a2:getworldpos()
	dd = "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a4:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a6:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a8:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a10:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a12:getworldpos()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
end

dbg_actr_rot = function()
	local p1 = a2:getrot()
	dd = "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a4:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a6:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a8:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a10:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
	local p1 = a12:getrot()
	dd = dd .. "(" .. p1["x"] .. "," .. p1["y"] .. "," .. p1["z"] .. ")\n"
end
