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

-- ! most methods follow turtle API https://tweaked.cc/module/turtle.html

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

function dig(_recipient, _side, _dir)
	msg.send("drone_dig", { side = _side, dir = _dir }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_dig", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, nil
end

-- Attempt to break the block in front of the turtle.
--
-- This requires a turtle tool capable of breaking the block. 
-- Diamond pickaxes (mining turtles) can break any vanilla block, 
-- but other tools (such as axes) are more limited.
--
-- @param number _recipient Drone ID
-- @param string _side The specific tool to use. Should be "left" or "right".
-- @return
--	boolean Whether the block was broken.
--	string|nil The reason the block was not broken.
function module.dig(_recipient, _side)
	return dig(_recipient, _side, 0)
end

-- Attempt to break the block above the turtle.
--
-- @param number _recipient Drone ID
-- @param string _side The specific tool to use. Should be "left" or "right".
-- @return
--	boolean Whether the block was broken.
--	string|nil The reason the block was not broken.
function module.digUp(_recipient, _side)
	return dig(_recipient, _side, 1)
end

-- Attempt to break the block below the turtle.
--
-- @param number _recipient Drone ID
-- @param string _side The specific tool to use. Should be "left" or "right".
-- @return
--	boolean Whether the block was broken.
--	string|nil The reason the block was not broken.
function module.digDown(_recipient, _side)
	return dig(_recipient, _side, 2)
end

function place (_recipient, _text, _dir)
	msg.send("drone_place", { text = _text, dir = _dir }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_place", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, nil
end

-- PlcaPlace a block or item into the world in front of the turtle.
--
-- "Placing" an item allows it to interact with blocks and entities 
-- in front of the turtle. For instance, buckets can pick up and place 
-- down fluids, and wheat can be used to breed cows. However, you 
-- cannot use place to perform arbitrary block interactions, 
-- such as clicking buttons or flipping levers.
--
-- @param string text When placing a sign, set its contents to this text. (optional)
-- @return
--	boolean Whether the block could be placed.
--	string|nil The reason the block was not placed.
function module.place (_recipient, _text)
	return place(_recipient, _text, 0)
end

function module.placeUp (_recipient, _text)
	return place(_recipient, _text, 1)
end

function module.placeDown (_recipient, _text)
	return place(_recipient, _text, 2)
end

function drop (_recipient, _count, _dir)
	msg.send("drone_drop", { count = _count, dir = _dir }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_drop", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, nil
end

-- Drop the currently selected stack into the inventory in front of the turtle, or as an item into the world if there is no inventory.
--
-- @param number count The number of items to drop. If not given, the entire stack will be dropped. (optional)
-- @return
--	boolean Whether items were dropped.
--	string|nil The reason the no items were dropped.
function module.drop(_recipient, _count)
	return drop(_recipient, _count, 0)
end

-- Drop the currently selected stack into the inventory above the turtle, or as an item into the world if there is no inventory.
--
-- @param number count The number of items to drop. If not given, the entire stack will be dropped. (optional)
-- @return
--	boolean Whether items were dropped.
--	string|nil The reason the no items were dropped.
function module.dropUp(_recipient, _count)
	return drop(_recipient, _count, 1)
end

-- Drop the currently selected stack into the inventory below the turtle, or as an item into the world if there is no inventory.
--
-- @param number _recipient Drone ID
-- @param number count The number of items to drop. If not given, the entire stack will be dropped. (optional)
-- @return
--	boolean Whether items were dropped.
--	string|nil The reason the no items were dropped.
function module.dropDown(_recipient, _count)
	return drop(_recipient, _count, 2)
end

-- Change the currently selected slot.
-- The selected slot is determines what slot actions like drop or getItemCount act on.
--
-- @param number _recipient Drone ID
-- @param number _slot The slot to select
-- @return true When the slot has been selected.
function module.select(_recipient, _slot)
	-- todo: limit slot to 1 to 16
	msg.send("drone_select", _slot, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_select" })
	return msgBody
end

-- Get the number of items in the given slot.
--
-- @param number _recipient Drone ID
-- @param number _slot The slot we wish to check. Defaults to the selected slot. (optional)
-- @return
--	number The number of items in this slot.
function module.getItemCount(_recipient, _slot)
	msg.send("drone_itemcount", _slot, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_itemcount" })
	return msgBody
end

-- Get the remaining number of items which may be stored in this stack.
--
-- For instance, if a slot contains 13 blocks of dirt, it has room for another 51.
--
-- @param number _recipient Drone ID
-- @param number _slot The slot we wish to check. Defaults to the selected slot. (optional)
-- @return
--	number The space left in in this slot.
function module.getItemSpace(_recipient, _slot)
	msg.send("drone_itemspace", _slot, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_itemspace" })
	return msgBody
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

function compare(_recipient, _dir)
	msg.send("drone_compare", _dir, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_compare" })
	return msgBody.equal
end

-- Check if the block in front of the turtle is equal to the item in the currently selected slot.
--
-- @param number _recipient Drone ID
-- @return
--	boolean If the block and item are equal.
function module.compare(_recipient)
	return compare(_recipient, 0)
end

-- Check if the block above the turtle is equal to the item in the currently selected slot.
--
-- @param number _recipient Drone ID
-- @return
--	boolean If the block and item are equal.
function module.compareUp(_recipient)
	return compare(_recipient, 1)
end

-- Check if the block below the turtle is equal to the item in the currently selected slot.
--
-- @param number _recipient Drone ID
-- @return
--	boolean If the block and item are equal.
function module.compareDown(_recipient)
	return compare(_recipient, 2)
end

function attack(_recipient, _side, _dir)
	msg.send("drone_attack", { side = _side, dir = _dir }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_attack", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, nil
end

-- Attack the entity in front of the turtle.
--
-- @param string side The specific tool to use. (optional)
-- @return
--	boolean Whether an entity was attacked.
--	string|nil The reason nothing was attacked.
function module.attack(_recipient, _side)
	return attack(_recipient, _side, 0)
end

-- Attack the entity above the turtle.
--
-- @param string side The specific tool to use. (optional)
-- @return
--	boolean Whether an entity was attacked.
--	string|nil The reason nothing was attacked.
function module.attackUp(_recipient, _side)
	return attack(_recipient, _side, 1)
end

-- Attack the entity below the turtle.
--
-- @param string side The specific tool to use. (optional)
-- @return
--	boolean Whether an entity was attacked.
--	string|nil The reason nothing was attacked.
function module.attackDown(_recipient, _side)
	return attack(_recipient, _side, 2)
end

function suck (_recipient, _count, _dir)
	msg.send("drone_suck", { count = _count, dir = _dir }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_suck", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, nil
end

-- Suck an item from the inventory in front of the turtle, or from an item floating in the world.
--
-- This will pull items into the first acceptable slot, starting at the currently selected one.
function module.suck(_recipient, _count)
	return suck(_recipient, _count, 0)
end

function module.suckUp(_recipient, _count)
	return suck(_recipient, _count, 1)
end

function module.suckDown(_recipient, _count)
	return suck(_recipient, _count, 2)
end

function module.compareTo(_recipient, _slot)
	msg.send("drone_compareto", _slot, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_compareto" })
	return msgBody
end

function module.transferTo(_recipient, _slot, _count)
	msg.send("drone_transferto", { slot = _slot, count = _count }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_transferto" })
	return msgBody
end

function module.getSelectedSlot(_recipient)
	msg.send("drone_selected", nil, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_selected" })
	return msgBody
end

function equip (_recipient, _side)
	msg.send("drone_equip", _side, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_equip", "drone_status" })
	if msgType == "drone_status" then
		return false, msgBody
	end
	return true, nil
end

function module.equipLeft(_recipient)
	return equip(_recipient, 0)
end

function module.equipRight(_recipient)
	return equip(_recipient, 1)
end

function module.getItemDetail(_recipient, _slot, _detailed)
	msg.send("drone_itemdetail", { slot = _slot, detailed = _detailed }, _recipient)
	msgType, msgBody = waitForResponse(_recipient, { "drone_itemdetail" })
	return msgBody
end

return module