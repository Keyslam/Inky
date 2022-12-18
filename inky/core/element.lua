local PATH = string.sub(..., 1, string.len(...) - string.len("core.element"))

local ElementWrapper = require(PATH .. "core.elementWrapper")
local Caller         = require(PATH .. "core.caller")
local Context        = require(PATH .. "core.context")
local View           = require(PATH .. "core.view")

---@class Inky.Element
---@field initializer any
---@field scene Inky.Scene
---@field props { [string]: any }
---@field view Inky.View
---@field render fun(view : Inky.View) | nil
---@field context Inky.Context
local Element   = {}
local ElementMt = {
	__index = Element,
}

function Element.new(initializer, scene)
	local element = setmetatable({
		initializer = initializer,
		scene = scene,

		props = {},
		hiddenProps = {},
		view = View(0, 0, 0, 0),

		render = nil,
	}, ElementMt)

	local elementWrapper = ElementWrapper(element, Caller)

	element.context = Context(scene, element.view, element.props, elementWrapper)

	return elementWrapper
end

function Element:draw(xOrView, y, w, h)
	if (self.render == nil) then
		self.render = self.initializer(
			self.scene,
			self.context,
			self.props
		)
	end

	self.view:set(xOrView, y, w, h)

	self.context:hook()
	self.render(self.view)
end

---@generic T
---@param initializer fun(scene: Inky.Scene, context: Inky.Context, props: T): fun(view: Inky.View)
---@return function
function Element.make(initializer)
	return function(scene)
		return Element.new(initializer, scene)
	end
end

return setmetatable(Element, {
	__call = function(_, initializer)
		return Element.make(initializer)
	end,
})
