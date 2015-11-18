-- FileName: LayerManager.lua
-- Author: wangming
-- Date: 2015-09-08
-- Purpose: 层的管理器
--[[TODO List]]

LayerManager = {}

local m_director = cc.Director:getInstance()

local mMrgStack = {} -- 记录当前模块堆叠的容器栈

local nZPop = 100 -- 弹出窗口的初始Zorder
local nShieldLayoutTag = 666669 -- ShieldLayout 的 tag，用于检测是否存在

---------------------get set 控制 -------------------

local function getCurManager( ... )
	return mMrgStack[#mMrgStack]
end

local function getCurRoot( ... )
	local _rootMgr = getCurManager()
	if not _rootMgr then
		return nil
	end
	return _rootMgr._layRoot
end

local function getCurStack( ... )
	local _rootMgr = getCurManager()
	if not _rootMgr then
		return nil
	end
	return _rootMgr._tbLayoutStack
end

local function getCurLay( ... )
	local _curStack = getCurStack()
	if not _curStack then
		return nil
	end
	return _curStack[#_curStack]
end

--创建一个全屏幕的layer ， 可控该层是否接收touch
local function getFullLayout( notGetTouch )
	local pLay = cc.Layer:create()
	if(notGetTouch) then
		pLay:setTouchEnabled(false)
	else
		pLay:setTouchEnabled(true)
		local function touchCall( eventType, x, y )
			if (eventType == "began") then
				return true
			end
		end
		pLay:registerScriptTouchHandler(touchCall)
	end
	return pLay
end

--[[desc:屏蔽旧界面往新界面传递触摸 添加屏蔽层
—]]
function LayerManager.addShieldLayout( isOnlyGet, sTime )
	if isOnlyGet then
		return getFullLayout()
	end
	local runningScene = m_director:getRunningScene()
	if (runningScene == nil) then
		return
	end
	local touchLayer = getFullLayout()
	touchLayer:setTag(nShieldLayoutTag) 
	runningScene:addChild(touchLayer, nZPop)

	local _time = tonumber(sTime) or 0.01
	performWithDelay(runningScene,function()
		local shield = runningScene:getChildByTag(nShieldLayoutTag)
		if (shield) then
			shield:removeFromParent()
		end
	end, _time)
end

-------------------UI创建、移除控制-----------------------------

function LayerManager.pushModule( slayer, isFirst )
	local runningScene = cc.Scene:create()
	if isFirst then
		mMrgStack = {}
		LayerManager.isSend = nil
		m_director:replaceScene(runningScene)
	else
		m_director:pushScene(runningScene)
	end

	local mTable = {}
	local _layRoot = cc.Layer:create()
	runningScene:addChild(_layRoot)
	_layRoot._scene = runningScene
	mTable._layRoot = _layRoot

	mTable._tbLayoutStack = {} --附加到parent上的Layout的容器栈

	table.insert(mMrgStack, mTable)

	if isFirst then
		_layer = requires("src/layer/mainCityLayer/MainCitylayer.lua"):create("login_layer")
		LayerManager.addLayout(_layer)
	end
	
	if slayer then
		LayerManager.addLayout(slayer)
	end

end

function LayerManager.popModule( )
	local _length = #mMrgStack
	if _length > 1 then
		local _curMgr = table.remove(mMrgStack)
		-- _curMgr._layRoot:removeFromParent()
		_curMgr._tbLayoutStack = {}
		m_director:popScene()
		helper.collectMemory()
	end
end

function LayerManager.popModuleToDefult( )
	while true do
		local _length = #mMrgStack
		if _length > 1 then
			local _curMgr = table.remove(mMrgStack)
			-- _curMgr._layRoot:removeFromParent()
			_curMgr._tbLayoutStack = {}
			-- helper.collectMemory()
		else
			break
		end
	end
	m_director:popToRootScene()
end

function LayerManager.sendZuobi( )
	if LayerManager.isSend == true then
		return
	end
	LayerManager.isSend = true
	local runningScene = m_director:getRunningScene()
	if (runningScene == nil) then
		LayerManager.backToLoginLayer(true)
		return
	end

	ZCHttp:requestAsyncInGameWithParams({
        modules = "illegalModify?",
        successCallback = function(data)
	        local _runSc = m_director:getRunningScene()
	        if _runSc then
	        	performWithDelay(_runSc,function( )
	        		LayerManager.backToLoginLayer(true)
		        end, 1.0)
	        else
	        	LayerManager.backToLoginLayer(true)
	        end
        end,--成功回调
        failedCallback = function()
		    LayerManager.backToLoginLayer(true)
        end,--失败回调
        targetNeedsToRetain = runningScene,--需要保存引用的目标
        loadingParent = runningScene,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function LayerManager.backToLoginLayer( isZuobi )
	local _layRoot = getCurRoot()
	if not _layRoot then
		return
	end
	local nowScene = _layRoot._scene
	local _length = #mMrgStack
	if _length > 1 then
		if nowScene then
		    nowScene:removeAllChildren()
		end
		gotoMaincity()
		-- if nowScene then
		--     nowScene:cleanup()
		-- end
	end
	mMrgStack = {}
	MsgCenter:reset()
	zc.LogoutSDK()
	local _scene = cc.Scene:create()
	local login = requires("src/layer/login_layer/LoginLayer.lua"):create()
	_scene:addChild(login)
	cc.Director:getInstance():replaceScene(_scene)	
	performWithDelay(_scene,function( )
		if isZuobi then
		    local confirmDialog = ZCConfirmDialog:createWithParams({
		    	msg = LANGUAGE_KEY_ZUOBI,
		    	leftVisible = false,
		    	isHide = false
	    	})
		    _scene:addChild(confirmDialog,1000)
		    
		    local callbalc = confirmDialog:getContainerLayer()
		    if callbalc ~= nil then
		        callbalc:setTouchEndedCallback(function()end)
		    end

		    confirmDialog:setCallbackRight(function (  )
		        confirmDialog:removeFromParent()
		    end)
		else
			ZCTOAST(LANGUAGE_KEY_NETWORKERROR)
		end
	end,0.5)	
end

--[[desc:—
	params : 
		noHide 堆栈上一层隐藏控制
		delayHide 堆栈上一层的延迟隐藏控制

]]
function LayerManager.addLayout( sLayout, params )
	assert(sLayout, "addLayout : sLayout get nil ")
	
	local _layRoot = getCurRoot()
	assert(_layRoot, "addLayout : _layRoot get nil ")
	_layRoot:addChild(sLayout)
	local _curStack = getCurStack()
	table.insert(_curStack, sLayout)
	local _params = params or {}
	if not _params.noHide then
		local _length = #_curStack
		local pLay = _curStack[_length-1]
		if pLay then
			local pDelayTime = tonumber(_params.delayHide) or 0
			if pDelayTime > 0 then
				performWithDelay(pLay, function() 
					pLay:setVisible(false)
				end, pDelayTime)
			else
				pLay:setVisible(false)
			end
		end
	end

	--切换模块之后删除添加的触摸屏蔽层
	LayerManager.addShieldLayout()
end

function LayerManager.removeLayout( sLayout, notRemove )
	local _curStack = getCurStack()
	local _length = #_curStack
	if _length > 1 then
		local pLay = _curStack[_length-1]
		local popLayer = table.remove(_curStack)
		if popLayer then
			if not notRemove then
				popLayer:removeFromParent()
			end
			if pLay then
				pLay:setVisible(true)
			end
		end
	end
end

function LayerManager.removeLayoutToDefult( )
	while true do
		local _curStack = getCurStack()
		local _length = #_curStack
		if _length > 1 then
			local pLay = _curStack[_length-1]
			local popLayer = table.remove(_curStack)
			if popLayer then
				popLayer:removeFromParent()
				if pLay then
					pLay:setVisible(true)
				end
			end
		else
			break
		end
	end
end

----------------------临时替换回旧的层级体系

-- function LayerManager.pushModule( slayer, isFirst )
-- 	local scene = cc.Scene:create()
-- 	if isFirst then
-- 		m_director:replaceScene(scene)
-- 	else
-- 		m_director:pushScene(scene)
-- 	end
-- 	local _layer = slayer
-- 	if isFirst then
-- 		_layer = requires("src/layer/mainCityLayer/MainCitylayer.lua"):create("login_layer")
-- 	end
-- 	if _layer then
-- 		scene:addChild(_layer)
-- 	end
-- end

-- function LayerManager.popModule( )
-- 	m_director:popScene()
-- end


-- function LayerManager.popModuleToDefult( )
-- 	m_director:popToRootScene()
-- end

-- function LayerManager.addLayout( sLayout, params )
-- 	if not sLayout then
-- 		return
-- 	end
-- 	params = params or {}log
-- 	if not params.par then
-- 		params.par = m_director:getRunningScene()
-- 	end
-- 	local _zz = tonumber(params.zz) or 0
-- 	if _zz ~= 0 then
-- 		params.par:addChild(sLayout, _zz)
-- 	else
-- 		params.par:addChild(sLayout)
-- 	end
-- end

-- function LayerManager.removeLayout( sLayout )
-- 	if sLayout then
-- 		sLayout:removeFromParent()
-- 	end
-- end

-- function LayerManager.removeLayoutToDefult( )
	
-- end


----------------------------module 创建方法--------------------------------------

function LayerManager.createModule( sName, sParams )
	local pModule = requires(sName)
	if not pModule then
		return
	end
	LayerManager.addShieldLayout()
	local _pLay = pModule:createForLayerManager(sParams)
	return _pLay
end
