local PATH = (...):gsub('%.init$', '')

local Inky = {
	_VERSION     = "1.0",
	_DESCRIPTION = "A GUI Framework for LÖVE",
	_LICENCE     = [[
		MIT LICENSE
		Copyright (c) 2025 Justin van der Leij (Keyslam)
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   ]]
}

---@module "inky.core.scene"
Inky.scene = require(PATH .. ".core.scene")
---@module "inky.core.pointer"
Inky.pointer = require(PATH .. ".core.pointer")
---@module "inky.core.defineElement"
Inky.defineElement = require(PATH .. ".core.defineElement")

return Inky
