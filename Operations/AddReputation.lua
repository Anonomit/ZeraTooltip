
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
  [{217337, 215390, 215417, 215389, 215391, 215386, 215387, 215388, 215420, 215421, 215419, 215400, 215392, 215418}] = {factionID = MERCHANT_FACTION_ID, rep = 700,  cutoff = 7},
  [{217338, 215393, 215385, 215398, 215415, 215401, 215402, 215407, 215408, 215414, 215411, 215399, 215395, 215403}] = {factionID = MERCHANT_FACTION_ID, rep = 850,  cutoff = 7},
  [{217339, 215397, 215409, 215396, 215416, 215404}]                                                                 = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7},
  
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
  
  [{3358}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 20},  -- Khadgar's Whisker
  [{3729}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Soothing Turtle Bisque
  [{3818}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 16},  -- Fadeleaf
  [{3819}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 20},  -- Wintersbite
  [{3860}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 6},   -- Mithril Bar
  [{4235}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 5},   -- Heavy Hide
  [{4304}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Thick Leather
  -- [{4334}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 3},   -- Formal White Shirt
  [{4594}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 40},  -- Rockscale Cod
  [{6371}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Fire Oil
  [{6451}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Heavy Silk Bandage
  [{7966}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Solid Grinding Stone
  [{8831}]  = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 8},   -- Purple Lotus
  [{17222}] = {factionID = MERCHANT_FACTION_ID, rep = 700, cutoff = 7, count = 10},  -- Spider Sausage
  
  [{1710}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 16},  -- Greater Healing Potion
  [{3577}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Gold Bar
  [{3835}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 5},   -- Green Iron Bracers
  [{4335}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 5},   -- Rich Purple Silk Shirt
  [{4391}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 2},   -- Compact Harvest Reaper Kit
  [{4394}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 8},   -- Big Iron Bomb
  [{5964}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Barbaric Shoulders
  [{5966}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 6},   -- Guardian Gloves
  [{7062}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Crimson Silk Pantaloons
  [{7377}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 3},   -- Frost Leather Cloak
  [{7919}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Heavy Mithril Gauntlet
  [{8949}]  = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 12},  -- Elixir of Agility
  [{10546}] = {factionID = MERCHANT_FACTION_ID, rep = 850, cutoff = 7, count = 4},   -- Deadly Scope
  
  [{3855}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 2},  -- Massive Iron Axe
  [{8198}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 3},  -- Turtle Scale Bracers
  [{8951}]  = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 14}, -- Elixir of Greater Defense
  [{10008}] = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 4},  -- White Bandit Mask
  [{10508}] = {factionID = MERCHANT_FACTION_ID, rep = 1000, cutoff = 7, count = 2},  -- Mithril Blunderbuss
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
function Addon:RewordReputation(itemID)
  local repInfo = reputationItems[itemID]
  if not repInfo then return end
  
  if not repInfo.faction then
    repInfo.faction = GetFactionInfoByID(repInfo.factionID)
  end
  
  local text = repInfo.faction
  if repInfo.cutoff then
    local standingID = select(3, GetFactionInfoByID(repInfo.factionID))
    text = text .. format(REPUTATION_CUTOFF_PATTERN, standingID < repInfo.cutoff and Addon.COLORS.GREEN or Addon.COLORS.RED, reputationStandings[standingID], reputationStandings[repInfo.cutoff])
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
  if self:GetOption("hide", stat) then return end
  
  local text = self:RewordReputation(tooltipData.id)
  if not text then return end
  
  local color = self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and self:GetOption("color", stat) or self:GetDefaultOption("color", stat)
  
  self:AddExtraLine(tooltipData, tooltipData.locs.description, text, color)
end

