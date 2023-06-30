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
				_, metadata = controller.detect(droneId)
				if string.find(metadata.name, "chest") then
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

-- main

controller.open()

while true do
	local senderId, msgType, msgBody = nil, nil, nil

	-- wait for fetch requests
	repeat
		senderId, msgType, msgBody = = msg.receive()
	until msgType ~= nil and string.find(msgType, "fetcher")

	if msgType == "fetcher_get" then
		local requestedItem = msgBody.item
		local deliveryPos = msgBody.pos

		-- check that we have the material the requestor wants
		if requestedItem == itemName then
			-- todo: getting on top of delivery location would be easier but no pathfinding yet so drone would just get stuck
			-- go to delivery position
			goTo(deliveryPos)
			-- drop off materials
			-- todo: check for space first
			for _, slot in controller.findItem(droneId, itemName) do
				controller.select(droneId, slot)
				controller.drop(droneId)
			end
		end
	end

end