local controller = require("drone_controller")

local args = { ... }
if #args == 0 then
	error("Usage: basic_controller <verb>")
end

local verb = args[1]
local dirs = { "north", "west", "south", "east" }

-- functions

local function getLocation (_drone)
	pos, dir = controller.getLocation(_drone)
	print(string.format("Drone %d is located at (%d, %d, %d), facing %s", _drone, pos.x, pos.y, pos.z, dirs[dir + 1]))
end

local function getDrones ()
	drones = controller.drones()
	for i, drone in ipairs(drones) do
		pos, dir = controller.getLocation(drone)
		print(string.format("%d (%d, %d, %d) %s", drone, pos.x, pos.y, pos.z, dirs[dir + 1]))
	end
end

-- main

controller.open()

if verb == "drones" then
	getDrones()
elseif verb == "locate" then
	if #args ~= 2 then
		error("Usage: basic_controller locate <drone ID>")
	end

	droneId = tonumber(args[2])
	getLocation(droneId)
elseif verb == "goto" then
	if #args ~= 5 then
		error("Usage: basic_controller goto <drone ID> <x> <y> <z>")
	end

	droneId = tonumber(args[2])
	x = tonumber(args[3])
	y = tonumber(args[4])
	z = tonumber(args[5])

	success, result = controller.goTo(droneId, vector.new(x, y, z), nil)
	if not success then
		if result == "Out of fuel" then
			success, result = controller.refuel(droneId)
			if success then
				success, result = controller.goTo(droneId, vector.new(x, y, z), nil)
			end
		end
	end
	print(success, textutils.serialize(result))
elseif verb == "refuel" then
	if #args ~= 2 then
		error("Usage: basic_controller refuel <drone ID>")
	end
	droneId = tonumber(args[2])
	success, result = controller.refuel(droneId)
	print(textutils.serialize(result))
end