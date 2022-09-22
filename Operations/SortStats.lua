
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

function Addon:SortStats(tooltipData)
  if not self:GetOption("allow", "reorder") then return end
  local stats = {
    BaseStat = {},
    SecondaryStat = {},
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
  
  -- TODO: bring padding if needed?
  -- if (tooltipData[stats.BaseStat.location + 1] or {}).type ~= "Padding" then
  --   if (tooltipData[(stats.SecondaryStat.location or -1) + 1] or {}).type == "Padding" then
  --     tinsert(tooltipData[stats.SecondaryStat.location + 1], tblRemove(tooltipData, stats.SecondaryStat.location + 1))
  --   end
  -- end
  
  if self:GetOption"combineStats" then
    while #stats.SecondaryStat > 0 do
      tinsert(stats.BaseStat, tblRemove(stats.SecondaryStat, 1))
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
