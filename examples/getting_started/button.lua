local Inky = require("inky")

return Inky.element.make(function(scene, context, props)
	local count = 0

	context:onPointer("release", function()
		count = count + 1
	end)

	return function(view)
		love.graphics.rectangle("line", view.x, view.y, view.w, view.h)
		love.graphics.printf("I have been clicked " .. count .. " times", view.x, view.y, view.w, "center")
	end
end)
