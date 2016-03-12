--
-- Maze package/object.
--
local tm = require("tilemap")

local screenW, screenH = display.contentWidth, display.contentHeight


---
-- Main maze object
-- @field tilemap   Maze tilemap data (2d array of tile identifiers).
-- @field group     Display group to add maze elements to.
-- @field theme     Display theme for this maze.
--
local Maze = {
    tilemap = nil,
    group = nil,
    theme = nil,
}

---
-- Creates a new Maze object.
-- @param o
--
function Maze:new (o)
    if (o == nil) then
        error("Maze:new: constructor requires a table as its input parameter")
    end

    if (o.tilemap == nil) then
        error("Maze:new: constructor table missing 'mazeData' field")
    end

    if (o.group == nil) then
        error("Maze:new: constructor table missing 'group' field")
    end

    -- Default to test theme
    if (o.theme == nil) then
        o.theme = require("theme_crate")
    end

    --o = o or {}
    setmetatable(o, self)
    self.__index = self

    --
    -- Set convenience variables for number of rows/cols in our tilemap
    --
    self.rows = #self.tilemap
    self.cols = #self.tilemap[1]

    return o
end

---
-- Gets number of rows and cols needed to display both the maze
-- passages and walls.
--
--function Maze:getDisplayDimensions ()
--    return self:getRows() * 2 + 1, self:getCols() * 2 + 1
--end

---
-- Based on number of rows and columns in the maze tilemap, calculate the best screen
-- size for the square maze cells.
--
-- @return Size to use for square wall images.
--
function Maze:calcOptimalCellSize()
    local cellWidth = math.floor(screenW / self.cols)
    local cellHeight = math.floor(screenH / self.rows)

    self.cellSize = math.min(cellWidth, cellHeight)
end

---
-- Get starting X/Y screen coordinates for drawing a maze.
-- @returns x,y coords of top left corner of maze.
--
function Maze:getStartCoords()
    local totalMazeHeight = self.cellSize * self.rows
    local totalMazeWidth = self.cellSize * self.cols

    local startY = (screenH - totalMazeHeight) / 2
    local startX = (screenW - totalMazeWidth) / 2

    return startX, startY
end


---
-- Creates the maze on the screen.
--
function Maze:display()
    self:calcOptimalCellSize()

    local disp = display
    --
    -- Run through each row and col in the maze tilemap creating the maze tiles
    --
    for r = 1,self.rows do

        for c = 1,self.cols do
            local tile = disp.newImageRect(
                self.group, self.theme[ self.tilemap[r][c] ], self.cellSize, self.cellSize )

            tile.anchorX = 0
            tile.anchorY = 0
            tile.x = c * self.cellSize
            tile.y = r * self.cellSize
        end

    end

    --
    -- Move display group so that it is centered in the middle of the screen.
    --
    local startX, startY = self:getStartCoords(self)
    self.group.x = startX
    self.group.y = startY
end


function Maze:isWalkable(x, y)
    local col = x / self.cellSize
    local row = y / self.cellSize

    return tm.isWall(self.tilemap[row][col])
end

return Maze