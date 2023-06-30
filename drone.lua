local module = {}

local tps = require("tps")
local gpsmove = require("gpsmove")
local msg = require("msg")
local tstd = require("std_turtle")

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

function handleDigMessage(_recipient, _dir, _side)
	success, reason = false, nil
	if _dir == 0 then
		success, reason = turtle.dig(_side)
	elseif _dir == 1 then
		success, reason = turtle.digUp(_side)
	elseif _dir == 2 then
		success, reason = turtle.digDown(_side)
	end

	if success then
		msg.send("drone_dig", { dir = _dir }, _recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handlePlaceMessage(_recipient, _dir, _text)
	success, reason = false, nil
	if _dir == 0 then
		success, reason = turtle.place(_text)
	elseif _dir == 1 then
		success, reason = turtle.placeUp(_text)
	elseif _dir == 2 then
		success, reason = turtle.placeDown(_text)
	end

	if success then
		msg.send("drone_place", { dir = _dir }, _recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handleDropMessage(_recipient, _dir, _count)
	success, reason = false, nil
	if _dir == 0 then
		success, reason = turtle.drop(_count)
	elseif _dir == 1 then
		success, reason = turtle.dropUp(_count)
	elseif _dir == 2 then
		success, reason = turtle.dropDown(_count)
	end

	if success then
		msg.send("drone_drop", { dir = _dir }, _recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handleSelect(_recipient, _slot)
	success = turtle.select(_slot)
	msg.send("drone_select", success, _recipient)
end

function handleGetItemCount(_recipient, _slot)
	count = turtle.getItemCount(_slot)
	msg.send("drone_itemcount", count, _recipient)
end

function handleGetItemSpace (_recipient, _slot)
	space = turtle.getItemSpace(_slot)
	msg.send("drone_itemspace", space, _recipient)
end

function handleRefuel(_recipient, _count)
	success, reason = turtle.refuel(_count)
	if success then
		module.sendFuelStats(_recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handleInspectMessage(_recipient, _dir)
	hasBlock, data = false, nil
	if _dir == 0 then
		hasBlock, data = turtle.inspect()
	elseif _dir == 1 then
		hasBlock, data = turtle.inspectUp()
	elseif _dir == 2 then
		hasBlock, data = turtle.inspectDown()
	end
	msg.send("drone_inspect", { hasBlock = hasBlock, data = data, dir = _dir }, _recipient)
end

function handleDetectMessage(_recipient, _dir)
	hasBlock = false
	if _dir == 0 then
		hasBlock = turtle.detect()
	elseif _dir == 1 then
		hasBlock = turtle.detectUp()
	elseif _dir == 2 then
		hasBlock = turtle.detectDown()
	end
	msg.send("drone_detect", { hasBlock = hasBlock, dir = _dir }, _recipient)
end

function handleCompare(_recipient, _dir)
	equal = false
	if _dir == 0 then
		equal = turtle.compare()
	elseif _dir == 1 then
		equal = turtle.compareUp()
	elseif _dir == 2 then
		equal = turtle.compareDown()
	end
	msg.send("drone_compare", { equal = equal, dir = _dir }, _recipient)
end

function handleAttack(_recipient, _dir, _side)
	success, reason = false, nil
	if _dir == 0 then
		success, reason = turtle.attack(_side)
	elseif _dir == 1 then
		success, reason = turtle.attackUp(_side)
	elseif _dir == 2 then
		success, reason = turtle.attackDown(_side)
	end

	if success then
		msg.send("drone_attack", { dir = _dir }, _recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handleSuck (_recipient, _dir, _count)
	success, reason = false, nil
	if _dir == 0 then
		success, reason = turtle.suck(_count)
	elseif _dir == 1 then
		success, reason = turtle.suckUp(_count)
	elseif _dir == 2 then
		success, reason = turtle.suckDown(_count)
	end

	if success then
		msg.send("drone_suck", { dir = _dir }, _recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handleCompareTo (_recipient, _slot)
	equal = turtle.compareTo(_slot)
	msg.send("drone_compareto", equal, _recipient)
end

function handleTransferTo (_recipient, _slot, _count)
	success = turtle.transferTo(_slot, _count)
	msg.send("drone_transferto", success, _recipient)
end

function handleGetSelectedSlot (_recipient)
	slot = turtle.getSelectedSlot()
	msg.broadcastOrSend("drone_selected", slot, _recipient)
end

function handleEquip (_recipient, _side)
	success, reason = false, nil
	if _side == 0 then
		success, reason = turtle.equipLeft()
	elseif _side == 1 then
		success, reason = turtle.equipRight()
	end
	
	if success then
		msg.send("drone_equip", { side = _side }, _recipient)
	else
		module.sendStatusMessage(reason)
	end
end

function handleGetItemDetail (_recipient, _slot, _detailed)
	details = turtle.getItemDetail(_slot,  _detailed)
	msg.send("drone_itemdetail", details, _recipient)
end

function handleFind(_recipient, _name)
	slots = tstd.findItem(_name)
	msg.send("drone_find", slots, _recipient)
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
	elseif msgType == "drone_dig" then
		handleDigMessage(senderId, msgBody.dir, msgBody.side)
	elseif msgType == "drone_place" then
		handlePlaceMessage(senderId, msgBody.dir, msgBody.text)
	elseif msgType == "drone_drop" then
		handleDropMessage(senderId, msgBody.dir, msgBody.count)
	elseif msgType == "drone_select" then
		handleSelect(senderId, msgBody)
	elseif msgType == "drone_itemcount" then
		handleGetItemCount(senderId, msgBody)
	elseif msgType == "drone_itemspace" then
		handleGetItemSpace(senderId, msgBody)
	elseif msgType == "drone_compare" then
		handleCompare(senderId, msgBody)
	elseif msgType == "drone_attack" then
		handleAttack(senderId, msgBody.dir, msgBody.side)
	elseif msgType == "drone_suck" then
		handleSuck(senderId, msgBody.dir, msgBody.count)
	elseif msgType == "drone_fuel" then
		module.sendFuelStats(senderId)
	elseif msgType == "drone_refuel" then
		handleRefuel(senderId, msgType)
	elseif msgType == "drone_inspect" then
		handleInspectMessage(senderId, msgBody)
	elseif msgType == "drone_detect" then
		handleDetectMessage(senderId, msgBody)
	elseif msgType == "drone_location" then
		module.sendLocationUpdate(senderId)
	elseif msgType == "drone_compareto" then
		handleCompareTo(senderId, msgBody)
	elseif msgType == "drone_transferto" then
		handleTransferTo(senderId, msgBody.slot, msgBody.count)
	elseif msgType == "drone_selected" then
		handleGetSelectedSlot()
	elseif msgType == "drone_equip" then
		handleEquip(senderId, msgBody)
	elseif msgType == "drone_itemdetail" then
		handleGetItemDetail(senderId, msgBody.slot, msgBody.detailed)
	elseif msgType == "drone_find" then
		handleFind(senderId, msgBody)
	end

	-- todo: don't return anything when handling internal types?
	
	return senderId, msgType, msgBody
end

return module