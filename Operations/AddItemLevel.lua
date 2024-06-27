
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strMatch = string.match
local tinsert  = table.insert

local mathMax = math.max

local invTypeBlacklist = Addon:MakeLookupTable{"", "INVTYPE_NON_EQUIP_IGNORE", "INVTYPE_BAG", "INVTYPE_TABARD", "INVTYPE_BODY"}


local function TableMax(t)
  local key, val = next(t)
  local max = val
  repeat
      max = mathMax(max, val)
      key, val = next(t, key)
  until not val
  return max
end
local function GetItemLevelByClass(classLevels)
  return classLevels[Addon.MY_CLASS] or TableMax(classLevels)
end

local tokenOverrides = {}
for ids, ilvl in pairs{
  [{215390, 215417, 215386, 215388, 215419, 215392}] = 30, -- Waylaid Supplies
  [{215398, 215402, 215408, 215411}] = 35, -- Waylaid Supplies
  [{215415, 215403}] = 40, -- Waylaid Supplies
  [{217337}] = 30, -- Supply Shipment
  [{217338}] = 35, -- Supply Shipment
  [{281008, 281009, 281010}] = 45, -- Supply Shipment
  
  [{209693, 211452}] = 33, -- Perfect Blackfathom Pearl
  
  [{18665, 18646}] = 75, -- Benediction / Anathema
  [{18703, 18704, 18705}] = 75, -- Lok'delar, Rhok'delar, Lamina
  [{17204}] = 80, -- Sulfuras
  [{18563, 18564}] = 80, -- Thunderfury
  
  [{18422, 18423}] = 74, -- Head of Onyxia
  
  [{19002, 19003}] = 83, -- Head of Nefarian
  
  [{19721}] = 61, -- Primal Hakkari Shawl
  [{19724}] = GetItemLevelByClass{
    [3] = 68,
    [4] = 65,
    [5] = 68,
  }, -- Primal Hakkari Aegis
  [{19723}] = 65, -- Primal Hakkari Kossack
  [{19722}] = 65, -- Primal Hakkari Tabard
  [{19717}] = 61, -- Primal Hakkari Armsplint
  [{19716}] = 61, -- Primal Hakkari Bindings
  [{19718}] = 61, -- Primal Hakkari Stanchion
  [{19719}] = 61, -- Primal Hakkari Girdle
  [{19720}] = 61, -- Primal Hakkari Sash
  
  [{19939, 19940, 19941, 19942, 19819, 19820, 19818, 19814, 19821, 19816, 19817, 19813, 19815}] = 65, -- ZG Trinkets
  
  [{19802}] = 68, -- Heart of Hakkar
  
  [{20888}] = 65, -- Qiraji Ceremonial Ring
  [{20884}] = 65, -- Qiraji Magisterial Ring
  [{20885}] = 67, -- Qiraji Martial Drape
  [{20889}] = 67, -- Qiraji Regal Drape
  [{20890}] = 70, -- Qiraji Ornate Hilt
  [{20886}] = 70, -- Qiraji Spiked Hilt
  
  [{20220}] = 70, -- Head of Ossirian the Unscarred
  
  [{21237}] = 79, -- Imperial Qiraji Regalia
  [{21232}] = 79, -- Imperial Qiraji Armaments
  [{20928}] = GetItemLevelByClass{
    [1] = 78,
    [3] = 81,
    [4] = 78,
    [5] = 78,
  }, -- Qiraji Bindings of Command
  [{20932}] = 78, -- Qiraji Bindings of Dominance
  
  [{20930, 20926}] = 81, -- Vek'lor's Diadem, Vek'nilash's Circlet
  [{20927, 20931}] = 81, -- Ouro's Intact Hide, Skin of the Great Sandworm
  [{20929, 20933}] = 88, -- Carapace of the Old God, Husk of the Old God
  
  [{21221}] = 88, -- Eye of C'Thun
  
  [{22726, 22727, 22724, 22733}] = 90, -- Atiesh
  
  [{22369, 22362, 22355}] = 88, -- T3 Bracers
  [{22371, 22364, 22357}] = 88, -- T3 Gloves
  [{22370, 22363, 22356}] = 88, -- T3 Belts
  [{22366, 22359, 22352}] = 88, -- T3 Legs
  [{22372, 22365, 22358}] = 86, -- T3 Shoes
  [{22351, 22350, 22349}] = 92, -- T3 Chests
  [{22368, 22361, 22354}] = 86, -- T3 Shoulders
  [{22367, 22360, 22353}] = 88, -- T3 Heads
  
  [{22520}] = 90, -- The Phylactery of Kel'Thuzad
  
  
  
  [{29757, 29758, 29756, 29760, 29761, 29759, 29763, 29764, 29762, 29766, 29767, 29765, 29754, 29753, 29755}] = 120, -- T4
  
  [{32385, 32386}] = 125, -- Magtheridon's Head
  
  [{30239, 30240, 30241, 30245, 30246, 30247, 30242, 30243, 30244, 30248, 30249, 30250, 30236, 30237, 30238}] = 133, -- T5
  
  [{32405}] = 138, -- Verdant Sphere
  
  [{31092, 31094, 31093, 31097, 31095, 31096, 31101, 31103, 31102, 31098, 31100, 31099, 31089, 31091, 31090}] = 146, -- T6 BT/Hyjal
  [{34848, 34851, 34852, 34853, 34854, 34855, 34856, 34857, 34858}] = 154, -- T6 SWP
  
  
  
  [{40610, 40611, 40612, 40613, 40614, 40615, 40616, 40617, 40618, 40619, 40620, 40621, 40622, 40623, 40624}] = 200, -- T7 10
  [{40625, 40626, 40627, 40628, 40629, 40630, 40631, 40632, 40633, 40634, 40635, 40636, 40637, 40638, 40639}] = 213, -- T7 25
  [{44569}] = 213, -- Key to the Focusing Iris 10
  [{44581}] = 226, -- Key to the Focusing Iris 25
  
  [{45635, 45636, 45637, 45644, 45645, 45646, 45647, 45648, 45649, 45650, 45651, 45652, 45659, 45660, 45661}] = 225, -- T8 10
  [{45632, 45633, 45634, 45638, 45639, 45640, 45653, 45654, 45655, 45641, 45642, 45643, 45656, 45657, 45658}] = 232, -- T8 25
  [{46052}] = 239, -- Reply-Code Alpha 10
  [{46053}] = 252, -- Reply-Code Alpha 25
  [{45038}] = 258, -- Fragment of Val'anyr
  
  [{47242}] = 245, -- T9 10H / 25 / 25H
  [{47557, 47558, 47559}] = 258, -- T9 25H
  
  [{49643, 49644}] = 245, -- Head of Onyxia
  
  [{52025, 52026, 52027}] = 264, -- T10 10H / 25 / 25H
  [{52028, 52029, 52030}] = 277, -- T10 25H
  [{50274, 49869, 50226, 50231}] = 284, -- Shadowmourne
  
  [{63683, 63684, 63682, 64315, 64316, 64314}] = 359, -- T11 N
  [{67429, 67430, 67431, 67428, 67427, 67426, 65001, 65000, 65002, 67423, 67424, 67425, 65088, 65087, 65089, 66998}] = 372, -- T11 H
} do
  for _, id in ipairs(ids) do
    Addon:Assertf(not tokenOverrides[id], "Duplicate item level override: %d", id)
    tokenOverrides[id] = ilvl
  end
