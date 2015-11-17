
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local GameFunction = {}


function GameFunction.initData( )
	GameFunction.spriteNum = 0
	GameFunction.statusTable = {
		{
			1,
			2,
			3,
			4,
			5,
			6,
		},
		{
			1,
			2,
			3,
			4,
			5,
			6,
		},
		{
			6,
			3,
			1,
			2,
			5,
			4,
		},
		{
			2,
			1,
			5,
			6,
			3,
			4,
		},
		{
			5,
			4,
			2,
			3,
			1,
			6,
		},
		{
			3,
			1,
			5,
			4,
			2,
			6,
		},
	}
	local statusTable = GameFunction.statusTable
	local zeroTable = {}
	for i = 1, #statusTable[1] do
		zeroTable[i] = 0
	end
	table.insert( statusTable, 1, zeroTable )
	table.insert( statusTable, clone( zeroTable ) )
	for i = 1, #statusTable do
		table.insert( statusTable[i], 1, 0 )
		table.insert( statusTable[i], 0 )
	end
	dump( statusTable, "添加0之后的statusTable" )
	GameFunction.COLUMN = #statusTable
	GameFunction.ROW    = #statusTable[1]
	print( "行＝"..GameFunction.ROW.."  列＝"..GameFunction.COLUMN )
	GameFunction.initUI( )
end
function GameFunction.initUI( )
	for i = 1, GameFunction.COLUMN do
		local data = GameFunction.statusTable[i]
		for j = 1, GameFunction.ROW do
			if data[j] ~= 0 then
				local spriteBg = display.newSprite( "res/icon/potential/1.png", 100 * i - 50, 100 * ( GameFunction.ROW - j ) + 50 )
				spriteBg:setTag( ( j - 1 ) * GameFunction.COLUMN + i )
				spriteBg:setVisible( false )
				GameFunction.bgLayout:addChild( spriteBg )
				local sprite = display.newSprite( "res/icon/18"..data[j]..".png", 100 * i - 50, 100 * ( GameFunction.ROW - j ) + 50 )
				sprite:setTag( ( j - 1 ) * GameFunction.COLUMN + i )
				GameFunction.spriteLayout:addChild( sprite )
				GameFunction.spriteNum = GameFunction.spriteNum + 1
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
					GameFunction.clickSpriteCallback( ( j - 1 ) * GameFunction.COLUMN + i )
				end, cc.Handler.EVENT_TOUCH_ENDED )
				local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
				eventDispatcher:addEventListenerWithSceneGraphPriority( listenner, sprite )
			end
		end
	end
end
function GameFunction.judgeSprite( x, y )
	for i = x - 1, x + 1 do
		for j = y - 1, y + 1 do
			if i > 1 and i < GameFunction.COLUMN and j > 1 and j < GameFunction.ROW and GameFunction.statusTable[i][j] == 0 then
				return true
			end
		end
	end
	return false
end
function GameFunction.buildData( column, row, kind )
	print( "buildData" )
	GameFunction.COLUMN = column + 2
	GameFunction.ROW = row + 2
	GameFunction.KIND = kind
	local totalNum = column * row
	GameFunction.spriteNum = 0
	GameFunction.statusTable = {}
	for i = 1, GameFunction.COLUMN do
		GameFunction.statusTable[i] = {}
		for j = 1, GameFunction.ROW do
			GameFunction.statusTable[i][j] = 0
		end
	end
	local randomLastIndex = 0
	local randomLastX = 0
	local randomLastY = 0
	local randomNextIndex = 0
	local randomNextX = 0
	local randomNextY = 0
	local randomKind = 0
	-- local outFlag = 0
	while GameFunction.spriteNum < totalNum do
		randomLastIndex = math.random( totalNum )
		randomLastX = ( randomLastIndex - 1 ) % column + 2
		randomLastY = math.ceil( randomLastIndex / column ) + 1
		randomLastIndex = randomLastX + ( randomLastY - 1 ) * GameFunction.COLUMN
		randomKind = math.random( kind )
		print( "randomLastIndex =", randomLastIndex )
		print( "randomLastX =", randomLastX )
		print( "randomLastY =", randomLastY )
		print( "randomKind =", randomKind )
		print()
		if GameFunction.statusTable[randomLastX][randomLastY] == 0 and GameFunction.judgeSprite( randomLastX, randomLastY ) then
			GameFunction.statusTable[randomLastX][randomLastY] = randomKind
			while true do
				randomNextIndex = math.random( totalNum )
				randomNextX = ( randomNextIndex - 1 ) % column + 2
				randomNextY = math.ceil( randomNextIndex / column ) + 1
				randomNextIndex = randomNextX + ( randomNextY - 1 ) * GameFunction.COLUMN
				if GameFunction.statusTable[randomNextX][randomNextY] == 0 then
					GameFunction.statusTable[randomNextX][randomNextY] = randomKind
					if GameFunction.judgeSprites( randomLastIndex, randomNextIndex ) then
						break
					else
						GameFunction.statusTable[randomNextX][randomNextY] = 0
						-- outFlag = outFlag + 1
						-- if outFlag > 10 then
						-- 	GameFunction.statusTable[randomLastX][randomLastY] = 0
						-- 	break
						-- end
					end
				end
			end
			GameFunction.spriteNum = GameFunction.spriteNum + 2
			print( "spriteNum =", GameFunction.spriteNum )
		end
	end
	dump( GameFunction.statusTable, "init statusTable" )
	GameFunction.initUI( )
