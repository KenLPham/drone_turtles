local module = {}

function module.has_value (_arr, _element)
	for i, element in ipairs(_arr) do
		if element == _element then
			return true
		end
	end
	return false
end