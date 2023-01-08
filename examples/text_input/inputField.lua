local Inky = require("inky")

return Inky.defineElement(function(self)
	self.props.text = ""

	self:onPointer("release", function()
		self.props.select(self)
	end)

	self:onPointer("textinput", function(_, _, t)
		self.props.text = self.props.text .. t
	end)

	self:onPointer("backspace", function()
		self.props.text = self.props.text:sub(1, #self.props.text - 1)
	end)

	self:onPointer("return", function()
		print(self.props.text)
		self.props.text = ""
	end)

	return function(_, x, y, w, h)
		if (self.props.isSelected(self)) then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(0.8, 0.8, 0.8)
		end
		love.graphics.rectangle("line", x, y, w, h)

		love.graphics.print(self.props.text, x, y)
	end
end)
