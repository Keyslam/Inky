local Inky = require("inky")

return Inky.defineElement(function(self, scene)
	self:useOverlapCheck(self.props.overlapCheck)

	self:onPointer("release", function()
		print("button " .. self.props.name .. " clicked")
	end)

	return function(_, x, y, w, h)
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", x, y, w, h)

		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.props.name, x, y)
	end
end)
