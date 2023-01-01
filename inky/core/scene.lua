local PATH = string.sub(..., 1, string.len(...) - string.len("core.scene"))

---@module "inky.lib.middleclass"
local Middleclass = require(PATH .. "lib.middleclass")
---@module "inky.lib.hashset"
local HashSet     = require(PATH .. "lib.hashSet")

local Pointer = require(PATH .. "core.pointer")

---@class Inky.Scene
---@operator call:Inky.Scene
local Scene = Middleclass("Inky.Scene")

function Scene:initialize(...)
	self.pointers                   = HashSet()
	self.previousRegisteredContexts = HashSet()
	self.registeredContexts         = HashSet()

	self._currentDepth = 0

	self._parentStack = {}
	self._parents = {}
end

function Scene:newFrame()
	self:endFrame()

	self._parentStack = {}
	self._parents = {}

	self.previousRegisteredContexts, self.registeredContexts = self.registeredContexts, self.previousRegisteredContexts
	self.registeredContexts:clear()

	self._currentDepth = 0

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

function Scene:pushParent(parent)
	self._parentStack[#self._parentStack + 1] = parent
end

function Scene:popParent()
	self._parentStack[#self._parentStack] = nil
end

function Scene:getParentOf(context)
	return self._parents[context]
end

function Scene:setCurrentDepth(depth)
	self._currentDepth = depth
end

function Scene:getCurrentDepth()
	return self._currentDepth
end

---@param context Inky.Context
function Scene:registerContext(context, depth)
	self.registeredContexts:add(context)

	local parent = self._parentStack[#self._parentStack]
	self._parents[context] = parent
end

function Scene:onPointerChanged(pointer)
	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)
		context:checkPointer(pointer)
	end
end

function Scene:onPointerEmit(pointer, name, ...)
	local interestedContexts = {}

	for i = 1, self.registeredContexts:count() do
		local context = self.registeredContexts:getByIndex(i)

		if (context:doesCapturePointerEvent(pointer, name)) then
			table.insert(interestedContexts, context)
		end
	end

	if (#interestedContexts > 0) then
		table.sort(interestedContexts, function(a, b)
			return a._depth > b._depth
		end)

		local context = interestedContexts[1]
		context:handlePointerEmit(name, pointer, ...)

		local parent = self:getParentOf(context)
		while (parent ~= nil) do
			parent:handleHierarchyEmit(name, pointer, ...)
			parent = self:getParentOf(parent)
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
