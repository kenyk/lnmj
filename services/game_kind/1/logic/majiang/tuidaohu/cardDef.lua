require "table_util"
local math = math
local table = table

local cardDef = {}

local AllCards =
{
--  一万二万三万四万五万六万七八万九万
	11,12,13,14,15,16,17,18,19,
	11,12,13,14,15,16,17,18,19,
	11,12,13,14,15,16,17,18,19,
	11,12,13,14,15,16,17,18,19,
--  一筒  二筒  三筒 四筒  五筒  六筒 七筒  八筒  九筒
	21,22,23,24,25,26,27,28,29,
	21,22,23,24,25,26,27,28,29,
	21,22,23,24,25,26,27,28,29,
	21,22,23,24,25,26,27,28,29,
--  一条  二条  三条 四条  五条  六条 七条  八条 九条
	31,32,33,34,35,36,37,38,39,
	31,32,33,34,35,36,37,38,39,
	31,32,33,34,35,36,37,38,39,
	31,32,33,34,35,36,37,38,39,
--  东  南 西  北 中 發  白
	41,42,43,44,45,46,47,
	41,42,43,44,45,46,47,
	41,42,43,44,45,46,47,
	41,42,43,44,45,46,47,
--	梅  兰 菊  竹 
	51,52,53,54,
	51,52,53,54,
	51,52,53,54,
	51,52,53,54
};

-- 带风牌
local daifeng = {
  [1]=22,   [2]=17,     [3]=26,     [4]=18,     [5]=21,     [6]=16,     [7]=38,     [8]=44,     [9]=17,     [10]=28,
  [11]=38,  [12]=44,    [13]=15,    [14]=43,    [15]=14,    [16]=34,    [17]=32,    [18]=45,    [19]=36,    [20]=11,
  [21]=12,  [22]=35,    [23]=25,    [24]=32,    [25]=13,    [26]=37,    [27]=23,    [28]=12,    [29]=25,    [30]=46,
  [31]=18,  [32]=23,    [33]=24,    [34]=24,    [35]=43,    [36]=17,    [37]=11,    [38]=17,    [39]=42,    [40]=34,
  [41]=19,  [42]=35,    [43]=31,    [44]=41,    [45]=34,    [46]=38,    [47]=14,    [48]=38,    [49]=19,    [50]=43,
  [51]=35,  [52]=34,    [53]=42,    [54]=31,    [55]=37,    [56]=23,    [57]=31,    [58]=16,    [59]=46,    [60]=19,
  [61]=29,  [62]=42,    [63]=26,    [64]=47,    [65]=41,    [66]=47,    [67]=39,    [68]=44,    [69]=33,    [70]=21,
  [71]=46,  [72]=12,    [73]=36,    [74]=29,    [75]=27,    [76]=26,    [77]=45,    [78]=36,    [79]=39,    [80]=21,
  [81]=15,  [82]=42,    [83]=33,    [84]=32,    [85]=43,    [86]=37,    [87]=47,    [88]=26,    [89]=47,    [90]=39,
  [91]=11,  [92]=25,    [93]=46,    [94]=14,    [95]=28,    [96]=25,    [97]=24,    [98]=19,    [99]=45,    [100]=13,
  [101]=28, [102]=35,   [103]=23,   [104]=18,   [105]=27,   [106]=33,   [107]=36,   [108]=13,   [109]=45,   [110]=28,
  [111]=29, [112]=32,   [113]=41,   [114]=16,   [115]=22,   [116]=12,   [117]=27,   [118]=29,   [119]=11,   [120]=22,    
  [121]=21, [122]=37,	[123]=33,   [124]=18,   [125]=44, 	[126]=39,   [127]=15,   [128]=31,   [129]=24,   [130]=15,    
  [131]=27, [132]=13,	[133]=16, 	[134]=22,  	[135]=14, 	[136]=41,	
}

--不带风牌
local budaifeng = {
	[1]=22,    [2]=17,    [3]=26,     [4]=18,     [5]=21,     [6]=16,     [7]=38,    [8]=39,    [9]=17,   [10]=28,
	[11]=38,   [12]=18,   [13]=15,    [14]=21,    [15]=14,    [16]=34,    [17]=32,   [18]=36,   [19]=11,  [20]=12,
	[21]=35,   [22]=25,   [23]=32,    [24]=13,    [25]=37,    [26]=23,    [27]=12,   [28]=25,   [29]=24,  [30]=18,
	[31]=23,   [32]=24,   [33]=24,    [34]=37,    [35]=17,    [36]=11,    [37]=17,   [38]=27,   [39]=34,  [40]=19,
	[41]=35,   [42]=31,   [43]=16,    [44]=22,    [45]=38,    [46]=14,    [47]=38,   [48]=19,   [49]=22,  [50]=35,
	[51]=34,   [52]=11,   [53]=31,    [54]=37,    [55]=23,    [56]=31,    [57]=16,   [58]=31,   [59]=19,  [60]=29,
	[61]=12,   [62]=26,   [63]=13,    [64]=34,    [65]=16,    [66]=39,    [67]=15,   [68]=33,   [69]=21,  [70]=15,
	[71]=12,   [72]=36,   [73]=29,    [74]=27,    [75]=26,    [76]=36,    [77]=39,   [78]=21,   [79]=15,  [80]=29,
	[81]=33,   [82]=32,   [83]=33,    [84]=37,    [85]=22,    [86]=26,    [87]=14,   [88]=39,   [89]=11,  [90]=25,
	[91]=27,   [92]=14,   [93]=28,    [94]=25,    [95]=24,    [96]=19,    [97]=13,   [98]=28,   [99]=35,  [100]=23,
	[101]=18,  [102]=27,  [103]=33,   [104]=36,   [105]=13,   [106]=28,   [107]=29,  [108]=32,	
}

