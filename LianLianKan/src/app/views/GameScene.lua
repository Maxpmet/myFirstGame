--[[
	File:			GameScene.lua
	Description:	游戏的主界面，逻辑部分
	Author:			Maxpmet
	Time:			2015.11.2
]]

local GameScene = class("GameScene", cc.load("mvc").ViewBase)

local statusTable = nil
local ROW         = nil
local COLUMN      = nil
local lastIndex   = nil

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
	ROW    = #statusTable
	COLUMN = #statusTable[1]
end

function GameScene.initUI()
	for i = 1, ROW do
		local data = statusTable[i]
		for j = 1, COLUMN do
			if data[j] then
				local sprite = display.newSprite( "icon/"..data[j]..".png", 80 * j - 40, 80 * (ROW - i) + 40 )
				sprite:setTag( (i - 1) * COLUMN + j )
				sprite:setTouchEnabled(true)
				sprite:addNodeEventListener(self, GameScene.clickSpriteCallback)
				this->addChild(sprite)
			end
		end
	end
end

function GameScene.clickSpriteCallback(pSender, event)
	if event.name == "began"
	if lastIndex then
		-- 第二次点击，判断能否连接
	else
		-- 第一次点击
		lastIndex = sprite
	end
end

function GameScene.clean()
	statusTable = nil
	ROW         = nil
	COLUMN      = nil
	lastIndex 	= nil
end

return GameScene
