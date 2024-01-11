
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
local WAYLAID_PATTERN           = format(" +%%d (%s) | +%%d (%s)", EMPTY or GLYPH_EMPTY or GLYPH_INACTIVE, LOC_TYPE_FULL or LOAD_FULL or SHAKE_INTENSITY_FULL)
local REPUTATION_CUTOFF_PATTERN = " (|cff%s%s/%s|r)"



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
  [{211331, 210771, 211332, 211329, 211315, 211316, 211933, 211317, 211330}]                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 100, cutoff = 5, max = 300},
  [{211365}]                                                                                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 300, cutoff = 5},
  [{211327, 211328, 211319, 211326, 211325, 211934, 211321, 211318, 211322, 211324, 211323, 211320}] = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 100, cutoff = 5, max = 450},
  [{211367}]                                                                                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 450, cutoff = 5},
  [{211819, 211822, 211837, 211838, 211821, 211820, 211836, 211835, 211823}]                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 200, cutoff = 6, max = 500},
  [{211839}]                                                                                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 500, cutoff = 6},
  [{211831, 211833, 211824, 211828, 211825, 211829}]                                                 = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 200, cutoff = 6, max = 650},
  [{211840}]                                                                                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 650, cutoff = 6},
  [{211935, 211832, 211830, 211834, 211827, 211826}]                                                 = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 200, cutoff = 6, max = 800},
  [{211841}]                                                                                         = {factionID = Addon.MY_FACTION == "Alliance" and 2586 or 2587, min = 800, cutoff = 6},
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

