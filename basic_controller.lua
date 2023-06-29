local controller = require("drone_controller")

local args = { ... }
if #args == 0 then
	error("Usage: basic_controller <verb>")
end

local verb = args[1]

-- functions

local function getDrones ()
	drones = controller.drones()
	for i, drone in ipairs(drones) do
		msgType, msgBody = getLocation(_drone)
		print(string.format("%d (%d, %d, %d)", drone, msgBody.pos.x, msgBody.pos.y, msgBody.pos.z))
	end
end

local function getLocation (_drone)
	controller.getLocation(_drone)
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