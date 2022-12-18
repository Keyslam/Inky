local Caller = setmetatable({
	_field = nil,
}, {
	__call = function(self, wrapper, value)
		local element = wrapper._element

		if (not element.hiddenProps[self._field]) then
			local field = self._field
			element.props[field] = function()
				return element.hiddenProps[field]
			end
		end

		element.hiddenProps[self._field] = value

		local getter = element.props[self._field]
		element.context:handlePropChanged(getter)

		return wrapper
	end
})

return Caller
