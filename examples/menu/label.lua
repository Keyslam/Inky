local Inky = require("inky")

local font = love.graphics.newFont("examples/menu/coolvetica.ttf", 20)

return Inky.defineElement(function(self)
	local fontHeight = font:getHeight()

	return function(_, x, y, w, h)
		love.graphics.setFont(font)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(self.props.text, x, y + (h - fontHeight) / 2)
	end
end)
