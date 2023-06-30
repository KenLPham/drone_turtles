local drone = require("drone")

drone.calibrate(tostring(os.computerID()))

local done = false
while not done do
	-- todo: handle exiting loop somehow
	senderId, msgType, msgBody = drone.receive()
	print(string.format("[%s] %d> %s", msgType, senderId, textutils.serialize(msgBody)))
end