end
-- 点击精灵
function GameFunction.clickSpriteCallback( tag )
	print( "click tag =", tag )
	if GameFunction.lastTag then
		local resultFlag, pathTable = GameFunction.judgeSprites( GameFunction.lastTag, tag )
		print( "judge result =", result )
		dump( pathTable, "pathTable" )
		if resultFlag then
			GameFunction.result( GameFunction.lastTag, tag, pathTable )
		else
			GameFunction.bgLayout:getChildByTag( GameFunction.lastTag ):setVisible( false )
			GameFunction.bgLayout:getChildByTag( tag ):setVisible( false )
			GameFunction.lastTag = nil
		end
	else
		GameFunction.lastTag = tag
		GameFunction.bgLayout:getChildByTag( tag ):setVisible( true )
	end
	return true
end
-- 判断两点是否在一条直线上，如果在，是否线上没有其他精灵
function GameFunction.judgeLine( ax, ay, bx, by )
	print( "judgeLine", ax, ay, bx, by )
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
			if GameFunction.statusTable[ax][i] ~= 0 then
				print( "judgeLine", ax, i, false )
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
			if GameFunction.statusTable[i][ay] ~= 0 then
				print( "judgeLine", i, ay, false )
				return false
			end
		end
	end
	return true
end
-- 判断是否能消除
function GameFunction.judgeSprites( lastIndex, nextIndex )
	local function print( ... )
	end
	print( "------------------开始------------------" )
	if lastIndex == nextIndex then
		print( "一个精灵" )
		print( "------------------结束------------------" )
		return false
	else
		print( "两个精灵" )
		local statusTable = GameFunction.statusTable
		-- 判断
		local lastX = ( lastIndex - 1 ) % GameFunction.COLUMN + 1
		local lastY = math.ceil( lastIndex / GameFunction.COLUMN )
		local nextX = ( nextIndex - 1 ) % GameFunction.COLUMN + 1
		local nextY = math.ceil( nextIndex / GameFunction.COLUMN )
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
			if GameFunction.judgeLine( lastX, lastY, nextX, nextY ) then
				print( "一条线连接成功" )
				print( "------------------成功------------------" )
				return true, pathTable
			end
		end
		print( "一条线连接失败" )



		print( "尝试两条线连接" )
		if statusTable[lastX][nextY] == 0 then
			-- 两条线结果
			if GameFunction.judgeLine( lastX, lastY, lastX, nextY ) and GameFunction.judgeLine( lastX, nextY, nextX, nextY ) then
				print( "两条线连接成功" )
				table.insert( pathTable, 2, {
					lastX, nextY,
				} )
				print( "------------------成功------------------" )
				return true, pathTable
			end
		end
		if statusTable[nextX][lastY] == 0 then
			if GameFunction.judgeLine( lastX, lastY, nextX, lastY ) and GameFunction.judgeLine( nextX, lastY, nextX, nextY ) then
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
		while lastXOver <= GameFunction.COLUMN and statusTable[lastXOver][lastY] == 0 do
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
		while nextXOver <= GameFunction.COLUMN and statusTable[nextXOver][nextY] == 0 do
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
				dump( sortTable, "sortedTable" )
				local numberTable = {}
				for i = sortTable[2], sortTable[3] do
					table.insert( numberTable, i )
				end
				dump( numberTable, "numberTable" )
				table.sort( numberTable, function( a, b )
					return math.abs( a - lastX ) < math.abs( b - lastX )
				end )
				dump( numberTable, "sortTable numberTable" )
				for i, v in ipairs(numberTable) do
					if GameFunction.judgeLine( v, lastY, v, nextY ) then
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
		while lastYOver <= GameFunction.ROW and statusTable[lastX][lastYOver] == 0 do
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
		while nextYOver <= GameFunction.ROW and statusTable[nextX][nextYOver] == 0 do
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
				dump(sortTable, "sortedTable")
				local numberTable = {}
				for i = sortTable[2], sortTable[3] do
					table.insert( numberTable, i )
				end
				dump(numberTable, "numberTable")
				table.sort( numberTable, function( a, b )
					return math.abs( a - lastY ) < math.abs( b - lastY )
				end )
				dump(numberTable, "sortTable numberTable")
				for i, v in ipairs(numberTable) do
					if GameFunction.judgeLine( lastX, v, nextX, v ) then
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
function GameFunction.result( lastIndex, nextIndex, pathTable )
	dump( pathTable, "路径" )
	local lastX = ( lastIndex - 1 ) % GameFunction.COLUMN + 1
	local lastY = math.ceil( lastIndex / GameFunction.COLUMN )
	local nextX = ( nextIndex - 1 ) % GameFunction.COLUMN + 1
	local nextY = math.ceil( nextIndex / GameFunction.COLUMN )
	local sprite = GameFunction.spriteLayout:getChildByTag( lastIndex )
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:removeEventListener( GameFunction.spriteLayout:getChildByTag( lastIndex )._listenner )
	eventDispatcher:removeEventListener( GameFunction.spriteLayout:getChildByTag( nextIndex )._listenner )
	GameFunction.bgLayout:getChildByTag( lastIndex ):removeFromParent( true )
	GameFunction.bgLayout:getChildByTag( nextIndex ):removeFromParent( true )
	GameFunction.statusTable[lastX][lastY] = 0
	GameFunction.statusTable[nextX][nextY] = 0
	GameFunction.lastTag = nil
	local array = {}
	for i = 2, #pathTable do
		local steps = math.abs(pathTable[i][1] + pathTable[i][2] - pathTable[i-1][1] - pathTable[i-1][2])
		table.insert( array, cc.JumpTo:create( 0.5 * steps, cc.p( 100 * pathTable[i][1] - 50, 100 * ( GameFunction.ROW - pathTable[i][2] ) + 50 ), 30, steps ) )
	end
	local function disappear( )
		sprite:removeFromParent( true )
		GameFunction.spriteLayout:getChildByTag( nextIndex ):removeFromParent( true )
		GameFunction.spriteNum = GameFunction.spriteNum - 2
		if GameFunction.spriteNum == 0 then
			-- GameFunction.bgLayout:removeAllChildren( true )
			-- GameFunction.spriteLayout:removeAllChildren( true )
			GameFunction.buildData( 8, 6, 10 )
		end
	end
    table.insert( array, cc.CallFunc:create( disappear ) )
    sprite:runAction( cc.Sequence:create( array ) )
end
function MainScene:onCreate()
	GameFunction.bgLayout = ccui.Layout:create()
	GameFunction.bgLayout:setOpacity( 160 )
	GameFunction.bgLayout:setPosition( cc.p( display.cx - 8 * 50, display.cy - 8 * 50 ) )
	GameFunction.bgLayout:setContentSize({ 8 * 100, 8 * 100 })
	self:addChild( GameFunction.bgLayout )

	GameFunction.spriteLayout = ccui.Layout:create()
	GameFunction.spriteLayout:setPosition( cc.p( display.cx - 8 * 50, display.cy - 8 * 50 ) )
	GameFunction.spriteLayout:setContentSize({ 8 * 100, 8 * 100 })
	self:addChild( GameFunction.spriteLayout )

	math.newrandomseed()

	GameFunction.buildData( 4, 6, 5 )
	print( "init OVER" )
end

return MainScene
