local args = { ... }
if #args ~= 5 then
	error("Usage: item_fetcher <drone id> <item name> <x> <y> <z>")
end

local controller = require("drone_controller")
local msg = require("msg")

local droneId = tonumber(args[1])
local itemName = args[2]
local chestPos = vector.new(args[3], args[4], args[5])

local function goTo (_pos)
	success, result = false, nil
	repeat
		success, result = controller.goTo(droneId, _pos)
		if not success then
			if result == "Movement obstructed" then
				_, data = controller.inspect(droneId)
				if data ~= nil and (string.find(data.name, "chest") or string.find(data.name, "turtle")) then
					success = true
				end
			else
				-- in case of fuel, another drone will see status and refill it
				print(result)
				os.sleep(2)
			end
		end
	until success
end

local function tryRefill ()
	local slots = controller.findItem(droneId, itemName)
	if #slots == 0 then
		-- go to refill chest
		goTo(chestPos)
		-- loop through each slot and refill with items
		for i=1,16 do
			if controller.getItemCount(droneId, i) == 0 then
				controller.suck(droneId)
			end
		end
	end
end

-- main

controller.open()

while true do
	tryRefill()

	local senderId, msgType, msgBody = nil, nil, nil

	-- wait for fetch requests
	repeat
		senderId, msgType, msgBody = msg.receive()
	until msgType ~= nil and string.find(msgType, "fetcher")

	if msgType == "fetcher_get" then
		local requestedItem = msgBody.item
		local deliveryPos = msgBody.pos

		-- check that we have the material the requestor wants
		if requestedItem == itemName then
			-- go to delivery position
			goTo(deliveryPos)
			-- drop off materials
			-- todo: check for space first
			-- todo: run a loop to make sure the inv is still there while dropping
			for _, slot in ipairs(controller.findItem(droneId, itemName)) do
				controller.select(droneId, slot)
				controller.drop(droneId)
			end
		end
	end

end