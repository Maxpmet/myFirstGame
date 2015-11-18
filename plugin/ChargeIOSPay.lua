--[[create by hezhitao
    date:2015/06/04  ]]
ChargeIOSPay = ChargeIOSPay or class("ChargeIOSPay")

local _Store = nil
local show_tip_bg = nil
local callback = nil
local is_load_products = false

function ChargeIOSPay:ctor()
    --初始化商店
    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        _Store = requires("src/plugin/Store.lua")
        _Store.init(function(p) self:storeCallback(p)   end )
    end
end

function ChargeIOSPay:create(productId,callback_)
    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        local show_msg = LANGUAGE_TIPS_WORDS207--------"正在进行APPSTORE充值，请勿退出游戏。\n      充值成功后该界面自动关闭"
        show_tip_bg = ZCDialog:create()
        show_tip_bg:setName("show_tip_bg")
        cc.Director:getInstance():getRunningScene():addChild(show_tip_bg)
        local bg = ccui.Scale9Sprite:create(cc.rect(20,20,1,1),"res/common/btn26_select.png")
        bg:setContentSize(550,380)
        bg:setPosition(show_tip_bg:getContentSize().width/2,show_tip_bg:getContentSize().height/2)
        show_tip_bg:addChild(bg)

        local tip_txt = ZCLabel:createWithParams({
            text = show_msg,
            fontSize = 27,
            color = cc.c3b(71,34,34)
            })
        tip_txt:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
        bg:addChild(tip_txt)

        -- local loadingSprite = cc.Sprite:create("res/loading/loading_small.png")
        local loadingSprite = LoadingCircleLayer:create( 0 )
        loadingSprite:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height/2)
        bg:addChild(loadingSprite)
  
        local loadingAnim = cc.RotateBy:create(0.6, 360)
        loadingSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(loadingAnim)))

        if not _Store then
            ChargeIOSPay.new()
        end

        callback = callback_

        _Store.loadProducts({productId}, function(param) self:loadCallback(param)   end )

    end
end


--充值成功回调
function  ChargeIOSPay:storeCallback(transaction)
    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        dump(transaction, "transaction print")
       if transaction["transaction"] and transaction["transaction"]["state"] == "purchased" then
        ChargeIOSPay:removeTipBg()
        
        local receipt = tostring(transaction["transaction"]["receipt"])

        --把拿到的receipt经过64位编码发送给服务器，否则服务器验证不通过
        local str_receipt =  cc.Crypto:encodeBase64(receipt, string.len(receipt))
        --设置当前交易完成
        -- _Store.finishTransaction(transaction["transaction"])

        local str_md5 = cc.Crypto:MD5(str_receipt,false)

        --保存订单
        cc.UserDefault:getInstance():setStringForKey(CHARGE_PAY_ORDER,tostring(str_receipt))
        cc.UserDefault:getInstance():setStringForKey(CHARGE_PAY_MD5,tostring(str_md5))

        --防止漏单操作
        cc.UserDefault:getInstance():setStringForKey(CHARGE_RESTORE,"deal_restore")   --添加需要加元宝需求
        cc.UserDefault:getInstance():setStringForKey(CHARGE_YANZHENG,"need_yanzheng")  --添加需要验证需求

        ChargeIOSPay:setCallbackParam("buy_success")
        ChargeResources:sendDataToServer()
        elseif transaction["transaction"] and transaction["transaction"]["state"] == "cancelled" then
            --todo
            if is_load_products == true then
                ChargeIOSPay:removeTipBg()
                ChargeIOSPay:setCallbackParam("user_stop")
            end
        elseif transaction["transaction"] and transaction["transaction"]["state"] == "failed" then
            ZCTOAST(LANGUAGE_KEY_RECHARGEFAIL)------"充值失败")
            ChargeIOSPay:removeTipBg()
       end
    end
    --设置当前交易完成
    _Store.finishTransaction(transaction["transaction"])
end

--各种失败回调
function ChargeIOSPay:failedCallback()
    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        ChargeIOSPay:removeTipBg()
    end
end

--load产品回调
function ChargeIOSPay:loadCallback(products)
    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        --获取产品列表成功
        is_load_products = true

        if type(products) == "table" and type(products["products"]) == "table" and products["products"][1] then
            _Store.purchase(products["products"][1]["productIdentifier"])
        else
            ChargeIOSPay:removeTipBg()
            ChargeIOSPay:setCallbackParam("get_products_fail")
        end
    end
end


function ChargeIOSPay:removeTipBg()
    if show_tip_bg ~= nil and cc.Director:getInstance():getRunningScene():getChildByName("show_tip_bg") then
        show_tip_bg:removeFromParent()
    end
end


function ChargeIOSPay:setCallbackParam( msg_tag )
    if callback then
        callback(msg_tag)
    end
end


ChargeIOSPay.new()
