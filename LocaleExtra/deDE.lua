if GetLocale() ~= "deDE" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



-- override the default stat rewords for this locale
do
  -- Addon:AddDefaultRewordByLocale(stat, val)
end


-- override the default stat mods for this locale
do
  -- Addon:AddDefaultModByLocale(stat, val)
end


-- override the default stat precision for this locale
do
  -- Addon:AddDefaultPrecisionByLocale(stat, val)
end



Addon:AddExtraStatCapture("Armor Penetration Rating",
  {INPUT = "^Erhöht die Rüstungsdurchschlagwertung um (%d+)%.$"})

