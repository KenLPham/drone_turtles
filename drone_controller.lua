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

function module.getLocation (_recipient)
	msg.send("drone_location", nil, _recipient)
	return waitForResponse(_recipient, { "drone_location" })
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

function module.goTo (_recipient, _pos, _dir)
	msg.send("drone_goto", { pos = _pos, dir = _dir }, _recipient)
	return waitForResponse(_recipient, { "drone_location", "drone_status" })
end

function module.fuelStats (_recipient)
	msg.send("drone_fuel", nil, _recipient)
	return waitForResponse(_recipient, { "drone_fuel" })
end

function module.refuel (_recipient, _count)
	msg.send("drone_refuel", _count, _recipient)
	return waitForResponse(_recipient, { "drone_fuel", "drone_status" })
end

function inspect (_recipient, _dir)
	msg.send("drone_inspect", _dir, _recipient)
	-- todo: handle drone_inspect { has_block = has_block, dir = msgBody }
	return waitForResponse(_recipient, { "drone_inspect" })
end

function module.inspect(_recipient)
	return inspect(_recipient, 0)
end

function module.inspectUp(_recipient)
	return inspect(_recipient, 1)
end

function module.inspectDown(_recipient)
	return inspect(_recipient, 2)
end

function detect (_recipient, _dir)
	msg.send("drone_detect", _dir, _recipient)
	-- todo: handle drone_detect { has_block = has_block, dir = msgBody }
	return waitForResponse(_recipient, { "drone_detect" })
end

function module.detect(_recipient)
	return detect(_recipient, 0)
end

function module.detectUp(_recipient)
	return detect(_recipient, 1)
end

function module.detectDown(_recipient)
	return detect(_recipient, 2)
end

return module