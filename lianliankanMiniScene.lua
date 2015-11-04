--[[
	连连看界面
	唐实聪
	2015.11.3
--]]
local SCENE = {}

local lianliankanMiniScene = nil
local miniSceneHeight      = nil
local touchLayer           = nil
local bgLayout             = nil
local spriteLayout         = nil

local statusTable          = nil 	-- 数据
local COLUMN               = nil
local ROW                  = nil
local lastTag              = nil
local spriteNum            = nil

function SCENE.create( params )
	dump( params, "lianliankanMiniScene" )
	lianliankanMiniScene, miniSceneHeight, touchLayer = zc.createMyMiniScene( "lianliankan" )
	zc.setMainNoticeView( touchLayer, "Main/common/noTice_bk_2.jpg", true )

	-- 返回按钮button
    local backButton = zc.createButton({
        pos      = ccp(zc.width - 40, miniSceneHeight - 40),
        effect   = "back",
        normal   = "Main/common/back_n.png",
        pressed  = "Main/common/back_h.png",
        listener = SCENE.clickBackCallback,
    })
    lianliankanMiniScene:addChild(backButton)

	SCENE.initData()
	
	return lianliankanMiniScene
end

---------------------------------------------------------
---------------------  初始化函数  -----------------------
---------------------------------------------------------

