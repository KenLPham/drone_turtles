local controller = require("drone_controller")
local astar = require("astar")

local args = { ... }
if #args ~= 7 then
	error("Usage: path_finder <drone id> <start x> <y> <z> <end x> <y> <z>")
end

local droneId = tonumber(args[1])
local startPos = vector.new(args[2], args[3], args[4])
local endPos = vector.new(args[5], args[6], args[7])

controller.open()

function validPos (_pos)
	local success, blocked, result = false, false, nil
	repeat
		success, result = controller.goTo(droneId, _pos)
		if not success then
			local curPos = controller.getLocation(droneId)
			if result == "Movement obstructed" then
				-- todo check that expected location is in front of us
				local diff = curPos - _pos
				if (diff.x <= 1 or diff.x >= -1) and (diff.y <= 1 or diff.y >= -1) and (diff.z <= 1 or diff.y >= 1) then
					success = true
					blocked = true
				end
			else
				-- in case of fuel, another drone will see status and refill it
				-- todo: send fetch request for fuel
				os.sleep(2)
			end
		end
	until success

	return not blocked
end

path = astar.findPath(startPos, endPos, validPos)
print(textutils.serialize(path))

