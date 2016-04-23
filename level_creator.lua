-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local creator = require "creator"
local Maze = require "maze"

--------------------------------------------

-- forward declarations and other locals
local decRowBtn, incRowBtn
local decColBtn, incColBtn
local createBtn, exportBtn
local rowsLabel, colsLabel

local rows = 4
local cols = 4

local maze

-- event listener for incRowsBtn
local function onIncRows()

    if rows + 1 < 30 then
        rows = rows + 1
        rowsLabel.text = string.format("Rows: %d", rows)
    end

	return true
end

-- event listener for decRowsBtn
local function onDecRows()

    if rows - 1 > 2 then
        rows = rows - 1
        rowsLabel.text = string.format("Rows: %d", rows)
    end

    return true
end

-- event listener for incColsBtn
local function onIncCols()

    if cols + 1 < 30 then
        cols = cols + 1
        colsLabel.text = string.format("Cols: %d", cols)
    end

    return true
end

-- event listener for decColsBtn
local function onDecCols()

    if cols - 1 > 2 then
        cols = cols - 1
        colsLabel.text = string.format("Cols: %d", cols)
    end

    return true
end

local function onCreateBtn()
    local mazeTileMap = creator.generateMaze(rows, cols)

    if maze then
        maze:destroy()
    end

    --
    -- Create our maze
    --
    maze = Maze:new({
        tilemap = mazeTileMap,
        group = display.newGroup(),
    })

    maze:create()
    maze.group:toBack()
end

local function makeButton (label, x, y, callback)
    local button = widget.newButton{
        label=label,
        fontSize=24,
        labelColor = { default={255}, over={128} },
        defaultFile="button.png",
        overFile="button-over.png",
        width=100, height=40,
        onRelease = callback
    }

    button.x = x
    button.y = y

    return button
end

function scene:create( event )
	local sceneGroup = self.view
	local buttonY = 25
    local curX = 5
    local xInc = 100 + 10 -- button width + 10


	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	decRowBtn = makeButton("- Rows", curX, buttonY, onDecRows)
    curX = curX + xInc

    incRowBtn = makeButton("+ Rows", curX, buttonY, onIncRows)
    curX = curX + xInc

    decColBtn = makeButton("- Cols", curX, buttonY, onDecCols)
    curX = curX + xInc

    incColBtn = makeButton("+ Cols", curX, buttonY, onIncCols)
    curX = curX + xInc

    createBtn = makeButton("Create", curX, buttonY, onCreateBtn)
    curX = curX + xInc

    exportBtn = makeButton("Export", curX, buttonY, onExportBtn)
    curX = curX + xInc

	-- all display objects must be inserted into group
	sceneGroup:insert( decRowBtn )
    sceneGroup:insert( incRowBtn )
    sceneGroup:insert( decColBtn )
    sceneGroup:insert( incColBtn )
    sceneGroup:insert( createBtn )
    sceneGroup:insert( exportBtn )

    --
    -- Setup labels across top
    --
    rowsLabel = display.newText("Rows: 4", 0, 0, system.nativeFont, 24)
    colsLabel = display.newText("Cols: 4", 0, 0, system.nativeFont, 24)

    rowsLabel.x = curX
    curX = curX + xInc
    colsLabel.x = curX
    rowsLabel.y = buttonY
    colsLabel.y = buttonY

    sceneGroup:insert( rowsLabel )
    sceneGroup:insert( colsLabel )
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
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
		decRowBtn:removeSelf()	-- widgets must be manually removed
		decRowBtn = nil
        incRowBtn:removeSelf()	-- widgets must be manually removed
        incRowBtn = nil
        decColBtn:removeSelf()	-- widgets must be manually removed
        decColBtn = nil
        incColBtn:removeSelf()	-- widgets must be manually removed
        incColBtn = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene