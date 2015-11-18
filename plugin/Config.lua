
ZC_targetPlatform = cc.Application:getInstance():getTargetPlatform()


--UC 配置
UC_CPID = "53156"     --0
UC_GAME_ID = "577727"   --535784
UC_SERVER_ID = "0"

--渠道号
--[[--以下命名规则建议改成:CHANNEL_CODE_xxxxx
(下次提交这部分的代码的时候需要多加小心)
]]
CHANNEL_IOS_CODE = "appstore"
CHANNEL_UC_CODE = "uc"  
CHANNEL_XM_CODE = "xm"   --小米
CHANNEL_CN_CODE = "cn"
CHANNEL_XY_CODE = "xy"
CHANNEL_DL_CODE = "dl"   --当乐
CHANNEL_360_CODE = "360"  
CHANNEL_BD_CODE = "bd"   --百度
CHANNEL_PP_CODE = "pp"
CHANNEL_ZC_IOS_CODE = "zctech_ios" 
CHANNEL_91_CODE = "bd_91"   --百度91 越狱

-- if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
--     CHANNEL_CN_CODE = "an" --android官网
-- -- elseif (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) or (cc.PLATFORM_OS_MAC == ZC_targetPlatform) then
-- --     CHANNEL_CN_CODE = "oc" --android官网
-- end

--游戏设备信息
GAME_CHANNEL = "cn" --默认为android官网的
GAME_MAC = ""
GAME_ADID = ""
GAME_IDFA = ""
GAME_BASE_VERSION = ""
GAME_REPLACE_VERSION = "" 
GAME_MODLE_BUILD = ""


--用于异步更新渠道判断
if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
    GAME_CHANNEL = "cn" --android官网
elseif (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) or (cc.PLATFORM_OS_MAC == ZC_targetPlatform) then
    GAME_CHANNEL = "appstore" --IOS官网
end

--用于统计手机型号，版本号等
GAME_ANDROID_MODEL = ""         --手机型号
GAME_ANDROID_VERSION_NUM = ""   --版本号

--Java中用的类
JAVA_ZCJNIHELPER = "com/zctech/cocos/jni/ZCJniHelper"
JAVA_USERLOGIN = "org/cocos2dx/plugin/UserLogin"
JAVA_IAPONLINEPAY = "org/cocos2dx/plugin/IApOnlinePay"
OC_ZCJNIHELPER = "ZCJniHelper"
JAVA_BPUSH = "com/zctech/cocos/jni/ZCJniHelper"