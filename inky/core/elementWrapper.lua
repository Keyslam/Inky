local WrapperMt = {
	__index = function(self, key)
		self._caller._field = key
		return self._caller
	end,
	__newindex = function(self, key, value)
		self._caller._field = key
		self:_caller(value)
	end,
	__call = function(self, x, y, width, height)
		self._element:draw(x, y, width, height)
	end
}

return function(element, caller)
	local wrapper = setmetatable({
		_element = element,
		_caller = caller,
	}, WrapperMt)

	return wrapper
end
