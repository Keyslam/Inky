local Inky = require("inky")

local Window = require("examples.windows.window")

local Resize = love.mouse.getSystemCursor("sizenwse")

local scene   = Inky.scene()
local pointer = Inky.pointer(scene, {
	cursorType = "default"
})

local windows = {}

local function getWindowData(windowElement)
	for _, windowData in ipairs(windows) do
		if (windowData.element == windowElement) then
			return windowData
		end
	end
end

local function move(windowElement, dx, dy)
	local windowData = getWindowData(windowElement)
	windowData.x = windowData.x + dx
	windowData.y = windowData.y + dy
end

local function resize(windowElement, dx, dy)
	local windowData = getWindowData(windowElement)
	windowData.w = windowData.w + dx
	windowData.h = windowData.h + dy
end

local function focus(windowElement)
	for i, windowData in ipairs(windows) do
		if (windowData.element == windowElement) then
			table.remove(windows, i)
			table.insert(windows, windowData)
			break
		end
	end
end

local function addWindow()
	local x = love.math.random(0, love.graphics.getWidth() - 100)
	local y = love.math.random(0, love.graphics.getWidth() - 100)
	local w = love.math.random(100, 200)
	local h = love.math.random(100, 200)

	local window  = Window(scene)
	window.move   = move
	window.resize = resize
	window.focus  = focus

	table.insert(windows, {
		element = window,
		x = x,
		y = y,
		w = w,
		h = h,
	})
end

addWindow()
addWindow()
addWindow()

love.window.setTitle("Example: Window")
local background = love.graphics.newImage("examples/windows/bg.png")

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)

	local cursorType = nil
	if (pointer:getUserdata().cursorType == "resize") then
		cursorType = Resize
	end
	love.mouse.setCursor(cursorType)
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(background)

	scene:newFrame()

	for depth, window in ipairs(windows) do
		window.element(window.x, window.y, window.w, window.h, depth)
	end
end

function love.mousepressed(x, y, button, _, presses)
	if (button == 1) then
		pointer:emit("press", presses)
	end
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:emit("release")
	end
end

function love.mousemoved(x, y, dx, dy)
	pointer:emit("move", dx, dy)
end
