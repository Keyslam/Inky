local PATH = string.sub(..., 1, string.len(...) - string.len("lib.hashSet"))

local Middleclass = require(PATH .. "lib.middleclass")

---@class Inky.HashSet
---@field _indices { [any]: number }
---@field _elements any[]
---@operator call:Inky.HashSet
local HashSet = Middleclass("Inky.Hashset")

function HashSet:initialize()
	self._indices  = {}
	self._elements = {}
end

---Adds the specified element to the HashSet
---@param element any
---@return Inky.HashSet
function HashSet:add(element)
	if (self:has(element)) then
		return self
	end

	local index = #self._elements + 1
	self._indices[element] = index
	self._elements[index] = element

	return self
end

---Removes the specified element from the HashSet
---@param element any
---@return Inky.HashSet
function HashSet:remove(element)
	if (not self:has(element)) then
		return self
	end

	local index = self._indices[element]
	local lastIndex = #self._elements

	-- Copy last element into place of removed element, then remove the last element
	-- This works out even if the to be removed element is the last element
	self._indices[element]    = nil
	self._elements[index]     = self._elements[lastIndex]
	self._elements[lastIndex] = nil

	return self
end

---Determines whether the HashSet has the specified element
---@param element any
---@return boolean True if the HashSet contains the specified element, false otherwise
function HashSet:has(element)
	return self._indices[element] ~= nil
end

---Gets the number of elements that are in the HashSet
---@return integer Number of elements in the HashSet
function HashSet:count()
	return #self._elements
end

---Returns the index of the element within the HashSet
---@param element any
---@return number|nil The index of the element or nil if it does not exist
function HashSet:indexOf(element)
	return self._indices[element]
end

---Returns the element at the specified index
---@param index number
---@return any|nil The element at the specified index, or nil if it does not exist
function HashSet:getByIndex(index)
	return self._elements[index]
end

---Removes all elements from the HashSet
---@return Inky.HashSet
function HashSet:clear()
	for i = 1, #self._elements do
		local element          = self._elements[i]
		self._elements[i]      = nil
		self._indices[element] = nil
	end

	return self
end

return HashSet
