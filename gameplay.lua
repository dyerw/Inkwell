
local composer = require( "composer" )
require("wordlookup")
require("ai")
local widget = require "widget"
local scene = composer.newScene()


-- forward declarations and other locals
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY


local sceneGroup = nil

local gridSize = 4
local tileSize = screenW / gridSize
local gridOffset = 150

local letterGrid = {}
local labelGrid = {}
local tileGrid = {}
local selectedWord = ""

local selectedPoints = {}

local lastClicked = {x=nil, y=nil}

local wordLabel = nil
local healthAmountLabel = nil
local enemyHealthAmountLabel = nil
local damageLabel = nil
local enemyWordLabel = nil


local energyLabel = nil
local energyAmount = 0

local energyTilePosition = {x=nil, y=nil}

local words = {}
local aiWords = {}

local playerHealth = 200
local enemyHealth = 200


local playerHealthBar
local enemyHealthBar

local lastEnemyWord = ""

local successSoundEffect = nil
local failSoundEffect = nil

function round(x)
    return math.floor(x + 0.5)
end

function randomLetter()
    letters = "AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ"
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
            damageLabel.text = tostring(string.len(selectedWord) * string.len(selectedWord))
            tileGrid[gridX][gridY].fill.a = tileGrid[gridX][gridY].fill.a + 0.5
        end
    end
end

