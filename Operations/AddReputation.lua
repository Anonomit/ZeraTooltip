
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strMatch = string.match

local mathFloor = math.floor


--[[
Reputation standings
0 - Unknown
1 - Hated
2 - Hostile
3 - Unfriendly
4 - Neutral
5 - Friendly
6 - Honored
7 - Revered
8 - Exalted
]]



local REP_PATTERN               = " +%d"
local REP_COUNT_PATTERN         = " +%d x%d = +%d"
local REPUTATION_CUTOFF_PATTERN = " (|cff%s%s/%s|r)"

local MERCHANT_FACTION_ID = Addon.MY_FACTION == "Alliance" and 2586 or 2587


local reputationStandings = {}
do
  local i = 1
  while _G["FACTION_STANDING_LABEL"..i] do
    reputationStandings[i] = _G["FACTION_STANDING_LABEL"..i]
    i = i + 1
  end
end


Addon.waylaidSupplies = {}
local reputationItems = {}
for ids, repInfo in pairs{
  [{211365, 211331, 210771, 211332, 211329, 211315, 211316, 211933, 211317, 211330}]                                 = {factionID = MERCHANT_FACTION_ID, rep = 300,  cutoff = 5},
  [{211367, 211327, 211328, 211319, 211326, 211325, 211934, 211321, 211318, 211322, 211324, 211323, 211320}]         = {factionID = MERCHANT_FACTION_ID, rep = 450,  cutoff = 5},
  [{211839, 211819, 211822, 211837, 211838, 211821, 211820, 211836, 211835, 211823}]                                 = {factionID = MERCHANT_FACTION_ID, rep = 500,  cutoff = 6},
  [{211840, 211831, 211833, 211824, 211828, 211825, 211829}]                                                         = {factionID = MERCHANT_FACTION_ID, rep = 650,  cutoff = 6},
  [{211841, 211935, 211832, 211830, 211834, 211827, 211826}]                                                         = {factionID = MERCHANT_FACTION_ID, rep = 800,  cutoff = 6},
  [{217337, 215390, 215417, 215389, 215391, 215386, 215387, 215388, 215413, 215420, 215421, 215419, 215400, 215392}] = {factionID = MERCHANT_FACTION_ID, rep = 700,  cutoff = 7},
  [{217338, 215393, 215385, 215398, 215401, 215402, 215407, 215408, 215414, 215411, 215399, 215395, 215418}]         = {factionID = MERCHANT_FACTION_ID, rep = 850,  cutoff = 7},
  [{217339, 215397, 215415, 215409, 215396, 215416, 215404, 215403}]                                                 = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7},
  [{220924, 220927, 220926, 220921, 220922, 220925, 220923, 220919, 220918, 220920}]                                 = {factionID = MERCHANT_FACTION_ID, rep = 950,  cutoff = 8},
  [{220934, 220940, 220942, 220931, 220935, 220928, 220929, 220930, 220938, 220937, 220932}]                         = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8},
  [{220936, 220941, 220939, 220933}]                                                                                 = {factionID = MERCHANT_FACTION_ID, rep = 1850, cutoff = 8},
  
  [{6290}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 20},  -- Brilliant Smallfish
  [{2840}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 20},  -- Copper Bar
  [{2581}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 10},  -- Heavy Linen Bandage
  [{6888}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 20},  -- Herb Baked Egg
  [{2318}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 14},  -- Light Leather
  [{2447}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 20},  -- Peacebloom
  [{2835}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 10},  -- Rough Stone
  [{765}]   = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 20},  -- Silverleaf
  [{2680}]  = {factionID = MERCHANT_FACTION_ID, rep = 300, cutoff = 5, count = 20},  -- Spiced Wolf Meat
  
  [{4343}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 6},   -- Brown Linen Pant
  [{6238}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 4},   -- Brown Linen Robe
  [{2847}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 6},   -- Copper Shortsword
  [{2300}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 3},   -- Embossed Leather Vest
  [{4237}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 5},   -- Handstitched Leather Boots
  [{929}]   = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 10},  -- Healing Potion
  [{11287}] = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 2},   -- Lesser Magic Wand
  [{118}]   = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 20},  -- Minor Healing Potion
  [{20744}] = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 2},   -- Minor Wizard Oil
  [{4362}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 3},   -- Rough Boomsticks
  [{4360}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 12},  -- Rough Copper Bomb
  [{3473}]  = {factionID = MERCHANT_FACTION_ID, rep = 450, cutoff = 5, count = 3},   -- Runed Copper Pants
  
  [{2841}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 12},  -- Bronze Bar
  [{2453}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 20},  -- Bruiseweed
  [{5527}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 8},   -- Goblin Deviled Clam
  [{3531}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 15},  -- Heavy Wool Bandage
  [{2319}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 12},  -- Medium Leather
  [{2842}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 6},   -- Silver Bar
  [{6890}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 20},  -- Smoked Bear Meat
  [{21072}] = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 15},  -- Smoked Sagefish
  [{2452}]  = {factionID = MERCHANT_FACTION_ID, rep = 500, cutoff = 6, count = 20},  -- Swiftthistle
  
  [{2316}]  = {factionID = MERCHANT_FACTION_ID, rep = 650, cutoff = 6, count = 2},   -- Dark Leather Cloak
  [{2587}]  = {factionID = MERCHANT_FACTION_ID, rep = 650, cutoff = 6, count = 4},   -- Gray Woolen Shirt
  [{3385}]  = {factionID = MERCHANT_FACTION_ID, rep = 650, cutoff = 6, count = 20},  -- Lesser Mana Potion
  [{20745}] = {factionID = MERCHANT_FACTION_ID, rep = 650, cutoff = 6, count = 2},   -- Minor Mana Oil
  [{6350}]  = {factionID = MERCHANT_FACTION_ID, rep = 650, cutoff = 6, count = 3},   -- Rough Bronze Boots
  [{4374}]  = {factionID = MERCHANT_FACTION_ID, rep = 650, cutoff = 6, count = 12},  -- Small Bronze Bomb
  
  [{6373}]  = {factionID = MERCHANT_FACTION_ID, rep = 800, cutoff = 6, count = 15},  -- Elixir of Firepower
  [{4251}]  = {factionID = MERCHANT_FACTION_ID, rep = 800, cutoff = 6, count = 2},   -- Hillman's Shoulders
  [{5507}]  = {factionID = MERCHANT_FACTION_ID, rep = 800, cutoff = 6, count = 2},   -- Ornate Spyglass
  [{5542}]  = {factionID = MERCHANT_FACTION_ID, rep = 800, cutoff = 6, count = 3},   -- Pearl-clasped Cloak
  [{6339}]  = {factionID = MERCHANT_FACTION_ID, rep = 800, cutoff = 6, count = 1},   -- Runed Silver Rod
  [{15869}] = {factionID = MERCHANT_FACTION_ID, rep = 800, cutoff = 6, count = 14},  -- Silver Skeleton Key
  
  [{3358}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Khadgar's Whisker
  [{3729}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Soothing Turtle Bisque
  [{3818}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 16},  -- Fadeleaf
  [{3819}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 8},   -- Wintersbite
  [{3860}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 6},   -- Mithril Bar
  [{4235}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 5},   -- Heavy Hide
  [{4304}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Thick Leather
  [{4334}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 3},   -- Formal White Shirt
  [{4594}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 40},  -- Rockscale Cod
  [{6371}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 7},   -- Fire Oil
  [{6451}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Heavy Silk Bandage
  [{7966}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 5},   -- Solid Grinding Stone
  [{8831}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 8},   -- Purple Lotus
  
  [{1710}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 16},  -- Greater Healing Potion
  [{3577}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Gold Bar
  [{3835}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 5},   -- Green Iron Bracers
  [{4391}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 2},   -- Compact Harvest Reaper Kit
  [{4394}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 8},   -- Big Iron Bomb
  [{5964}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Barbaric Shoulders
  [{5966}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 5},   -- Guardian Gloves
  [{7062}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Crimson Silk Pantaloons
  [{7377}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 2},   -- Frost Leather Cloak
  [{7919}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 3},   -- Heavy Mithril Gauntlet
  [{8949}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 6},   -- Elixir of Agility
  [{17222}] = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 5},   -- Spider Sausage
  
  [{3855}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 2},  -- Massive Iron Axe
  [{4335}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 5},  -- Rich Purple Silk Shirt
  [{8198}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 2},  -- Turtle Scale Bracers
  [{8951}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 14}, -- Elixir of Greater Defense
  [{10008}] = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 3},  -- White Bandit Mask
  [{10508}] = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 2},  -- Mithril Blunderbuss
  [{10546}] = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 2},  -- Deadly Scope
  
  [{6037}]  = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 12},  -- Truesilver Bar
  [{8169}]  = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 8},   -- Thick Hide
  [{8170}]  = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 14},  -- Rugged Leather
  [{8545}]  = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 14},  -- Heavy Mageweave Bandage
  [{8838}]  = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 15},  -- Sungrass
  [{12359}] = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 16},  -- Thorium Bar
  [{13463}] = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 6},   -- Dreamfoil
  [{13931}] = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 8},   -- Nightfin Soup
  [{16766}] = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 16},  -- Undermine Clam Chowder
  [{18045}] = {factionID = MERCHANT_FACTION_ID, rep = 950, cutoff = 8, count = 12},  -- Tender Wolf Steak
  
  [{7931}]  = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 3},  -- Mithril Coif
  [{10024}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 5},  -- Black Mageweave Headband
  [{10034}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 4},  -- Tuxedo Shirt
  [{10562}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 16},  -- Hi-Explosive Bomb
  [{12406}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 5},  -- Thorium Belt
  [{12655}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 4},  -- Enchanted Thorium Bar
  [{13443}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 6},  -- Superior Mana Potion
  [{13446}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 8},  -- Major Healing Potion
  [{15084}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 6},  -- Wicked Leather Bracers
  [{15564}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 12},  -- Rugged Armor Kit
  [{15993}] = {factionID = MERCHANT_FACTION_ID, rep = 1300, cutoff = 8, count = 3},  -- Thorium Grenade
  
  [{7938}]  = {factionID = MERCHANT_FACTION_ID, rep = 1850, cutoff = 8, count = 2},  -- Truesilver Gauntlets
  [{13856}] = {factionID = MERCHANT_FACTION_ID, rep = 1850, cutoff = 8, count = 6},  -- Runecloth Belt
  [{15092}] = {factionID = MERCHANT_FACTION_ID, rep = 1850, cutoff = 8, count = 5},  -- Runic Leather Bracers
  [{15995}] = {factionID = MERCHANT_FACTION_ID, rep = 1850, cutoff = 8, count = 2},  -- Thorium Rifle
} do
  local faction = GetFactionInfoByID(repInfo.factionID)
  if faction then
    repInfo.faction = faction
  end
  
  if Addon.MY_RACE_FILENAME == "Human" then
    repInfo.rep = mathFloor(repInfo.rep * 1.1)
  end
  for _, id in ipairs(ids) do
    Addon:Assertf(not reputationItems[id], "Duplicate reputation item: %d", id)
    reputationItems[id]       = repInfo
    Addon.waylaidSupplies[id] = true
  end
