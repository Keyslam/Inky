local Inky = require("inky")

local Button = require("examples.windows.button")

local Header = Inky.element.make(function(scene, context, props)
	local dragging = false

	context:onPointer("move", function(pointer, view, dx, dy)
		if (dragging) then
			props.onMove()(dx, dy)
		end
	end)

	context:onPointer("press", function(pointer, view, presses)
		dragging = true
		context:capturePointer("move", true)
		context:capturePointer("release", true)
	end)

	context:onPointer("release", function()
		dragging = false
		context:capturePointer("move", false)
		context:capturePointer("release", false)
	end)

	return function(view)
		love.graphics.setColor(0, 0.35, 0.85, 1)
		love.graphics.rectangle("fill", view.x, view.y, view.w, view.h)
	end
end)

local ResizePoint = Inky.element.make(function(scene, context, props)
	local dragging = false

	context:onPointerEnter(function(pointer)
		pointer:getUserdata().cursorType = "resize"
	end)

	context:onPointerExit(function(pointer)
		pointer:getUserdata().cursorType = "default"
	end)

	context:onPointer("move", function(pointer, view, dx, dy)
		if (dragging) then
			props.onDrag()(dx, dy)
		end
	end)

	context:onPointer("press", function()
		dragging = true
		context:capturePointer("move", true)
		context:capturePointer("release", true)
	end)

	context:onPointer("release", function()
		dragging = false
		context:capturePointer("move", false)
		context:capturePointer("release", false)
	end)

	return function(view)
	end
end)

return Inky.element.make(function(scene, context, props)
	local onMove = function(dx, dy)
		props:move()(context:getWrapper(), dx, dy)
	end

	local onDrag = function(dx, dy)
		props:resize()(context:getWrapper(), dx, dy)
	end

	context:onPointer("press", function()
		props:focus()(context:getWrapper())
	end)

	context:onPointerInHierarchy("press", function()
		props:focus()(context:getWrapper())
	end)

	local header = Header(scene)
		:onMove(onMove)
		:onDrag(onDrag)
	local resizePoint = ResizePoint(scene)
		:onDrag(onDrag)
	local button = Button(scene)

	return function(view, depth)
		love.graphics.setColor(0, 0.35, 0.85, 1)
		love.graphics.rectangle("fill", view.x, view.y, view.w, view.h)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("fill", view.x + 3, view.y + 3, view.w - 6, view.h - 6)

		header(view.x + 3, view.y + 3, view.w - 6, 20)

		button(view.x + 6, view.y + 29, view.w - 12, 35)

		resizePoint(view.x + view.w - 3, view.y + view.h - 3, 7, 7)
	end
end)
