--
-- Maze module.
--
local screenW, screenH = display.contentWidth, display.contentHeight
local HERE = 0
--local N = 1
local S = 2
--local W = 3
local E = 4
local SE = 5


---
-- Main maze object
-- @field mazeData  Raw maze data loaded from maze config file.
-- @field group     Display group to add maze elements to.
-- @field physics   The physics simulation for the maze's scene.
--
local Maze = {
    --mazeData = nil,
    --group = nil,
    --physics = nil,
}

---
-- Creates a new Maze object.
-- @param o
--
function Maze:new (o)
    if (o == nil) then
        error("Maze:new: constructor requires a table as its input parameter")
    end

    if (o.mazeData == nil) then
        error("Maze:new: constructor table missing 'mazeData' field")
    end

    if (o.group == nil) then
        error("Maze:new: constructor table missing 'group' field")
    end

    --o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

---
-- Gets the number of rows in the raw maze data.
--
function Maze:getRows ()
    --print("Maze:getRows: ", #self.mazeData)
    return #self.mazeData
end

---
-- Gets the number of columns in the raw maze data.
--
function Maze:getCols ()
    --print("Maze:getCols: ", #self.mazeData[1])
    return #self.mazeData[1]
end

---
-- Gets number of rows and cols needed to display both the maze
-- passages and walls.
--
function Maze:getDisplayDimensions ()
    return self:getRows() * 2 + 1, self:getCols() * 2 + 1
end

---
-- Based on number of rows and columns in the maze, calculate the best screen
-- size for the square maze cells.
--
-- @param rows Needed number of rows.
-- @param cols Needed number of columns.
-- @return Size to use for square wall images.
--
function Maze:calcOptimalCellSize()
    local displayRows, displayCols = self:getDisplayDimensions()
    local cellWidth = math.floor(screenW / displayCols)
    local cellHeight = math.floor(screenH / displayRows)

    self.cellSize = math.min(cellWidth, cellHeight)
end

---
-- Get starting X/Y screen coordinates for drawing a maze.
-- @returns x,y coords of top left corner of maze.
--
function Maze:getStartCoords()
    local displayRows, displayCols = self:getDisplayDimensions()
    local totalMazeHeight = self.cellSize * displayRows
    local totalMazeWidth = self.cellSize * displayCols

    local startY = (screenH - totalMazeHeight) / 2
    local startX = (screenW - totalMazeWidth) / 2

    return startX, startY
end

---
-- Adds a wall to the maze.
-- @param group Display group to add wall to.
-- @param x X coordinate of cell to add wall to.
-- @param y Y coordinate of cell to add wall to.
-- @param where Position of wall (N, S, SE, or HERE).
--
function Maze:addWall(x, y, where)
    local wallX, wallY

    if where == HERE then   wallX, wallY = x, y
    elseif where == S then  wallX, wallY = x, y + self.cellSize
    elseif where == E then  wallX, wallY = x + self.cellSize, y
    elseif where == SE then wallX, wallY = x + self.cellSize, y + self.cellSize
    end

    local crate = display.newImageRect( "crate.png", self.cellSize, self.cellSize )
    crate.anchorX = 0
    crate.anchorY = 0
    crate.x, crate.y = wallX, wallY
    self.group:insert(crate)
    self.physics.addBody(crate, "static", { friction = 0.0 })
end

---
-- Creates the maze on the screen.
-- @param m     Maze matrix.
-- @param group Display group to add maze walls to.
-- @param displayCols Number of display columns needed for maze.
-- @param cellSize    Maze cell size as given by getOptimalCellSize().
-- @param startX      X coordinate to start drawing maze at.
-- @param startY      Y coordinate to start drawing maze at.
--
function Maze:display()
    self:calcOptimalCellSize()
    local startX, startY = self:getStartCoords(self)
    local displayRows, displayCols = self:getDisplayDimensions()

    local curX = startX
    local curY = startY

    --
    -- Create top border of walls across the entire level.
    --
    for i = 1,displayCols do
        self:addWall(curX, curY, HERE)
        curX = curX + self.cellSize
    end

    curY = curY + self.cellSize

    local mazeRows, mazeCols = self:getRows(), self:getCols()
    --
    -- Run through each row in the maze data
    --
    for r = 1,mazeRows do
        curX = startX

        -- Add leftmost/western border for this row
        self:addWall(curX, curY, HERE)

        -- Add corner cap under border
        self:addWall(curX, curY, S)

        curX = curX + self.cellSize

        for c = 1,mazeCols do
            -- Add south east corner cap
            self:addWall(curX, curY, SE)

            -- If there is a south wall, create it
            if self.mazeData[r][c][S] == 1 then
                self:addWall(curX, curY, S)
            end

            -- Move to where east wall would be
            curX = curX + self.cellSize

            -- If there is a east wall, create it
            if self.mazeData[r][c][E] == 1 then
                self:addWall(curX, curY, HERE)
            end

            curX = curX + self.cellSize
        end

        curY = curY + self.cellSize*2
    end
end

return Maze