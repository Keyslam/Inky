local Inky = require("inky")

local InputField = require("examples.text_input.inputField")

local scene = Inky.scene()

local pointer          = Inky.pointer(scene)
local selectionPointer = Inky.pointer(scene)

local function isSelected(element)
	return selectionPointer:getTarget() == element
end

local function select(element)
	return selectionPointer:setTarget(element)
end

local inputFields = {}
for i = 1, 3 do
	local inputField = InputField(scene)
	inputField.props.isSelected = isSelected
	inputField.props.select = select

	inputFields[i] = inputField
end

love.window.setTitle("Example: Text Input")

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
end

function love.draw()
	scene:beginFrame()

	for i, inputField in ipairs(inputFields) do
		inputField:render(10, i * 30, 200, 16)
	end

	scene:finishFrame()
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:raise("release")
	end
end

function love.textinput(t)
	selectionPointer:raise("textinput", t)
end

function love.keypressed(key)
	if (key == "backspace") then
		selectionPointer:raise("backspace")
	end

	if (key == "return") then
		selectionPointer:raise("return")
	end
end
