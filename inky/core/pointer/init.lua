local PATH = string.sub(..., 1, string.len(...) - string.len("core.pointer"))

---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")

---@module "inky.core.pointer.internal"
local Internal = require(PATH .. "core.pointer.internal")


---@class Inky.Pointer
---
---@field private _internal Inky.Pointer.Internal
---
---@operator call:Inky.Pointer
local Pointer = Class()

---@param scene Inky.Scene
---@private
function Pointer:constructor(scene)
	self._internal = Internal(self, scene)
end

---Sets the position of the Pointer, to potentially enter or exit Elements
---\
---@see Inky.Element.OnPointerEnterCallback
---@see Inky.Element.OnPointerExitCallback
---
---@param x number
---@param y number
---@return self
function Pointer:setPosition(x, y)
	self._internal:setPosition(x, y)
	return self
end

---Gets the position of the Pointer
---@return number? x
---@return number? y
---@nodiscard
function Pointer:getPosition()
	return self._internal:getPosition()
end

---Sets the target of the Pointer, to potentially enter or exit Elements
---
---A 'target' Pointer is useful for keyboard navigation, or invoking events on Elements programmatically
---\
---@see Inky.Element.OnPointerEnterCallback
---@see Inky.Element.OnPointerExitCallback
---
---@param target Inky.Element
---@return self
function Pointer:setTarget(target)
	self._internal:setTarget(target)
	return self
end

---Gets the target of the Pointer
---@return Inky.Element?
---@nodiscard
function Pointer:getTarget()
	return self._internal:getTarget()
end

---Gets the mode of the Pointer
---@return Inky.PointerMode
---@nodiscard
function Pointer:getMode()
	return self._internal:getMode()
end

---Sets if the Pointer is active, to potentially enter or exit Elements
---\
---@see Inky.Element.OnPointerEnterCallback
---@see Inky.Element.OnPointerExitCallback
---
---@param active boolean
---@return self
function Pointer:setActive(active)
	self._internal:setActive(active)
	return self
end

---Gets if the Pointer is active
---@return boolean
---@nodiscard
function Pointer:isActive()
	return self._internal:isActive()
end

---Gets if the Pointer overlaps the Element
---@param element Inky.Element
---@return boolean
---@nodiscard
function Pointer:doesOverlapElement(element)
	return self._internal:doesOverlapElement(element)
end

---Get if the Pointer overlaps any Elements
---
---@return boolean
---@nodiscard
function Pointer:doesOverlapAnyElement()
	return self._internal:doesOverlapAnyElement()
end

---Raise a Pointer event, to be caught by Elements
---\
---@see Inky.Element.onPointer
---@see Inky.Element.onPointerInHierarchy
---
---@param eventName string
---@param ... any
---@return boolean
function Pointer:raise(eventName, ...)
	return self._internal:raise(eventName, ...)
end

---Capture a Element, meaning all raised events will be able to be sent to it, even if it's not being hovered
---\
---@see Inky.Element.onPointer
---@see Inky.Element.onPointerInHierarchy
---
---@param element Inky.Element
---@param shouldCapture? boolean
---@return self
function Pointer:captureElement(element, shouldCapture)
	self._internal:captureElement(element, shouldCapture)
	return self
end

---Get if the Pointer captures the Element
---
---@param element Inky.Element
---@return boolean
---@nodiscard
function Pointer:doesCaptureElement(element)
	return self._internal:doesCaptureElement(element)
end

---Get the internal representation of the Pointer
---
---For internal use\
---Don't touch unless you know what you're doing
---@return Inky.Pointer.Internal
function Pointer:__getInternal()
	return self._internal
end

return Pointer
