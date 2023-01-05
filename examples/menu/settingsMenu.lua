local Inky = require("inky")

local Label       = require("examples.menu.label")
local Switch      = require("examples.menu.switch")
local Slider      = require("examples.menu.slider")
local RadioButton = require("examples.menu.radioButton")
local Button      = require("examples.menu.button")

local font = love.graphics.newFont("examples/menu/coolvetica.ttf", 22)

return Inky.defineElement(function(self, scene)
	local musicLabel = Label(scene)
	musicLabel.props.text = "Music"

	local musicSwitch = Switch(scene)
	musicSwitch.props.active = true


	local sfxLabel = Label(scene)
	sfxLabel.props.text = "Sfx"

	local sfxSwitch = Switch(scene)
	sfxSwitch.props.active = false


	local volumeLabel = Label(scene)
	volumeLabel.props.text = "Volume"

	local volumeSlider = Slider(scene)
	volumeSlider.props.progress = 0.5


	local qualityLabel = Label(scene)
	qualityLabel.props.text = "Quality"

	local qualityLowRadio = RadioButton(scene)
	qualityLowRadio.props.key = "Low"

	local qualityMediumRadio = RadioButton(scene)
	qualityMediumRadio.props.key = "Medium"

	local qualityHighRadio = RadioButton(scene)
	qualityHighRadio.props.key = "High"

	local function setQualityActiveKey(key)
		qualityLowRadio.props.activeKey = key
		qualityMediumRadio.props.activeKey = key
		qualityHighRadio.props.activeKey = key
	end

	qualityLowRadio.props.setActiveKey = setQualityActiveKey
	qualityMediumRadio.props.setActiveKey = setQualityActiveKey
	qualityHighRadio.props.setActiveKey = setQualityActiveKey

	setQualityActiveKey("Medium")


	local saveButton = Button(scene)
	saveButton.props.backgroundColor = { 0.9, 0.2, 0.9, 1 }
	saveButton.props.textColor = { 1, 1, 1, 1 }
	saveButton.props.style = "fill"
	saveButton.props.text = "Save"


	local cancelButton = Button(scene)
	cancelButton.props.backgroundColor = { 0.8, 0.8, 0.8, 1 }
	cancelButton.props.textColor = { 1, 1, 1, 1 }
	cancelButton.props.style = "line"
	cancelButton.props.text = "Cancel"


	return function(_, x, y, w, h)
		local borderRounding = 10
		local headerHeight = 50
		local fontHeight = font:getHeight()

		do -- Border
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("line", x, y, w, h, borderRounding)
		end

		do -- Header
			love.graphics.setScissor(x, y, w, headerHeight)
			love.graphics.setColor(0, 0, 0, 0.7)
			love.graphics.rectangle("fill", x, y, w, headerHeight + borderRounding, borderRounding)
			love.graphics.setScissor()

			love.graphics.setFont(font)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print("Settings", x + 20, y + (headerHeight - fontHeight) / 2)
		end

		do -- Background
			love.graphics.setScissor(x, y + headerHeight, w, h - headerHeight)
			love.graphics.setColor(0, 0, 0, 0.5)
			love.graphics.rectangle("fill", x, y + headerHeight - borderRounding, w, h - headerHeight + borderRounding,
				borderRounding)
			love.graphics.setScissor()
		end

		do -- Content
			local contentX = x + 30
			local contentY = y + headerHeight
			local contentW = w - 60

			musicLabel:render(contentX, contentY + 20, contentW, 30)
			musicSwitch:render(contentX + contentW - 60, contentY + 20, 60, 20)

			sfxLabel:render(contentX, contentY + 60, contentW, 30)
			sfxSwitch:render(contentX + contentW - 60, contentY + 60, 60, 20)

			volumeLabel:render(contentX, contentY + 100, contentW, 30)
			volumeSlider:render(contentX + contentW - 200, contentY + 100, 200, 30)

			qualityLabel:render(contentX, contentY + 140, contentW, 50)
			qualityLowRadio:render(contentX + contentW - 150, contentY + 140, 30, 50)
			qualityMediumRadio:render(contentX + contentW - 90, contentY + 140, 30, 50)
			qualityHighRadio:render(contentX + contentW - 30, contentY + 140, 30, 50)

			local buttonWidth = contentW / 2 - 20
			saveButton:render(contentX, y + h - 70, buttonWidth, 50)
			cancelButton:render(contentX + contentW - buttonWidth, y + h - 70, buttonWidth, 50)
		end
	end
end)
