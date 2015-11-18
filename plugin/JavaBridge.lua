-- ******** Lua与java的交互类 ***********

--判断是应该cn登陆，还是应该sdk渠道登陆
function zctech.LoginInCnOrSDK()
    if GAME_CHANNEL ~= CHANNEL_CN_CODE then
        zctech.switchScene("PluginLogin",GAME_SDK_LOGIN)
    else
        zctech.switchScene("Login")
    end
end

--lua调用java
function zctech.ZCCallJava(className,functionName,args,sigs)
    local luaj = require "src/cocos/cocos2d/luaj.lua"
    local ok,ret  = luaj.callStaticMethod(className,functionName,args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("The java ret is:", ret)
    end
end

--lua 调用OC
function zctech.ZCCallOC( className, methodName, args )
    local luaoc = require("src/cocos/cocos2d/luaoc.lua")
    local ok,ret  = luaoc.callStaticMethod(className, methodName, args)
    if not ok then
        print("luaj error:", ret)
    else
        print("The java ret is:", ret)
    end

    --如果调AppStore ，则使用zctech.ZCCallOC("ShowAppStore","callAppStore")
end

--获取基础信息
function zctech.getGameInfoFromJava()
    print("enter zctech.getGameInfoFromJava")
    local function callbackLua(param)
        print("enter callbackLua")
        dump(param,"param test")
        -- dump(param,"the data is java")
        local javaCallback = string.split(param,",")
        GAME_CHANNEL = javaCallback[1]
        -- GAME_MAC = javaCallback[2]
        -- GAME_ADID= javaCallback[3]
        -- GAME_ANDROID_MODEL = javaCallback[4]
        -- GAME_ANDROID_VERSION_NUM = javaCallback[5]
        -- GAME_BASE_VERSION = javaCallback[6] --目前先定为一样，稍后每次把android端传过来的保存在本地，然后进行替换
        -- GAME_REPLACE_VERSION = javaCallback[6]

        dump(javaCallback,"javaCallback test")
        print("all value",GAME_CHANNEL)

         --渠道判断，进行初始化(UC单独处理)
        if GAME_CHANNEL == CHANNEL_UC_CODE then
            -- zctech.ZCInitFromJava()
        end

    end
    local channelArgs = { callbackLua }
    local channelSigs = "(I)V"
    zctech.ZCCallJava(JAVA_ZCJNIHELPER,"getGameInfo",channelArgs,channelSigs)

end 

--渠道判断，进行初始化
function zctech.ZCInitFromJava()
    print("enter zctech.ZCInitFromJava")
    local paramsStr = ""
    if GAME_CHANNEL == CHANNEL_UC_CODE then
        paramsStr = 1 .. "," .. 2 .. "," .. 3
        -- paramsStr = 0 .. "," .. 319115 .. "," .. 0
    elseif GAME_CHANNEL == CHANNEL_CN_CODE then
        paramsStr = 1 .. "," .. 2 .. "," .. 3
    elseif GAME_CHANNEL == CHANNEL_XM_CODE then
        paramsStr = 1 .. "," .. 2 .. "," .. 3
    end
    print("paramsStr",paramsStr)
    local args = {paramsStr}
    local sigs = "(Ljava/lang/String;)V"
    zctech.ZCCallJava(JAVA_USERLOGIN,"ZCInit",args,sigs)
end

--获取基础游戏信息，android平台进行sdk初始化。
function zctech.ZCInitInLua()   
    print("enter zctech.ZCInitInLua")
    --渠道号默认为官网渠道
    GAME_CHANNEL = CHANNEL_CN_CODE
    --如果是android平台，需要先向平台传递参数，进行初始化
    if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
        --获取基础信息
        zctech.getGameInfoFromJava()
    end
end

--SDK登陆成功，分平台从java端获取登陆成功后的信息，如：sessionId、uid等
function zctech.ZCLoginCallbackFromJava(javaCallback)
    local javaTable = {
        uid = "",
        sessionid = ""
    }
    if GAME_CHANNEL == CHANNEL_UC_CODE then
        javaTable.sessionid = javaCallback[1]
        GAME_SDK_TOKEN = javaCallback[1]
    end
    return javaTable
end

--SDK在Lua端登陆，不同的SDK只是参数不同而已，所以这个方法只是根据平台返回不同参数而已。
function zctech.ZCLoginUrlForJava()
    local platform_url = nil
    if GAME_CHANNEL == CHANNEL_UC_CODE then
        platform_url = "c=useruc&m=login"
    end
    return platform_url
end

--游戏调用sdk的支付，需要给sdk传入的参数。这里以逗号的形式分割各个参数，在java中进行分割使用。
function  zctech.ZCPayInSDKForJava( data , productDes )
    local paramsStr = ""
    if GAME_CHANNEL == CHANNEL_UC_CODE then
        paramsStr = data["orderid"] .. "," .. GAME_SDK_ROLE_ID .. "," .. GAME_SDK_ROLE_NAME .. "," .. GAME_SDK_ROLE_LEVEL .. "," .. productDes.price
    end
    return paramsStr
end

--游戏退出SDK登录
function zctech.ZCLogout(  )
    local args = {}
    local sigs = "()V"
    zctech.ZCCallJava(JAVA_USERLOGIN,"ZCLogout",args,sigs)
end

--游戏返回键
function zctech.ZCGameBack(  )
    local args = {}
    local sigs = "()V"
    zctech.ZCCallJava(JAVA_USERLOGIN,"gameBackKey",args,sigs)
end

--向SDK发送拓展信息
function zctech.ZCExtendData(  )
    if GAME_CHANNEL == CHANNEL_UC_CODE or GAME_CHANNEL == CHANNEL_CN_CODE then
        --玩家角色ID，玩家角色名，玩家角色等级，游戏区服ID,游戏服务器名字,vip
        local param = gameUser.getUserId()..","..gameUser.getNickname()..","..gameUser.getLevel()..","..gameUser.getServerId()..","..gameUser.getServerName()..","..gameUser.getVip()
        local args = {param}
        local sigs = "(Ljava/lang/String;)V"
        zctech.ZCCallJava(JAVA_USERLOGIN,"ZCSdkSubmitExtendData",args,sigs)
    end
end

--获取百度推送的appid userid channelid
--获取友盟推送的device token 
function zctech.ZCGetBPushData(  )
    print("hezhitao zctech.ZCGetBPushData")
    --如果是andro平台的话，则需要从java端获取百度channelid，然后保存的到userdefault中
    if ZC_targetPlatform == cc.PLATFORM_OS_ANDROID then
        function callbackBP( param )
            dump(param,"hezhitao bpush data is ")
            -- local  arr_data = string.split(param,",")
            -- if arr_data[1] and arr_data[2] and arr_data[3] and arr_data[1] ~= "" and arr_data[2] ~= "" and arr_data[3] ~= "" then
            --     cc.UserDefault:getInstance():setStringForKey(BPUSH_APP_ID,arr_data[1])
            --     cc.UserDefault:getInstance():setStringForKey(BPUSH_USER_ID,arr_data[2])
            --     cc.UserDefault:getInstance():setStringForKey(BPUSH_CHANNEL_ID,arr_data[3])
            -- end
            if param ~= nil and param ~= "" and string.len(param) ~= 0 then
                cc.UserDefault:getInstance():setStringForKey(BPUSH_USER_ID,param)
            end

            print("hezhitao userdefault data 1123 ",cc.UserDefault:getInstance():getStringForKey(BPUSH_USER_ID) )
            
        end

        local args = {callbackBP}
        local sigs = "(I)V"
        zctech.ZCCallJava(JAVA_BPUSH,"getPushData",args,sigs)
        print("hezhitao zctech.ZCGetBPushData 123")
    end
end

--SDK中用户注销时回调
function zctech.javaZctechLogout(  )
    function zctech_android_logout( param )
        print("zctech_logout   zctech_logout123",param)
        MsgCenter:reset()    ------断开Socket
        local _layer = requires("src/layer/login_layer/LoginLayer.lua")
        local _scene = cc.Scene:create()
        _scene:addChild(_layer:create())
        cc.Director:getInstance():replaceScene(_scene)
    end

    local arg = { zctech_android_logout }
    local sig = "(I)V"
    zctech.ZCCallJava(JAVA_USERLOGIN,"zctechLogout",arg,sig)
end

--玩家退出游戏
function zctech.javaZctechExit(  )
    local arg = {}
    local sig = "()V"
    zctech.ZCCallJava(JAVA_USERLOGIN,"exitGame",arg,sig)
end

--umeng 自定义统计事件,传递一个参数，用于统计进入到哪个界面
function zctech.umengCustomEvent( eventName )
    if ZC_targetPlatform == cc.PLATFORM_OS_ANDROID then
        local arg = {eventName}
        local sig = "(Ljava/lang/String;)V"
        zctech.ZCCallJava(JAVA_BPUSH,"customEvent",arg,sig)
    end
    
end

--umeng 统计引导步骤和当前关卡信息
function zctech.umengCustomEventWithNum( _type,num )
    if ZC_targetPlatform == cc.PLATFORM_OS_ANDROID then
        local tmp_str = _type..","..num
        local arg = {tmp_str}
        local sig = "(Ljava/lang/String;)V"
        zctech.ZCCallJava(JAVA_BPUSH,"customEventWithHash",arg,sig)
    end
end




