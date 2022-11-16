
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strMatch = string.match
local tinsert  = table.insert


local tokenOverrides = {}

for ilvl, ids in pairs({
  [200] = {40610, 40611, 40612, 40613, 40614, 40615, 40616, 40617, 40618, 40619, 40620, 40621, 40622, 40623, 40624}, -- T7 10m
  [213] = {40625, 40626, 40627, 40628, 40629, 40630, 40631, 40632, 40633, 40634, 40635, 40636, 40637, 40638, 40639, 44569}, -- T7 25m, Key to the Focusing Iris 10m
  [219] = {45635, 45636, 45637, 45644, 45645, 45646, 45647, 45648, 45649, 45650, 45651, 45652, 45659, 45660, 45661}, -- T8 10m
  [226] = {45632, 45633, 45634, 45638, 45639, 45640, 45653, 45654, 45655, 45641, 45642, 45643, 45656, 45657, 45658, 44581, 46052}, -- T8 25m, Key to the Focusing Iris 25m, Reply-Code Alpha 10m
  [239] = {46053}, -- Reply-Code Alpha 25m
  [245] = {45038}, -- Fragment of Val'anyr
}) do
  for _, id in ipairs(ids) do
    tokenOverrides[id] = ilvl
  end
end



local stat = "ItemLevel"

local iLvlText    = strMatch(GARRISON_FOLLOWER_ITEM_LEVEL, "(.-) *%%")
local coveredText = Addon:CoverSpecialCharacters(iLvlText)
local emptyText   = iLvlText .. " *"



function Addon:RewordItemLevel(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, emptyText, alias)
      elseif alias ~= prefix then
        text = strGsub(text, coveredText, alias)
      end
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


function Addon:AddItemLevel(tooltipData)
  if self:GetOption("hide", stat) then return end
  local equipLoc = select(4, GetItemInfoInstant(tooltipData.id))
  if equipLoc ~= "" or tokenOverrides[tooltipData.id] then
    local itemLevel = tokenOverrides[tooltipData.id] or select(4, GetItemInfo(tooltipData.id))
    local color = self:GetDefaultOption("color", stat)
    if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) then
      color = self:GetOption("color", stat)
    end
    self:AddExtraLine(tooltipData, tooltipData.title or 1, self:RewordItemLevel(format(GARRISON_FOLLOWER_ITEM_LEVEL, itemLevel)), color)
  end
end

