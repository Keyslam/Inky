local PATH = string.sub(..., 1, string.len(...) - string.len("core.context"))

---@module "inky.lib.middleclass"
local Middleclass = require(PATH .. "lib.middleclass")
---@module "inky.lib.hashSet"
local HashSet     = require(PATH .. "lib.hashSet")

local defaultOverlapPredicate = function(x, y, view)
	return x >= view.x and x <= view.x + view.w and y >= view.y and y <= view.y + view.h
end

---@class Inky.Context
---@operator call:Inky.Context
local Context = Middleclass("Inky.Context")

function Context:initialize(scene, view, props, elementWrapper)
	self._scene          = scene
	self._props          = props
	self._view           = view
	self._elementWrapper = elementWrapper

	self._depth = nil
	self._previousDepth = nil

	self._effects = {}
	self._state   = {}

	self._callbacks                 = {}
	self._pointerCallbacks          = {}
	self._pointerHierarchyCallbacks = {}
	self._onPointerEnterCallback    = nil
	self._onPointerExitCallback     = nil

	self._capturedPointerCallbacks = {}

	self._onEnableCallback  = nil
	self._onDisableCallback = nil

	self._overlapPredicate = defaultOverlapPredicate

	self._pointers = HashSet()
end

function Context:getWrapper()
	return self._elementWrapper
end

---Run callback when an event with matching name is emitted from the scene
---@param name string
---@param callback fun(view: Inky.View, ...)
---@return Inky.Context self
function Context:on(name, callback)
	self._callbacks[name] = callback

	return self
end

---Run callback when an event with matching name is emitted from a overlapping pointer
---@param name string
---@param callback fun(pointer: Inky.Pointer, view: Inky.View)
---@return Inky.Context self
function Context:onPointer(name, callback)
	self._pointerCallbacks[name] = callback

	return self
end

---@param name string
---@param callback fun(pointer: Inky.Pointer, view: Inky.View)
---@return Inky.Context self
function Context:onPointerInHierarchy(name, callback)
	self._pointerHierarchyCallbacks[name] = callback

	return self
end

---Run callback when a pointer enters
---@param callback fun(pointer: Inky.Pointer)
---@return Inky.Context self
function Context:onPointerEnter(callback)
	self._onPointerEnterCallback = callback

	return self
end

---Run callback when a pointer exits
---@param callback fun(pointer: Inky.Pointer)
---@return Inky.Context self
function Context:onPointerExit(callback)
	self._onPointerExitCallback = callback

	return self
end

function Context:begin(depth)
	self._scene:registerContext(self, self._view, depth)
	self._scene:pushParent(self)

	self._previousDepth = self._scene:getCurrentDepth()
	if (not depth) then
		depth = self._previousDepth + 1
	end
	self._depth = depth
	self._scene:setCurrentDepth(depth)

	return depth
end

function Context:finish()
	self._scene:setCurrentDepth(self._previousDepth)
	self._scene:popParent(self)
end

function Context:hasPointer(pointer)
	return self._pointers:has(pointer)
end

function Context:addPointer(pointer)
	self._pointers:add(pointer)
	if (self._onPointerEnterCallback) then
		self._onPointerEnterCallback(pointer)
	end
	return self
end

function Context:removePointer(pointer)
	self._pointers:remove(pointer)
	if (self._onPointerExitCallback) then
		self._onPointerExitCallback(pointer)
	end
	return self
end

function Context:handlePointerEmit(name, pointer, ...)
	local callback = self._pointerCallbacks[name]
	if (callback) then
		callback(pointer, self._view, ...)
	end
end

function Context:handleEmit(name, ...)
	local callback = self._callbacks[name]
	if (callback) then
		callback(...)
	end
end

function Context:handleHierarchyEmit(name, pointer, ...)
	local callback = self._pointerHierarchyCallbacks[name]
	if (callback) then
		callback(pointer, self._view, ...)
	end
end

---@param callback fun()
---@return Inky.Context self
function Context:onEnable(callback)
	self._onEnableCallback = callback

	return self
end

function Context:_handleEnable()
	if (self._onEnableCallback) then
		self._onEnableCallback()
	end
