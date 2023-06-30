local module = {}

-- Find item in inventory by name
function module.findItem (_name)
	slots = {}
	for i=1,16 do
		data = turtle.getItemDetail()
		if data ~= nil and string.find(data.name, _name) then
			table.insert(slots, i)
		end
	end
	return slots
end

return module