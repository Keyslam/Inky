local Inky = require("inky")

local List = require("examples.scrollable_list.list")

local scene   = Inky.scene()
local pointer = Inky.pointer(scene)

local list = List(scene)

love.window.setTitle("Example: Scrollable List")

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
end

function love.draw()
	scene:beginFrame()

	list:render(50, 50, 200, 200)

	scene:finishFrame()
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:raise("release")
	end
end

function love.wheelmoved(dx, dy)
	pointer:raise("scroll", dy)
end
