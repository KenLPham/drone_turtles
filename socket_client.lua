local socket = assert(http.websocket("ws://192.168.1.189:8000"))

-- ? load modules to global
_G.gpsmove = require("gpsmove")
_G.tps = require("tps")
_G.std = require("std")
_G.tstd = require("std_turtle")
_G.msg = require("msg")


while true do
	local msgString, isBinary = socket.receive()
	local msg = textutils.unserializeJSON(msgString)
	if msg.type == "eval" then
		local result = { _G[msg.module][msg.method](unpack(msg.args)) }
		local responseMsg = textutils.serializeJSON({ type = "res", origin = msg, body = result })
		socket.send(responseMsg)
	end
end