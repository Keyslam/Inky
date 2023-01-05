local Inky = require("inky")

return Inky.defineElement(function(self)
	self.props.count = 0

	self:onPointer("release", function()
		self.props.count = self.props.count + 1
	end)

	return function(_, x, y, w, h, depth)
		love.graphics.rectangle("line", x, y, w, h)
		love.graphics.printf("I have been clicked " .. self.props.count .. " times", x, y, w, "center")
	end
end)
