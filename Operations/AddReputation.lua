
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
local WAYLAID_PATTERN           = format(" +%%d (%s) | +%%d (%s)", EMPTY or GLYPH_EMPTY or GLYPH_INACTIVE, LOC_TYPE_FULL or LOAD_FULL or SHAKE_INTENSITY_FULL)
local REPUTATION_CUTOFF_PATTERN = " (|cff%s%s/%s|r)"

local FACTION_ID = Addon.MY_FACTION == "Alliance" and 2586 or 2587


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
  [{211331, 210771, 211332, 211329, 211315, 211316, 211933, 211317, 211330}]                         = {factionID = FACTION_ID, min = 100, cutoff = 5, max = 300},
  [{211365}]                                                                                         = {factionID = FACTION_ID, min = 300, cutoff = 5},
  [{211327, 211328, 211319, 211326, 211325, 211934, 211321, 211318, 211322, 211324, 211323, 211320}] = {factionID = FACTION_ID, min = 100, cutoff = 5, max = 450},
  [{211367}]                                                                                         = {factionID = FACTION_ID, min = 450, cutoff = 5},
  [{211819, 211822, 211837, 211838, 211821, 211820, 211836, 211835, 211823}]                         = {factionID = FACTION_ID, min = 200, cutoff = 6, max = 500},
  [{211839}]                                                                                         = {factionID = FACTION_ID, min = 500, cutoff = 6},
  [{211831, 211833, 211824, 211828, 211825, 211829}]                                                 = {factionID = FACTION_ID, min = 200, cutoff = 6, max = 650},
  [{211840}]                                                                                         = {factionID = FACTION_ID, min = 650, cutoff = 6},
  [{211935, 211832, 211830, 211834, 211827, 211826}]                                                 = {factionID = FACTION_ID, min = 200, cutoff = 6, max = 800},
  [{211841}]                                                                                         = {factionID = FACTION_ID, min = 800, cutoff = 6},
  
  [{6290}]  = {factionID = FACTION_ID, min = 300, count = 20, cutoff = 5}, -- Brilliant Smallfish
  [{2840}]  = {factionID = FACTION_ID, min = 300, count = 20, cutoff = 5}, -- Copper Bar
  [{2581}]  = {factionID = FACTION_ID, min = 300, count = 10, cutoff = 5}, -- Heavy Linen Bandage
  [{6888}]  = {factionID = FACTION_ID, min = 300, count = 20, cutoff = 5}, -- Herb Baked Egg
  [{2318}]  = {factionID = FACTION_ID, min = 300, count = 14, cutoff = 5}, -- Light Leather
  [{2447}]  = {factionID = FACTION_ID, min = 300, count = 20, cutoff = 5}, -- Peacebloom
  [{2835}]  = {factionID = FACTION_ID, min = 300, count = 10, cutoff = 5}, -- Rough Stone
  [{765}]   = {factionID = FACTION_ID, min = 300, count = 20, cutoff = 5}, -- Silverleaf
  [{2680}]  = {factionID = FACTION_ID, min = 300, count = 20, cutoff = 5}, -- Spiced Wolf Meat
  
  [{4343}]  = {factionID = FACTION_ID, min = 450, count = 6,  cutoff = 5}, -- Brown Linen Pant
  [{6238}]  = {factionID = FACTION_ID, min = 450, count = 4,  cutoff = 5}, -- Brown Linen Robe
  [{2847}]  = {factionID = FACTION_ID, min = 450, count = 6,  cutoff = 5}, -- Copper Shortsword
  [{2300}]  = {factionID = FACTION_ID, min = 450, count = 3,  cutoff = 5}, -- Embossed Leather Vest
  [{4237}]  = {factionID = FACTION_ID, min = 450, count = 5,  cutoff = 5}, -- Handstitched Leather Boots
  [{929}]   = {factionID = FACTION_ID, min = 450, count = 10, cutoff = 5}, -- Healing Potion
  [{11287}] = {factionID = FACTION_ID, min = 450, count = 2,  cutoff = 5}, -- Lesser Magic Wand
  [{118}]   = {factionID = FACTION_ID, min = 450, count = 20, cutoff = 5}, -- Minor Healing Potion
  [{20744}] = {factionID = FACTION_ID, min = 450, count = 2,  cutoff = 5}, -- Minor Wizard Oil
  [{4362}]  = {factionID = FACTION_ID, min = 450, count = 3,  cutoff = 5}, -- Rough Boomsticks
  [{4360}]  = {factionID = FACTION_ID, min = 450, count = 12, cutoff = 5}, -- Rough Copper Bomb
  [{3473}]  = {factionID = FACTION_ID, min = 450, count = 3,  cutoff = 5}, -- Runed Copper Pants
  
  [{2841}]  = {factionID = FACTION_ID, min = 500, count = 12, cutoff = 6}, -- Bronze Bar
  [{2453}]  = {factionID = FACTION_ID, min = 500, count = 20, cutoff = 6}, -- Bruiseweed
  [{5527}]  = {factionID = FACTION_ID, min = 500, count = 8,  cutoff = 6}, -- Goblin Deviled Clam
  [{3531}]  = {factionID = FACTION_ID, min = 500, count = 15, cutoff = 6}, -- Heavy Wool Bandage
  [{2319}]  = {factionID = FACTION_ID, min = 500, count = 12, cutoff = 6}, -- Medium Leather
  [{2842}]  = {factionID = FACTION_ID, min = 500, count = 6,  cutoff = 6}, -- Silver Bar
  [{6890}]  = {factionID = FACTION_ID, min = 500, count = 20, cutoff = 6}, -- Smoked Bear Meat
  [{21072}] = {factionID = FACTION_ID, min = 500, count = 15, cutoff = 6}, -- Smoked Sagefish
  [{2452}]  = {factionID = FACTION_ID, min = 500, count = 20, cutoff = 6}, -- Swiftthistle
  
  [{2316}]  = {factionID = FACTION_ID, min = 650, count = 2,  cutoff = 6}, -- Dark Leather Cloak
  [{2587}]  = {factionID = FACTION_ID, min = 650, count = 4,  cutoff = 6}, -- Gray Woolen Shirt
  [{3385}]  = {factionID = FACTION_ID, min = 650, count = 20, cutoff = 6}, -- Lesser Mana Potion
  [{20745}] = {factionID = FACTION_ID, min = 650, count = 2,  cutoff = 6}, -- Minor Mana Oil
  [{6350}]  = {factionID = FACTION_ID, min = 650, count = 3,  cutoff = 6}, -- Rough Bronze Boots
  [{4374}]  = {factionID = FACTION_ID, min = 650, count = 12, cutoff = 6}, -- Small Bronze Bomb
  
  [{6373}]  = {factionID = FACTION_ID, min = 800, count = 15, cutoff = 6}, -- Elixir of Firepower
  [{4251}]  = {factionID = FACTION_ID, min = 800, count = 2,  cutoff = 6}, -- Hillman's Shoulders
  [{5507}]  = {factionID = FACTION_ID, min = 800, count = 2,  cutoff = 6}, -- Ornate Spyglass
  [{5542}]  = {factionID = FACTION_ID, min = 800, count = 3,  cutoff = 6}, -- Pearl-clasped Cloak
  [{6339}]  = {factionID = FACTION_ID, min = 800, count = 1,  cutoff = 6}, -- Runed Silver Rod
  [{15869}] = {factionID = FACTION_ID, min = 800, count = 14, cutoff = 6}, -- Silver Skeleton Key
} do
  local faction = GetFactionInfoByID(repInfo.factionID)
  if faction then
    repInfo.faction = faction
  end
  
  if Addon.MY_RACE_FILENAME == "Human" then
    for _, k in ipairs{"min", "max"} do
      local rep = repInfo[k]
      if rep then
        repInfo[k] = mathFloor(rep * 1.1)
      end
    end
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
  if repInfo.max then
    text = text .. format(WAYLAID_PATTERN, repInfo.min, repInfo.max)
  elseif repInfo.count then
    text = text .. format(REP_COUNT_PATTERN, Addon:Round(repInfo.min/repInfo.count, 1), repInfo.count, repInfo.min)
  else
    text = text .. format(REP_PATTERN, repInfo.min)
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

