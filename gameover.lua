local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY


-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()

	-- go to level1.lua scene
	composer.gotoScene( "difficultyscene", "fade", 500 )

	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

  composer.removeHidden()
	--
  local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( 0 )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
  local text = nil
  if event.params.didWin then
      text = "You won, you sexy genius."
  else
      text = "You lost to the word: " .. event.params.enemyWord
  end
  local outcomeMessage = display.newText( { text=text, font=native.systemFontBold,
                            x=halfW, y=30 } )

	-- create a widget button (which will loads level1.lua on release)
	playButton = widget.newButton{
		label="Play Again",
		labelColor = { default={255}, over={128} },
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}

	print(screenW .. " " .. screenH)
	playButton.x = screenW/2
	playButton.y = screenH/2


	sceneGroup:insert(background)
  sceneGroup:insert(outcomeMessage)
	sceneGroup:insert(playButton)
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

function scene:destroy3( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
