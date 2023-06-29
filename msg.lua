local module = {
	protocol = nil
}

function open(protocol)
	module.protocol = protocol

	-- setup rednet
	modem = peripheral.find("modem") or error("No modem equipped on turtle.")
	side = peripheral.getName(modem)
	rednet.open(side)
end

function module.broadcast (_type, _body)
	rednet.broadcast({ type = _type, body = _body }, module.protocol)
end

function module.receive (timeout)
	senderId, message = rednet.receive(module.protocol, timeout)
	return senderId, message.type, message.body
end

function module.send(_type, _body, _recipient)
	rednet.send(_recipient, { type = _type, body = _body }, module.protocol)
end

function module.broadcastOrSend (_type, _body, _recipient)
	if _recipient ~= nil then
		module.send(_type, _body, _recipient)
	else
		module.broadcast(_type, _body)
	end


return module