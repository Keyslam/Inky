local PATH = string.sub(..., 1, string.len(...) - string.len("core.scene.internal"))

---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")
---@module "inky.lib.hashSet"
local HashSet = require(PATH .. "lib.hashSet")

---@module "inky.core.spatialHash"
local SpatialHash = require(PATH .. "core.spatialHash")
---@module "inky.core.pointer.mode"
local PointerMode = require(PATH .. "core.pointer.mode")


---@class Inky.Scene.Internal
---
---@field private _scene Inky.Scene
---
---@field private _pointers Inky.HashSet
---
---@field private _beganFrame boolean
---
---@field private _elementsChanged boolean
---
---@field private _elements Inky.HashSet
---@field private _parents { [Inky.Element]: Inky.Element }
---@field private _parentStack Inky.Element[]
---
---@field private _suppliedElements Inky.HashSet
---
---@field private _spatialHash Inky.SpatialHash
---
---@operator call:Inky.Scene.Internal
local Internal = Class()

---@param scene Inky.Scene
---@param spatialHashSize? integer
---@private
function Internal:constructor(scene, spatialHashSize)
	spatialHashSize = spatialHashSize or 32

	self._scene = scene

	self._pointers = HashSet()

	self._beganFrame = false

	self._elementsChanged = false

	self._elements    = HashSet()
	self._parents     = {}
	self._parentStack = {}

	self._suppliedElements = HashSet()

	self._spatialHash = SpatialHash(spatialHashSize)
end

do
	local overlappingElements = HashSet()

	---@param pointer Inky.Pointer
	function Internal:_resolvePointerOverlappingElements(pointer)
		local active = pointer:isActive()

		if (not active) then
			pointer:__getInternal():setOverlappingElements(overlappingElements)
			return self
		end

		local mode = pointer:getMode()

		if (mode == PointerMode.POSITION) then
			local pointerX, pointerY = pointer:getPosition()

			if (pointerX == nil or pointerY == nil) then
				return
			end

			pointerX = math.floor(pointerX)
			pointerY = math.floor(pointerY)

			local elementsAtPoint = self._spatialHash:getElementsAtPoint(pointerX, pointerY)
			if (elementsAtPoint == nil) then
				pointer:__getInternal():setOverlappingElements(overlappingElements)
				return
			end

			for i = 1, elementsAtPoint:count() do
				---@type Inky.Element
				local element = elementsAtPoint:getByIndex(i)
				local internal = element:__getInternal()

				if (internal:doesPointPassBoundingboxCheck(pointerX, pointerY)) then
					if (internal:doesPointPassOverlapCheck(pointerX, pointerY)) then
						overlappingElements:add(element)
					end
				end
			end

			pointer:__getInternal():setOverlappingElements(overlappingElements)
			overlappingElements:clear()

			return self
		end

		if (mode == PointerMode.TARGET) then
			overlappingElements:add(pointer:getTarget())
			pointer:__getInternal():setOverlappingElements(overlappingElements)
			overlappingElements:clear()

			return self
		end

		return self
	end
end

---@param pointer Inky.Pointer
---@return self
function Internal:addPointer(pointer)
	self._pointers:add(pointer)
	return self
end

---@param pointer Inky.Pointer
function Internal:onPointerPositionChanged(pointer)
	self:_resolvePointerOverlappingElements(pointer)
end

---@param pointer Inky.Pointer
function Internal:onPointerTargetChanged(pointer)
	self:_resolvePointerOverlappingElements(pointer)
end

---@param pointer Inky.Pointer
function Internal:onPointerActiveChanged(pointer)
	self:_resolvePointerOverlappingElements(pointer)
end

---@return self
function Internal:beginFrame()
	self._beganFrame = true

	self._suppliedElements:clear()

	for i = 1, self._elements:count() do
		local element = self._elements:getByIndex(i)
		self._parents[element] = nil
	end

	return self
end

---@return self
function Internal:finishFrame()
	self._beganFrame = false

	local removedElements = self._elements:difference(self._suppliedElements)

	if (#removedElements > 0) then
		self._elementsChanged = true
	end

	for _, element in ipairs(removedElements) do
		self._elements:remove(element)
		self._spatialHash:remove(element)
	end

	for _, element in ipairs(removedElements) do
		element:__getInternal():raiseDisable()
	end

	if (self._elementsChanged) then
		for i = 1, self._pointers:count() do
			local pointer = self._pointers:getByIndex(i)
			self:_resolvePointerOverlappingElements(pointer)
		end

		self._elementsChanged = false
	end

	return self
end

---@param element Inky.Element
---@param x number
---@param y number
---@param w number
---@param h number
---@param depth? number
function Internal:render(element, x, y, w, h, depth)
	if (not self._beganFrame) then
		error("Can't render Element when frame wasn't begun", 3)
	end

	local elementInternal = element:__getInternal()

	if (not elementInternal:isInitialized()) then
		elementInternal:initialize()
	end

	if (depth == nil) then
		local parent = self._parentStack[#self._parentStack]

		if (parent) then
			local parentDepth = parent:__getInternal():getDepth()
			depth = parentDepth + 1
		else
			depth = 0
		end
	end

	self:_beginElement(element, x, y, w, h)
	elementInternal:renderIntoScene(self._scene, x, y, w, h, depth)
	self:_finishElement(element)
end

---Raise an event
---@param eventName string
---@param ... unknown
function Internal:raise(eventName, ...)
	for i = 1, self._elements:count() do
		local element = self._elements:getByIndex(i) --[[@as Inky.Element]]
		element:__getInternal():raiseOn(eventName, ...)
	end
end

---Get if frame did begin
---@return boolean
function Internal:didBeginFrame()
	return self._beganFrame
end

---@param element Inky.Element
---@return Inky.Element?
---@nodiscard
function Internal:getElementParent(element)
	return self._parents[element]
end

---@param element Inky.Element
---@return self
---@private
function Internal:_beginElement(element, x, y, w, h)
	local viewDiffers = element:__getInternal():doesViewDiffer(x, y, w, h)
	element:__getInternal():setView(x, y, w, h)

	self._suppliedElements:add(element)
	self._parents[element] = self._parentStack[#self._parentStack]
	self._parentStack[#self._parentStack + 1] = element

	if (not self._elements:has(element)) then
		self._elementsChanged = true

		self._elements:add(element)
		self._spatialHash:add(element)

		element:__getInternal():raiseEnable()
	elseif (viewDiffers) then
		self._elementsChanged = true

		self._spatialHash:move(element)
	end

	return self
end

---@param element Inky.Element
---@return self
---@private
function Internal:_finishElement(element)
	self._parentStack[#self._parentStack] = nil

	return self
end

return Internal
