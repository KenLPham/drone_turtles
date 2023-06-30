-- ? yoinked from https://github.com/merlinlikethewizard/Shacktuator/blob/main/merlib/algs.lua

local module = {}

local cardinalDir = {
	vector.new(1, 0, 0),
	vector.new(-1, 0, 0),
	vector.new(0, 1, 0),
	vector.new(0, -1, 0),
	vector.new(0, 0, 1),
	vector.new(0, 0, -1),
}

function posToIdx (_pos)
	return string.format("%d,%d,%d", _pos.x, _pos.y, _pos.z)
end

function distance (_a, _b)
	displacement = _b - _a
	return math.sqrt(math.pow(displacement.x, 2) + math.pow(displacement.y, 2) + math.pow(displacement.z, 2))
end

function module.findPath (_startPos, _endPos, validFunction)
	local queue = {
		[posToIdx(_startPos)] = {
			pos = _startPos,
			gScore = 0,
			hScore = distance(_startPos, _endPos)
			fScore = distance(_startPos, _endPos) -- f = g + h
		}
	}
	local visited = {}

	while true do
		-- find lowest f score
		local bestIdx, bestNode = next(queue)
		for idx, node in ipairs(queue) do
			if node.fScore < bestNode.fScore or (node.fScore == bestNode.fScore and node.hScore < bestNode.hScore) then
				bestNode = node
				bestIdx = idx
			end
		end

		-- no nodes found
		if not bestNode then
			return
		end

		-- move node to visited
		queue[bestIdx] = nil
		visited[bestIdx] = true

		-- check if end reached
		if bestNode.pos == _endPos then
			-- build path back to start
			local path = {}
			local currentNode = bestNode
			while currentNode.fromNode do
				table.insert(path, currentNode.fromNode.pos)
				currentNode = currentNode.fromNode
			end

			return path
		end

		-- for each neighbor
		for i, vector in ipairs(cardinalDir) do
			local neighborPos = bestNode + vector
			local neighborIdx = posToIdx(neighborPos)

			-- check if neighbor hasn't been visited and isn't an obstacle
			if not (queue[neighborIdx] or visited[neighborIdx]) and (not validFunction or validFunction(neighborPos)) then
				-- create neighbor node
				local neighborNode = {
					pos = neighborPos,
					gScore = bestNode.gScore + 1
					hScore = distance(neighborPos, endPos)
				}
				neighborNode.fScore = neighborNode.gScore + neighborNode.hScore

				-- create bread crumbs
				neighborNode.fromNode = bestNode

				-- add to queue
				queue[neighborIdx] = neighborNode
			end
		end
	end
end

return module