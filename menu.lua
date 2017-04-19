local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"

local playBtn

local function onPlayBtnRelease()
	composer.gotoScene( "gameplay", "fade", 500 )
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

    -- Initialize Play Button
	playBtn = widget.newButton{
		label="Play Now",
		labelColor = { default={255}, over={128} },
		width=154, height=40,
		onRelease = onPlayBtnRelease
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 125
	sceneGroup:insert( playBtn )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
end

function scene:destroy( event )
	local sceneGroup = self.view
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
