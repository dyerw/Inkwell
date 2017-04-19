local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"

local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY

local sceneGroup = nil
local background = nil

local authors = {'will', 'lovecraft'}
local images = {
    will = {
        selected = 'willSelected.png',
        notSelected = 'willNotSelected.png'
    },
    lovecraft = {
        selected = 'lovecraftSelected.png',
        notSelected = 'lovecraftNotSelected.png'
    }
}

local heights = {
    will = 150,
    lovecraft = 350
}

local ogButtons = {}
local selectedGuy = nil


function select(event)
    if selectedGuy then
        selectedGuy:removeSelf()
        selectedGuy = nil
    end
    local pressed = event.target
    local author = pressed.author
    createButton(author, "selected", heights[author])
end

function createButton(author, buttonState, y)

    if willButton then
        willButton:removeSelf()
    end

    print(author)
    local imageCandidates = images[author]
    local image = imageCandidates[buttonState]
    local button = widget.newButton{
		defaultFile = image,
		width=150, height=150,
		onRelease = select
	}
	button.x = halfW
	button.y = y
    button.author = author
	sceneGroup:insert( button )
    if buttonState ~= "selected" then
        ogButtons[#ogButtons + 1] = button
    else
        selectedGuy = button
    end
end

function deselect()
    if selectedGuy then
        selectedGuy:removeSelf()
        selectedGuy = nil
    end
end

function createBackground()
    print("building background")
    background = widget.newButton{
		defaultFile = "background.jpg",
        x=halfW, y=halfH,
		width=screenW, height=screenH,
		onRelease = deselect
	}
    sceneGroup:insert(background)
end

function scene:create( event )
    sceneGroup = self.view
    createBackground()
    for index, author in pairs( authors ) do
        createButton(author, "notSelected", heights[author])
    end
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
    if background then
        background:removeSelf()
        background = nil
    end
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
