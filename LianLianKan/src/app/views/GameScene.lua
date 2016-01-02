
local GameScene = class("GameScene", cc.load("mvc").ViewBase)

-- init
function GameScene:init( column, row, kind )
	-- icon background container
	self.bgLayout = ccui.Layout:create()
	self.bgLayout:setOpacity( 160 )
	self.bgLayout:setPosition( cc.p( display.cx - ( column + 2 )*50, display.cy - ( row + 2 )*50 ) )
	self.bgLayout:setContentSize({( column + 2 )*100, ( row + 2 )*100 })
	self:addChild( self.bgLayout )
	-- icon container
	self.spriteLayout = ccui.Layout:create()
	self.spriteLayout:setPosition( cc.p( display.cx - ( column + 2 )*50, display.cy - ( row + 2 )*50 ) )
	self.spriteLayout:setContentSize({( column + 2 )*100, ( row + 2 )*100 })
	self:addChild( self.spriteLayout )

	-- build map data
	self:initData( column, row, kind )

	-- init map ui
	self:initUI()
end
-- build new map data
function GameScene:initData( column, row, kind )
	self.COLUMN = column + 2
	self.ROW = row + 2
	self.KIND = kind

	local totalNum = column * row
	self.spriteNum = 0
	self.statusTable = {}
	-- clear self.statusTable to 0
	for i = 1, self.COLUMN do
		self.statusTable[i] = {}
		for j = 1, self.ROW do
			self.statusTable[i][j] = 0
		end
	end
	print("--------------initial map data--------------")
	-- virable
	-- first random
	local randomLastIndex = 0
	local randomLastX = 0
	local randomLastY = 0
	-- second random
	local randomNextIndex = 0
	local randomNextX = 0
	local randomNextY = 0
	-- random kind
	local randomKind = 0
	-- count for out
	local outFlag = 0
	-- count for tmpNum
	local tmpNum = 0
	while tmpNum < totalNum do
		-- first random infomation,transform to the location in map
		randomLastIndex = math.random( totalNum )
		randomLastX = ( randomLastIndex - 1 ) % column + 2
		randomLastY = math.ceil( randomLastIndex / column ) + 1
		randomLastIndex = randomLastX + ( randomLastY - 1 ) * self.COLUMN
		randomKind = math.random( kind )
		-- judge whether the first random point is empty and whether it is connective
		if self.statusTable[randomLastX][randomLastY] == 0 and self:judgeSprite( randomLastX, randomLastY ) then
			-- ensure the first point
			self.statusTable[randomLastX][randomLastY] = randomKind
			-- search for the second point
			while true do
				-- second random infomation,transform to the location in map
				randomNextIndex = math.random( totalNum )
				randomNextX = ( randomNextIndex - 1 ) % column + 2
				randomNextY = math.ceil( randomNextIndex / column ) + 1
				randomNextIndex = randomNextX + ( randomNextY - 1 ) * self.COLUMN
				-- judge whether the second random point is empty and whether it is connective
				if self.statusTable[randomNextX][randomNextY] == 0 then
					if self:judgeSprite( randomNextX, randomNextY ) then
						self.statusTable[randomNextX][randomNextY] = randomKind
						if self:judgeSprites( randomLastIndex, randomNextIndex ) then
						-- ensure the second point
							print("success")
							self.spriteNum = self.spriteNum + 2
							break
						else
							self.statusTable[randomNextX][randomNextY] = 0
						end
					end
				end
				-- the second point is not suitable
				outFlag = outFlag + 1
				if outFlag > 10 then
					-- no match point for first point,clear the first point
					self.statusTable[randomLastX][randomLastY] = 0
					print("failed")
					break
				end
			end
			tmpNum = tmpNum + 2
			outFlag = 0
		end
	end
	self:dumpMap()
end
-- print new map
function GameScene:dumpMap( x, y )
	-- local function print( ... )
	-- end
	print("---------------------地图-----------------------")
	for i, v in ipairs(self.statusTable) do
		local string = ""
		if x and i == x then
			for j, w in ipairs(v) do
				if y and y == j then
					string = string.."  ".."*"
				else
					string = string.."  "..w
				end
			end
		else
			for j, w in ipairs(v) do
				string = string.."  "..w
			end
		end
		print( string )
	end
	print("-----------------------------------------------")
