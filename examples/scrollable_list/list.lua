local Inky = require("inky")

local Button = require("examples.scrollable_list.button")

return Inky.defineElement(function(self, scene)
	local buttonHeight  = 30
	local buttonPadding = 10

	self.props.offsetY = 0
	self.props.buttons = {}

	local function overlapCheck(px, py)
		local x, y, w, h = self:getView()
		return px >= x and px < x + w and py >= y and py < y + h
	end

	for i = 1, 10 do
		local button = Button(scene)
		button.props.name = tostring(i)
		button.props.overlapCheck = overlapCheck

		self.props.buttons[i] = button
	end

	self:onPointer("scroll", function(_, _, dy)
		local offsetY = self.props.offsetY + dy * 10

		local _, _, _, h = self:getView()

		offsetY = math.min(0, offsetY)
		offsetY = math.max(-h + buttonPadding, offsetY)

		self.props.offsetY = offsetY
	end)

	return function(_, x, y, w, h)
		love.graphics.setScissor(x, y, w, h)

		for i, button in ipairs(self.props.buttons) do
			local buttonH = buttonHeight
			local buttonY = y + (i - 1) * (buttonH + buttonPadding) + self.props.offsetY

			button:render(x, buttonY, w, buttonH)
		end

		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("line", x, y, w, h)

		love.graphics.setScissor()
	end
end)
