local controller = require("drone_controller")
local msg = require("msg")

local args = { ... }
if #args < 2 then
	error("Usage: block_placer <drone_id> <verb>")
end

local droneId = tonumber(args[1])
local verb = args[2]

local function waitForFuel ()
	local success = false
	repeat
		success = controller.refuel(droneId)
		os.sleep(2)
	until success
end

local function waitForBlock(_block)
	local slots = {}
	repeat
		print("waiting for", _block)
		-- broadcast request for materials
		local curPos = controller.getLocation(droneId)
		-- todo: make a fetcher API
		msg.broadcast("fetcher_get", { item = _block, pos = curPos })
		-- check for materials
		slots = controller.findItem(droneId, _block)
		-- pause program to not spam network
		os.sleep(2)
	until #slots > 0
	return slots
end

local function fill (_startPos, _endPos, _block)
	-- go to start
	local success, reason = controller.goTo(droneId, _startPos)

	if not success then
		if reason == "Out of fuel" then
			waitForFuel()
			success, reason = controller.goTo(droneId, _startPos)
		else
			error(string.format("Drone could not get to start point. Reason: %s", reason))
		end
	end

	-- go through each
	local incr = true
	zStep = 1
	if _endPos.z < _startPos.z then
		zStep = -1
	end
	for z=_startPos.z, _endPos.z, zStep do
		startpos, endpos = _startPos.x, _endPos.x
		xStep = 1
		if not incr then
			startpos, endpos = _endPos.x, _startPos.x
			xStep = -1
		end

		for x=startpos, endpos, xStep do
			-- todo: at some point do height
			local pos = vector.new(x, _startPos.y, z)
			success, reason = controller.goTo(droneId, pos)
			-- handle failures
			if not success then
				print(reason)
				-- todo: handle blocked
				if reason == "Out of fuel" then
					waitForFuel()
				end
			end
			-- place a block below if there is nothing there
			local slots = controller.findItem(droneId, _block)
			if #slots == 0 then
				slots = waitForBlock(_block)
			end
			-- already checked for item to place so only way this would fail is if there is a solid block. which we can ignore
			controller.select(droneId, slots[1])
			controller.placeDown(droneId)

			if x == endpos then
				incr = not incr
			end
		end
	end

	print(textutils.serialize(reason))
end

-- main

controller.open()

if verb == "fill" then
	if #args ~= 9 then
		error("Usage: block_placer <drone_id> fill <block> <start_x> <start_y> <start_z> <end_x> <end_y> <end_z>")
	end
	block = args[3]
	startPos = vector.new(args[4], args[5], args[6])
	endPos = vector.new(args[7], args[8], args[9])
	fill(startPos, endPos, block)
end

