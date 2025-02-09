import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "config"

local gfx <const> = playdate.graphics

local playerSprite = nil

local playTimer = nil
local playTime = config.timeLimitSeconds * 1000

local coinSprite = nil
local score = 0

local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function moveCoin()
	local randX = math.random(40, 360)
	local randY = math.random(40, 200)
	if coinSprite then
		coinSprite:moveTo(randX, randY)
	else

	end
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local playerImage = gfx.image.new("images/player")
	playerSprite = gfx.sprite.new(playerImage)
	playerSprite:moveTo(200, 120)
	playerSprite:setCollideRect(0, 0, playerSprite:getSize())
	playerSprite:add()

	local coinImage = gfx.image.new("images/coin")
    coinSprite = gfx.sprite.new(coinImage)
	moveCoin()
	coinSprite:setCollideRect(0, 0, coinSprite:getSize())
	coinSprite:add()

	local backgroundImage = gfx.image.new("images/background")
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)

	resetTimer()
end

initialize()

function playdate.update()
	if playTimer and playTimer.value == 0 then
		if playdate.buttonJustPressed(playdate.kButtonA) then
			resetTimer()
			moveCoin()
			score = 0
		end
	else
		if playdate.buttonIsPressed(playdate.kButtonUp) and playerSprite then
			playerSprite:moveBy(0, -config.playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) and playerSprite then
			playerSprite:moveBy(config.playerSpeed, 0)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) and playerSprite then
			playerSprite:moveBy(0, config.playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) and playerSprite then
			playerSprite:moveBy(-config.playerSpeed, 0)
		end

		local collisions = {}
		if coinSprite then
			collisions = coinSprite:overlappingSprites()
		end
		if #collisions >= 1 then
			moveCoin()
			score += 1
		end
	end

	playdate.timer.updateTimers()
	gfx.sprite.update()

	if playTimer then
		gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
	end
	gfx.drawText("Score: " .. score, 320, 5)
end