end
-- use the data to init ui
function GameScene:initUI()
	for i = 1, self.COLUMN do
		local data = self.statusTable[i]
		for j = 1, self.ROW do
			if data[j] ~= 0 then
				-- bg
				local spriteBg = display.newSprite( "res/icon/potential/1.png", 100 * i - 50, 100 * ( self.ROW - j ) + 50 )
				spriteBg:setTag( ( j - 1 ) * self.COLUMN + i )
				spriteBg:setVisible( false )
				self.bgLayout:addChild( spriteBg )
				-- icon
				local sprite = display.newSprite( "res/icon/"..( 180 + data[j] )..".png", 100 * i - 50, 100 * ( self.ROW - j ) + 50 )
				sprite:setTag( ( j - 1 ) * self.COLUMN + i )
				self.spriteLayout:addChild( sprite )
				-- listener
				local listenner = cc.EventListenerTouchOneByOne:create()
				sprite._listenner = listenner
				listenner:setSwallowTouches(true)
				listenner:registerScriptHandler( function( touch, event )
					local target = event:getCurrentTarget()
			        local locationInNode = target:convertToNodeSpace(touch:getLocation())
			        local s = target:getContentSize()
			        local rect = cc.rect(0, 0, s.width, s.height)
			        
			        if cc.rectContainsPoint(rect, locationInNode) then
			            return true
			        end
			        return false
				end, cc.Handler.EVENT_TOUCH_BEGAN )
				listenner:registerScriptHandler( function()
					self:clickSpriteCallback( ( j - 1 ) * self.COLUMN + i )
				end, cc.Handler.EVENT_TOUCH_ENDED )
				local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
				eventDispatcher:addEventListenerWithSceneGraphPriority( listenner, sprite )
			end
		end
	end
end
-- judge whether the point is surrendered by other icons
function GameScene:judgeSprite( x, y )
	if x > 1 and x < self.COLUMN and y > 1 and y < self.ROW then
		-- point in table
		if self.statusTable[x - 1][y - 1] == 0 or self.statusTable[x + 1][y - 1] == 0 or self.statusTable[x - 1][y + 1] == 0 or self.statusTable[x + 1][y + 1] == 0 then
			return true
		end
	end
	-- when at least one of the left and right and up and down point is empty, return true
	return false
end
-- click sprite
function GameScene:clickSpriteCallback( tag )
	if self.lastTag then
		local resultFlag, pathTable = self:judgeSprites( self.lastTag, tag )
		-- dump( pathTable, "pathTable" )
		if resultFlag then
			self:showResult( self.lastTag, tag, pathTable )
		else
			self.bgLayout:getChildByTag( self.lastTag ):setVisible( false )
			self.bgLayout:getChildByTag( tag ):setVisible( false )
			self.lastTag = nil
		end
	else
		self.lastTag = tag
		self.bgLayout:getChildByTag( tag ):setVisible( true )
	end
	return true
end
-- 判断两点是否在一条直线上，如果在，是否线上没有其他精灵
function GameScene:judgeLine( ax, ay, bx, by )
	-- print( "judgeLine", ax, ay, bx, by )
	if ax == bx then
		local start = 0
		local over  = 0
		if ay > by then
			start = by + 1
			over  = ay - 1
		else
			start = ay + 1
			over  = by - 1
		end
		for i = start, over do
			if self.statusTable[ax][i] ~= 0 then
				-- print( "judgeLine", ax, i, false )
				return false
			end
		end
	elseif ay == by then
		local start = 0
		local over  = 0
		if ax > bx then
			start = bx + 1
			over  = ax - 1
		else
			start = ax + 1
			over  = bx - 1
		end
		for i = start, over do
			if self.statusTable[i][ay] ~= 0 then
				-- print( "judgeLine", i, ay, false )
				return false
			end
		end
	end
	return true
