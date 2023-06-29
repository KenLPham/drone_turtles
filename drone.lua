local module = {}

local tps = require("tps")
local gpsmove = require("gpsmove")
local msg = require("msg")

function module.calibrate (name, protocol)
	-- setup rednet
	msg.open(protocol or "drone")
	rednet.host(msg.protocol, name)

	-- check fuel level
	if turtle.getFuelLevel() == 0 then
		success, reason = turtle.refuel()
		if not success then
			error(reason)
		end
	end

	-- setup gps
	tps.calibrate()
end

-- broadcast or send to recipient the location of turtle
function module.sendLocationUpdate (_recipient)
	pos, dir = tps.getLocation()
	body = {
		pos = pos,
		dir = dir
	}

	msg.broadcastOrSend("drone_location", body, _recipient)
end

-- send status messages (like out of fuel, stuck, etc)
function module.sendStatusMessage(_msg)
	msg.broadcast("drone_status", _msg)
end

function handleMovementMessage (_success, _reason)
	if _success then
		module.sendLocationUpdate()
	else
		module.sendStatusMessage(_reason)
	end
end

function handleGoToMessage (_pos, _dir)
	goSuccess, goReason = gpsmove.goTo(_pos)
	if goSuccess then
		if _dir ~= nil then
			turnSuccess, turnReason = gpsmove.turnTo(_dir)
			if not turnSuccess then
				module.sendStatusMessage(turnReason)
			end
		end
		module.sendLocationUpdate()
	else
		module.sendStatusMessage(goReason)
	end
end

function module.sendFuelStats (_recipient)
	body = {
		limit = turtle.getFuelLimit(),
		level = turtle.getFuelLevel()
	}
	msg.broadcastOrSend("drone_fuel", body, _recipient)
end


-- Wait to receive messages from controller.
-- Any turtle API messages (movement, detect, etc) 
-- will be handled internally and returned.
--
-- Returns:
--	string Sender ID
--	string Message Type
--	string Message Body
function module.receive ()
	senderId, msgType, msgBody = msg.receive()

	if msgType == "drone_forward" then
		success, reason = tps.forward()
		handleMovementMessage(success, reason)
	elseif msgType == "drone_back" then
		success, reason = tps.back()
		handleMovementMessage(success, reason)
	elseif msgType == "drone_left" then
		success, reason = tps.turnLeft()
		handleMovementMessage(success, reason)
	elseif msgType == "drone_right" then
		success, reason = tps.turnRight()
		handleMovementMessage(success, reason)
	elseif msgType == "drone_goto" then
		handleGoToMessage(msgBody.pos, msgBody.dir)
	elseif msgType == "drone_fuel" then
		module.sendFuelStats(senderId)
	elseif msgType == "drone_refuel" then
		success, reason = turtle.refuel(msgBody)
		if success then
			module.sendFuelStats(senderId)
		else
			module.sendStatusMessage(reason)
		end
	elseif msgType == "drone_inspect" then
		has_block, data = false, nil
		if msgBody == 0 then
			has_block, data = turtle.inspect()
		elseif msgBody == 1 then
			has_block, data = turtle.inspectUp()
		elseif msgBody == 2 then
			has_block, data = turtle.inspectDown()
		end
		msg.send("drone_inspect", { has_block = has_block, data = data, dir = msgBody }, senderId)
	elseif msgType == "drone_detect" then
		has_block = false
		if msgBody == 0 then
			has_block = turtle.detect()
		elseif msgBody == 1 then
			has_block = turtle.detectUp()
		elseif msgBody == 2 then
			has_block = turtle.detectDown()
		end
		msg.send("drone_detect", { has_block = has_block, dir = msgBody }, senderId)
	elseif msgType == "drone_location" then
		module.sendLocationUpdate(senderId)
	end

	-- todo: don't return anything when handling internal types?
	
	return senderId, msgType, msgBody
end

return module