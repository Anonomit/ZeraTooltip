
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhTW", false, not Addon:IsDebugEnabled())
if not L then return end



L["Refund"] = "可退款"

