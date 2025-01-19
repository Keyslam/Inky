local PATH = string.sub(..., 1, string.len(...) - string.len("lib.hashSet"))

---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")


---@class Inky.HashSet
---@field _indices { [any]: number }
---@field _elements any[]
---@operator call:Inky.HashSet
local HashSet = Class()

function HashSet:constructor()
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

	if (index == lastIndex) then
		self._elements[index]  = nil
		self._indices[element] = nil
	else
		local lastElement = self._elements[lastIndex]

		self._elements[index]      = lastElement
		self._elements[lastIndex]  = nil
		self._indices[element]     = nil
		self._indices[lastElement] = index
	end

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

---Compute the difference between 2 sets
---@param other Inky.HashSet
---@param out? table
---@return table
function HashSet:difference(other, out)
	out = out or {}

	for i = 1, self:count() do
		local element = self:getByIndex(i)
		if (not other:has(element)) then
			out[#out + 1] = element
		end
	end

	return out
end

return HashSet
