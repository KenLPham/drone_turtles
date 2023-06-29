-- ? https://pastebin.com/mWMv7rtr

local module = { ... }

local tps = require("tps")

-- Turn to a given direction
-- 0 = north, 1 = west, 2 = south, 3 = east
--
-- Returns:
--	boolean Whether the turtle could successfully turn.
--	string | nil The reason the turtle could not turn.
function module.turnTo (_dir)
	goLeft = _dir > tps.dir
	if tps.dir ~= _dir then
		repeat
			if goLeft then
				success, reason = tps.turnLeft()
				if not success then
					return success, reason
				end
			else
				success, reason = tps.turnRight()
				if not success then
					return success, reason
				end
			end
		until tps.dir == _dir
	end

	return true, nil
end

-- Move along the X axis
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function moveToX (_x)
	-- set direction
	if tps.pos.x < _x then
		module.turnTo(3) -- east
	elseif tps.pos.x > _x then
		module.turnTo(1) -- west
	end
	-- move
	repeat
		success, reason = tps.forward()
		-- stop loop if move can't be made and return error if there is one
		if not success then
			return success, reason
		end
	until tps.pos.x == _x

	return true, nil
end

-- Move along the Z axis
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function moveToZ (_z)
	-- set direction
	if tps.pos.z < _z then
		module.turnTo(2) -- south
	elseif tps.pos.z > _z then
		module.turnTo(0) -- north
	end
	-- move
	repeat
		success, reason = tps.forward()
		-- stop loop if move can't be made and return error if there is one
		if not success then
			return success, reason
		end
	until tps.pos.z == _z

	return true, nil
end

-- Move along the Y axis
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function moveToY (_y)
	if tps.pos.y < _y then
		repeat
			success, reason = tps.up()
			-- stop loop if move can't be made and return error if there is one
			if not success then
				return success, reason
			end
		until tps.pos.y == _y
	elseif tps.pos.y < _y then
		repeat
			success, reason = tps.down()
			-- stop loop if move can't be made and return error if there is one
			if not success then
				return success, reason
			end
		until tps.pos.y == _y
	end

	return true, nil
end

-- Move to the given coordinates
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function module.goTo (x, y, z)
	xSuccess, xReason = moveToX(x)
	if not xSuccess then
		return xSuccess, xReason
	end
	ySuccess, yReason = moveToY(y)
	if not ySuccess then
		return ySuccess, yReason
	end
	zSuccess, zReason = moveToZ(z)
	if not zSuccess then
		return zSuccess, zReason
	end
	return true, nil
end

-- Convience function to move to the given coordinates
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function module.goTo (vector)
	return module.goTo(vector.x, vector.y, vector.z)
end

return module