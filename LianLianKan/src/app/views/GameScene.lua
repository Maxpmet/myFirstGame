--[[
	File:			GameScene.lua
	Description:	游戏的主界面，逻辑部分
	Author:			Maxpmet
	Time:			2015.11.2
]]

local GameScene = class("GameScene", cc.load("mvc").ViewBase)

local statusTable = nil
local ROW = 6
local COLUMN = 6

function GameScene:onCreate()
	GameScene.initData()
end

function GameScene.initData()
	statusTable = {
		{
			false,
			1,
			2,
			3,
			1,
			4,
		},
		{
			false,
			1,
			2,
			3,
			1,
			4,
		},
		{
			false,
			1,
			2,
			3,
			1,
			4,
		},
		{
			false,
			1,
			2,
			3,
			1,
			4,
		},
		{
			false,
			1,
			2,
			3,
			1,
			4,
		},
		{
			false,
			1,
			2,
			3,
			1,
			4,
		},
	}
end

function GameScene.initUI()
	for i = 1, ROW do
		local data = statusTable[i]
		for j = 1, COLUMN do
			if data[j] then
				local sprite = display.newSprite( "icon/"..data[j]..".png", 80 * j - 40, 80 * (ROW - i) + 40 )
				sprite:setTag( (i - 1) * COLUMN + j )
				sprite:setTouchEnabled(true)
				sprite:addTouchEventListener(GameScene.clickSpriteCallback)
				this->addChild(sprite)
			end
		end
	end
end

function GameScene.clickSpriteCallback()
	
end

function GameScene.clean()
	statusTable = nil
end

return GameScene
