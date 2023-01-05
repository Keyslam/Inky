local Inky = require("inky")

local font = love.graphics.newFont("examples/menu/coolvetica.ttf", 12)

return Inky.defineElement(function(self)
	self:onPointer("release", function()
		self.props.setActiveKey(self.props.key)
	end)

	return function(_, x, y, w, h)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", x, y + (h - w), w, w, 5)

		love.graphics.setFont(font)
		local width = font:getWidth(self.props.key)
		love.graphics.print(self.props.key, x - (width - w) / 2, y)

		if (self.props.activeKey == self.props.key) then
			love.graphics.setColor(0.9, 0.2, 0.9, 1)
			love.graphics.rectangle("fill", x + 3, y + 3 + h - w, w - 6, w - 6, 5)
		end
	end
end)