function drawTile(x, y)
    local backgroundRect = display.newRect(x, y, tileSize, tileSize)

    sceneGroup:insert(backgroundRect)
    backgroundRect.fill = { 1 }

    rect = display.newRect( x, y, tileSize, tileSize)
    rect.strokeWidth = 2
    rect:setStrokeColor( black )
    rect:addEventListener( "touch", onTileTouch )

    gridX = translateToGridX(x)
    gridY = translateToGridY(y)

    if ( gridX == energyTilePosition['x'] and gridY == energyTilePosition['y']) then
        rect.fill = { 252 / 255, 246 / 255, 63 / 255, 1 }
    else
        rect.fill = { 66 / 255, 134 / 255, 244 / 255, 0.01 }
    end

    sceneGroup:insert(rect)

    text = display.newText( { text=letterGrid[gridX][gridY], font=native.systemFontBold,
                              x=x, y=y } )
    text:setFillColor( black )

    sceneGroup:insert(text)

    labelGrid[gridX][gridY] = text
    tileGrid[gridX][gridY] = rect
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
  for line in io.lines(system.pathForFile('all-words.txt', system.ResourceDirectory)) do
    words[#words + 1] = line
  end

  for line in io.lines(system.pathForFile('wiki-100k.txt', system.ResourceDirectory)) do
    aiWords[#aiWords + 1] = line
  end
end

function initializeLabelGrid()
    for i=1, gridSize do
        labelGrid[i] = {}
    end
end

function initializeTileGrid()
    for i=1, gridSize do
        tileGrid[i] = {}
    end
end

function whiteOutTiles()
    for x=1, gridSize do
        for y=1, gridSize do
            tileGrid[x][y].fill = { 66 / 255, 134 / 255, 244 / 255, 0.01 }
        end
    end

    tileGrid[energyTilePosition.x][energyTilePosition.y].fill = { 252 / 255, 246 / 255, 63 / 255, 1 }
end

local function updateEnemyHealthLabel()
    enemyHealthBar.width = (enemyHealth / 200) * 100
    enemyHealthBar.x = screenW - ((enemyHealthBar.width / 2) + 10)
end

local function refreshGrid()


    whiteOutTiles()

    for x=1, #letterGrid do
        for y=1, #(letterGrid[x]) do
            letterGrid[x][y] = randomLetter()
        end
    end

    for x=1, #labelGrid do
        for y=1, #(labelGrid[x]) do
            labelGrid[x][y].text = letterGrid[x][y]
        end
    end
end

local function updateHealthLabel()
    playerHealthBar.width = (playerHealth / 200) * 100
    playerHealthBar.x = (playerHealthBar.width / 2) + 10
end

local function enemyAction()
    enemyWordLabel.text = "Enemy making move..."
    local enemyWord = makeMove(letterGrid, aiWords)
    lastEnemyWord = enemyWord
    local wordLength = string.len(enemyWord)
    playerHealth = playerHealth - wordLength * wordLength

    enemyWordLabel.text = "Last Enemy Move: " .. enemyWord

    updateHealthLabel()

    if playerHealth <= 0 then
        composer.gotoScene( "gameover", {
            effect = "fade",
            time = 400,
            params = {
                didWin = false,
                enemyWord = lastEnemyWord
            }
        } )
    end
end

local function onSubmitRelease ()

    whiteOutTiles()

    local validWord = table.binsearch(words, selectedWord) ~= nil

   if (validWord) then
       audio.play( successSoundEffect )
       enemyHealth = enemyHealth -  string.len(selectedWord) * string.len(selectedWord)
       updateEnemyHealthLabel()

       for i=1,#selectedPoints do
           if (selectedPoints[i].x == energyTilePosition.x and selectedPoints[i].y == energyTilePosition.y) then
               energyAmount = energyAmount + 1
           end
       end

       energyLabel.text = "ENERGY: " .. tostring(energyAmount)

       if enemyHealth <= 0 then
           composer.gotoScene( "gameover", {
               effect = "fade",
               time = 400,
               params = {
                   didWin = true,

               }
           } )
       end

       enemyAction()

       energyTilePosition = { x = math.random(gridSize), y = math.random(gridSize) }
       refreshGrid()
   else
     audio.play(failSoundEffect)
   end

   selectedWord = ""
   wordLabel.text = selectedWord
   damageLabel.text = "0"
   selectedPoints = {}
end




function scene:create( event )

    successSoundEffect = audio.loadSound("soundeffects/success.mp3")
    failSoundEffect = audio.loadSound("soundeffects/failure.mp3")
    composer.removeHidden( )
    local character =  event.params.character
    sceneGroup = self.view
	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
    math.randomseed( os.time() )
    initializeLetterGrid()
    initializeWords()
    initializeLabelGrid()
    initializeTileGrid()

    energyTilePosition={ x = math.random(gridSize), y = math.random(gridSize)}

	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
  	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
  	background.anchorX = 0
  	background.anchorY = 0
  	background:setFillColor( 0 )

  	sceneGroup:insert( background )

    drawGrid(gridOffset)

    local doneButton = widget.newButton {
  		label="Done",
  		labelColor = { default={255}, over={128} },
  		width=154, height=40,
  		onRelease = onSubmitRelease,
          left=(halfW - (154 / 2)), top=(screenH - 90)
  	}

    wordLabel = display.newText( { text="", font=native.systemFontBold,
                                    x=halfW, y=10, fontSize=40 } )

    playerHealthBar = display.newRect(60, 90, 100, 25)
    playerHealthBar:setFillColor(0, 1, 0)


    enemyHealthBar = display.newRect(screenW - 60, 90, 100, 25)
    enemyHealthBar:setFillColor(1, 0, 0)

    enemyWordLabel = display.newText ( {text=tostring("Last Enemy Move: --"), font=native.systemFontBold,
                                        x=halfW, y=120, fontSize=12})

    damageLabel = display.newText( { text="0", font=native.systemFontBold, x = halfW, y = 50, fontSize=30 })

    energyLabel = display.newText( { text="ENERGY: 0", font=native.systemFontBold, x = (halfW / 2), y = 50, fontSize = 15 })
    energyLabel:setFillColor( 252 / 255, 246 / 255, 63 / 255, 1 )


	-- all display objects must be inserted into group
    sceneGroup:insert(energyLabel)
    sceneGroup:insert(damageLabel)
    sceneGroup:insert(enemyHealthBar)
    sceneGroup:insert(playerHealthBar)
    sceneGroup:insert(rect)
    sceneGroup:insert(wordLabel)
    sceneGroup:insert(doneButton)
    sceneGroup:insert( enemyWordLabel )
end


function scene:show( event )
  composer.removeHidden()
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
  sceneGroup.active = false
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
	-- local sceneGroup = self.view
  if doneButton then
    doneButton:removeSelf();
    doneButton = nil
  end
  audio.dispose( successSoundEffect )
  audio.dispose( failSoundEffect )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
