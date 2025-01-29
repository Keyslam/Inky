love.graphics.setNewFont(32)

local Inky = require("inky")

local MenuItem = Inky.defineElement(function(self)
    self.props.label = self.props.label
    self.props.selected = false
    self.props.selectedTime = 0

    self:onPointerEnter(function()
        self.props.selected = true
        self.props.selectedTime = love.timer.getTime()
    end)

    self:onPointerExit(function()
        self.props.selected = false
    end)

    return function(_, x, y, w, h)
        local offset = self.props.selected
            and math.sin((love.timer.getTime() - self.props.selectedTime) * 5) * 5
            or 0

        love.graphics.printf(self.props.label, x, y + offset, w, "center");
    end
end)

local scene = Inky.scene()
local mousePointer = Inky.pointer(scene)
mousePointer:setActive(false)

local keyboardPointer = Inky.pointer(scene)
keyboardPointer:setActive(false)
local keyboardPointerSelectedIndex = 1

local menuItems = {}

menuItems[1] = MenuItem(scene)
menuItems[1].props.label = "Play"

menuItems[2] = MenuItem(scene)
menuItems[2].props.label = "Options"

menuItems[3] = MenuItem(scene)
menuItems[3].props.label = "Quit"

function love.draw()
    scene:beginFrame()

    for i, menuItem in ipairs(menuItems) do
        menuItem:render(0, i * 100 + 50, love.graphics.getWidth(), 50)
    end

    scene:finishFrame()
end

function love.mousemoved(x, y)
    mousePointer:setPosition(x, y)
    mousePointer:setActive(true)
    keyboardPointer:setActive(false)
end

function love.keypressed(key)
    if (key == "up" or key == "down") then
        if (not keyboardPointer:isActive()) then
            mousePointer:setActive(false)
            keyboardPointer:setActive(true)
            keyboardPointerSelectedIndex = 1
        else
            if (key == "up") then
                keyboardPointerSelectedIndex = keyboardPointerSelectedIndex - 1
                if (keyboardPointerSelectedIndex == 0) then
                    keyboardPointerSelectedIndex = #menuItems
                end
            else
                keyboardPointerSelectedIndex = keyboardPointerSelectedIndex + 1
                if (keyboardPointerSelectedIndex > #menuItems) then
                    keyboardPointerSelectedIndex = 1
                end
            end
        end

        keyboardPointer:setTarget(menuItems[keyboardPointerSelectedIndex])
    end
end
