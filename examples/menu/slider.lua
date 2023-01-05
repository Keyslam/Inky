local Inky = require("inky")

local Knob = Inky.defineElement(function(self)
	self.props.hovered = false

	self:onPointerEnter(function()
		self.props.hovered = true
	end)

	self:onPointerExit(function()
		self.props.hovered = false
	end)

	return function(_, x, y, w, h)
		love.graphics.setColor(0.8, 0.8, 0.8, 1)
		love.graphics.rectangle("fill", x + 3, y + 3, w - 6, h - 6, 2)

		if (self.props.hovered) then
			love.graphics.rectangle("line", x, y, w, h, 2)
		end
	end
end)

local function inverseLerp(a, b, v)
	return (v - a) / (b - a)
end

return Inky.defineElement(function(self, scene)
	local knob = Knob(scene)

	local function setProgress(pointerX)
		local x, _, w, _ = self:getView()
		local progress = inverseLerp(x, x + w, pointerX)
		progress = math.max(0, progress)
		progress = math.min(1, progress)

		self.props.progress = progress
	end

	self:onPointer("press", function(_, pointer)
		pointer:captureElement(self)

		local pointerX, _ = pointer:getPosition()
		setProgress(pointerX)
	end)

	self:onPointer("release", function(_, pointer)
		pointer:captureElement(self, false)
	end)

	self:onPointer("drag", function(_, pointer)
		local pointerX, _ = pointer:getPosition()
		setProgress(pointerX)
	end)


	return function(_, x, y, w, h)
		do -- Rail
			local railHeight = h / 4
			local railY = y + (h - railHeight) / 2

			love.graphics.setColor(0.9, 0.2, 0.9, 1)
			love.graphics.rectangle("fill", x, railY, w * self.props.progress, railHeight, 2)

			love.graphics.setColor(0.8, 0.8, 0.8, 1)
			love.graphics.rectangle("fill", x + w * self.props.progress, railY, w * (1 - self.props.progress), railHeight, 2)
		end

		do -- Knob
			local knobH = h
			local knobW = knobH
			local knobX = x + w * self.props.progress - knobW / 2
			local knobY = y

			knob:render(knobX, knobY, knobW, knobH)
		end
	end
end)
