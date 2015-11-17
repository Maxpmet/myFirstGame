--[[
	File:			GameScene.lua
	Description:	游戏的主界面，逻辑部分
	Author:			Maxpmet
	Time:			2015.11.2
]]

local GameScene = class("GameScene", cc.load("mvc").ViewBase)

local GameLogic = {}
local statusTable = nil
local ROW         = nil
local COLUMN      = nil
local lastIndex   = nil

function GameScene:onCreate()
	GameLogic.initData()
	
	
end

function GameLogic.initData( ... )
	statusTable = {
		{
			5,
			1,
			2,
			3,
			1,
			4,
		},
		{
			5,
			1,
			2,
			3,
			1,
			4,
		},
		{
			5,
			1,
			2,
			3,
			1,
			4,
		},
		{
			5,
			1,
			2,
			3,
			1,
			4,
		},
		{
			5,
			1,
			2,
			3,
			1,
			4,
		},
		{
			5,
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

function GameLogic.initUI( ... )
	for i = 1, ROW do
		local data = statusTable[i]
		for j = 1, COLUMN do
			if data[j] ~= 0 then
				local sprite = display.newSprite( "icon/"..data[j]..".png", 80 * j - 40, 80 * (ROW - i) + 40 ):addTo(self)
				sprite:setTag( (i - 1) * COLUMN + j )
				-- sprite:setTouchEnabled(true)
				-- sprite:addNodeEventListener(self, self:clickSpriteCallback)
			end
		end
	end
end

return GameScene