end
-- 判断是否能消除
function GameScene:judgeSprites( lastIndex, nextIndex )
	local function print( ... )
	end
	print( "------------------开始------------------" )
	if lastIndex == nextIndex then
		print( "一个精灵" )
		print( "------------------结束------------------" )
		return false
	else
		print( "两个精灵" )
		local statusTable = self.statusTable
		-- 判断
		local lastX = ( lastIndex - 1 ) % self.COLUMN + 1
		local lastY = math.ceil( lastIndex / self.COLUMN )
		local nextX = ( nextIndex - 1 ) % self.COLUMN + 1
		local nextY = math.ceil( nextIndex / self.COLUMN )
		print( "原坐标 ＝", lastX, lastY )
		print( "新坐标 ＝", nextX, nextY )
		-- 结果
		local pathTable  = {
			{
				lastX, lastY,
			},
			{
				nextX, nextY,
			},
		}
		if statusTable[lastX][lastY] ~= statusTable[nextX][nextY] then
			print( "不同精灵不能消除" )
			print( "------------------失败------------------" )
			return false
		end

		print( "尝试一条线连接" )
		-- 一条线连接
		if lastX == nextX or lastY == nextY then
			print( "两个精灵在一条线上" )
			if self:judgeLine( lastX, lastY, nextX, nextY ) then
				print( "一条线连接成功" )
				print( "------------------成功------------------" )
				return true, pathTable
			end
		end
		print( "一条线连接失败" )



		print( "尝试两条线连接" )
		if statusTable[lastX][nextY] == 0 then
			-- 两条线结果
			if self:judgeLine( lastX, lastY, lastX, nextY ) and self:judgeLine( lastX, nextY, nextX, nextY ) then
				print( "两条线连接成功" )
				table.insert( pathTable, 2, {
					lastX, nextY,
				} )
				print( "------------------成功------------------" )
				return true, pathTable
			end
		end
		if statusTable[nextX][lastY] == 0 then
			if self:judgeLine( lastX, lastY, nextX, lastY ) and self:judgeLine( nextX, lastY, nextX, nextY ) then
				print( "两条线连接成功" )
				table.insert( pathTable, 2, {
					nextX, lastY,
				} )
				print( "------------------成功------------------" )
				return true, pathTable
			end
		end
		print( "两条线连接失败" )
		

		print( "尝试三条线连接" )
		-- 三条线连接
		print( "尝试三条线横向连接" )
		-- 横向
		-- lastX左
		local lastXStart = lastX - 1
		while lastXStart >= 1 and statusTable[lastXStart][lastY] == 0 do
			lastXStart = lastXStart - 1
		end
		lastXStart = lastXStart + 1
		-- lastX右
		local lastXOver = lastX + 1
		while lastXOver <= self.COLUMN and statusTable[lastXOver][lastY] == 0 do
			lastXOver = lastXOver + 1
		end
		lastXOver = lastXOver - 1
		-- nextX左
		local nextXStart = nextX - 1
		while nextXStart >= 1 and statusTable[nextXStart][nextY] == 0 do
			nextXStart = nextXStart - 1
		end
		nextXStart = nextXStart + 1
		-- nextX右
		local nextXOver = nextX + 1
		while nextXOver <= self.COLUMN and statusTable[nextXOver][nextY] == 0 do
			nextXOver = nextXOver + 1
		end
		nextXOver = nextXOver - 1
		print( "原精灵X范围＝", lastXStart, lastXOver )
		print( "新精灵X范围＝", nextXStart, nextXOver )
		-- 判断是否有可能三条线连接
		if lastXStart < lastXOver and nextXStart < nextXOver then
			-- 两个精灵左右不为空
			if not ( nextXOver < lastXStart or lastXOver < nextXStart ) then
				print("三条线横向连接初始条件满足")
				-- 有交集
				local sortTable = { lastXStart, lastXOver, nextXStart, nextXOver }
				table.sort( sortTable, function( a, b )
					return a < b
				end )
				-- dump( sortTable, "sortedTable" )
				local numberTable = {}
				for i = sortTable[2], sortTable[3] do
					table.insert( numberTable, i )
				end
				-- dump( numberTable, "numberTable" )
				table.sort( numberTable, function( a, b )
					return math.abs( a - lastX ) < math.abs( b - lastX )
				end )
				-- dump( numberTable, "sortTable numberTable" )
				for i, v in ipairs(numberTable) do
					if self:judgeLine( v, lastY, v, nextY ) then
						print( "三条线横向连接成功" )
						table.insert( pathTable, 2, {
								v, lastY,
						} )
						table.insert( pathTable, 3, {
								v, nextY,
						} )
						print( "------------------成功------------------" )
						return true, pathTable
					end
				end
			end
		end
		print( "三条线横向连接失败" )
		

		print( "尝试三条线纵向连接" )
		-- 纵向
		-- lastY上
		local lastYStart = lastY - 1
		while lastYStart >= 1 and statusTable[lastX][lastYStart] == 0 do
			lastYStart = lastYStart - 1
		end
		lastYStart = lastYStart + 1
		-- lastY下
		local lastYOver = lastY + 1
		while lastYOver <= self.ROW and statusTable[lastX][lastYOver] == 0 do
			lastYOver = lastYOver + 1
		end
		lastYOver = lastYOver - 1
		-- nextY上
		local nextYStart = nextY - 1
		while nextYStart >= 1 and statusTable[nextX][nextYStart] == 0 do
			nextYStart = nextYStart - 1
		end
		nextYStart = nextYStart + 1
		-- nextY下
		local nextYOver = nextY + 1
		while nextYOver <= self.ROW and statusTable[nextX][nextYOver] == 0 do
			nextYOver = nextYOver + 1
		end
		nextYOver = nextYOver - 1
		print( "原精灵Y范围＝", lastYStart, lastYOver )
		print( "新精灵Y范围＝", nextYStart, nextYOver )
		-- 判断是否有可能三条线连接
		if lastYStart < lastYOver and nextYStart < nextYOver then
			-- 两个精灵上下不为空
			if not ( nextYOver < lastYStart or lastYOver < nextYStart ) then
				print( "三条线纵向连接初始条件满足" )
				-- 有交集
				local sortTable = { lastYStart, lastYOver, nextYStart, nextYOver }
				table.sort( sortTable, function( a, b )
					return a < b
				end )
				-- dump(sortTable, "sortedTable")
				local numberTable = {}
				for i = sortTable[2], sortTable[3] do
					table.insert( numberTable, i )
				end
				-- dump(numberTable, "numberTable")
				table.sort( numberTable, function( a, b )
					return math.abs( a - lastY ) < math.abs( b - lastY )
				end )
				-- dump(numberTable, "sortTable numberTable")
				for i, v in ipairs(numberTable) do
					if self:judgeLine( lastX, v, nextX, v ) then
						print( "三条线纵向连接成功" )
						table.insert( pathTable, 2, {
								lastX, v,
						} )
						table.insert( pathTable, 3, {
								nextX, v,
						} )
						print( "------------------成功------------------" )
						return true, pathTable
					end
				end
			end
		end
		print( "三条线纵向连接失败" )

		print( "------------------失败------------------" )
		return false
	end
