local PATH = string.sub(..., 1, string.len(...) - string.len("core.element.internal"))


---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")

---@module "inky.core.props"
local Props = require(PATH .. "core.props")


---@class Inky.Element.Internal
---
---@field private _element Inky.Element
---@field private _scene Inky.Scene
---
---@field private _props Inky.Props
---
---@field private _initializer Inky.Element.Initializer
---@field private _isInitialized boolean
---@field private _draw Inky.Element.Draw
---
---@field private _x number
---@field private _y number
---@field private _w number
---@field private _h number
---@field private _depth number
---
---@field private _onCallbacks { [string]: Inky.Element.OnCallback }
---
---@field private _onPointerCallbacks { [string]: Inky.Element.OnPointerCallback }
---@field private _onPointerInHierarchyCallbacks { [string]: Inky.Element.OnPointerCallback }
---
---@field private _onPointerEnterCallback? Inky.Element.OnPointerEnterCallback
---@field private _onPointerExitCallback? Inky.Element.OnPointerExitCallback
---
---@field private _onEnableCallback? Inky.Element.OnEnableCallback
---@field private _onDisableCallback? Inky.Element.OnDisableCallback
---
---@field private _effects { [string]: Inky.Element.Effect[] }
---
---@field private _overlapCheck Inky.Element.OverlapPredicate
---
---@operator call:Inky.Element.Internal
local Internal = Class()

---@param element Inky.Element
---@param scene Inky.Scene
---@param initializer Inky.Element.Initializer
---@private
function Internal:constructor(element, scene, initializer)
	self._element = element
	self._scene   = scene

	self._props = Props()

	self._initializer   = initializer
	self._isInitialized = false
	self._draw          = nil

	self._x     = 0
	self._y     = 0
	self._w     = 0
	self._h     = 0
	self._depth = 0

	self._onCallbacks = {}

	self._onPointerCallbacks            = {}
	self._onPointerInHierarchyCallbacks = {}

	self._onPointerEnterCallback = nil
	self._onPointerExitCallback  = nil

	self._onEnableCallback  = nil
	self._onDisableCallback = nil

	self._effects = {}
end

---@return Inky.Props
function Internal:getProps()
	return self._props
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return self
function Internal:setView(x, y, w, h)
	self._x = x
	self._y = y
	self._w = w
	self._h = h
	return self
end

---@return number x
---@return number y
---@return number w
---@return number h
---@nodiscard
function Internal:getView()
	return self._x, self._y, self._w, self._h
end

---@return number
---@nodiscard
function Internal:getDepth()
	return self._depth
end

---@param eventName string
---@param callback Inky.Element.OnCallback
---@return self
function Internal:on(eventName, callback)
	self._onCallbacks[eventName] = callback
	return self
end

---@param eventName string
---@param callback Inky.Element.OnPointerCallback
---@return self
function Internal:onPointer(eventName, callback)
	self._onPointerCallbacks[eventName] = callback
	return self
end

---@param eventName string
---@param callback Inky.Element.OnPointerInHierarchyCallback
---@return self
function Internal:onPointerInHierarchy(eventName, callback)
	self._onPointerInHierarchyCallbacks[eventName] = callback
	return self
end

---@param callback Inky.Element.OnPointerEnterCallback
---@return self
function Internal:onPointerEnter(callback)
	self._onPointerEnterCallback = callback
	return self
end

---@param callback Inky.Element.OnPointerExitCallback
---@return self
function Internal:onPointerExit(callback)
	self._onPointerExitCallback = callback
	return self
end

---@param callback? Inky.Element.OnEnableCallback
---@return self
function Internal:onEnable(callback)
	self._onEnableCallback = callback
	return self
end

---@param callback? Inky.Element.OnDisableCallback
---@return self
function Internal:onDisable(callback)
	self._onDisableCallback = callback
	return self
end

