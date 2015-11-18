-- ******** Lua与OC的交互类 ***********

--lua 调用OC
function zctech.ZCCallOC( className, methodName, args )
    print("enter zctech.ZCCallOC")
    local luaoc = require("src/cocos/cocos2d/luaoc.lua")
    local ok,ret  = luaoc.callStaticMethod(className, methodName, args)
    if not ok then
        print("luaoc error:"..tostring(ret)..",className="..tostring(className)..",methodName="..tostring(methodName))
    else
        print("The oc ret is:"..tostring(ret)..",className="..tostring(className)..",methodName="..tostring(methodName))
    end

    --如果调AppStore ，则使用zctech.ZCCallOC("ShowAppStore","callAppStore")
end

function zctech.getGameInfoFromOC( ... )
    -- if GAME_CHANNEL == CHANNEL_XY_CODE then
        print("enter zctech.getGameInfoFromOC")
        function test_oc( param )
            print(param,"enter test_oc")
            dump(param,"oc_param")
            if param["channel_id"] ~= nil then
                GAME_CHANNEL = param["channel_id"] 
            end
        end

        local arg = {
                string = "haha ce shi",
                callback = test_oc
                }
        zctech.ZCCallOC(OC_ZCJNIHELPER,"getGameInfo",arg)
    -- end
end

function zctech.initSDKOC( ... )
    print("enter zctech.initSDKOC")
    zctech.getGameInfoFromOC()
end

--退出SDK登录
function zctech.ocLogoutSDK(  )
    local arg = {}
    zctech.ZCCallOC(OC_ZCJNIHELPER,"gameSDKLogout",arg)
end

--展游用户中心注销
function zctech.ocZctechLogout(  )
    function zctech_logout(  )
        print("zctech_logout   zctech_logout")
        MsgCenter:reset()    ------断开Socket
        local _layer = requires("src/layer/login_layer/LoginLayer.lua")
        local _scene = cc.Scene:create()
        _scene:addChild(_layer:create())
        cc.Director:getInstance():replaceScene(_scene)
    end

    local arg = {
            callback = zctech_logout
            }
    zctech.ZCCallOC(OC_ZCJNIHELPER,"zctechLogout",arg)
end

--向SDK发送拓展信息
function zctech.ocExtendData(  )
    if GAME_CHANNEL == CHANNEL_ZC_IOS_CODE then
        --玩家角色ID，玩家角色名，玩家角色等级，游戏区服ID,游戏服务器名字,vip
        local param = gameUser.getUserId()..","..gameUser.getNickname()..","..gameUser.getLevel()..","..gameUser.getServerId()..","..gameUser.getServerName()..","..gameUser.getVip()
        local args = {
                    userid = gameUser.getUserId(),
                    nickname = gameUser.getNickname(),
                    level = gameUser.getLevel(),
                    serverid = gameUser.getServerId(),
                    servername = gameUser.getServerName(),
                    vip = gameUser.getVip()
                    }
        zctech.ZCCallOC(OC_ZCJNIHELPER,"zcSdkSubmitExtendData",args)
    end
end

--umeng 自定义统计事件,传递一个参数，用于统计进入到哪个界面
function zctech.ocUmengCustomEvent( eventName )
    if ZC_targetPlatform == cc.PLATFORM_OS_IPHONE or ZC_targetPlatform == cc.PLATFORM_OS_IPAD then
        local arg = {event_name = eventName}
        zctech.ZCCallOC(OC_ZCJNIHELPER,"customEvent",arg)
    end
    
end

--umeng 统计引导步骤和当前关卡信息
function zctech.ocUmengCustomEventWithNum( _type,num )
    if ZC_targetPlatform == cc.PLATFORM_OS_IPHONE or ZC_targetPlatform == cc.PLATFORM_OS_IPAD then
        local tmp_str = _type..","..num
        local arg = {
        event_type = _type,
        event_num = num
    }
        zctech.ZCCallOC(OC_ZCJNIHELPER,"customEventWithHash",arg)
    end
end