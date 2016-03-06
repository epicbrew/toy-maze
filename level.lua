--
-- level.lua
--

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start();
physics.setGravity(0, 0);
physics.pause()

--------------------------------------------

--
-- forward declarations and other locals
--
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local HERE = 0
local N = 1
local S = 2
local W = 3
local E = 4
local SE = 5

---
-- Based on number of rows and columns in the maze, calculate the best screen
-- size for the square maze cells.
--
-- @param rows Needed number of rows.
-- @param cols Needed number of columns.
-- @return Size to use for square wall images.
--
local function getOptimalCellSize(rows, cols)
    local cellWidth = math.floor(screenW / cols)
    local cellHeight = math.floor(screenH / rows)

    return math.min(cellWidth, cellHeight)
end


---
-- Adds a wall to the maze.
-- @param group Display group to add wall to.
-- @param x X coordinate of cell to add wall to.
-- @param y Y coordinate of cell to add wall to.
-- @param where Position of wall (N, S, SE, or HERE).
--
local function addWall(group, x, y, where, cellSize)
    local wallX, wallY

    if where == HERE then   wallX, wallY = x, y
    elseif where == S then  wallX, wallY = x, y + cellSize
    elseif where == E then  wallX, wallY = x + cellSize, y
    elseif where == SE then wallX, wallY = x + cellSize, y + cellSize
    end

    local crate = display.newImageRect( "crate.png", cellSize, cellSize )
    crate.anchorX = 0
    crate.anchorY = 0
    crate.x, crate.y = wallX, wallY
    group:insert(crate)
    physics.addBody(crate, "static", { friction = 0.0 })
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
local function createMaze(m, group, displayCols, cellSize, startX, startY)

    local curX = startX
    local curY = startY

    local crate
    for i = 1,displayCols do
        addWall(group, curX, curY, HERE, cellSize)
        curX = curX + cellSize
    end

    curY = curY + cellSize

    for r = 1,#m do
        curX = startX

        addWall(group, curX, curY, HERE, cellSize)

        addWall(group, curX, curY, S, cellSize)

        curX = curX + cellSize

        for c = 1,#m[r] do
            addWall(group, curX, curY, SE, cellSize)

            if m[r][c][S] == 1 then
                addWall(group, curX, curY, S, cellSize)
            end

            curX = curX + cellSize

            if m[r][c][E] == 1 then
                addWall(group, curX, curY, HERE, cellSize)
            end

            curX = curX + cellSize
        end

        curY = curY + cellSize*2
    end
end

local function addPlayer(group, cellSize, row, col, startX, startY)
    local x = startX + cellSize + (cellSize * 0.5)
    local y = startY + cellSize + (cellSize * 0.5)


    local myObject = display.newCircle( x, y, cellSize * 0.4 )
    myObject:setFillColor( 1, 0, 0 )

    -- touch listener function
    function myObject:touch( event )
        if event.phase == "moved" then
            if event.x > self.x then
                self.x = self.x + 2
            else
                self.x = self.x - 2
            end

            if event.y > self.y then
                self.y = self.y + 2
            else
                self.y = self.y - 2
            end

        end

        return true
    end

    --[[
    function myObject:touch( event )
        if event.phase == "began" then

            self.markX = self.x    -- store x location of object
            self.markY = self.y    -- store y location of object

        elseif event.phase == "moved" then

            local x = (event.x - event.xStart) + self.markX
            local y = (event.y - event.yStart) + self.markY

            self.x, self.y = x, y    -- move object based on calculations above
        end

        return true
    end
    ]]--

    -- make 'myObject' listen for touch events
    --myObject:addEventListener( "touch", myObject )
    Runtime:addEventListener( "touch", myObject )

    group:insert(myObject)
    physics.addBody(myObject, { friction = 0.0 })
end

function scene:create( event )
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	local params = event.params

	--
	-- Load up our maze data
	--
    print(params.mazeData)
	local level = require (params.mazeData)

    print("--->", #level.maze, #level.maze[1])

    local mazeRows, mazeCols = #level.maze, #level.maze[1]
    local displayRows, displayCols = mazeRows*2+1, mazeCols*2+1
    local cellSize = getOptimalCellSize(displayRows, displayCols)

    local mazeGroup = display.newGroup()

    local totalMazeHeight = cellSize * displayRows
    local totalMazeWidth = cellSize * displayCols

    local startY = (screenH - totalMazeHeight) / 2
    local startX = (screenW - totalMazeWidth) / 2

    createMaze(level.maze, mazeGroup, displayCols, cellSize, startX, startY)

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( mazeGroup )

    addPlayer(sceneGroup, cellSize, 0, 0, startX, startY)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
