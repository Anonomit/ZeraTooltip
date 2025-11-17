
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGsub  = string.gsub
local strMatch = string.match
local tinsert  = table.insert

local mathMax = math.max


--[[
1   Warrior       WARRIOR
2   Paladin       PALADIN
3   Hunter        HUNTER
4   Rogue         ROGUE
5   Priest        PRIEST
6   Death Knight  DEATHKNIGHT
7   Shaman        SHAMAN
8   Mage          MAGE
9   Warlock       WARLOCK
10  Monk          MONK
11  Druid         DRUID
12  Demon Hunter  DEMONHUNTER
13  Evoker        EVOKER
]]

local Enum_ClassID = {
  WARRIOR     = 1,
  PALADIN     = 2,
  HUNTER      = 3,
  ROGUE       = 4,
  PRIEST      = 5,
  DEATHKNIGHT = 6,
  SHAMAN      = 7,
  MAGE        = 8,
  WARLOCK     = 9,
  MONK        = 10,
  DRUID       = 11,
  DEMONHUNTER = 12,
  EVOKER      = 13,
}


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
local function GetItemLevelByClass(classLevels, default)
  return classLevels[Addon.MY_CLASS] or default or TableMax(classLevels)
end

local tokenOverrides = {}
for ids, ilvl in pairs{
  [{215390, 215417, 215386, 215388, 215419, 215392}] = 30, -- Waylaid Supplies
  [{215398, 215402, 215408, 215411}] = 35, -- Waylaid Supplies
  [{215415, 215403}] = 40, -- Waylaid Supplies
  [{217337}] = 30, -- Supply Shipment
  [{217338}] = 35, -- Supply Shipment
  [{221008, 221009, 221010}] = 45, -- Supply Shipment
  
  [{221299, 221289, 221280, 221272}] = 55, -- Darkmoon Decks (SoD)
  [{19228, 19257, 19267, 19277}] = 66, -- Darkmoon Decks
  
  [{209693, 211452}] = 33, -- Perfect Blackfathom Pearl
  
  [{217350, 217351}] = 45, -- Thermaplugg's Engineering Notes
  [{217008, 217009, 217007}] = 45, -- Gnomeregan Set (SoD)
  
  [{221346, 221363}] = 55, -- Scapula of the Fallen Avatar
  [{220637, 220636}] = 55, -- Sunken Temple Set (SoD)
  
  [{18422, 18423}] = 74, -- Head of Onyxia
  
  [{227532, 227537, 227535, 227531, 227533, 227530, 227534, 227536, 227764, 227762, 227766, 227760, 227759, 227761, 227763, 227765, 227755, 227752, 227758, 227750, 227756, 227751, 227754, 227757}] = 66, -- T1 (SoD)
  
  [{18665, 18646}] = 75, -- Benediction / Anathema
  [{18703, 18704, 18705}] = 75, -- Lok'delar, Rhok'delar, Lamina
  [{228129}] = 71, -- Shadowflame Sword
  [{17204, 227728}] = 80, -- Sulfuras
  [{18563, 18564}] = 80, -- Thunderfury
  
  [{231711, 231709, 231714, 231707, 231712, 231708, 231710, 231713, 231719, 231717, 231723, 231715, 231720, 231716, 231718, 231721, 231728, 231726, 231731, 231724, 231729, 231725, 231727, 231730}] = 76, -- T2 (SoD)
  
  [{19002, 19003}] = 83, -- Head of Nefarian
  
  [{19721}] = Addon:Ternary(Addon.isSoD, 65, 61), -- Primal Hakkari Shawl
  [{19724}] = Addon:Ternary(Addon.isSoD, 68, GetItemLevelByClass{
    [Enum_ClassID.HUNTER] = 68,
    [Enum_ClassID.ROGUE]  = 65,
    [Enum_ClassID.PRIEST] = 68,
  }), -- Primal Hakkari Aegis
  [{19723}] = Addon:Ternary(Addon.isSoD, 68, 65), -- Primal Hakkari Kossack
  [{19722}] = Addon:Ternary(Addon.isSoD, 68, 65), -- Primal Hakkari Tabard
  [{19717}] = Addon:Ternary(Addon.isSoD, 65, 61), -- Primal Hakkari Armsplint
  [{19716}] = Addon:Ternary(Addon.isSoD, 65, 61), -- Primal Hakkari Bindings
  [{19718}] = Addon:Ternary(Addon.isSoD, 65, 61), -- Primal Hakkari Stanchion
  [{19719}] = Addon:Ternary(Addon.isSoD, 65, 61), -- Primal Hakkari Girdle
  [{19720}] = Addon:Ternary(Addon.isSoD, 65, 61), -- Primal Hakkari Sash
  
  [{19939, 19940, 19941, 19942, 19819, 19820, 19818, 19814, 19821, 19816, 19817, 19813, 19815}] = 65, -- ZG Trinkets
  
  [{19802}] = 68, -- Heart of Hakkar
  
  [{20644}]  = 72, -- Nightmare Engulfed Object
  [{235049}] = 75, -- Nightmare Engulfed Object (SoD)
  
  [{20888}] = Addon:Ternary(Addon.isSoD, 74, 65), -- Qiraji Ceremonial Ring
  [{20884}] = Addon:Ternary(Addon.isSoD, 74, 65), -- Qiraji Magisterial Ring
  [{20885}] = Addon:Ternary(Addon.isSoD, 76, 67), -- Qiraji Martial Drape
  [{20889}] = Addon:Ternary(Addon.isSoD, 76, 67), -- Qiraji Regal Drape
  [{20890}] = Addon:Ternary(Addon.isSoD, 79, 70), -- Qiraji Ornate Hilt
  [{20886}] = Addon:Ternary(Addon.isSoD, 79, 70), -- Qiraji Spiked Hilt
  
  [{20220}]  = 70, -- Head of Ossirian the Unscarred
  [{235048}] = 77, -- Head of Ossirian the Unscarred (SoD)
  
  [{21237, 21232}] = 79, -- Imperial Qiraji Regalia, Imperial Qiraji Armaments
  [{20928}] = GetItemLevelByClass({
    [Enum_ClassID.WARRIOR] = 78,
    [Enum_ClassID.HUNTER]  = 81,
    [Enum_ClassID.ROGUE]   = 78,
    [Enum_ClassID.PRIEST]  = 78,
  }, 78), -- Qiraji Bindings of Command
  [{20932}] = 78, -- Qiraji Bindings of Dominance
  
  [{20930, 20926}] = 81, -- Vek'lor's Diadem, Vek'nilash's Circlet
  [{20927, 20931}] = 81, -- Ouro's Intact Hide, Skin of the Great Sandworm
  [{20929, 20933}] = 88, -- Carapace of the Old God, Husk of the Old God
  
  [{235046}] = 79, -- Imperial Qiraji Armaments (SoD)
  [{235045}] = 79, -- Imperial Qiraji Regalia (SoD)
  
  [{233371}] = 78, -- Qiraji Bindings of Sovereignty (SoD)
  [{233369}] = 78, -- Qiraji Bindings of Dominance (SoD)
  [{233370}] = GetItemLevelByClass({
    [Enum_ClassID.WARRIOR] = 78,
    [Enum_ClassID.HUNTER]  = 81,
    [Enum_ClassID.MAGE]    = 78,
  }, 78), -- Qiraji Bindings of Command (SoD),
  
  [{233368}] = 81, -- Intact Entrails (SoD)
  [{233365}] = 81, -- Intact Viscera (SoD)
  [{233367}] = 81, -- Intact Peritoneum (SoD)
  
  [{233364}] = 88, -- Skin of the Old God (SoD)
  [{233362}] = 88, -- Husk of the Old God (SoD)
  [{233363}] = 88, -- Carapace of the Old God (SoD)
  
  [{21221}] = 88, -- Eye of C'Thun
  
  [{22726, 22727, 22724, 22733, 22734}] = 90, -- Atiesh
  
  [{22367, 22360, 22353, 236241, 236236, 236249}] = 88, -- T3 Heads
  [{22368, 22361, 22354, 236240, 236237, 236254}] = 86, -- T3 Shoulders
  [{22351, 22350, 22349, 236242, 236231, 236251}] = 92, -- T3 Chests
  [{22369, 22362, 22355, 236245, 236235, 236247}] = 88, -- T3 Bracers
  [{22371, 22364, 22357, 236243, 236233, 236250}] = 88, -- T3 Gloves
  [{22370, 22363, 22356, 236244, 236232, 236252}] = 88, -- T3 Belts
  [{22366, 22359, 22352, 236246, 236238, 236253}] = 88, -- T3 Legs
  [{22372, 22365, 22358, 236239, 236234, 236248}] = 86, -- T3 Shoes
  
  [{22520, 236350}] = 90, -- The Phylactery of Kel'Thuzad
  
  [{242465, 239117, 239714, 239712, 239715, 239719, 239716, 239718, 239721, 239710, 239707, 239708, 239761, 239759, 239762, 239760, 239709, 239706, 239729, 239758, 239731, 239722, 239730, 239756, 239757, 239726}] = 98, -- T3.5 (Sod)
  
  [{239215}] = 96, -- Charred Emblem
  [{238945}] = 96, -- Caladbolg
  [{242365, 242364, 242366}] = 100, -- Strings of Fate
  [{239196, 239216, 239696}] = 100, -- Corrupted Ashbringer
  
  [{242425}] = 88,  -- Putress' Diary - Page 1
  [{242426}] = 90,  -- Putress' Diary - Page 2
  [{242428}] = 92,  -- Putress' Diary - Page 3
  [{242430}] = 94,  -- Putress' Diary - Page 4
  [{242431}] = 96,  -- Putress' Diary - Page 5
  [{242433}] = 100, -- Putress' Diary - Page 6
  
  
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
  
  [{71675, 71682, 71668, 71681, 71688, 71674}] = 378, -- T12 N
  [{71677, 71684, 71670, 71680, 71687, 71673, 71679, 71686, 71672, 71676, 71683, 71669, 71678, 71685, 71671}] = 391, -- T12 H
  
  [{71617}] = 391, -- Firestone
  
  [{78182, 78177, 78172, 78180, 78175, 78170, 78184, 78179, 78174, 78183, 78178, 78173, 78181, 78176, 78171}] = 397, -- T13 N
  [{78850, 78851, 78852, 78859, 78860, 78861, 78847, 78848, 78849, 78853, 78854, 78855, 78856, 78857, 78858}] = 410, -- T13 H
  
  [{89235, 89234, 89236, 89246, 89248, 89247, 89237, 89239, 89238, 89240, 89242, 89241, 89243, 89245, 89244}] = 496, -- T14 N
  [{89259, 89258, 89260, 89262, 89261, 89263, 89250, 89249, 89251, 89256, 89255, 89257, 89253, 89252, 89254}] = 509, -- T14 H
  
  [{95577, 95582, 95571, 95578, 95583, 95573, 95574, 95579, 95569, 95575, 95580, 95570, 95576, 95581, 95572}] = 522, -- T15 N
  [{96624, 96625, 96623, 96700, 96701, 96699, 96567, 96568, 96566, 96600, 96601, 96599, 96632, 96633, 96631}] = 535, -- T15 H
} do
  for _, id in ipairs(ids) do
    Addon:ThrowfAssert(not tokenOverrides[id], "Duplicate item level override: %d", id)
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

