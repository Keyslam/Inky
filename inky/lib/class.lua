local function new(self, ...)
	local obj = setmetatable({}, self)
	if self.constructor then self.constructor(obj, ...) end
	return obj
end

local mt = {
	__call = function(self, ...)
		return self:new(...)
	end
}

---Create a Class
---@return table
return function()
	local class = {
		new = new
	}

	class.class = class
	class.__index = class

	return setmetatable(class, mt)
end
