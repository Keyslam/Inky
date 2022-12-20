local Inky = require("inky")

local TestElement = Inky.element.make(function(scene, context, props)
	context:onEnable(function()
		print("Enabled")
	end)

	context:onDisable(function()
		print("Disabled")
	end)

	return function(view)
		love.graphics.print("Visible")
	end
end)

local scene = Inky.scene()

local testElement = TestElement(scene)
local testElementVisible = true

love.window.setTitle("Example: Lifetime hooks")

function love.draw()
	scene:newFrame()

	if (testElementVisible) then
		testElement(0, 0, 0, 0)
	end
end

function love.keypressed(x, y, button)
	testElementVisible = not testElementVisible
end
