local PATH = string.sub(..., 1, string.len(...) - string.len("core.props"))

---@module "inky.core.props.internal"
local Internal = require(PATH .. "core.props.internal")


local Mt = {
	---@param self Inky.Props
	---@param key string
	---@return any
	__index = function(self, key)
		return self._internal.values[key]
	end,
	---@param self Inky.Props
	---@param key string
	---@param value any
	---@return any
	__newindex = function(self, key, value)
		self._internal.values[key] = value
		self._internal.changedValues:add(key)
	end,
}


---@class Inky.Props : { [string]: any }
---
---@field _internal Inky.Props.Internal
---
---@operator call:Inky.Props
local Props = function()
	local props = setmetatable({}, Mt)

	local internal = Internal(props)
	rawset(props, "_internal", internal)

	return props
end

return Props
