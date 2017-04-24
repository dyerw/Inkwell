local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"

local easyBtn
local hardBtn
local impossibleBtn

local difficulty

local function onBtnRelease(event)
    composer.gotoScene( "characterselect", {
        effect = "fade",
        time = 400,
        params = {
            difficulty = difficulty
        }
    } )
	return true	-- indicates successful touch
end

local function onEasyBtn()
    difficulty = 1
    onBtnRelease()
end

local function onHardBtn()
    difficulty = 2
    onBtnRelease()
end

local function onImpossibleBtn()
    difficulty = 3
    onBtnRelease()
end

function scene:create( event )
	local sceneGroup = self.view

	easyBtn = widget.newButton{
		label = "EASY",
		width=154, height=40,
		onRelease = onEasyBtn
	}
	easyBtn.x = display.contentCenterX
	easyBtn.y = display.contentHeight - 125

    hardBtn = widget.newButton{
        label = "HARD",
        width=154, height=40,
        onRelease = onHardBtn
    }
    hardBtn.x = display.contentCenterX
    hardBtn.y = display.contentHeight - 225

    impossibleBtn = widget.newButton{
        label = "IMPOSSIBLE",
        width=154, height=40,
        onRelease = onImpossibleBtn
    }
    impossibleBtn.x = display.contentCenterX
    impossibleBtn.y = display.contentHeight - 325

	sceneGroup:insert( easyBtn )
    sceneGroup:insert( hardBtn )
    sceneGroup:insert( impossibleBtn )

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
	easyBtn:removeSelf()	-- widgets must be manually removed
	easyBtn = nil

    hardBtn:removeSelf()
    hardBtn = nil

    impossibleBtn:removeSelf()
    impossibleBtn = nil
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
