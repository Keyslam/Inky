local PATH = string.sub(..., 1, string.len(...) - string.len("core.scene"))

local Middleclass = require(PATH .. "lib.middleclass")
local HashSet     = require(PATH .. "lib.hashSet")

local Pointer = require(PATH .. "core.pointer")

---@class Inky.Scene
---@operator call:Inky.Scene
local Scene = Middleclass("Inky.Scene")

function Scene:initialize(...)
	self.pointers                   = HashSet()
	self.previousRegisteredContexts = HashSet()
	self.registeredContexts         = HashSet()
end

function Scene:newFrame()
	self:endFrame()
	self.previousRegisteredContexts, self.registeredContexts = self.registeredContexts, self.previousRegisteredContexts
	self.registeredContexts:clear()

	return self
end

function Scene:endFrame()
	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)
		if (not self.previousRegisteredContexts:has(context)) then
			context:_handleEnable()
		end
	end

	for i = 1, self.previousRegisteredContexts:count() do
		local context = self.previousRegisteredContexts:getByIndex(i)
		if (not self.registeredContexts:has(context)) then
			context:_handleDisable()
		end
	end

	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)

		for j = 1, self.pointers:count() do
			local pointer = self.pointers:getByIndex(j)
			context:checkPointer(pointer)
		end
	end
end

---@param context Inky.Context
function Scene:registerContext(context)
	self.registeredContexts:add(context)
end

function Scene:onPointerChanged(pointer)
	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)
		context:checkPointer(pointer)
	end
end

function Scene:onPointerEmit(pointer, name, ...)
	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)

		if (context:hasPointer(pointer)) then
			context:handlePointerEmit(name, pointer, ...)
		end
	end
end

function Scene:emit(name, ...)
	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)
		context:handleEmit(name, ...)
	end

	return self
end

function Scene:addPointer(pointer)
	self.pointers:add(pointer)
end

return Scene
