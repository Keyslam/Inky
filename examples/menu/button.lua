local Inky = require("inky")

local font = love.graphics.newFont("examples/menu/coolvetica.ttf", 20)
local fontHeight = font:getHeight()

return Inky.defineElement(function(self)
	self.props.hovered = false

	self:onPointerEnter(function()
		self.props.hovered = true
	end)

	self:onPointerExit(function()
		self.props.hovered = false
	end)

	return function(_, x, y, w, h)
		love.graphics.setColor(self.props.backgroundColor)
		love.graphics.rectangle(self.props.style, x + 3, y + 3, w - 6, h - 6, 5)

		if (self.props.hovered) then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("line", x, y, w, h, 5)
		end

		love.graphics.setFont(font)
		love.graphics.setColor(self.props.textColor)
		love.graphics.printf(self.props.text, x, y + (h - fontHeight) / 2, w, "center")
	end
end)
