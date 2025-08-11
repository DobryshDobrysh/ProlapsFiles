--[[
	Cube Cluster - математический класс кубических кластеров.

	Представим что некое пространство разбито на равные кубы.
	Можно сказать что внутри определенного куба может находится объект.
	С помощью этого класса мы можем узнать какому кубу принадлежит объект по абсолютным координатам.
	Также можем узнать позицию куба по его id и получить все соседние кубы.

	В реальности этот класс не является хранилищем объектов или кубов. Все что делает этот класс, это расчеты.
	Объект хранит только параметры для расчетов, и предоставляет набор математических функций.

	Приоритет нумерации выбран по осям, сначала по x, затем по y, затем по z.
	Нумерация кластеров и их позиции начинаются с 0, это позволяет избавиться от лишних математических операций.
	Позиция попадает в кластер по нижней границе, поэтому правый дальний верхний угол это необрабатываемый случай.
--]]

local floor = math.floor

local function CalcId(x, y, z, sideCount)
	return x + y * sideCount + z * sideCount * sideCount
end

local function CalcNearIds(x, y, z, sideCount)
	local ids = {}
	for dz = -1, 1 do
		for dy = -1, 1 do
			for dx = -1, 1 do
				local numX = x + dx
				local numY = y + dy
				local numZ = z + dz
				if numX >= 0 and numX < sideCount and numY >= 0 and numY < sideCount and numZ >= 0 and numZ < sideCount then
					local id = CalcId(numX, numY, numZ, sideCount)
					ids[id] = true
				end
			end
		end
	end
	return ids
end

local function CalcBoundIds(minX, minY, minZ, maxX, maxY, maxZ, sideCount)
	local ids = {}
	for numZ = minZ, maxZ do
		for numY = minY, maxY do
			for numX = minX, maxX do
				if numX >= 0 and numX < sideCount and numY >= 0 and numY < sideCount and numZ >= 0 and numZ < sideCount then
					local id = CalcId(numX, numY, numZ, sideCount)
					ids[id] = true
				end
			end
		end
	end
	return ids
end

local function CalcPos(id, sideCount)
	local z = floor(id / (sideCount * sideCount))
	local xy = id - z * sideCount * sideCount
	local y = floor(xy / sideCount)
	local x = xy - y * sideCount
	return Vector(x, y, z)
end

local CUBE_CLUSTER = {}
CUBE_CLUSTER.__index = CUBE_CLUSTER

function CubeCluster(size, step, offset)
	offset = offset or Vector()
	local grid = {
		_step = step,
		_offset = offset,
		_sideCount = math.ceil(size / step)
	}
	return setmetatable(grid, CUBE_CLUSTER)
end

-- Возвращает id кластера по абсолютной позиции.
-- При выходе за диапазон возвращает ничего.
function CUBE_CLUSTER:GetId(pos)
	local sideCount = self._sideCount
	local step = self._step
	local num = pos - self._offset
	local numX, numY, numZ = num:Unpack()
	numX = floor(numX / step)
	numY = floor(numY / step)
	numZ = floor(numZ / step)
	if numX >= 0 and numX < sideCount and numY >= 0 and numY < sideCount and numZ >= 0 and numZ < sideCount then
		return CalcId(numX, numY, numZ, sideCount)
	end
end

-- Возвращает таблицу соседних кластеров. В таблице id записаны ключами.
-- При выходе за диапазон возвращает прилегающие к границе кластеры или пустую таблицу.
function CUBE_CLUSTER:GetNearIds(pos)
	local sideCount = self._sideCount
	local step = self._step
	local num = pos - self._offset
	local numX, numY, numZ = num:Unpack()
	numX = floor(numX / step)
	numY = floor(numY / step)
	numZ = floor(numZ / step)
	return CalcNearIds(numX, numY, numZ, sideCount)
end

-- Возвращает таблицу кластеров, попадающих в баунд. В таблице id записаны ключами.
-- При выходе за диапазон возвращает прилегающие к границе кластеры или пустую таблицу.
function CUBE_CLUSTER:GetBoundIds(aabb)
	local sideCount = self._sideCount
	local step = self._step
	local minNum = aabb.mins - self._offset
	local minNumX, minNumY, minNumZ = minNum:Unpack()
	minNumX = floor(minNumX / step)
	minNumY = floor(minNumY / step)
	minNumZ = floor(minNumZ / step)
	local maxNum = aabb.maxs - self._offset
	local maxNumX, maxNumY, maxNumZ = maxNum:Unpack()
	maxNumX = floor(maxNumX / step)
	maxNumY = floor(maxNumY / step)
	maxNumZ = floor(maxNumZ / step)
	return CalcBoundIds(minNumX, minNumY, minNumZ, maxNumX, maxNumY, maxNumZ, sideCount)
end

-- Возвращает позицию нижней границы кластера.
-- При выходе за диапазон возвращает ничего.
function CUBE_CLUSTER:GetPos(id)
	local sideCount = self._sideCount
	if id >= 0 and id < sideCount * sideCount * sideCount then
		local pos = CalcPos(id, sideCount)
		pos:Mul(self._step)
		pos:Add(self._offset)
		return pos
	end
end

-- Возвращает центр кластера.
-- При выходе за диапазон возвращает ничего.
function CUBE_CLUSTER:GetCenterPos(id)
	local sideCount = self._sideCount
	if id >= 0 and id < sideCount * sideCount * sideCount then
		local pos = CalcPos(id, sideCount)
		pos:Add(Vector(0.5, 0.5, 0.5))
		pos:Mul(self._step)
		pos:Add(self._offset)
		return pos
	end
end

-- Возвращает id сектора сверху.
-- При выходе за диапазон возвращает ничего.
function CUBE_CLUSTER:GetUp(id)
	local sideCount = self._sideCount
	id = id + sideCount * sideCount
	if id >= 0 and id < sideCount * sideCount * sideCount then
		return id
	end
end

-- Возвращает id сектора снизу.
-- При выходе за диапазон возвращает ничего.
function CUBE_CLUSTER:GetDown(id)
	local sideCount = self._sideCount
	id = id - sideCount * sideCount
	if id >= 0 and id < sideCount * sideCount * sideCount then
		return id
	end
end

-- Возвращает таблицу кластеров из to, которых нет в from. В таблице id записаны ключами.
function CUBE_CLUSTER:DiffIds(from, to)
	local diff = {}
	for id in pairs(to) do
		if not from[id] then
			diff[id] = true
		end
	end
	return diff
end
