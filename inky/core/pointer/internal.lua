local PATH = string.sub(..., 1, string.len(...) - string.len("core.pointer.internal"))


---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")
---@module "inky.lib.hashSet"
local HashSet = require(PATH .. "lib.hashSet")

---@module "inky.core.pointerMode"
local PointerMode = require(PATH .. "core.pointer.mode")


---@class Inky.Pointer.Internal
---
---@field private _pointer? Inky.Pointer
---@field private _scene? Inky.Scene
---
---@field private _x? number
---@field private _y? number
---
---@field private _target? Inky.Element
---
---@field private _mode Inky.PointerMode
---
---@field private _active boolean
---
---@field private _overlappingElements Inky.HashSet
---
---@field private _capturedElements Inky.HashSet
---
---@operator call:Inky.Pointer.Internal
local Internal = Class()

---@param pointer Inky.Pointer
---@param scene Inky.Scene
---@private
function Internal:constructor(pointer, scene)
	self._pointer = pointer
	self._scene   = scene

	self._x = 0
	self._y = 0

	self._target = nil

	self._mode = PointerMode.POSITION

	self._active = true

	self._overlappingElements = HashSet()

	self._capturedElements = HashSet()

	self._scene:__getInternal():addPointer(pointer)
end

---@param x number
---@param y number
---@return self
function Internal:setPosition(x, y)
	if (self._x == x and self._y == y and self._mode == PointerMode.POSITION) then
		return self
	end

	self._x = x
	self._y = y

	self._mode = PointerMode.POSITION

	self._scene:__getInternal():onPointerPositionChanged(self._pointer)

	return self
end

---@return number? x
---@return number? y
---@nodiscard
function Internal:getPosition()
	return self._x, self._y
end

---@param target Inky.Element
---@return self
function Internal:setTarget(target)
	if (self._target == target) then
		return self
	end

	self._target = target
	self._mode = PointerMode.TARGET

	self._scene:__getInternal():onPointerTargetChanged(self._pointer)

	return self
end

---@return Inky.Element?
---@nodiscard
function Internal:getTarget()
	return self._target
end

---@return Inky.PointerMode
---@nodiscard
function Internal:getMode()
	return self._mode
end

---@param active boolean
---@return self
function Internal:setActive(active)
	if (self._active == active) then
		return self
	end

	self._active = active

	self._scene:__getInternal():onPointerActiveChanged(self._pointer)

	return self
end

---@return boolean
---@nodiscard
function Internal:isActive()
	return self._active
end

---@param element Inky.Element
---@return boolean
---@nodiscard
function Internal:doesOverlapElement(element)
	return self._overlappingElements:has(element)
end

function Internal:doesOverlapAnyElement()
	return self._overlappingElements:count() ~= 0
end

do
	---@param a Inky.Element
	---@param b Inky.Element
	---@return boolean
	local function sortByDepth(a, b)
		return a:__getInternal():getDepth() > b:__getInternal():getDepth()
	end

	---@param eventName string
	---@param ... any
	---@return boolean
	function Internal:raise(eventName, ...)
		---@type Inky.Element[]
		local elements = {}

		for i = 1, self._overlappingElements:count() do
			---@type Inky.Element
			local element = self._overlappingElements:getByIndex(i)
			elements[i] = element
		end

		for i = 1, self._capturedElements:count() do
			---@type Inky.Element
			local element = self._capturedElements:getByIndex(i)

			if (not self._overlappingElements:has(element)) then
				elements[#elements + 1] = element
			end
		end

		table.sort(elements, sortByDepth)

		for i = 1, #elements do
			local element = elements[i]
			local accepted, consumed = element:__getInternal():raiseOnPointer(eventName, self._pointer, ...)

			if (accepted) then
				local parent = self._scene:__getInternal():getElementParent(element)

				while (parent) do
					parent:__getInternal():raiseOnPointerInHierarchy(eventName, self._pointer, ...)
					parent = self._scene:__getInternal():getElementParent(parent)
				end
			end

			if (consumed) then
				return true
			end
		end

		return false
	end
end

---@param element Inky.Element
---@param shouldCapture? boolean
---@return self
function Internal:captureElement(element, shouldCapture)
	if (shouldCapture == nil) then
		shouldCapture = true
	end

	if (shouldCapture) then
		self._capturedElements:add(element)
	else
		self._capturedElements:remove(element)
	end

	return self
end

---@param element Inky.Element
---@return boolean
---@nodiscard
function Internal:doesCaptureElement(element)
	return self._capturedElements:has(element)
end

do
	---@type Inky.Element[]
	local tempRemovedElements = {}
	---@type Inky.Element[]
	local tempAddedElements = {}

	---@param overlappingElements? Inky.HashSet
	function Internal:setOverlappingElements(overlappingElements)
		if (overlappingElements) then
			self._overlappingElements:difference(overlappingElements, tempRemovedElements)
			overlappingElements:difference(self._overlappingElements, tempAddedElements)

			for i = 1, #tempRemovedElements do
				local element = tempRemovedElements[i]
				self._overlappingElements:remove(element)
			end

			for i = 1, #tempAddedElements do
				local element = tempAddedElements[i]
				self._overlappingElements:add(element)
			end

			for i = 1, #tempRemovedElements do
				local element = tempRemovedElements[i]
				element:__getInternal():raisePointerExit(self._pointer)
				tempRemovedElements[i] = nil
			end

			for i = 1, #tempAddedElements do
				local element = tempAddedElements[i]
				element:__getInternal():raisePointerEnter(self._pointer)
				tempAddedElements[i] = nil
			end
		else
			for i = 1, self._overlappingElements:count() do
				local element = self._overlappingElements:getByIndex(i)
				tempRemovedElements[i] = element
			end

			self._overlappingElements:clear()

			for i = 1, #tempRemovedElements do
				local element = tempRemovedElements[i]
				element:__getInternal():raisePointerExit(self._pointer)
				tempRemovedElements[i] = nil
			end
		end
	end
end

return Internal
