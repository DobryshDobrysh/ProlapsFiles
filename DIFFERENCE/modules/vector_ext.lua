---@class Vector
---@field Set fun(vector: Vector)
---@field WithinAABox fun(boxStart: Vector, boxEnd: Vector): boolean
---@field Unpack fun(): number, number, number
local VECTOR = FindMetaTable("Vector")

-- Применяет на вектор матрицу трансформации, возвращает новый вектор.
function VECTOR:GetTransformed(matrix)
	local transform = Matrix(matrix)
	transform:Translate(self)
	return transform:GetTranslation()
end

-- Применяет на вектор матрицу трансформации, модифицируя его.
function VECTOR:Transform(matrix)
	self:Set(self:GetTransformed(matrix))
end

-- Общая обертка для совместимости с баундом.
function VECTOR:Intersect(aabb)
	return self:WithinAABox(aabb.mins, aabb.maxs)
end

-- Возвращает новый вектор с минимальными компонентами двух векторов.
function VECTOR:GetMin(vec)
	self = Vector(self)
	vec = Vector(vec)
	OrderVectors(self, vec)
	return self
end

-- Возвращает новый вектор с максимальными компонентами двух векторов.
function VECTOR:GetMax(vec)
	self = Vector(self)
	vec = Vector(vec)
	OrderVectors(self, vec)
	return vec
end

-- Округляет компоненты вектора до шага кубической сетки step, или до целых если не задано.
local floor = math.floor
function SnapVector(vec, step)
	step = step or 1
	local x, y, z = vec:Unpack()
	x = floor(x / step + 0.5) * step
	y = floor(y / step + 0.5) * step
	z = floor(z / step + 0.5) * step
	return Vector(x, y, z)
end
