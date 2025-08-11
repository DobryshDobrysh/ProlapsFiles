--[[
	Based on List implementation from the book "Programming in Lua".

	Стек очень низкоуровневый. Он содержит все элементы сам в себе, чтобы создавать только одну таблицу.
	Стек итерируется с помощью ipairs. Использовать pairs нельзя, так как туда попадает длина стека.
	Конструктор принимает в качестве аргумента другой стек или последовательную таблицу.
	Ручное присвоение по несуществующим числовым индексам может привести к непредсказуемому поведению.

	Работает #, но дороже чем Size. На Lua 5.2 я бы переопределил __len и __pairs.
--]]
---@class Stack
local STACK = {}
STACK.__index = STACK

---@return Stack
function Stack(tab)
	local self = {
		_length = 0
	}
	setmetatable(self, STACK)
	if tab then
		self:Extend(tab)
	end
	return self
end

-- Добавляет элемент в конец стека.
function STACK:Push(obj)
	assert(obj ~= nil, "Stack can't work with nil values")
	local length = self._length + 1
	self[length] = obj
	self._length = length
end

-- Извлекает элемент по индексу, все что выше сдвигается. Если индекс не указан, то извлекается последний элемент.
function STACK:Pop(index)
	local length = self._length
	index = index or length
	assert(index > 0 and index <= length, "Stack out of range")

	local obj = self[index]
	for i = index + 1, length do
		self[i - 1] = self[i]
	end
	self[length] = nil

	self._length = length - 1
	return obj
end

-- Возвращает новый стек, индекс указывает сколько элементов нужно оставить с исходном стеке.
function STACK:Slice(index)
	local length = self._length
	assert(index and index > 0 and index < length, "Stack out of range")

	local slice = Stack()
	for i = index + 1, length do
		slice:Push(self[i])
		self[i] = nil
	end

	self._length = index
	return slice
end

-- Расширяет стек, добавляя в конец все элементы другого стека или последовательной таблицы.
function STACK:Extend(tab)
	local length = #tab
	for i = 1, length do
		self:Push(tab[i])
	end
end

-- Очищает стек, нужно чтобы сохранить адрес.
function STACK:Clear()
	local length = self._length
	for i = 1, length do
		self[i] = nil
	end
	self._length = 0
end

-- Возвращает последний элемент стека.
function STACK:Peek()
	return self[self._length]
end

-- Возвращает число элементов в стеке.
function STACK:Size()
	return self._length
end

function STACK:IsEmpty()
	return self._length == 0
end

-- Отрезать часть стека, индекс указывает сколько элементов нужно оставить. Если стек меньше, ничего не произойдет.
function STACK:Clip(index)
	local length = self._length
	assert(index and index > 0, "Stack out of range")

	if index < length then
		for i = index + 1, length do
			self[i] = nil
		end
		self._length = index
	end
end

-- Удаление элемента со сдвигом во время итерации, для этого `func` должен вернуть `true`.
-- Ключ **всегда актуальный**, то есть сдвиг при удалении предыдущего элемента учитывается.
-- В реальности удаление не во время цикла, потому что по умолчанию модификация таблицы во время итерации портит цикл.
---@param func fun(i, v): boolean
function STACK:RemoveInPlace(func)
	local length = self._length

	local removedKeys = Stack()
	local j = 1
	for i = 1, length do
		if func(j, self[i]) then
			-- Можно было бы сразу делать Pop, но так вроде быстрее.
			removedKeys:Push(i)
		else
			j = j + 1
		end
	end

	for i = removedKeys:Size(), 1, -1 do
		self:Pop(removedKeys[i])
	end
	self._length = j - 1
end
