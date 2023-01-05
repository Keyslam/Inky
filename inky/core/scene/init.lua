local PATH = string.sub(..., 1, string.len(...) - string.len("core.scene"))

---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")

---@module "inky.core.scene.internal"
local Internal = require(PATH .. "core.scene.internal")


---@class Inky.Scene
---
---@field private _internal Inky.Scene.Internal
---
---@operator call:Inky.Scene
local Scene = Class()

---@param spatialHashSize? integer
---@private
function Scene:constructor(spatialHashSize)
	self._internal = Internal(self, spatialHashSize)
end

---Begin a frame to render Elements in
---
---Note: A frame must have been begun before Elements can be drawn
---\
---@see Inky.Element.render
---
---@return Inky.Scene
function Scene:beginFrame()
	self._internal:beginFrame()
	return self
end

---End a frame to render Elements in
---
---A frame must have been finished before Elements can be acted on
---
---@return Inky.Scene
function Scene:finishFrame()
	self._internal:finishFrame()
	return self
end

---Get if frame did begin
---@return boolean
---@nodiscard
function Scene:didBeginFrame()
	return self._internal:didBeginFrame()
end

---Raise a Scene event, to be caught by Elements
---\
---@see Inky.Element.OnCallback
---
---@param eventName string
---@param ... unknown
---@return self
function Scene:raise(eventName, ...)
	self._internal:raise(eventName, ...)
	return self
end

---Get the internal representation of the Scene
---
---For internal use\
---Don't touch unless you know what you're doing
---@return Inky.Scene.Internal
---@nodiscard
function Scene:__getInternal()
	return self._internal
end

return Scene