--白板做鬼，在不带风选项下
local baiban_budaifeng = {
  [1]=22,   [2]=17,     [3]=26,     [4]=18,     [5]=21,     [6]=16,     [7]=38,     [8]=39,     [9]=17,     [10]=28,
  [11]=38,  [12]=18,    [13]=15,    [14]=21,    [15]=14,    [16]=34,    [17]=32,    [18]=47,    [19]=36,    [20]=11,
  [21]=12,  [22]=35,    [23]=25,    [24]=32,    [25]=13,    [26]=37,    [27]=23,    [28]=12,    [29]=25,    [30]=24,
  [31]=18,  [32]=23,    [33]=24,    [34]=24,    [35]=37,    [36]=17,    [37]=11,    [38]=17,    [39]=27,    [40]=34,
  [41]=19,  [42]=35,    [43]=31,    [44]=16,    [45]=22,    [46]=38,    [47]=14,    [48]=38,    [49]=19,    [50]=22,
  [51]=35,  [52]=34,    [53]=11,    [54]=31,    [55]=37,    [56]=23,    [57]=31,    [58]=16,    [59]=31,    [60]=19,
  [61]=29,  [62]=12,    [63]=26,    [64]=13,    [65]=34,    [66]=16,    [67]=39,    [68]=15,    [69]=33,    [70]=21,
  [71]=15,  [72]=12,    [73]=36,    [74]=29,    [75]=27,    [76]=26,    [77]=47,    [78]=36,    [79]=39,    [80]=21,
  [81]=15,  [82]=29,    [83]=33,    [84]=32,    [85]=33,    [86]=37,    [87]=22,    [88]=26,    [89]=14,    [90]=39,
  [91]=11,  [92]=25,    [93]=27,    [94]=14,    [95]=28,    [96]=25,    [97]=24,    [98]=19,    [99]=47,    [100]=13,
  [101]=28, [102]=35,   [103]=23,   [104]=18,   [105]=27,   [106]=33,   [107]=36,   [108]=13,   [109]=47,   [110]=28,
  [111]=29, [112]=32,
}

function cardDef:init_cards(laiZi, player_count, baiban_laizi, feng)
    local randcard = {}
    if no_feng == true then 
    	if laiZi and baiban_laizi then 
    		randcard = baiban_budaifeng
    	else
    		randcard = budaifeng
    	end
    else
    	randcard = daifeng
    end

    local cards = table.clone(randcard)
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local player_cards = {}
    for i = 1, player_count do

        player_cards[i] = {}
        for k = 1 , 13 do
            table.insert(player_cards[i], table.remove(cards, math.random(#cards)))
        end
    end
    return player_cards, cards
end

function cardDef:getFanPaiLaizi(no_feng)
	local cards = {}
	if no_feng == true then
		cards = budaifeng
	else
		cards = daifeng
	end
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    return cards[math.random(#cards)]
end


function cardDef:testCard()
	return testCard
end

function cardDef:dealCards(rawcards, playercount, cutIndex)
	local cards = table.clone(rawcards)
	local tailtable = {}
	for i = 1, cutIndex do
		table.insert(tailtable, cards[1])
		table.remove(cards,1)
	end

	for k, v in pairs(tailtable) do
		table.insert(cards, v)
	end

	local player_cards = {}
	for i = 1, playercount do
		player_cards[i] = {}
	end
	local count = 1
    for k , v in pairs(player_cards) do
        for i = 1 , 13 do
            table.insert(v, table.remove(cards, 1))
        end
    end
--	for i = 1, 4 do
--		for k, v in pairs(player_cards) do
--			if i < 4 then
--				table.insert(v, cards[1])
--				table.remove(cards, 1)
--				table.insert(v, cards[1])
--				table.remove(cards, 1)
--				table.insert(v, cards[1])
--				table.remove(cards, 1)
--				table.insert(v, cards[1])
--				table.remove(cards, 1)
--			else
--				table.insert(v, cards[1])
--				table.remove(cards, 1)
--			end
--		end
--	end
	return player_cards, cards
end

function cardDef:add_stackCard(cards,card)
	if cards[card] then
		cards[card] = cards[card] +1
	else
		cards[card] = 1
	end
end

function cardDef:sub_stackCard(cards,card)
	cards[card] = cards[card] - 1 
end


--[[
把牌分类
 	cards[11] = num
 	cards[32] = num
]]
function cardDef:stackCards(cards)
	local newcard = {}
	for k, v in pairs(cards) do
		self:add_stackCard(newcard, v)
	end
	return newcard
end

function cardDef:canPend(cards, card)
	if cards[card] and cards[card] >= 2 then
		return true
	end
	return false
end

function cardDef:canPengGang(cards, card) 
	if cards[card] and cards[card] == 3 then
		return true
	end
end

function cardDef:canGang(cards, card, flag)
	if flag == "chupai" then
	elseif flag == "mopai" then
	-- elseif flag == "mogangpai" then
	end
end

return cardDef