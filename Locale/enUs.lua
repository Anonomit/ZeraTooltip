
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, not Addon:IsDebugEnabled())
if not L then return end





L["Reorder"] = true
L["Recolor"] = true

L["Group Secondary Stats with Base Stats"] = true
L["Space Above Bonus Effects"]             = true

L["Multiply"]   = true
L["Multiplier"] = true

-- padding locations
L["Spacing"]            = true
L["Hide Extra Spacing"] = true
L["Space Above"]        = true
L["Space Below"]        = true
L["Secondary Stats"]    = true
L["Sockets"]            = true
L["Set List"]           = true
L["Set Bonus"]          = true


-- refundable
L["Refund"] = true

-- trainable
L["Trainable Equipment"] = true

-- weapon damage
L["Show Minimum and Maximum"] = true
L["Show Average"]             = true
L["Show Variance"]            = true
L["Variance Prefix"]          = true
L["Show Percent"]             = true

-- dps
L["Remove Brackets"] = true

-- speed
L["Prefix"]    = true
L["Precision"] = true

-- speed bar
L["Speed Bar"]       = true
L["Test"]            = true
L["Show Speed"]      = true
L["Fill Character"]  = true
L["Blank Character"] = true

-- durability
L["Show Current"] = true

-- races
L["Hide Pointless Lines"] = true

-- prefixes
L["Remove Space"] = true
L["Icon Space"]   = true

-- reset
L["Order"] = true
L["Mod"]   = true


