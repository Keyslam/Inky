local PATH = string.sub(..., 1, string.len(...) - string.len("core.defineElement"))

local Element = require(PATH .. "core.element")

---Creates a definition for an Element
---
---Call the definition to create an instance of the Element
---
---@param initializer Inky.Element.Initializer
---@return fun(scene: Inky.Scene): Inky.Element
local DefineElement = function(initializer)
	return function(scene)
		return Element(scene, initializer)
	end
end

return DefineElement
