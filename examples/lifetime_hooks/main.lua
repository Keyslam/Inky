local Inky = require("inky")

local TestElement = Inky.defineElement(function(self)
	self:onEnable(function()
		print("Enabled")
	end)

	self:onDisable(function()
		print("Disabled")
	end)

	return function(_, x, y, w, h, depth)
		love.graphics.print("Visible")
	end
end)

local scene = Inky.scene()

local testElement = TestElement(scene)
local testElementVisible = true

love.window.setTitle("Example: Lifetime hooks")

function love.draw()
	scene:beginFrame()

	if (testElementVisible) then
		testElement:render(0, 0, 0, 0)
	end

	scene:finishFrame()
end

function love.keypressed(x, y, button)
	testElementVisible = not testElementVisible
end