-- 从后端获取数据
function SCENE.initData()
	spriteNum = 0
	statusTable = {
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
	local zeroTable = {}
	for i = 1, #statusTable[1] do
		zeroTable[i] = 0
	end
	table.insert( statusTable, 1, zeroTable )
	table.insert( statusTable, table.copy( zeroTable ) )
	for i = 1, #statusTable do
		table.insert( statusTable[i], 1, 0 )
		table.insert( statusTable[i], 0 )
	end
	dump( statusTable, "添加0之后的statusTable" )
	COLUMN = #statusTable
	ROW    = #statusTable[1]
	print( "行＝"..ROW.."  列＝"..COLUMN )
	SCENE.initUI()
end

-- 创建ui
function SCENE.initUI()
	bgLayout = zc.createLayout( {
		pos = ccp( zc.cx - COLUMN * 50, zc.cy - ROW * 50 ),
		size = CCSize( COLUMN * 100, ROW * 100 ),
	} )
	lianliankanMiniScene:addChild( bgLayout )
	spriteLayout = zc.createLayout( {
		pos = ccp( zc.cx - COLUMN * 50, zc.cy - ROW * 50 ),
		size = CCSize( COLUMN * 100, ROW * 100 ),
	} )
	lianliankanMiniScene:addChild( spriteLayout )
	for i = 1, COLUMN do
		local data = statusTable[i]
		for j = 1, ROW do
			if data[j] ~= 0 then
				local spriteBg = zc.createImageView( {
					ap = ccp( 0.5, 0.5 ),
					pos = ccp( 100 * i - 50, 100 * ( ROW - j ) + 50 ),
					src = "Main/head_icon/potential/bk_1.png",
					tag = ( j - 1 ) * COLUMN + i,
				} )
				spriteBg:setVisible( false )
				bgLayout:addChild( spriteBg )
				local sprite = zc.createImageView( {
					ap = ccp( 0.5, 0.5 ),
					pos = ccp( 100 * i - 50, 100 * ( ROW - j ) + 50 ),
					src = "Main/head_icon/head_icon_"..data[j]..".png",
					tag = ( j - 1 ) * COLUMN + i,
					listener = SCENE.clickSpriteCallback,
				} )
				spriteLayout:addChild( sprite )
				spriteNum = spriteNum + 1
			end
		end
	end
end

---------------------------------------------------------
-----------------------  回调函数  -----------------------
---------------------------------------------------------

-- 点击返回按钮
function SCENE.clickBackCallback( pSender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		zc.changeToMiniScene("main")
	end
end

-- 点击精灵
function SCENE.clickSpriteCallback( pSender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		local nextTag = pSender:getTag()
		if lastTag then
			print( "------------------开始------------------" )
			if lastTag == nextTag then
				print( "一个精灵" )
				bgLayout:getChildByTag( nextTag ):setVisible( false )
				lastTag = nil
				print( "------------------结束------------------" )
			else
				print( "两个精灵" )
				-- 判断
				local lastX = ( lastTag - 1 ) % COLUMN + 1
				local lastY = math.ceil( lastTag / COLUMN )
				local nextX = ( nextTag - 1 ) % COLUMN + 1
				local nextY = math.ceil( nextTag / COLUMN )
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
					bgLayout:getChildByTag( lastTag ):setVisible( false )
					bgLayout:getChildByTag( nextTag ):setVisible( false )
					lastTag = nil
					print( "不同精灵不能消除" )
					print( "------------------失败------------------" )
					return
				end

				print( "尝试一条线连接" )
				-- 一条线连接
				if lastX == nextX or lastY == nextY then
					print( "两个精灵在一条线上" )
					if SCENE.judgeLine( lastX, lastY, nextX, nextY ) then
						print( "一条线连接成功" )
						spriteLayout:getChildByTag( lastTag ):setTouchEnabled(false)
						spriteLayout:getChildByTag( nextTag ):setTouchEnabled(false)
						bgLayout:getChildByTag( lastTag ):removeFromParentAndCleanup( true )
						bgLayout:getChildByTag( nextTag ):removeFromParentAndCleanup( true )
						statusTable[lastX][lastY] = 0
						statusTable[nextX][nextY] = 0
						SCENE.resultAction( nextTag, pathTable )
						lastTag = nil
						print( "------------------成功------------------" )
						return
					end
				end
				print( "一条线连接失败" )



				print( "尝试两条线连接" )
				if statusTable[lastX][nextY] == 0 then
					-- 两条线结果
					if SCENE.judgeLine( lastX, lastY, lastX, nextY ) and SCENE.judgeLine( lastX, nextY, nextX, nextY ) then
						print( "两条线连接成功" )
						table.insert( pathTable, 2, {
							lastX, nextY,
						} )
						dump( pathTable, "连接点" )
						spriteLayout:getChildByTag( lastTag ):setTouchEnabled(false)
						spriteLayout:getChildByTag( nextTag ):setTouchEnabled(false)
						bgLayout:getChildByTag( lastTag ):removeFromParentAndCleanup( true )
						bgLayout:getChildByTag( nextTag ):removeFromParentAndCleanup( true )
						statusTable[lastX][lastY] = 0
						statusTable[nextX][nextY] = 0
						SCENE.resultAction( nextTag, pathTable )
						lastTag = nil
						print( "------------------成功------------------" )
						return
					end
				end
				if statusTable[nextX][lastY] == 0 then
					if SCENE.judgeLine( lastX, lastY, nextX, lastY ) and SCENE.judgeLine( nextX, lastY, nextX, nextY ) then
						print( "两条线连接成功" )
						table.insert( pathTable, 2, {
							nextX, lastY,
						} )
						dump( pathTable, "连接点" )
						spriteLayout:getChildByTag( lastTag ):setTouchEnabled(false)
						spriteLayout:getChildByTag( nextTag ):setTouchEnabled(false)
						bgLayout:getChildByTag( lastTag ):removeFromParentAndCleanup( true )
						bgLayout:getChildByTag( nextTag ):removeFromParentAndCleanup( true )
						statusTable[lastX][lastY] = 0
						statusTable[nextX][nextY] = 0
						SCENE.resultAction( nextTag, pathTable )
						lastTag = nil
						print( "------------------成功------------------" )
						return
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
				while lastXOver <= COLUMN and statusTable[lastXOver][lastY] == 0 do
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
				while nextXOver <= COLUMN and statusTable[nextXOver][nextY] == 0 do
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
						for i = sortTable[2], sortTable[3] do
							if SCENE.judgeLine( i, lastY, i, nextY ) then
								print( "三条线横向连接成功" )
								table.insert( pathTable, 2, {
										i, lastY,
								} )
								table.insert( pathTable, 3, {
										i, nextY,
								} )
								dump( pathTable, "连接点" )
								spriteLayout:getChildByTag( lastTag ):setTouchEnabled(false)
								spriteLayout:getChildByTag( nextTag ):setTouchEnabled(false)
								bgLayout:getChildByTag( lastTag ):removeFromParentAndCleanup( true )
								bgLayout:getChildByTag( nextTag ):removeFromParentAndCleanup( true )
								statusTable[lastX][lastY] = 0
								statusTable[nextX][nextY] = 0
								SCENE.resultAction( nextTag, pathTable )
								lastTag = nil
								print( "------------------成功------------------" )
								return
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
				while lastYOver <= ROW and statusTable[lastX][lastYOver] == 0 do
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
				while nextYOver <= ROW and statusTable[nextX][nextYOver] == 0 do
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
						for i = sortTable[2], sortTable[3] do
							if SCENE.judgeLine( lastX, i, nextX, i ) then
								print( "三条线纵向连接成功" )
								table.insert( pathTable, 2, {
										lastX, i,
								} )
								table.insert( pathTable, 3, {
										nextX, i,
								} )
								dump( pathTable, "连接点" )
								spriteLayout:getChildByTag( lastTag ):setTouchEnabled(false)
								spriteLayout:getChildByTag( nextTag ):setTouchEnabled(false)
								bgLayout:getChildByTag( lastTag ):removeFromParentAndCleanup( true )
								bgLayout:getChildByTag( nextTag ):removeFromParentAndCleanup( true )
								statusTable[lastX][lastY] = 0
								statusTable[nextX][nextY] = 0
								SCENE.resultAction( nextTag, pathTable )
								lastTag = nil
								print( "------------------成功------------------" )
								return
							end
						end
					end
				end
				print( "三条线纵向连接失败" )


				-- 失败结果
				bgLayout:getChildByTag( lastTag ):setVisible( false )
				bgLayout:getChildByTag( nextTag ):setVisible( false )
				lastTag = nil
				print( "------------------失败------------------" )
			end
		else
			lastTag = nextTag
			bgLayout:getChildByTag( nextTag ):setVisible( true )
		end
	end	
end

function SCENE.judgeLine( ax, ay, bx, by )
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
			if statusTable[ax][i] ~= 0 then
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
			if statusTable[i][ay] ~= 0 then
				print( "judgeLine", i, ay, false )
				return false
			end
		end
	end
	return true
end

function SCENE.resultAction( nextTag, path )
	dump( path, "路径" )
	local sprite = spriteLayout:getChildByTag( lastTag )
	local array = CCArray:create()
	for i = 2, #path do
		local steps = math.abs(path[i][1] + path[i][2] - path[i-1][1] - path[i-1][2])
		array:addObject( CCJumpTo:create( 0.5 * steps, ccp( 100 * path[i][1] - 50, 100 * ( ROW - path[i][2] ) + 50 ), 30, steps ) )
	end
	local function disappear()
		sprite:removeFromParentAndCleanup( true )
		spriteLayout:getChildByTag( nextTag ):removeFromParentAndCleanup( true )
		spriteNum = spriteNum - 2
		if spriteNum == 0 then
			zc.tipInfo({text = "恭喜你赢了"})
			bgLayout:removeFromParentAndCleanup( true )
			spriteLayout:removeFromParentAndCleanup( true )
			SCENE.initData()
		end
	end
    array:addObject( CCCallFuncN:create( disappear ) )
    sprite:runAction( CCSequence:create( array ) )
end

function SCENE.clean()
	lianliankanMiniScene:removeAllChildrenWithCleanup(true)
	lianliankanMiniScene = nil
	miniSceneHeight      = nil
	touchLayer           = nil
	statusTable          = nil 	-- 数据
	COLUMN               = nil
	ROW                  = nil
	lastTag              = nil
end

return SCENE