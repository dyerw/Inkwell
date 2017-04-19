local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"

local lovecraftButton = nil
local sceneGroup = nil


local onLovecraftBtnRelease = nil

local function createLovecraftButton(image)
    if lovecraftButton then
        lovecraftButton:removeSelf()
    end

    lovecraftButton = widget.newButton{
		defaultFile = image,
		width=150, height=150,
		onRelease = onLovecraftBtnRelease
	}
	lovecraftButton.x = display.contentCenterX
	lovecraftButton.y = 150
	sceneGroup:insert( lovecraftButton )
end

onLovecraftBtnRelease = function()
    print('selected lovecraft')
    createLovecraftButton('lovecraftSelected.png')
	return true	-- indicates successful touch
end


function scene:create( event )
    sceneGroup = self.view
    createLovecraftButton('lovecraftNotSelected.png')
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
	if lovecraftButton then
		lovecraftButton:removeSelf()	-- widgets must be manually removed
		lovecraftButton = nil
	end
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
