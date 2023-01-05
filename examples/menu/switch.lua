local Inky = require("inky")

return Inky.defineElement(function(self)
	self:onPointer("release", function()
		self.props.active = not self.props.active
	end)

	return function(_, x, y, w, h)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", x, y, w, h, 5)

		local indicatorPadding = 3
		local indicatorW = (w - indicatorPadding * 2) * 0.6

		if (self.props.active) then
			local indicatorX = x + w - indicatorW - indicatorPadding
			local indicatorY = y + indicatorPadding
			local indicatorH = h - indicatorPadding * 2

			love.graphics.setColor(0.9, 0.2, 0.9, 1)
			love.graphics.rectangle("fill", indicatorX, indicatorY, indicatorW, indicatorH, 5)
		else
			local indicatorX = x + indicatorPadding
			local indicatorY = y + indicatorPadding
			local indicatorH = h - indicatorPadding * 2

			love.graphics.setColor(0.8, 0.8, 0.8, 1)
			love.graphics.rectangle("fill", indicatorX, indicatorY, indicatorW, indicatorH, 5)
		end
	end
end)