end



local stat = "ItemLevel"

Addon.itemLevelTexts = {
  [true] = {
    iLvlFormat = Addon.L["iLvl %d"],
  },
  [false] = {
    iLvlFormat = Addon.L["Item Level %d"],
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
  
  local tokenOverride = tokenOverrides[tooltipData.id]
  
  if Addon.waylaidSupplies[tooltipData.id] then
    if self:GetOption("itemLevel", "showWaylaidSupplies") then
      -- success
    else
      return
    end
  elseif tokenOverride then
    -- success
  elseif self:GetOption("hide", "nonEquipment") then
    local equipLoc = select(4, GetItemInfoInstant(tooltipData.id))
    if invTypeBlacklist[equipLoc] then
      return
    end
  end
  
  local itemLevel = tokenOverride or select(4, GetItemInfo(tooltipData.id))
  if not itemLevel then return end
  
  local color = self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and self:GetOption("color", stat) or self:GetDefaultOption("color", stat)
  
  self:AddExtraLine(tooltipData, self:GetOption("doReorder", stat) and tooltipData.locs.itemLevel or tooltipData.locs.quality, self:RewordItemLevel(format(self.itemLevelTexts[self:GetOption("itemLevel", "useShortName")].iLvlFormat, itemLevel)), color)
end