end




local stat = "Reputation"
function Addon:ShouldHideReputation(itemID)
  if self:GetOption("hide", stat) then return true end
  
  local repInfo = reputationItems[itemID]
  if not repInfo then return true end
  if self:GetOption("hide", "Reputation_waylaidSuppliesItems") and repInfo.count then return true end
  
  return false
end

function Addon:RewordReputation(itemID)
  local repInfo = reputationItems[itemID]
  if not repInfo then return end
  
  if not repInfo.faction then
    repInfo.faction = GetFactionInfoByID(repInfo.factionID)
  end
  
  local text = repInfo.faction
  if repInfo.cutoff then
    local standingID = select(3, GetFactionInfoByID(repInfo.factionID))
    text = text .. format(REPUTATION_CUTOFF_PATTERN, standingID < repInfo.cutoff and Addon.colors.GREEN or Addon.colors.RED, reputationStandings[standingID], reputationStandings[repInfo.cutoff])
  end
  if repInfo.count then
    text = text .. format(REP_COUNT_PATTERN, Addon:Round(repInfo.rep/repInfo.count, 1), repInfo.count, repInfo.rep)
  else
    text = text .. format(REP_PATTERN, repInfo.rep)
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


function Addon:AddReputation(tooltipData)
  if self:ShouldHideReputation(tooltipData.id) then return end
  
  local text = self:RewordReputation(tooltipData.id)
  if not text then return end
  
  local color = self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and self:GetOption("color", stat) or self:GetDefaultOption("color", stat)
  
  self:AddExtraLine(tooltipData, tooltipData.locs.description, text, color)
end

