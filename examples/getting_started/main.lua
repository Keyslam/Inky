local Inky = require("inky")

local Button = require("examples.getting_started.button")

local scene   = Inky.scene()
local pointer = Inky.pointer(scene)

local button_1 = Button(scene)
local button_2 = Button(scene)

love.window.setMode(220, 66)
love.window.setTitle("Example: Getting Started")

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
end

function love.draw()
	scene:beginFrame()

	button_1:render(10, 10, 200, 16)
	button_2:render(10, 40, 200, 16)

	scene:finishFrame()
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:raise("release")
	end
end
