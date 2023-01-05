local PATH = string.sub(..., 1, string.len(...) - string.len("core.props.internal"))


---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")
---@module "inky.lib.hashSet"
local HashSet = require(PATH .. "lib.hashSet")


---@class Inky.Props.Internal
---
---@field values { [string]: any }
---@field changedValues Inky.HashSet
---
---@operator call:Inky.Pointer.Internal
local Internal = Class()

function Internal:constructor()
	self.values        = {}
	self.changedValues = HashSet()
end

return Internal
