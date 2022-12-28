local Inky = require("inky")

return Inky.element.make(function(scene, context, props)
	context = context --[[@as Inky.Context]]

	local pressed = false
	local count = 0

	context:onPointer("press", function()
		pressed = true
	end)

	context:onPointer("release", function()
		if (pressed) then
			count = count + 1
			pressed = false
		end
	end)

	return function(view)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("line", view.x, view.y, view.w, view.h)
		love.graphics.printf("I have been clicked " .. count .. " times", view.x + 3, view.y + 3, view.w - 6, "center")
	end
end)
