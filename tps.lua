local module = {
	-- initial position and direction
	initPos = nil,
	initDir = 0,
	-- current position and direction
	pos = nil,
	dir = 0
}

function isNorth ()
	return module.dir == 0
end

function isWest ()
	return module.dir == 1
end

function isSouth ()
	return module.dir == 2
end

function isEast ()
	return module.dir == 3
end

-- locate turtle and store initial location
function initLocation ()
	module.initPos = vector.new(gps.locate())
	module.pos = module.initPos
end

-- run through movement sequence to find initial direction
-- this method with throw an error if the initial location isn't set
function initDirection ()
	if module.initPos ~= nil then
		-- move forward
		if not turtle.forward() then
			error("Can't set face if turtle is blocked or has no fuel.")
		end
		-- get position
		newPos = vector.new(gps.locate())
		-- use difference with initial location to set direction
		posDiff = module.pos - newPos
		xDiff = posDiff.x
		zDiff = posDiff.y

		if xDiff > 0 then
            -- west
            module.initDir = 1
        elseif xDiff < 0 then
            -- east
            module.initDir = 3
        elseif zDiff > 0 then
            -- south
            module.initDir = 2
        elseif zDiff < 0 then
            -- north
            module.initDir = 0
        end
		module.dir = module.initDir
		-- move back
		turtle.back()
	else
		error("Location must be set before direction can be found.")
	end
end

-- calibrate turtle
function module.calibrate ()
	initLocation()
	initDirection()
end

-- get current position and direction
function module.getLocation ()
	return module.pos, module.dir
end

-- movement methods

-- Rotate the turtle 90 degrees to the right.
-- The direction is also decremented.
-- 
-- Returns:
--	boolean Whether the turtle could successfully turn.
--	string | nil The reason the turtle could not turn.
function module.turnRight ()
	success, reason = turtle.forward()
	if success == true then
		if module.dir == 0 then
			module.dir = 3
		else
			module.dir = module.dir - 1
		end
	end
	return success, reason
end

-- Rotate the turtle 90 degrees to the left.
-- The direction is also incremented.
--
-- Returns:
--	boolean Whether the turtle could successfully turn.
--	string | nil The reason the turtle could not turn.
function module.turnLeft ()
	success, reason = turtle.turnLeft()
	if success == true then
	if module.dir == 3 then
			module.dir = 0
		else
			module.dir = module.dir + 1
		end
	end
	return success, reason
end

-- Move the turtle forward one block.
-- The position is also updated.
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function module.forward ()
	success, reason = turtle.forward()
	if success then
		if isNorth() then
			module.pos.z = module.pos.z - 1
		elseif isWest() then
			module.pos.x = module.pos.x - 1
		elseif isSouth() then
			module.pos.z = module.pos.z + 1
		elseif isEast() then
			module.pos.x = module.pos.x + 1
		end
	end
	return success, reason
end

-- Move the turtle backwards one block.
-- The position is also updated.
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function module.back ()
	success, reason = turtle.back()
	if success then
		if isNorth() then
            module.pos.z = module.pos.z + 1
        elseif isWest() then
            module.pos.x = module.pos.x + 1
        elseif isSouth() then
            module.pos.z = module.pos.z - 1
        elseif isEast() then
            module.pos.x = module.pos.x - 1
        end
	end
	return success, reason
end

-- Move the turtle up one block.
-- The position is also updated.
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function module.up ()
	success, reason = turtle.up()
	if success then
		module.pos.y = module.pos.y + 1
	end
	return success, reason
end

-- Move the turtle down one block.
-- The position is also updated.
--
-- Returns:
--	boolean Whether the turtle could successfully move.
--	string | nil The reason the turtle could not move.
function module.down ()
	success, reason = turtle.down()
	if success then
		module.pos.y = module.pos.y - 1
	end
	return success, reason
end

return module