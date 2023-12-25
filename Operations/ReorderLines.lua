
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tinsert   = table.insert
local tblRemove = table.remove
local tblSort   = table.sort


local function GetStatSortValue(line)
  return line.stat and Addon.statOrder[line.stat] or 1000000 + line.i
end
local function StatSorter(a, b)
  return GetStatSortValue(a) < GetStatSortValue(b)
end

local function SortStats(tooltipData)
  local self = Addon
  if not self:GetOption("allow", "reorder") then return end
  
  local stats = {
    BaseStat             = {},
    SecondaryStat        = {},
    Charges              = {},
    Cooldown             = {},
    EnchantOnUse         = {},
    RequiredEnchantOnUse = {},
  }
  do
    local count = 0
    for i = #tooltipData, 1, -1 do
      if stats[tooltipData[i].type] then
        stats[tooltipData[i].type].location = i
        tinsert(stats[tooltipData[i].type], 1, tblRemove(tooltipData, i))
        count = count + 1
      end
    end
    if count == 0 then
      return
    end
    for i = #stats.RequiredEnchantOnUse, 1, -1 do
      tinsert(stats.EnchantOnUse, tblRemove(stats.RequiredEnchantOnUse, 1))
    end
  end
  stats.BaseStat.location      = stats.BaseStat.location      or tooltipData.embedLocs.statStart + 1
  stats.SecondaryStat.location = stats.SecondaryStat.location or tooltipData.embedLocs.secondaryStatStart + 1
  
  for i = #stats.Charges, 1, -1 do
    tinsert(stats[tooltipData.lastUse], tblRemove(stats.Charges, 1))
  end
  for i = #stats.Cooldown, 1, -1 do
    tinsert(stats[tooltipData.lastUse], tblRemove(stats.Cooldown, 1))
  end
  
  if self:GetOption("doReorder", "EnchantOnUse") then
    for i = #stats.EnchantOnUse, 1, -1 do
      tinsert(stats.SecondaryStat, tblRemove(stats.EnchantOnUse, 1))
    end
  end
  if self:GetOption"combineStats" then
    while #stats.SecondaryStat > 0 do
      tinsert(stats.BaseStat, tblRemove(stats.SecondaryStat, 1))
      self:BumpLocationsExact(tooltipData, 1, "enchant", "socketBonus")
    end
  end
  if not self:GetOption("doReorder", "EnchantOnUse") then
    for i = #stats.EnchantOnUse, 1, -1 do
      tinsert(stats.BaseStat, tblRemove(stats.EnchantOnUse, 1))
      
      self:BumpLocationsExact(tooltipData, 1, "socketBonus")
      if not self:GetOption"combineStats" and stats.SecondaryStat.location then
        stats.SecondaryStat.location = stats.SecondaryStat.location + 1
      end
    end
  end
  
  for _, statType in ipairs{"BaseStat", "SecondaryStat"} do
    local statTable = stats[statType]
    tblSort(statTable, StatSorter)
    while #statTable > 0 do
      tinsert(tooltipData, statTable.location, tblRemove(statTable, #statTable))
    end
  end
end


local function MoveLine(tooltipData, from, toLoc, offset)
  offset = offset or 0
  
  local loc      = tooltipData.locs[toLoc]
  local embedLoc = tooltipData.embedLocs[toLoc]
  
  local to = "embedLocs"
  if embedLoc + offset > tooltipData[from].i then
    to = "locs"
  end
  to = tooltipData[to][toLoc] + offset
  
  tinsert(tooltipData, to, tblRemove(tooltipData, from))
end


function Addon:ReorderLines(tooltipData)
  
  SortStats(tooltipData)
  
  local i = 1
  while i <= #tooltipData do
    local line = tooltipData[i]
    
    if (line.type == "ProposedEnchant" or line.type == "EnchantHint") then
      if self:GetOption("doReorder", line.type) then
        self:BumpLocationsExact(tooltipData, 1, "enchant", "socketBonus")
        MoveLine(tooltipData, i, "enchant")
      end
    elseif line.type == "RequiredRaces" or line.type == "RequiredClasses" or line.type == "RequiredLevel" then
      if self:GetOption("doReorder", line.type) then
        MoveLine(tooltipData, i, "quality", 1)
        self:BumpLocationsRange(tooltipData, tooltipData.locs.quality + 1)
      end
    elseif line.type == "SocketHint" then
      if self:GetOption("doReorder", line.type) then
        MoveLine(tooltipData, i, "socketBonus", 1)
      end
    elseif line.type == "Refundable" or line.type == "SoulboundTradeable" then
      if self:GetOption("doReorder", line.type) then
        MoveLine(tooltipData, i, "binding", 1)
      end
    end
    
    i = i + 1
  end
  
end
