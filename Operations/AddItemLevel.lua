
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strMatch = string.match
local tinsert  = table.insert


local invTypeBlacklist = Addon:MakeLookupTable{"", "INVTYPE_BAG", "INVTYPE_TABARD", "INVTYPE_BODY"}

local tokenOverrides = {}

for ids, ilvl in pairs({
  [{40610, 40611, 40612, 40613, 40614, 40615, 40616, 40617, 40618, 40619, 40620, 40621, 40622, 40623, 40624}] = 200, -- T7 10
  [{40625, 40626, 40627, 40628, 40629, 40630, 40631, 40632, 40633, 40634, 40635, 40636, 40637, 40638, 40639}] = 213, -- T7 25
  [{44569}] = 213, -- Key to the Focusing Iris 10
  [{44581}] = 226, -- Key to the Focusing Iris 25
  
  [{45635, 45636, 45637, 45644, 45645, 45646, 45647, 45648, 45649, 45650, 45651, 45652, 45659, 45660, 45661}] = 225, -- T8 10
  [{45632, 45633, 45634, 45638, 45639, 45640, 45653, 45654, 45655, 45641, 45642, 45643, 45656, 45657, 45658}] = 232, -- T8 25
  [{46052}] = 226, -- Reply-Code Alpha 10
  [{46053}] = 239, -- Reply-Code Alpha 25
  [{45038}] = 258, -- Fragment of Val'anyr
}) do
  for _, id in ipairs(ids) do
    tokenOverrides[id] = ilvl
  end
end



local stat = "ItemLevel"

Addon.itemLevelTexts = {
  [true] = {
    iLvlFormat = GARRISON_FOLLOWER_ITEM_LEVEL,
  },
  [false] = {
    iLvlFormat = ITEM_LEVEL,
  },
}
for bool, t in pairs(Addon.itemLevelTexts) do
  t.iLvlText    = strMatch(t.iLvlFormat, "(.-) *%%")
  t.coveredText = Addon:CoverSpecialCharacters(t.iLvlText)
  t.emptyText   = t.iLvlText .. " *"
end

function Addon:RewordItemLevel(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      local t = self.itemLevelTexts[self:GetOption("itemLevel", "useShortName")]
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, t.emptyText, alias)
      elseif alias ~= t.coveredText then
        text = strGsub(text, t.coveredText, alias)
      end
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


function Addon:AddItemLevel(tooltipData)
  if self:GetOption("hide", stat) then return end
  local equipLoc = select(4, GetItemInfoInstant(tooltipData.id))
  if not (self:GetOption("hide", "nonEquipment") and invTypeBlacklist[equipLoc]) or tokenOverrides[tooltipData.id] then
    local itemLevel = tokenOverrides[tooltipData.id] or select(4, GetItemInfo(tooltipData.id))
    if not itemLevel then return end
    local color = self:GetDefaultOption("color", stat)
    if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) then
      color = self:GetOption("color", stat)
    end
    self:AddExtraLine(tooltipData, self:GetOption("doReorder", stat) and tooltipData.itemLevel or tooltipData.title, self:RewordItemLevel(format(self.itemLevelTexts[self:GetOption("itemLevel", "useShortName")].iLvlFormat, itemLevel)), color)
  end
end

