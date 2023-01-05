local PATH = string.sub(..., 1, string.len(...) - string.len("core.element"))

---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")

---@module "inky.core.element.internal"
local Internal = require(PATH .. "core.element.internal")


---@alias Inky.Element.Initializer fun(self: Inky.Element, scene: Inky.Scene): Inky.Element.Draw
---@alias Inky.Element.Draw fun(self: Inky.Element, x: number, y: number, w: number, h: number, depth?: number)
---@alias Inky.Element.OnCallback fun(element: Inky.Element, ...: any): nil
---@alias Inky.Element.OnPointerCallback fun(element: Inky.Element, pointer: Inky.Pointer, ...: any): nil
---@alias Inky.Element.OnPointerInHierarchyCallback fun(element: Inky.Element, pointer: Inky.Pointer, ...: any): nil
---@alias Inky.Element.OnPointerEnterCallback fun(element: Inky.Element, pointer: Inky.Pointer): nil
---@alias Inky.Element.OnPointerExitCallback fun(element: Inky.Element, pointer: Inky.Pointer): nil
---@alias Inky.Element.OnEnableCallback fun(element: Inky.Element): nil
---@alias Inky.Element.OnDisableCallback fun(element: Inky.Element): nil
---@alias Inky.Element.Effect fun(element: Inky.Element): nil
---@alias Inky.Element.OverlapPredicate fun(pointerX: number, pointerY: number, x: number, y: number, w: number, h: number): boolean


---@class Inky.Element
---
---@field private _internal Inky.Element.Internal
---
---@field props Inky.Props
---
---@operator call:Inky.Element
local Element = Class()

---@param initializer Inky.Element.Initializer
---@private
function Element:constructor(scene, initializer)
	self._internal = Internal(self, scene, initializer)

	self.props = self._internal:getProps()
end

---Return the x, y, w, h that the Element was last rendered at
---
---@return number x
---@return number y
---@return number w
---@return number h
---@nodiscard
function Element:getView()
	return self._internal:getView()
end

---Execute callback when Scene event is raised from the parent Scene
---\
---@see Inky.Scene.raise
---
---@param eventName string
---@param callback Inky.Element.OnCallback
---@return self
function Element:on(eventName, callback)
	self._internal:on(eventName, callback)
	return self
end

---Execute callback when a Pointer event is raised from an overlapping/capturing Pointer
---\
---@see Inky.Pointer.raise
---@see Inky.Pointer.captureElement
---
---@param eventName string
---@param callback Inky.Element.OnPointerCallback
---@return self
function Element:onPointer(eventName, callback)
	self._internal:onPointer(eventName, callback)
	return self
end

---Execute callback when a Pointer event was accepted by a child Element
---\
---@see Inky.Pointer.raise
---@see Inky.Element.onPointer
---
---@param eventName string
---@param callback Inky.Element.OnPointerInHierarchyCallback
---@return self
function Element:onPointerInHierarchy(eventName, callback)
	self._internal:onPointerInHierarchy(eventName, callback)
	return self
end

---Execute callback when a Pointer enters the bounding box of the Element
---
---@param callback Inky.Element.OnPointerEnterCallback
---@return self
function Element:onPointerEnter(callback)
	self._internal:onPointerEnter(callback)
	return self
end

---Execute callback when a Pointer exits the bounding box of the Element
---@param callback Inky.Element.OnPointerExitCallback
---@return self
function Element:onPointerExit(callback)
	self._internal:onPointerExit(callback)
	return self
end

---Execute callback when an Element is rendered, when it wasn't rendered last frame
---
---@param callback? Inky.Element.OnEnableCallback
---@return self
function Element:onEnable(callback)
	self._internal:onEnable(callback)
	return self
end

---Execute callback when an Element isn't rendered, when it was rendered last frame
---
---@param callback? Inky.Element.OnDisableCallback
---@return self
function Element:onDisable(callback)
	self._internal:onDisable(callback)
	return self
end

---Use an additional check to determine if a Pointer is overlapping an Element
---
---Note: Check is performed after a bounding box check
---
---@param predicate Inky.Element.OverlapPredicate
---@return self
function Element:useOverlapCheck(predicate)
	self._internal:useOverlapCheck(predicate)
	return self
end

---Execute a side effect when any specified Element's prop changes
---
---Note: The effect is ran right before a render
---
---@param effect Inky.Element.Effect
---@param ... any
---@return self
function Element:useEffect(effect, ...)
	self._internal:useEffect(effect, ...)
	return self
end

---Render the Element, setting up all the hooks and drawing the Element
---
---Note: The parent Scene's frame must have been begun to be able to render\
---
---@see Inky.Scene.beginFrame
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param depth? number
function Element:render(x, y, w, h, depth)
	self._internal:render(x, y, w, h, depth)
	return self
end

---Get the internal representation of the Element
---
---For internal use\
---Don't touch unless you know what you're doing
---@return Inky.Element.Internal
---@nodiscard
function Element:__getInternal()
	return self._internal
end

return Element
