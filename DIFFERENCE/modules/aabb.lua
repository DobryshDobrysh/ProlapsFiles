--[[
	Рекомендуется использовать только с C++ функциями, которые возвращают новые вектора.
	Конструктор принимает в качестве аргумента два вектора минимум и максимум или баунд.
	Вектора наследуются напрямую и могут модифицироваться, баунд же копируется.

	Проверка пересечения реализована на Unpack, это самый быстрый способ.
--]]
---@class Aabb
---@field mins Vector
---@field maxs Vector
local AABB = {}
AABB.__index = AABB

---@return Aabb
function Aabb(obj, maxs)
	local self = {
		mins = obj,
		maxs = maxs
	}
	setmetatable(self, AABB)
	if istable(obj) then
		self.mins = Vector(obj.mins)
		self.maxs = Vector(obj.maxs)
	end
	return self
end

-- Получает центр баунда.
function AABB:GetCenter()
	local pos = self.mins + self.maxs
	pos:Mul(0.5)
	return pos
end

-- Проверяет пересечение баунда с баундом. Соприкосновение считается.
function AABB:WithinAABox(mins, maxs)
	local mins1x, mins1y, mins1z = self.mins:Unpack()
	local maxs1x, maxs1y, maxs1z = self.maxs:Unpack()
	local mins2x, mins2y, mins2z = mins:Unpack()
	local maxs2x, maxs2y, maxs2z = maxs:Unpack()
	return mins1x <= maxs2x and mins2x <= maxs1x and mins1y <= maxs2y and mins2y <= maxs1y and mins1z <= maxs2z and
		mins2z <= maxs1z
end

-- Общая обертка для совместимости с вектором.
function AABB:Intersect(obj)
	return obj:WithinAABox(self.mins, self.maxs)
end

-- Отступает равное расстояние от вершин баунда.
function AABB:Margin(dist)
	local margin = Vector(dist, dist, dist)
	self.mins:Sub(margin)
	self.maxs:Add(margin)
end

-- Расширяет баунд для включения в себя точки.
function AABB:EncapsulatePoint(vec)
	vec = Vector(vec)
	OrderVectors(self.mins, vec)
	OrderVectors(vec, self.maxs)
end

-- Расширяет баунд для включения в себя баунда.
function AABB:Encapsulate(aabb)
	self:EncapsulatePoint(aabb.mins)
	self:EncapsulatePoint(aabb.maxs)
end
