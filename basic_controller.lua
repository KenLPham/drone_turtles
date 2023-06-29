local controller = require("drone_controller")

local args = { ... }
if #args == 0 then
	error("Usage: basic_controller <verb>")
end

local verb = args[1]
local dirs = { "north", "west", "south", "east" }

-- functions

local function getLocation (_drone)
	msgType, msgBody = controller.getLocation(_drone)
	print(string.format("Drone %d is located at (%d, %d, %d), facing %s", _drone, msgBody.pos.x, msgBody.pos.y, msgBody.pos.z, dirs[msgBody.dir + 1]))
end

local function getDrones ()
	drones = controller.drones()
	for i, drone in ipairs(drones) do
		msgType, msgBody = controller.getLocation(drone)
		print(string.format("%d (%d, %d, %d) %s", drone, msgBody.pos.x, msgBody.pos.y, msgBody.pos.z, dirs[msgBody.dir + 1]))
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
end