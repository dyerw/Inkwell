-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY

local gridSize = 6
local tileSize = screenW / gridSize
local gridOffset = 150

local letterGrid = {}
local selectedWord = ""

local selectedPoints = {}

local lastClicked = {x=nil, y=nil}

local wordLabel = nil
local scoreLabel = nil

local words = {}

local score = 0

function round(x)
    return math.floor(x + 0.5)
end

function randomLetter()
    letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    index = math.random(string.len(letters))
    return string.sub(letters, index, index)
end

function initializeLetterGrid()
    for x=1, gridSize, 1 do
        letterGrid[x] = {}
        for y=1, gridSize, 1 do
            letterGrid[x][y] = randomLetter()
        end
    end
end

function translateToGridX(pixelX)
    return round( (pixelX - (0.5 * tileSize)) / tileSize + 1 )
end

function translateToGridY(pixelY)
    return round( ((pixelY - gridOffset - (0.5 * tileSize)) / tileSize)  + 1 )
end

function isAdjacentToLastClicked(x, y)
    if #selectedPoints == 0 then
        return true
    end
    local lastX = selectedPoints[#selectedPoints]["x"]
    local lastY = selectedPoints[#selectedPoints]["y"]

    local dX = math.abs(lastX - x)
    local dY = math.abs(lastY - y)
    if dX <= 1 and dY <= 1 then
        return true
    else
        return false
    end
end

function onTileTouch ( event )
    if (event.phase == "began") then
        gridX = translateToGridX(event.target.x)
        gridY = translateToGridY(event.target.y)
        if isAdjacentToLastClicked(gridX, gridY) then
            letter = letterGrid[gridX][gridY]
            selectedWord = selectedWord .. letter
            local newPoint = {x=gridX, y=gridY}
            selectedPoints[#selectedPoints + 1] = newPoint
            wordLabel.text = selectedWord
        end
    end
end

function drawTile(x, y)
    rect = display.newRect( x, y, tileSize, tileSize)
    rect.strokeWidth = 2
    rect:setStrokeColor( black )
    rect:addEventListener( "touch", onTileTouch )

    gridX = translateToGridX(x)
    gridY = translateToGridY(y)
    text = display.newText( { text=letterGrid[gridX][gridY], font=native.systemFontBold,
                              x=x, y=y } )
    text:setFillColor( black )
end

-- Draws a row across entire screen
function drawRow(y)
    for i=1, gridSize, 1 do
        drawTile((i - 1) * tileSize + (0.5 * tileSize), y)
    end
end

function drawGrid(y)
    for i=1, gridSize, 1 do
        drawRow(y + ((i - 1) * tileSize + (0.5 * tileSize)))
    end
end

function initializeWords()
  for line in io.lines(system.pathForFile('./all-words.txt', system.ResourceDirectory)) do
    words[#words + 1] = line
  end
end

local function onSubmitRelease ()
    print(selectedWord)

    local validWord = false
    for i=1,#words do
      if string.lower(words[i]) == string.lower(selectedWord) then
         validWord = true
      end
   end

   print(validWord)

   if (validWord) then
       score = score + string.len(selectedWord)
       scoreLabel.text = tostring(score)
   end

   selectedWord = ""
   wordLabel.text = selectedWord
   selectedPoints = {}
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
    initializeLetterGrid()
    initializeWords()
    for i=1, gridSize, 1 do
        print(letterGrid[i][1])
    end
	local sceneGroup = self.view



	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( 0 )

    drawGrid(gridOffset)

    widget.newButton{
		label="Done",
		labelColor = { default={255}, over={128} },
		width=154, height=40,
		onRelease = onSubmitRelease	-- event listener function
	}

    wordLabel = display.newText( { text="", font=native.systemFontBold,
                                    x=halfW, y=10 } )

    scoreLabel = display.newText( { text=tostring(score), font=native.systemFontBold,
                                    x=halfW, y=30 } )


	-- all display objects must be inserted into group
	sceneGroup:insert( background )
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
