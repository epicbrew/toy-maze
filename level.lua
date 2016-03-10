--
-- level.lua
--

local Maze = require ("maze")
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
local screenW, screenH = display.contentWidth, display.contentHeight
local touchPosition = { x = 0, y = 0 }
local moveSpeed = 6
local player

local function updatePlayerPosition (event)
    local _player = player
    local tp = touchPosition
    local mvSpeed = moveSpeed

    if tp.x > _player.x then
        _player.x = _player.x + mvSpeed
    else
        _player.x = _player.x - mvSpeed
    end

    if tp.y > _player.y then
        _player.y = _player.y + mvSpeed
    else
        _player.y = _player.y - mvSpeed
    end
end

local function addFrameListener ()
    Runtime:addEventListener("enterFrame", updatePlayerPosition)
end

local function removeFrameListener ()
    Runtime:removeEventListener("enterFrame", updatePlayerPosition)
end

local function touchCallback(event)
    if event.phase == "began" then
        touchPosition.x = event.x
        touchPosition.y = event.y
        timer.performWithDelay(1, addFrameListener)
    elseif event.phase == "moved" then
        touchPosition.x = event.x
        touchPosition.y = event.y
    elseif event.phase == "ended" then
        timer.performWithDelay(1, removeFrameListener)
    end

    return true
end

local function addPlayer(group, cellSize, row, col, startX, startY)
    local x = startX + cellSize + (cellSize * 0.5)
    local y = startY + cellSize + (cellSize * 0.5)


    local player = display.newCircle( x, y, cellSize * 0.4 )
    player:setFillColor( 1, 0, 0 )

    function player:touch( event )
        if event.phase == "moved" then
            if event.x > self.x then
                self.x = self.x + 5
            else
                self.x = self.x - 5
            end

            if event.y > self.y then
                self.y = self.y + 5
            else
                self.y = self.y - 5
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
    Runtime:addEventListener( "touch", player)
    --Runtime:addEventListener( "touch", touchCallback)

    group:insert(player)
    physics.addBody(player, { friction = 0.0 })
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
    print("loading maze data: ", params.mazeData)
	local levelMazeData = require (params.mazeData)

    --local mazeRows, mazeCols = #mazeData.maze, #mazeData.maze[1]
    --local displayRows, displayCols = mazeRows*2+1, mazeCols*2+1
    --local cellSize = getOptimalCellSize(displayRows, displayCols)

    local mazeGroup = display.newGroup()
    self.maze = Maze:new({
        mazeData = levelMazeData.maze,
        group = mazeGroup,
        physics = physics,
    })

    self.maze:display()


	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( mazeGroup )

    local startX, startY = self.maze:getStartCoords()

    addPlayer(sceneGroup, self.maze.cellSize, 0, 0, startX, startY)
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
