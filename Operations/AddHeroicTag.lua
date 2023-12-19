
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub = string.gsub
local tinsert = table.insert


local heroicItems = Addon:MakeLookupTable{
  -- Original Wrath
  --[[
  44964, 46964, 46965, 46966, 46967, 46968, 46969, 46971, 46973, 46975, 46977,
  46980, 46986, 46989, 46991, 46993, 46995, 47001, 47002, 47003, 47004, 47059,
  47060, 47061, 47062, 47063, 47064, 47066, 47067, 47068, 47074, 47075, 47076,
  47077, 47078, 47084, 47085, 47086, 47087, 47088, 47095, 47096, 47097, 47098,
  47099, 47109, 47110, 47111, 47112, 47113, 47129, 47130, 47131, 47132, 47133,
  47143, 47144, 47145, 47146, 47147, 47153, 47154, 47155, 47156, 47157, 47188,
  47189, 47190, 47191, 47192, 47205, 47206, 47207, 47208, 47209, 47224, 47236,
  47237, 47238, 47239, 47240, 47412, 47413, 47414, 47415, 47416, 47417, 47418,
  47419, 47420, 47421, 47422, 47423, 47424, 47425, 47426, 47427, 47428, 47429,
  47430, 47431, 47432, 47433, 47434, 47435, 47436, 47437, 47438, 47439, 47440,
  47441, 47442, 47443, 47444, 47445, 47446, 47447, 47448, 47449, 47450, 47451,
  47452, 47453, 47454, 47455, 47456, 47457, 47458, 47459, 47460, 47461, 47462,
  47463, 47464, 47465, 47466, 47467, 47468, 47469, 47470, 47471, 47472, 47473,
  47474, 47475, 47476, 47477, 47478, 47479, 47480, 47481, 47482, 47483, 47484,
  47485, 47486, 47487, 47489, 47490, 47491, 47492, 47506, 47513, 47515, 47516,
  47517, 47518, 47519, 47520, 47521, 47523, 47524, 47525, 47526, 47528, 47545,
  47546, 47547, 47548, 47549, 47550, 47551, 47552, 47553, 47554, 47758, 47759,
  47760, 47761, 47762, 47763, 47764, 47765, 47766, 47767, 47788, 47789, 47790,
  47791, 47792, 47793, 47794, 47795, 47796, 47797, 47915, 47916, 47917, 47918,
  47919, 47920, 47921, 47922, 47923, 47924, 47925, 47926, 47927, 47928, 47929,
  47930, 47931, 47932, 47933, 47934, 47935, 47937, 47938, 47939, 47940, 47941,
  47942, 47943, 47944, 47945, 47946, 47947, 47948, 47949, 47950, 47951, 47952,
  47953, 47954, 47955, 47956, 47957, 47958, 47959, 47960, 47961, 47962, 47963,
  47964, 47965, 47966, 47967, 47968, 47969, 47970, 47971, 47972, 47973, 47974,
  47975, 47976, 47977, 47978, 47979, 47988, 47989, 47990, 47991, 47992, 47993,
  47994, 47995, 47996, 47997, 47998, 47999, 48000, 48001, 48002, 48003, 48004,
  48005, 48006, 48007, 48008, 48009, 48010, 48011, 48012, 48013, 48014, 48015,
  48016, 48017, 48018, 48019, 48020, 48021, 48022, 48023, 48024, 48025, 48026,
  48027, 48028, 48029, 48030, 48031, 48032, 48033, 48034, 48035, 48036, 48037,
  48038, 48039, 48040, 48041, 48042, 48043, 48044, 48045, 48046, 48047, 48048,
  48049, 48050, 48051, 48052, 48053, 48054, 48055, 48056, 48057, 48058, 48059,
  48060, 48061, 48082, 48083, 48084, 48085, 48086, 48087, 48088, 48089, 48090,
  48091, 48138, 48139, 48140, 48141, 48142, 48143, 48144, 48145, 48146, 48147,
  48168, 48169, 48170, 48171, 48172, 48173, 48174, 48175, 48176, 48177, 48198,
  48199, 48200, 48201, 48202, 48203, 48204, 48205, 48206, 48207, 48228, 48229,
  48230, 48231, 48232, 48233, 48234, 48235, 48236, 48237, 48260, 48261, 48262,
  48263, 48264, 48265, 48266, 48267, 48268, 48269, 48290, 48291, 48292, 48293,
  48294, 48305, 48306, 48307, 48308, 48309, 48321, 48322, 48323, 48324, 48325,
  48326, 48327, 48328, 48329, 48330, 48351, 48352, 48353, 48354, 48355, 48356,
  48357, 48358, 48359, 48360, 48381, 48382, 48383, 48384, 48385, 48396, 48397,
  48398, 48399, 48400, 48433, 48447, 48451, 48453, 48455, 48466, 48467, 48468,
  48469, 48470, 48486, 48487, 48488, 48489, 48490, 48491, 48492, 48493, 48494,
  48495, 48543, 48544, 48545, 48546, 48547, 48548, 48549, 48550, 48551, 48552,
  48580, 48581, 48582, 48583, 48584, 48585, 48586, 48587, 48588, 48589, 48612,
  48613, 48614, 48615, 48616, 48617, 48618, 48619, 48620, 48621, 48642, 48643,
  48644, 48645, 48646, 48647, 48648, 48649, 48650, 48651, 48666, 48667, 48668,
  48669, 48670, 48671, 48672, 48673, 48674, 48675, 48693, 48695, 48697, 48699,
  48701, 48703, 48705, 48708, 48709, 48710, 48711, 48712, 48713, 48714, 49233,
  49234, 49237, 49238, 49686, 49717, 49721, 49724, 49725, 49727, 49729, 49731,
  49734, 49736, 49737, 49738, 49761, 49762, 49777, 50224, 50225, 50343, 50344,
  50345, 50346, 50348, 50349, 50363, 50364, 50365, 50366, 50603, 50604, 50605,
  50606, 50607, 50608, 50609, 50610, 50611, 50612, 50613, 50614, 50615, 50616,
  50617, 50618, 50619, 50620, 50621, 50622, 50623, 50624, 50625, 50626, 50627,
  50628, 50629, 50630, 50631, 50632, 50633, 50635, 50636, 50638, 50639, 50640,
  50641, 50642, 50643, 50644, 50645, 50646, 50647, 50648, 50649, 50650, 50651,
  50652, 50653, 50654, 50655, 50656, 50657, 50658, 50659, 50660, 50661, 50663,
  50664, 50665, 50667, 50668, 50670, 50671, 50672, 50673, 50674, 50675, 50676,
  50677, 50678, 50679, 50680, 50681, 50682, 50684, 50685, 50686, 50687, 50688,
  50689, 50690, 50691, 50692, 50693, 50694, 50695, 50696, 50697, 50698, 50699,
  50700, 50701, 50702, 50703, 50704, 50705, 50706, 50707, 50708, 50709, 50710,
  50711, 50712, 50713, 50714, 50715, 50716, 50717, 50718, 50719, 50720, 50721,
  50722, 50723, 50724, 50725, 50726, 50727, 50728, 50729, 50730, 50731, 50732,
  50733, 50734, 50735, 50736, 50737, 50738, 51028, 51220, 51221, 51222, 51223,
  51224, 51225, 51226, 51227, 51228, 51229, 51230, 51231, 51232, 51233, 51234,
  51235, 51236, 51237, 51238, 51239, 51240, 51241, 51242, 51243, 51244, 51245,
  51246, 51247, 51248, 51249, 51250, 51251, 51252, 51253, 51254, 51255, 51256,
  51257, 51258, 51259, 51260, 51261, 51262, 51263, 51264, 51265, 51266, 51267,
  51268, 51269, 51270, 51271, 51272, 51273, 51274, 51275, 51276, 51277, 51278,
  51279, 51280, 51281, 51282, 51283, 51284, 51285, 51286, 51287, 51288, 51289,
  51290, 51291, 51292, 51293, 51294, 51295, 51296, 51297, 51298, 51299, 51300,
  51301, 51302, 51303, 51304, 51305, 51306, 51307, 51308, 51309, 51310, 51311,
  51312, 51313, 51314, 51811, 51812, 51813, 51814, 51815, 51816, 51817, 51818,
  51819, 51820, 51821, 51822, 51823, 51824, 51825, 51826, 51827, 51828, 51829,
  51830, 51831, 51832, 51833, 51834, 51835, 51836, 51837, 51838, 51839, 51840,
  51841, 51842, 51843, 51844, 51845, 51846, 51847, 51848, 51849, 51850, 51851,
  51852, 51853, 51854, 51855, 51856, 51857, 51858, 51859, 51860, 51861, 51862,
  51863, 51864, 51865, 51866, 51867, 51868, 51869, 51870, 51871, 51872, 51873,
  51874, 51875, 51876, 51877, 51878, 51879, 51880, 51881, 51882, 51883, 51884,
  51885, 51886, 51887, 51888, 51889, 51890, 51891, 51892, 51893, 51894, 51895,
  51896, 51897, 51898, 51899, 51900, 51901, 51902, 51903, 51904, 51905, 51906,
  51907, 51908, 51909, 51910, 51911, 51912, 51913, 51914, 51915, 51916, 51917,
  51918, 51919, 51920, 51921, 51922, 51923, 51924, 51925, 51926, 51927, 51928,
  51929, 51930, 51931, 51932, 51933, 51934, 51935, 51936, 51937, 51938, 51939,
  51940, 51941, 51942, 51943, 51944, 51945, 51946, 51947, 52028, 52029, 52030,
  52034, 52042, 54556, 54557, 54558, 54559, 54560, 54561, 54562, 54563, 54564,
  54565, 54566, 54567, 54576, 54577, 54578, 54579, 54580, 54581, 54582, 54583,
  54584, 54585, 54586, 54587, 54588, 54589, 54590, 54591,
  --]]
  
  -- ZeraTooltip
  47557, 47558, 47559,
}




local stat = "Quality"
local defaultText = ITEM_HEROIC_QUALITY4_DESC
local coveredDefaultText = Addon:CoverSpecialCharacters(defaultText)
function Addon:RewordQuality(text, tooltipData)
  if not self:GetOption("hide", stat) and heroicItems[tooltipData.id] then
    text = ITEM_HEROIC_QUALITY4_DESC
  end
  return text
end



local stat = "Heroic"
local defaultText = ITEM_HEROIC
local coveredDefaultText = Addon:CoverSpecialCharacters(defaultText)
function Addon:RewordHeroic(text)
  if self:GetOption("allow", "reword") and self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredDefaultText then
      text = strGsub(text, coveredDefaultText, alias)
    end
  end
  return text
end


function Addon:AddHeroicTag(tooltipData)
  if self:GetOption("hide", stat) then return end
  if GetCVarBool"colorblindMode" then return end
  if heroicItems[tooltipData.id] then
    local color = self:GetDefaultOption("color", stat)
    if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) then
      color = self:GetOption("color", stat)
    end
    self:AddExtraLine(tooltipData, tooltipData.locs.title, self:RewordHeroic(self.L["Heroic"]), color)
  end
end

