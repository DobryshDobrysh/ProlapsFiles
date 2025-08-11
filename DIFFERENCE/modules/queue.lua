mwLib.queue = mwLib.queue or {}

local Queue = {}
Queue.__index = Queue

function mwLib.queue.create(processFunc)
	return setmetatable({
		processFunc = processFunc,
		pending = {},
		isRunning = false,
	}, Queue)
end

function Queue:Add(data)
	table.insert(self.pending, data)
	self:Run()
end

function Queue:IsRunning()
	return self.isRunning
end

function Queue:Run()
	if self:IsRunning() then return end
	self.isRunning = true

	local data = table.remove(self.pending, 1)
	if not data then
		self.isRunning = false
		return
	end

	self.processFunc(data, function()
		self.isRunning = false
		self:Run()
	end)
end
