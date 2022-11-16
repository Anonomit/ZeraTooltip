
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
  if not Addon:GetOption("allow", "reorder") then return end
  local stats = {
    BaseStat = {},
    SecondaryStat = {},
    EnchantOnUse = {},
    RequiredEnchantOnUse = {},
  }
  for i = #tooltipData, 1, -1 do
    if stats[tooltipData[i].type] then
      stats[tooltipData[i].type].location = i
      tinsert(stats[tooltipData[i].type], 1, tblRemove(tooltipData, i))
    end
  end
  if #stats.BaseStat + #stats.SecondaryStat == 0 then
    return
  end
  if not stats.BaseStat.location then
    stats.BaseStat.location = tooltipData.statStart + 1
  end
  if not stats.SecondaryStat.location then
    stats.SecondaryStat.location = tooltipData.secondaryStatStart + 1
  end
  if #stats.EnchantOnUse > 0 then
    tinsert(stats.SecondaryStat, tblRemove(stats.EnchantOnUse, 1))
  end
  if #stats.RequiredEnchantOnUse > 0 then
    tinsert(stats.SecondaryStat, tblRemove(stats.RequiredEnchantOnUse, 1))
  end
  
  if Addon:GetOption"combineStats" then
    while #stats.SecondaryStat > 0 do
      tinsert(stats.BaseStat, tblRemove(stats.SecondaryStat, 1))
      if tooltipData.Enchant then
        tooltipData.Enchant = tooltipData.Enchant + 1
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

function Addon:ReorderLines(tooltipData)
  
  SortStats(tooltipData)
  
  local offset = 0
  local enchantOffset = 1
  local i = 1
  while i <= #tooltipData do
    local line = tooltipData[i]
    
    if not line.hide then
      if (line.type == "ProposedEnchant" or line.type == "EnchantHint") and tooltipData.Enchant then
        if self:GetOption("doReorder", line.type) then
          tinsert(tooltipData, tooltipData.Enchant + enchantOffset, tblRemove(tooltipData, i))
          enchantOffset = enchantOffset + 1
        end
      elseif line.type == "Refundable" then
        if self:GetOption("doReorder", line.type) then
          tinsert(tooltipData, (tooltipData.binding or 2) + 1 + offset, tblRemove(tooltipData, i))
        end
      elseif line.type == "SoulboundTradeable" then
        if self:GetOption("doReorder", line.type) then
          tinsert(tooltipData, (tooltipData.binding or 2) + 1 + offset, tblRemove(tooltipData, i))
        end
      elseif line.type == "RequiredRaces" or line.type == "RequiredClasses" or line.type == "RequiredLevel" then
        if self:GetOption("doReorder", line.type) then
          tinsert(tooltipData, (tooltipData.title or 1) + 1, tblRemove(tooltipData, i))
          offset = offset + 1
        end
      end
    end
    
    i = i + 1
  end
  
end