end
-- show the path of two sprites, then clean the two sprites
function GameScene:showResult( lastIndex, nextIndex, pathTable )
	-- dump( pathTable, "路径" )
	-- transform position
	local lastX = ( lastIndex - 1 ) % self.COLUMN + 1
	local lastY = math.ceil( lastIndex / self.COLUMN )
	local nextX = ( nextIndex - 1 ) % self.COLUMN + 1
	local nextY = math.ceil( nextIndex / self.COLUMN )
	-- get sprite
	local sprite = self.spriteLayout:getChildByTag( lastIndex )
	local spriteBg = self.bgLayout:getChildByTag( lastIndex )
	self.bgLayout:getChildByTag( nextIndex ):setVisible( true )
	-- remove listener
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:removeEventListener( self.spriteLayout:getChildByTag( lastIndex )._listenner )
	eventDispatcher:removeEventListener( self.spriteLayout:getChildByTag( nextIndex )._listenner )
	-- remove bg
	-- self.bgLayout:getChildByTag( lastIndex ):removeFromParent( true )
	-- self.bgLayout:getChildByTag( nextIndex ):removeFromParent( true )
	self.statusTable[lastX][lastY] = 0
	self.statusTable[nextX][nextY] = 0
	self.lastTag = nil
	local array = {}
	local bgArray = {}
	for i = 2, #pathTable do
		local steps = math.abs(pathTable[i][1] + pathTable[i][2] - pathTable[i-1][1] - pathTable[i-1][2])
		local action = cc.JumpTo:create( 0.5 * steps, cc.p( 100 * pathTable[i][1] - 50, 100 * ( self.ROW - pathTable[i][2] ) + 50 ), 30, steps )
		array[#array + 1] = action
		bgArray[#bgArray + 1] = action:clone()
	end
	local function disappear( )
		sprite:removeFromParent( true )
		self.spriteLayout:getChildByTag( nextIndex ):removeFromParent( true )
		self.bgLayout:getChildByTag( lastIndex ):removeFromParent( true )
		self.bgLayout:getChildByTag( nextIndex ):removeFromParent( true )
		self.spriteNum = self.spriteNum - 2
		if self.spriteNum <= 0 then
			self.bgLayout:removeFromParent()
			self.bgLayou = nil
			self.spriteLayout:removeFromParent()
			self.spriteLayout = nil

			self:httpServer()
		end
	end
    table.insert( array, cc.CallFunc:create( disappear ) )
    sprite:runAction( cc.Sequence:create( array ) )
	spriteBg:runAction( cc.Sequence:create( bgArray ) )
end
-- http get
function GameScene:httpGet()
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", "http://114.246.157.82:8888/")--ip:port

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("tsctsctsc  ",xhr.response)
            self:init( self.COLUMN - 1, self.ROW - 1, self.KIND + 2 )
        else
            print("tsctsctsc  xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end
-- http post
function GameScene:httpPost()
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", "http://114.246.157.82:8888/")--ip:port
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response)
            self:init( self.COLUMN - 2, self.ROW - 2, self.KIND )
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send( os.date("year=%y&month=%m&day=%d&hour=%H&minute=%M&second=%S") )
end
-- send data to server
function GameScene:httpServer()
	print("tsctsctsc  httpServer")
	self:httpGet()
	-- self:httpPost()
end
function GameScene:onCreate()
	-- background
	local bg = cc.Sprite:create( "res/1.jpg" )
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(cc.p(display.cx,display.cy))
	self:addChild(bg)

	self:init( 4, 4, 3 )
end

return GameScene
