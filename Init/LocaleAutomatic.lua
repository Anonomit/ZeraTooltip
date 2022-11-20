
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




local strLower  = string.lower

local tostring = tostring



local L = setmetatable({}, {
  __index = function(self, key)
    rawset(self, key, key)
    if Addon:IsDebugEnabled() then
      geterrorhandler()(ADDON_NAME..": Missing automatic translation for '"..tostring(key).."'")
    end
    return key
  end
})
Addon.L = L



L["Enable"]  = ENABLE
L["Disable"] = DISABLE
L["Enabled"] = VIDEO_OPTIONS_ENABLED
-- L["Disabled"] = ADDON_DISABLED
L["Modifiers:"] = MODIFIERS_COLON

L["never"] = strLower(CALENDAR_REPEAT_NEVER)
L["any"]   = strLower(SPELL_TARGET_TYPE1_DESC)
L["all"]   = strLower(SPELL_TARGET_TYPE12_DESC)

L["SHIFT key"] = SHIFT_KEY
L["CTRL key"]  = CTRL_KEY
L["ALT key"]   = ALT_KEY

L["Features"] = FEATURES_LABEL

L["Stats"] = PET_BATTLE_STATS_LABEL

L["Example Text:"] = EXAMPLE_TEXT
L["Default"]       = DEFAULT
L["Current"]       = REFORGE_CURRENT

L["Move Up"]        = TRACKER_SORT_MANUAL_UP
L["Move Down"]      = TRACKER_SORT_MANUAL_DOWN
L["Move to Top"]    = TRACKER_SORT_MANUAL_TOP
L["Move to Bottom"] = TRACKER_SORT_MANUAL_BOTTOM

L["Color"]  = COLOR
L["Reset"]  = RESET
L["Custom"] = CUSTOM
L["Rename"] = PET_RENAME
L["Hide"]   = HIDE

L["Base Stats"]         = PLAYERSTAT_BASE_STATS
L["Enchant"]            = ENSCRIBE
L["Weapon Enchantment"] = WEAPON_ENCHANTMENT
L["End"]                = KEY_END

L["Trade"]         = TRADE
L["Settings"]      = SETTINGS
-- L["Other Options"] = UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER
L["Other"]         = FACTION_OTHER
L["Weapon"]        = WEAPON
L["Miscellaneous"] = MISCELLANEOUS
L["Minimum"]       = MINIMUM
L["Maximum"]       = MAXIMUM
L["Frame Width"]   = COMPACT_UNIT_FRAME_PROFILE_FRAMEWIDTH

L["Icon"]            = EMBLEM_SYMBOL
L["Choose an Icon:"] = MACRO_POPUP_CHOOSE_ICON
L["Manual"]          = TRACKER_SORT_MANUAL

L["Use:"] = ITEM_SPELL_TRIGGER_ONUSE

L["Me"]                         = COMBATLOG_FILTER_STRING_ME
L["Max Level"]                  = GUILD_RECRUITMENT_MAXLEVEL
L["Level %d"]                   = UNIT_LEVEL_TEMPLATE
L["|cff000000%s (low level)|r"] = TRIVIAL_QUEST_DISPLAY

L["All"] = ALL

L["Heroic"] = ITEM_HEROIC

L["ERROR"] = ERROR_CAPS


L["Debug"]                        = BINDING_HEADER_DEBUG
L["Reload UI"]                    = RELOADUI
L["Hide messages like this one."] = COMBAT_LOG_MENU_SPELL_HIDE
L["Clear Cache"]                  = BROWSER_CLEAR_CACHE
-- L["Delete"]                       = DELETE


-- L["Weapon Damage"] = DAMAGE_TOOLTIP
-- L["Damage Per Second"] = ITEM_MOD_DAMAGE_PER_SECOND_SHORT

-- missing?
-- L["Test"]        = TEST_BUILD


