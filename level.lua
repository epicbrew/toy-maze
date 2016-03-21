---
-- @file level.lua
--
-- Scene for displaying the main game levels.
--
local Maze = require ("maze")
local Player = require ("player")
local composer = require( "composer" )
local scene = composer.newScene()

--
-- forward declarations and other locals
--
local screenW, screenH = display.contentWidth, display.contentHeight


function scene:create( event )
    --
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	local sceneGroup = self.view

	--
	-- Load up our maze data
	--
    print("loading maze data: ", event.params.mazeData)
	local levelMazeData = require (event.params.mazeData)

	--
	-- Create our maze
	--
    self.maze = Maze:new({
        tilemap = levelMazeData,
        group = display.newGroup(),
    })

    self.maze:create()

	--
	-- Add the player to the maze.
	--
    self.player = Player:new(self.maze)

    --
    -- This gives the Player module a reference to our player so that it can be moved around
    -- by Runtime touch events.
    --
    Player.setCurrent(self.player)

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( self.maze.group )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen

		self.player:putAtStartPosition()

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

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
