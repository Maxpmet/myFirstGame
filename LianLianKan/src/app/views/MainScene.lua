
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
	-- onCreate execute before showwithscene
	local playButton = ccui.Button:create( "HelloWorld.png", "HelloWorld.png", "HelloWorld.png" )
	playButton:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	playButton:setPosition( display.cx, display.cy )
	playButton:addTouchEventListener(function()
		-- 进入游戏界面
		self:getApp():enterScene("GameScene")
	end)
	self:addChild( playButton )
end

return MainScene