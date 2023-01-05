local Inky = require("inky")

local SettingsMenu = require("examples.menu.settingsMenu")

local scene   = Inky.scene()
local pointer = Inky.pointer(scene)

love.window.setMode(1280, 720, {
	msaa = 8
})
love.window.setTitle("Example: Menu")


local background = love.graphics.newImage("examples/menu/background.png")

local settingsMenu = SettingsMenu(scene)

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(background)

	scene:beginFrame()
	settingsMenu:render(440, 110, 400, 500)
	scene:finishFrame()
end

function love.mousepressed(x, y, button)
	if (button == 1) then
		pointer:raise("press")
	end
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:raise("release")
	end
end

function love.mousemoved(x, y, dx, dy)
	if (love.mouse.isDown(1)) then
		pointer:setPosition(x, y)
		pointer:raise("drag", dx, dy)
	end
end
