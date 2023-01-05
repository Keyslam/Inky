local PATH = (...):gsub('%.init$', '')

---@module "inky"
local Inky = require(PATH .. ".inky")

return Inky
