---
-- Module representing the player/character in a maze.
--

local touchPosition = { x = 0, y = 0 }

---
-- Base Player object
-- @field maze    The maze the player is in.
-- @field current The current player that is in the maze level.
-- @field moveSpeed The number of pixels the player will move each frame while being touched.
--
local Player = {
    maze = nil,
    currentPlayer = nil,
    moveSpeed = 6,
    obj = nil,
}

---
-- Creates a new Player object.
-- @param o
--
function Player:new (playerMaze)
    if (playerMaze == nil) then
        error("Player:new requires a Maze object in its constructor.")
    end

    local newPlayer = {}
    newPlayer.maze = playerMaze

    setmetatable(newPlayer, self)
    self.__index = self

    return newPlayer
end

---
-- Sets the current player. The current player is the one that gets moved
-- around by touch events.
-- @param p The player object to set as the current player.
--
Player.setCurrent = function (p)
    Player.currentPlayer = p
end


local function updatePlayerPosition (event)
    local player = Player.currentPlayer.obj
    local mvSpeed = Player.moveSpeed
    local maze = Player.currentPlayer.maze
    local min = math.min
    local testX1, testY1, testX2, testY2

    local tp = {}
    tp.x, tp.y = player.parent:contentToLocal(touchPosition.x, touchPosition.y)

    local pxMin, pyMin = player.parent:contentToLocal(player.contentBounds.xMin, player.contentBounds.yMin)
    local pxMax, pyMax = player.parent:contentToLocal(player.contentBounds.xMax, player.contentBounds.yMax)

    --print(tp.x, tp.y, touchPosition.x, touchPosition.y)

    --[[
    local xMove = tp.x - _player.x

    if xMove < 0 then
        xMove = math.max(mvSpeed, xMove)
        testX1 = pxMin + mvSpeed
    else
        xMove = math.min(mvSpeed, xMove)
        testX1 = pxMax + mvSpeed
    end

    testY1 = pyMin
    testX2 = testX1
    testY2 = pyMax

    print( testX1, testY1, testX2, testY2)

    if levelMaze:isWalkable(testX1, testY1) and levelMaze:isWalkable(testX2, testY2) then
        _player.x = _player.x + mvSpeed
    end

    local yMove = tp.y - _player.y

    if yMove < 0 then
        yMove = math.max(mvSpeed, yMove)
        testY1 = pyMin + mvSpeed
    else
        yMove = math.min(mvSpeed, yMove)
        testY1 = pyMax + mvSpeed
    end

    testX1 = pxMin
    testX2 = pxMax
    testY2 = testY1

    if levelMaze:isWalkable(testX1, testY1) and levelMaze:isWalkable(testX2, testY2) then
        _player.y = _player.y + mvSpeed
    end
    ]]--
    ----------------

    local mvAmount

    if tp.x > player.x then
        mvAmount = min(mvSpeed, tp.x - player.x)

        testX1 = pxMax + mvAmount
        testY1 = pyMin
        testX2 = testX1
        testY2 = pyMax

        if maze:isWalkable(testX1, testY1) and maze:isWalkable(testX2, testY2) then
            player.x = player.x + mvSpeed
        end
    else
        mvAmount = min(mvSpeed, player.x - tp.x)

        testX1 = pxMin - mvAmount
        testY1 = pyMin
        testX2 = testX1
        testY2 = pyMax

        if maze:isWalkable(testX1, testY1) and maze:isWalkable(testX2, testY2) then
            player.x = player.x - mvSpeed
        end
    end

    if tp.y > player.y then
        mvAmount = min(mvSpeed, tp.y - player.y)

        testX1 = pxMax
        testY1 = pyMax + mvAmount
        testX2 = pxMin
        testY2 = testY1

        if maze:isWalkable(testX1, testY1) and maze:isWalkable(testX2, testY2) then
            player.y = player.y + mvSpeed
        end
    else
        mvAmount = min(mvSpeed, player.y - tp.y)

        testX1 = pxMax
        testY1 = pyMin - mvAmount
        testX2 = pxMin
        testY2 = testY1
        if maze:isWalkable(testX1, testY1) and maze:isWalkable(testX2, testY2) then
            player.y = player.y - mvSpeed
        end
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

function Player:putAtStartPosition(group, cellSize)
    local startX, startY = self.maze:getXYForCell(2,2)
    local x = startX + (self.maze.cellSize * 0.5)
    local y = startY + (self.maze.cellSize * 0.5)

    --local player = display.newCircle(group, x, y, cellSize * 0.4 )
    self.obj = display.newCircle(self.maze.group, x, y, self.maze.cellSize * 0.4 )
    self.obj:setFillColor( 1, 0, 0 )

    --[[
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
    ]]--

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
    --Runtime:addEventListener( "touch", player)
    Runtime:addEventListener( "touch", touchCallback)
end

return Player
