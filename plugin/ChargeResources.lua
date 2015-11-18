
--[[By hezhitao  2015.06.10]]

ChargeResources = ChargeResources or class("ChargeResources")
function ChargeResources:sendDataToServer( loading_type )

    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        local _loadingType = loading_type or 0
        local lastServer = cc.UserDefault:getInstance():getStringForKey(KEY_NAME_LAST_SERVER)
        lastServer = loadstring(lastServer)
        if type(lastServer) == "function" then
            lastServer = lastServer()
        else
            lastServer = checktable(lastServer)
        end

        local receipt =  cc.UserDefault:getInstance():getStringForKey(CHARGE_PAY_ORDER)
        local str_md5 = cc.UserDefault:getInstance():getStringForKey(CHARGE_PAY_MD5)
        local server_id = lastServer.serverId
        --测试充值接口，当打正式包时，需要更改接口

        -- local str_url = "http://192.168.170.119:8092/pay/iosPay?serverId="..server_id.."&passportId="..gameUser.getUserId().."&md5="..str_md5
        local str_url = "http://192.168.170.119:8092/pay/iosPay?"
        -- local str_url = "http://123.59.58.109:8092/pay/iosPay?"
        print("str_url",str_url)
        print("str_md5",str_md5)
        print("receipt",receipt)
        
        --post请求
        ZCHttp:_requestAsyncWithParams({
            encrypt = HTTP_ENCRYPT_TYPE.NONE,
            url = str_url,
            method = HTTP_REQUEST_TYPE.POST,
            timeoutForConnect = 30,
            timeoutForRead = 30,
            postData = "receipt="..receipt.."&serverId="..server_id.."&passportId="..gameUser.getUserId().."&md5="..str_md5,
            successCallback = function(data)
                if type(data) == "table" and data["result"] == 0 then
                    dump(data,"data")
                    
                    if loading_type ~= nil then  --处理漏单
                        ChargeResources:refreshUserData(loading_type,true)
                    else  --正常充值
                        ChargeResources:refreshUserData(loading_type)
                    end
                    cc.UserDefault:getInstance():setStringForKey(CHARGE_RESTORE,"success")   --添加元宝需求撤销
                    cc.UserDefault:getInstance():setStringForKey(CHARGE_YANZHENG,"not_yanzheng")  --需要验证需求撤销
                    print("防止漏单操作已撤回")

                    -- if loading_type then
                    --     ZCTOAST("漏单已处理")
                    -- end
                elseif type(data) == "table" and data["result"] == 5201 then   --超时，重新请求数据
                    ChargeResources:sendDataToServer(loading_type)
                elseif type(data) == "table" and data["result"] == 5200 then   --订单已生成
                    cc.UserDefault:getInstance():setStringForKey(CHARGE_YANZHENG,"not_yanzheng")  --需要验证需求撤销
                    ChargeResources:refreshUserData(loading_type,true)
                    -- ZCTOAST("漏单已处理")
                else
                    ZCTOAST(data["msg"])
                    
                end

                dump(data,"data")

            end,--成功回调
            failedCallback = function()
                
            end,--失败回调
            -- targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = _loadingType,--加载图显示 circle 光圈加载 head 头像加载
        })
    end
    
end

--充值成功刷新用户数据
function ChargeResources:refreshUserData( loading_type,deal_restore )  --deal_restore 1、正常充值；2、验证出错，漏单处理；3、添加元宝、漏单处理
    print("refreshUserDatarefreshUserDatarefreshUserData")
    local _loadingType = loading_type or 0
     ClientHttp:requestAsyncInGameWithParams({
        modules = "payFinish?",
        successCallback = function(data)
        if not data or next(data) == nil then
            ZCTOAST(LANGUAGE_KEY_SERVERCLOSED)------"服务器已关闭")
            return
        end

        --获取奖励成功
        if  tonumber(data.result) == 0 then
            if deal_restore == true then
                cc.UserDefault:getInstance():setStringForKey(CHARGE_RESTORE,"success")  
            end
            if type(data) == "table" and data["property"] then
                for i=1,#data["property"] do
                    local pro_data = string.split( data["property"][i],',')
                    if tonumber(pro_data[1]) == 403 then
                        gameUser.setIngot(tonumber(pro_data[2]))
                    end
                    --当前VIP等级发生变化时显示
                    if tonumber(pro_data[1]) == 406 then   --判断当前VIP
                        if tonumber(pro_data[2]) > tonumber(gameUser.getVip()) then
                            ZCTOAST(LANGUAGE_TIPS_WORDS208..pro_data[2])------"当前VIP等级为"..pro_data[2])
                            gameUser.setVip(pro_data[2])
                            zc.dispatchEvent({name = CUSTOM_EVENT.REFRESH_VIP_SHOW})
                        end
                        
                    end
                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                end
            end

            --设置金币、翡翠兑换次数
            if data["silverSurplusSum"] and data["feicuiSurplusSum"] then
                gameUser.setGoldSurplusExchangeCount(data["silverSurplusSum"])
                gameUser.setFeicuiSurplusExchangeCount(data["feicuiSurplusSum"])
                gameUser.setIngotTotal(data["totalIngot"])
            end
            
            zc.dispatchEvent({name = CUSTOM_EVENT.REFRESH_VIP_MSG})
            zc.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            zc.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO}) 
        else
            ZCTOAST(data.msg)
        end
          
        end,--成功回调
        failedCallback = function()
            ZCTOAST(LANGUAGE_KEY_SERVERCLOSED)-------"服务器已关闭")
        end,--失败回调
        loadingType = _loadingType,--加载图显示 circle 光圈加载 head 头像加载
    })
end



-- 漏单处理
function ChargeResources:dealRestoreOrder(  )
    --如果还没有和后端验证充值，则需要先验证，否则直接添加元宝
    if cc.UserDefault:getInstance():getStringForKey(CHARGE_YANZHENG) == "not_yanzheng" then  
        if cc.UserDefault:getInstance():getStringForKey(CHARGE_RESTORE) == "deal_restore" then
            -- ChargeResources:sendDataToServer(2)
            ChargeResources:refreshUserData(2,true)
        end
    elseif cc.UserDefault:getInstance():getStringForKey(CHARGE_YANZHENG) == "need_yanzheng" then
        ChargeResources:sendDataToServer(2)
    end
end