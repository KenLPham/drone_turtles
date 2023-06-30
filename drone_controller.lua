local module = {}

local std = require("std")
local msg = require("msg")

function module.open (protocol)
	-- setup rednet
	msg.open(protocol or "drone")
end

function module.drones ()
	result = rednet.lookup(msg.protocol)
	if result ~= nil then
		return { result }
	end
	return {}
end

function waitForResponse (_recipient, _types, _timeout)
	senderId, msgType, msgBody = nil, nil, nil
	repeat
		-- todo: abandon loop if timeout is met
		senderId, msgType, msgBody = msg.receive(_timeout)
	until senderId == _recipient and std.has_value(_types, msgType)

	return msgType, msgBody
end

-- Get location of drone
--
-- @param number _recipient Drone ID
-- @return
--	vector Position
--	number Direction
function module.getLocation (_recipient)
	msg.send("drone_location", nil, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_location" })
	return msgBody.pos, msgBody.dir
end

function module.forward (_recipient)
	msg.send("drone_forward", nil, _recipient)
	return waitForResponse(_recipient, { "drone_location", "drone_status" })
end

function module.back (_recipient)
	msg.send("drone_back", nil, _recipient)
	return waitForResponse(_recipient, { "drone_location", "drone_status" })
end

function module.turnLeft (_recipient)
	msg.send("drone_left", nil, _recipient)
	return waitForResponse(_recipient, { "drone_location", "drone_status" })
end

function module.turnRight (_recipient)
	msg.send("drone_right", nil, _recipient)
	return waitForResponse(_recipient, { "drone_location", "drone_status" })
end

-- Tell drone to go to position and face a specific direction if provided
--
-- @param number _recipient Drone ID
-- @param vector _pos Position to go to
-- @param number _dir Direction to face when at position (optional)
-- @return
--	boolean indicate if drone was able to move to position
--	table|string table with position and direction of turtle or string with reason for failure
function module.goTo (_recipient, _pos, _dir)
	msg.send("drone_goto", { pos = _pos, dir = _dir }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_location", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, msgBody
end

-- Get fuel level and limit of drone
--
-- @param number _recipient Drone ID
-- @return
--	number fuel level
--	number|string fuel limit
function module.fuelStats (_recipient)
	msg.send("drone_fuel", nil, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_fuel" })
	return msgBody.level, msgBody.limit
end

-- Try to refuel drone
--
-- @param number _recipient Drone ID
-- @param number _count The maximum number of items to consume. One can pass 0 to check if an item is combustable or not. (optional)
-- @return
--	boolean indicate if drone was able to refuel
--	table|string table containing fuel level and limit or string with failure reason
function module.refuel (_recipient, _count)
	msg.send("drone_refuel", _count, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_fuel", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, msgBody
end

function inspect (_recipient, _dir)
	msg.send("drone_inspect", _dir, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_inspect" })
	return msgBody.hasBlock, msgBody.data
end

-- Inspect block infront of drone
--
-- @param number _recipient Drone ID
-- @return
--	boolean indicate if there is a block
--	table block metadata
function module.inspect(_recipient)
	return inspect(_recipient, 0)
end

-- Inspect block above drone
--
-- @param number _recipient Drone ID
-- @return
--	boolean indicate if there is a block
--	table block metadata
function module.inspectUp(_recipient)
	return inspect(_recipient, 1)
end

-- Inspect block below drone
--
-- @param number _recipient Drone ID
-- @return
--	boolean indicate if there is a block
--	table block metadata
function module.inspectDown(_recipient)
	return inspect(_recipient, 2)
end

function detect (_recipient, _dir)
	msg.send("drone_detect", _dir, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_detect" })
	return msgBody.hasBlock
end

-- Detect block infront of drone
--
-- @param number _recipient Drone ID
-- @return
--	boolean indicate if there is a block
function module.detect(_recipient)
	return detect(_recipient, 0)
end

-- Detect block above drone
--
-- @param number _recipient Drone ID
-- @return
--	boolean indicate if there is a block
function module.detectUp(_recipient)
	return detect(_recipient, 1)
end

-- Inspect block below drone
--
-- @param number _recipient Drone ID
-- @return
--	boolean indicate if there is a block
function module.detectDown(_recipient)
	return detect(_recipient, 2)
end

return module