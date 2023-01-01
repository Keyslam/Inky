local PATH = string.sub(..., 1, string.len(...) - string.len("core.view"))

---@module "inky.lib.middleclass"
local Middleclass = require(PATH .. "lib.middleclass")

---@class Inky.View
---@field x number
---@field y number
---@field w number
---@field h number
---@operator call:Inky.View
local View = Middleclass("Inky.View")

function View:initialize(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

---
---@param xOrView number
---@param y number
---@param w number
---@param h number
---@return Inky.View
---@overload fun(xOrView: Inky.View): Inky.View
function View:set(xOrView, y, w, h)
	if (type(xOrView) == "table" and xOrView.isInstanceOf and xOrView:isInstanceOf(View)) then
		self:setFromView(xOrView)
	else
		self:setFromParams(xOrView, y, w, h)
	end

	return self
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return Inky.View
function View:setFromParams(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	return self
end

---@param view Inky.View
---@return Inky.View
function View:setFromView(view)
	self.x = view.x
	self.y = view.y
	self.w = view.w
	self.h = view.h

	return self
end

return View
