local PATH = string.sub(..., 1, string.len(...) - string.len("core.spatialHash"))

---@module "inky.lib.class"
local Class = require(PATH .. "lib.class")
---@module "inky.lib.hashSet"
local HashSet = require(PATH .. "lib.hashSet")


---@alias Inky.SpatialHash.Cell Inky.HashSet


---@class Inky.SpatialHash
---
---@field private _size integer
---
---@field private _cells Inky.SpatialHash.Cell[]
---@field private _elements { [Inky.Scene]: Inky.SpatialHash.Cell[] }
---
---@operator call:Inky.SpatialHash
local SpatialHash = Class()

function SpatialHash:constructor(size)
	self._size = size

	self._cells    = {}
	self._elements = {}
end

---@param x integer
---@param y integer
---@return number hash
---@private
---@nodiscard
function SpatialHash:_hash(x, y)
	return 0.5 * (x + y) * (x + y + 1) + y
end

---@param hash integer
---@return integer x
---@return integer y
---@private
---@nodiscard
function SpatialHash:_inverseHash(hash)
	local n = math.floor((-1 + math.sqrt(8 * hash + 1)) / 2)
	local y = hash - 0.5 * (n + 1) * n
	local x = n - y

	return x, y
end

---@param v integer
---@return integer cellV
---@private
---@nodiscard
function SpatialHash:_toCell(v)
	return math.floor(v / self._size)
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return integer topLeftCellX
---@return integer topLeftCellY
---@return integer bottomRightCellX
---@return integer bottomRightCellY
---@private
---@nodiscard
function SpatialHash:_toCellBounds(x, y, w, h)
	local topLeftCellX     = self:_toCell(x)
	local topLeftCellY     = self:_toCell(y)
	local bottomRightCellX = self:_toCell(x + w)
	local bottomRightCellY = self:_toCell(y + h)

	return topLeftCellX, topLeftCellY, bottomRightCellX, bottomRightCellY
end

---@param element Inky.Element
---@return self
function SpatialHash:add(element)
	local x, y, w, h = element:__getInternal():getView()
	local topLeftCellX, topLeftCellY, bottomRightCellX, bottomRightCellY = self:_toCellBounds(x, y, w, h)

	local cellLookup = self._elements[element]
	if (cellLookup == nil) then
		cellLookup = {}
		self._elements[element] = cellLookup
	end

	for cellX = topLeftCellX, bottomRightCellX do
		for cellY = topLeftCellY, bottomRightCellY do
			local cellHash = self:_hash(cellX, cellY)

			local cell = self._cells[cellHash]
			if (cell == nil) then
				cell = HashSet()
				self._cells[cellHash] = cell
			end

			cell:add(element)

			table.insert(cellLookup, cell)
		end
	end

	return self
end

---@param element Inky.Element
---@return self
function SpatialHash:remove(element)
	local cellLookup = self._elements[element]
	if (cellLookup == nil) then
		return self
	end

	for i = 1, #cellLookup do
		local cell = cellLookup[i]
		cell:remove(element)
	end

	self._elements[element] = nil

	return self
end

---@param element Inky.Element
---@return self
function SpatialHash:move(element)
	self:remove(element)
	self:add(element)

	return self
end

---@param x integer
---@param y integer
---@return Inky.SpatialHash.Cell
---@nodiscard
function SpatialHash:getElementsAtPoint(x, y)
	local cellX = self:_toCell(x)
	local cellY = self:_toCell(y)

	local cellHash = self:_hash(cellX, cellY)

	local cell = self._cells[cellHash]

	return cell
end

return SpatialHash