---@param effect Inky.Element.Effect
---@param ... any
---@return self
function Internal:useEffect(effect, ...)
	for i = 1, select("#", ...) do
		local propName = select(i, ...)

		local effects = self._effects[propName]
		if (effects == nil) then
			effects = {}
			self._effects[propName] = effects
		end

		effects[#effects + 1] = effect
	end

	return self
end

---@param predicate Inky.Element.OverlapPredicate
---@return self
function Internal:useOverlapCheck(predicate)
	self._overlapCheck = predicate
	return self
end

---@param eventName string
---@param ... any
---@return boolean accepted
---@nodiscard
function Internal:raiseOn(eventName, ...)
	local callback = self._onCallbacks[eventName]
	if (callback) then
		callback(self._element, ...)
		return true
	end
	return false
end

---@param eventName string
---@param pointer Inky.Pointer
---@param ... any
---@return boolean accepted
---@return boolean consumed
---@nodiscard
function Internal:raiseOnPointer(eventName, pointer, ...)
	local callback = self._onPointerCallbacks[eventName]
	if (callback) then
		callback(self._element, pointer, ...)
		return true, true
	end
	return false, false
end

---@param eventName string
---@param pointer Inky.Pointer
---@param ... any
---@return boolean accepted
---@nodiscard
function Internal:raiseOnPointerInHierarchy(eventName, pointer, ...)
	local callback = self._onPointerInHierarchyCallbacks[eventName]
	if (callback) then
		callback(self._element, pointer, ...)
		return true
	end
	return false
end

---@param pointer Inky.Pointer
---@return boolean accepted
---@nodiscard
function Internal:raisePointerEnter(pointer)
	if (self._onPointerEnterCallback) then
		self._onPointerEnterCallback(self._element, pointer)
		return true
	end
	return false
end

---@param pointer Inky.Pointer
---@return boolean accepted
---@nodiscard
function Internal:raisePointerExit(pointer)
	if (self._onPointerExitCallback) then
		self._onPointerExitCallback(self._element, pointer)
		return true
	end
	return false
end

---@return boolean accepted
---@nodiscard
function Internal:raiseEnable()
	if (self._onEnableCallback) then
		self._onEnableCallback(self._element)
		return true
	end
	return false
end

---@return boolean accepted
---@nodiscard
function Internal:raiseDisable()
	if (self._onDisableCallback) then
		self._onDisableCallback(self._element)
		return true
	end
	return false
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean
---@nodiscard
function Internal:doesViewDiffer(x, y, w, h)
	return x ~= self._x or y ~= self._y or w ~= self._w or h ~= self._h
end

---@param px number
---@param py number
---@return boolean
---@nodiscard
function Internal:doesPointPassBoundingboxCheck(px, py)
	return px >= self._x and px < self._x + self._w and py >= self._y and py < self._y + self._h
end

---@param px number
---@param py number
---@return boolean
---@nodiscard
function Internal:doesPointPassOverlapCheck(px, py)
	if (self._overlapCheck) then
		return self._overlapCheck(px, py, self._x, self._y, self._w, self._h)
	end
	return true
end

---@return boolean
function Internal:isInitialized()
	return self._isInitialized
end

function Internal:initialize()
	if (not self._isInitialized) then
		self._isInitialized = true
		self._draw = self._initializer(self._element, self._scene)
	end
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param depth? number
---@return self
function Internal:render(x, y, w, h, depth)
	self._scene:__getInternal():render(self._element, x, y, w, h, depth)
	return self
end

do
	local changedProps = {}

	---@param scene Inky.Scene
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param depth number
	function Internal:renderIntoScene(scene, x, y, w, h, depth)
		self._depth = depth

		local changedValues = self._props._internal.changedValues
		for i = 1, changedValues:count() do
			changedProps[i] = changedValues:getByIndex(i)
		end
		changedValues:clear()

		for i = 1, #changedProps do
			local propName = changedProps[i]
			local effects = self._effects[propName]

			if (effects) then
				for _, effect in ipairs(effects) do
					effect(self._element)
				end
			end

			changedProps[i] = nil
		end

		if (self._draw) then
			self._draw(self._element, x, y, w, h, depth)
		end
	end
end

return Internal