end

---@param callback fun()
---@return Inky.Context self
function Context:onDisable(callback)
	if (self._onDisableCallback) then
		self._onDisableCallback = callback
	end

	return self
end

function Context:_handleDisable()
	self._onDisableCallback()
end

function Context:capturePointer(name, shouldCapture)
	shouldCapture = type(shouldCapture) == nil or shouldCapture

	if (shouldCapture) then
		self._capturedPointerCallbacks[name] = true
	else
		self._capturedPointerCallbacks[name] = nil
	end

	return self
end

---Overrides the check for pointer overlap check
---Checks if 'x' and 'y' are within the view by default
---@param predicate fun(x: number, y:number, view: Inky.View): boolean
---@return Inky.Context self
function Context:useOverlapCheck(predicate)
	self._overlapPredicate = predicate

	return self
end

function Context:doesCapturePointerEvent(pointer, name)
	if (self._capturedPointerCallbacks[name]) then
		return true
	end

	if (self:hasPointer(pointer)) then
		return true
	end

	return false
end

function Context:doesOverlap(x, y)
	return self._overlapPredicate(x, y, self._view)
end

---@param pointer Inky.Pointer
---@return Inky.Context
function Context:checkPointer(pointer)
	local pointerActive = pointer:getActive()

	if (pointerActive) then
		self:_handleActivePointer(pointer)
	else
		self:_handleInactivePointer(pointer)
	end

	return self
end

---@param pointer Inky.Pointer
---@return Inky.Context
function Context:_handleActivePointer(pointer)
	local pointerMode = pointer:getMode()

	if (pointerMode == "TARGET") then
		self:_handleTargettingPointer(pointer)
	elseif (pointerMode == "POSITION") then
		self:_handlePositionedPointer(pointer)
	end

	return self
end

---@param pointer Inky.Pointer
---@return Inky.Context
function Context:_handleInactivePointer(pointer)
	if (self:hasPointer(pointer)) then
		self:removePointer(pointer)
	end

	return self
end

---@param pointer Inky.Pointer
---@return Inky.Context
function Context:_handlePositionedPointer(pointer)
	local pointerX, pointerY = pointer:getPosition()

	local overlap    = self:doesOverlap(pointerX, pointerY)
	local hasPointer = self:hasPointer(pointer)

	if (overlap and not hasPointer) then
		self:addPointer(pointer)
	elseif (not overlap and hasPointer) then
		self:removePointer(pointer)
	end

	return self
end

---@param pointer Inky.Pointer
---@return Inky.Context
function Context:_handleTargettingPointer(pointer)
	local isTarget   = self._elementWrapper == pointer:getTarget()
	local hasPointer = self:hasPointer(pointer)

	if (isTarget and not hasPointer) then
		self:addPointer(pointer)
	elseif (not isTarget and hasPointer) then
		self:removePointer(pointer)
	end

	return self
end

---Creates a variable as state, to be used with Context:useEffect
---@param initialValue any
---@return function getter
---@return function setter
---@nodiscard
function Context:useState(initialValue)
	local getter
	getter = function()
		return self._state[getter]
	end

	local setter = function(newValue)
		self._state[getter] = newValue

		local effects = self._effects[getter]
		if (effects) then
			for i = 1, #effects do
				local effect = effects[i]
				effect()
			end
		end
	end

	self._state[getter] = initialValue

	return getter, setter
end

function Context:handlePropChanged(getter)
	local effects = self._effects[getter]
	if (effects) then
		for i = 1, #effects do
			local effect = effects[i]
			effect()
		end
	end
end

---Perform a side effect when a variable changes
---When any of the passed in state or prop variables changes, the effect is ran
---The state or prop variables are identified by their getters
---@param effect fun()
---@param ... fun() Getters of state or prop to watch
function Context:useEffect(effect, ...)
	for i = 1, select("#", ...) do
		local getter = select(i, ...)
		local effects = self._effects[getter]
		if (not effects) then
			effects = {}
			self._effects[getter] = effects
		end

		effects[#effects + 1] = effect
	end

	effect()
end

return Context
