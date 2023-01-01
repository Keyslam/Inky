local PATH = string.sub(..., 1, string.len(...) - string.len("core.pointer"))

---@module "inky.lib.middleclass"
local Middleclass = require(PATH .. "lib.middleclass")

---@enum Inky.PointerMode
local POINTER_MODE = {
	POSITION = "POSITION",
	TARGET   = "TARGET",
}

---@class Inky.Pointer
---@field _x number | nil
---@field _y number | nil
---@field _target Inky.Element | nil
---@field _mode Inky.PointerMode
---@field _enabled boolean
---@field _scene Inky.Scene
---@field _userdata any
---@operator call:Inky.Pointer
local Pointer = Middleclass("Inky.Pointer")

function Pointer:initialize(scene, userdata)
	self._x = 0
	self._y = 0
	self._target = nil
	self._mode = POINTER_MODE.POSITION
	self._active = true
	self._scene = scene
	self._userdata = userdata

	self._scene:addPointer(self)
end

---Returns the position of hte pointer, or nil if it doesn't have any
---@return number|nil
---@return number|nil
---@nodiscard
function Pointer:getPosition()
	return self._x, self._y
end

---Sets the position of the pointer, and sets the mode to POSITION
---Returns self for method chaining
---@param x number
---@param y number
---@return Inky.Pointer self
function Pointer:setPosition(x, y)
	if (self._mode == POINTER_MODE.POSITION and self._x == x and self._y == y) then
		return self
	end

	if (not self._active) then
		return self
	end

	self._x = x
	self._y = y
	self._target = nil
	self._mode = POINTER_MODE.POSITION

	self._scene:onPointerChanged(self)

	return self
end

function Pointer:getTarget()
	return self._target
end

function Pointer:setTarget(target)
	if (self._mode == POINTER_MODE.TARGET and self._target == target) then
		return
	end

	if (not self._active) then
		return
	end

	self._x = nil
	self._y = nil
	self._target = target
	self._mode = POINTER_MODE.TARGET

	self._scene:onPointerChanged(self)
end

function Pointer:getMode()
	return self._mode
end

function Pointer:getActive()
	return self._active
end

function Pointer:setActive(active)
	if (self._active == active) then
		return
	end

	self._active = active

	self._scene:onPointerChanged(self)

	return self
end

function Pointer:emit(name, ...)
	if (not self._active) then
		return self
	end

	self._scene:onPointerEmit(self, name, ...)

	return self
end

function Pointer:getUserdata()
	return self._userdata
end

function Pointer:setUserData(userdata)
	self._userdata = userdata

	return self
end

return Pointer
