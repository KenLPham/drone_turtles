local controller = require("drone_controller")

local args = { ... }
if #args ~= 2 then
	error("Usage: block_placer <drone_id> <verb>")
end

local droneId = args[1]
local verb = args[2]

local function fill (_startPos, _endPos, _block)
	-- go to start
	success, reason = controller.goTo(_startPos)

	if not success then
		error(string.format("Drone could not get to start point. Reason: %s", reason))
	end

	-- go through each 
	for z=_startPos.z,_endPos.z do
		for x=_startPos.x,_endPos.x do
			-- todo: at some point do height
			pos = vector.new(x, _startPos.y, z)
			success, result = controller.goTo(pos)
			-- handle failures
			if not success then
				if result == "Out of fuel" then
					success, result = controller.refuel()
					if not success then
						print("Have to refuel manually")
						repeat
							success = controller.refuel()
						until success
					end
				end
			end
			-- place a block below if there is nothing there
			if not controller.detectDown() then
				slots = controller.findItem(_block)
				if #slots == 0 then
					print("need blocks")
					repeat
						controller.findItem(_block)
					until #slots > 0
				end
				controller.placeDown()
			end
		end
	end
end

-- main

controller.open()

if verb == "fill" then
	if #args ~= 9 then
		-- todo: optional coal and block chest pos
		error("Usage: block_placer <drone_id> fill <block> <start_x> <start_y> <start_z> <end_x> <end_y> <end_z>")
	end
	block = args[3]
	startPos = vector.new(args[4], args[5], args[6])
	endPos = vector.new(args[7], args[8], args[9])
	fill(startPos, endPos, block)
end

