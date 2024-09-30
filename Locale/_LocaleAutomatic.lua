
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strLower = string.lower
local strFind  = string.find
local strMatch = string.match
local strGsub  = string.gsub

local tostring = tostring



local locale = GetLocale()


--[[
L["key"] = value

value should be a string, but can also be a function that returns a string

value could also be a list of strings or functions that return strings. the first truthy value will be used
  a nil element will throw an error and continue to the next element
  a false element will fail silently and continue to the next element

a value of nil will throw an error and fail
a value of false will fail silently

accessing a key with no value will throw an error and return the key
]]


local actual = {}
local L = setmetatable({}, {
  __index = function(self, key)
    if not actual[key] then
      actual[key] = key
      Addon:Throwf("%s: Missing automatic translation for '%s'", ADDON_NAME, tostring(key))
    end
    return actual[key]
  end,
  __newindex = function(self, key, val)
    if actual[key] then
      Addon:Warnf(ADDON_NAME..": Automatic translation for '%s' has been overwritten", tostring(key))
    end
    if type(val) == "table" then
      -- get the largest key in table
      local max = 1
      for i in pairs(val) do
        if i > max then
          max = i
        end
      end
      -- try adding values from the table in order
      for i = 1, max do
        if val[i] then
          self[key] = val[i]
          if actual[key] then
            return
          else
            Addon:Warnf(ADDON_NAME..": Automatic translation #%d failed for '%s'", i, tostring(key))
          end
        elseif val[i] ~= false then
          Addon:Warnf(ADDON_NAME..": Automatic translation #%d failed for '%s'", i, tostring(key))
        end
      end
    elseif type(val) == "function" then
      -- use the function return value unless it errors
      if not Addon:xpcallSilent(val, function(err) Addon:Throwf("%s: Automatic translation error for '%s' : %s", ADDON_NAME, tostring(key), err) end) then
        return
      end
      local success, result = Addon:xpcall(val)
      if not success then
        Addon:Throwf("%s: Automatic translation error for '%s'", ADDON_NAME, tostring(key))
        return
      end
      self[key] = result
    elseif val ~= false then
      actual[key] = val
    end
  end,
})
Addon.L = L



if locale == "esES" then
  L["."] = "."
  L[","] = ","
else
  L["."] = DECIMAL_SEPERATOR
  L[","] = LARGE_NUMBER_SEPERATOR
end

L["[%d,%.]+"] = function() return "[%d%" .. L[","] .. "%" .. L["."] .. "]+" end



L["Options"] = OPTIONS

L["Enable"]  = ENABLE
L["Disable"] = DISABLE
L["Enabled"] = VIDEO_OPTIONS_ENABLED
-- L["Disabled"] = ADDON_DISABLED
L["Modifiers:"] = MODIFIERS_COLON

L["never"] = function() return strLower(CALENDAR_REPEAT_NEVER) end
L["any"]   = function() return strLower(SPELL_TARGET_TYPE1_DESC) end
L["all"]   = function() return strLower(SPELL_TARGET_TYPE12_DESC) end

L["SHIFT key"] = SHIFT_KEY
L["CTRL key"]  = CTRL_KEY
L["ALT key"]   = ALT_KEY

L["Features"] = FEATURES_LABEL

L["ERROR"] = ERROR_CAPS

L["Display Lua Errors"] = SHOW_LUA_ERRORS
L["Lua Warning"] = LUA_WARNING

L["Debug"] = BINDING_HEADER_DEBUG
L["Reload UI"] = RELOADUI
L["Hide messages like this one."] = COMBAT_LOG_MENU_SPELL_HIDE





L["Stats"] = PET_BATTLE_STATS_LABEL

L["Example Text:"] = EXAMPLE_TEXT
L["Default"]       = DEFAULT
L["Current"]       = REFORGE_CURRENT

L["Move Up"]        = TRACKER_SORT_MANUAL_UP
L["Move Down"]      = TRACKER_SORT_MANUAL_DOWN
L["Move to Top"]    = TRACKER_SORT_MANUAL_TOP
L["Move to Bottom"] = TRACKER_SORT_MANUAL_BOTTOM

L["Color"]      = COLOR
L["Reset"]      = RESET
L["Custom"]     = CUSTOM
L["Rename"]     = PET_RENAME
L["Formatting"] = FORMATTING
L["Hide"]       = HIDE
L["Show"]       = SHOW

L["Base Stats"]         = PLAYERSTAT_BASE_STATS
L["Enchant"]            = ENSCRIBE
L["Weapon Enchantment"] = WEAPON_ENCHANTMENT
L["Equipped Runes"]     = EQUIPPED_RUNES
L["All Runes"]          = ALL_RUNES
L["End"]                = KEY_END

L["Short Name"]        = COMMUNITIES_SETTINGS_SHORT_NAME_LABEL
L["Show Item Level"]   = SHOW_ITEM_LEVEL
L["Category"]          = CATEGORY
L["Weapon Damage"]     = DAMAGE_TOOLTIP
L["Speed"]             = SPEED
L["Damage Per Second"] = ITEM_MOD_DAMAGE_PER_SECOND_SHORT
L["Trade"]             = TRADE
L["Settings"]          = SETTINGS
-- L["Other Options"]  = UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER
L["Other"]             = FACTION_OTHER
L["Weapon"]            = WEAPON
L["Miscellaneous"]     = MISCELLANEOUS
L["Minimum"]           = MINIMUM
L["Maximum"]           = MAXIMUM
L["Frame Width"]       = COMPACT_UNIT_FRAME_PROFILE_FRAMEWIDTH
L["Show Class Color"]  = SHOW_CLASS_COLOR
L["Minimize"]          = MINIMIZE

L["Icon"]            = EMBLEM_SYMBOL
L["Choose an Icon:"] = MACRO_POPUP_CHOOSE_ICON
L["Manual"]          = TRACKER_SORT_MANUAL

L["Enable UI Colorblind Mode"]                                             = USE_COLORBLIND_MODE
L["Adds additional information to tooltips and several other interfaces."] = OPTION_TOOLTIP_USE_COLORBLIND_MODE
L["Colorblind Mode"]                                                       = {COLORBLIND_LABEL, COLORBLIND_MODE_LABEL, COLORBLIND_MODE_TAB}

L["Effects"]        = EFFECTS_SUBHEADER
L["Equip:"]         = ITEM_SPELL_TRIGGER_ONEQUIP
L["Chance on hit:"] = ITEM_SPELL_TRIGGER_ONPROC
L["Use:"]           = ITEM_SPELL_TRIGGER_ONUSE

L["Items"] = ITEMS

L["Me"]                         = COMBATLOG_FILTER_STRING_ME
L["Max Level"]                  = GUILD_RECRUITMENT_MAXLEVEL
L["Level %d"]                   = UNIT_LEVEL_TEMPLATE
L["|cff000000%s (low level)|r"] = TRIVIAL_QUEST_DISPLAY

L["All"] = ALL

L["Heroic"] = ITEM_HEROIC

L["Red Socket"]                       = EMPTY_SOCKET_RED
L["Blue Socket"]                      = EMPTY_SOCKET_BLUE
L["Yellow Socket"]                    = EMPTY_SOCKET_YELLOW
L["Matches a Red or Blue Socket."]    = GEM_TEXT_PURPLE
L["Matches a Blue or Yellow Socket."] = GEM_TEXT_GREEN
L["Matches a Red or Yellow Socket."]  = GEM_TEXT_ORANGE
L["Prismatic Socket"]                 = EMPTY_SOCKET_PRISMATIC
L["Meta Socket"]                      = EMPTY_SOCKET_META
L["Cogwheel Socket"]                  = EMPTY_SOCKET_COGWHEEL
L["Hydraulic Socket"]                 = EMPTY_SOCKET_HYDRAULIC



L["Clear Cache"]                  = BROWSER_CLEAR_CACHE
-- L["Delete"]                       = DELETE



-- missing?
-- L["Test"]        = TEST_BUILD











L["Heroic Epic"]                                                                                     = ITEM_HEROIC_QUALITY4_DESC
L["iLvl %d"]                                                                                         = GARRISON_FOLLOWER_ITEM_LEVEL
L["Item Level %d"]                                                                                   = ITEM_LEVEL
L["Stack Size"]                                                                                      = AUCTION_STACK_SIZE
L["Faction"]                                                                                         = FACTION
L["Alliance"]                                                                                        = FACTION_ALLIANCE
L["Horde"]                                                                                           = FACTION_HORDE
L["Races: %s"]                                                                                       = ITEM_RACES_ALLOWED
L["Armor"]                                                                                           = ARMOR
L["Block"]                                                                                           = BLOCK
L["Durability %d / %d"]                                                                              = DURABILITY_TEMPLATE
L["Enchanted: %s"]                                                                                   = ENCHANTED_TOOLTIP_LINE
L["<Shift Right Click to Socket>"]                                                                   = ITEM_SOCKETABLE
L["You may sell this item to a vendor within %s for a full refund."]                                 = REFUND_TIME_REMAINING
L["You may trade this item with players that were also eligible to loot this item for the next %s."] = BIND_TRADE_TIME_REMAINING
L["(%s damage per second)"]                                                                          = DPS_TEMPLATE
L["DPS"]                                                                                             = STAT_DPS_SHORT






L["Locked"] = LOCKED

L["Transmogrified to:"] = TRANSMOGRIFIED_HEADER

L["Soulbound"]                 = ITEM_SOULBOUND
L["Binds when equipped"]       = ITEM_BIND_ON_EQUIP
L["Binds when used"]           = ITEM_BIND_ON_USE
L["Binds when picked up"]      = ITEM_BIND_ON_PICKUP
L["Binds to account"]          = ITEM_BIND_TO_ACCOUNT
L["Binds to Blizzard account"] = ITEM_BIND_TO_BNETACCOUNT

L["Currently Equipped"]  = CURRENTLY_EQUIPPED
L["Gem to be destroyed"] = DESTROY_GEM

L["Unique"]                   = ITEM_UNIQUE
L["Unique (%d)"]              = ITEM_UNIQUE_MULTIPLE
L["Unique: %s (%d)"]          = ITEM_LIMIT_CATEGORY
L["Unique-Equipped"]          = ITEM_UNIQUE_EQUIPPABLE
L["Unique-Equipped: %s (%d)"] = ITEM_LIMIT_CATEGORY_MULTIPLE

L["Requires %s (%d)"] = ITEM_MIN_SKILL

L["Reforged"] = REFORGED

L["%s - %s Damage"]    = DAMAGE_TEMPLATE
L["%s - %s %s Damage"] = DAMAGE_TEMPLATE_WITH_SCHOOL
L["%s Damage"]         = SINGLE_DAMAGE_TEMPLATE

L["+ %s Damage"]         = PLUS_SINGLE_DAMAGE_TEMPLATE
L["+ %s - %s Damage"]    = PLUS_DAMAGE_TEMPLATE
L["+%s %s Damage"]       = PLUS_SINGLE_DAMAGE_TEMPLATE_WITH_SCHOOL
L["+ %s - %s %s Damage"] = PLUS_DAMAGE_TEMPLATE_WITH_SCHOOL

L["%s Armor"] = ARMOR_TEMPLATE
L["%d Block"] = SHIELD_BLOCK_TEMPLATE

L["Enchantment Requires %s"]       = ENCHANT_ITEM_REQ_SKILL
L["Enchantment Requires %s (%d)"]  = ENCHANT_ITEM_MIN_SKILL
L["Enchantment Requires Level %d"] = ENCHANT_ITEM_REQ_LEVEL

L["Socket Requires %s"] = SOCKET_ITEM_REQ_SKILL

L["Will receive %s."] = ITEM_PROPOSED_ENCHANT

L["Item will not be traded!"] = ITEM_ENCHANT_DISCLAIMER

L["Socket Bonus: %s"] = ITEM_SOCKET_BONUS

L["Classes: %s"] = ITEM_CLASSES_ALLOWED

L["Requires Level %d"]            = ITEM_MIN_LEVEL
L["Requires level %d to %d"]      = ITEM_LEVEL_RANGE
L["Requires level %d to %d (%d)"] = ITEM_LEVEL_RANGE_CURRENT
L["Heirloom"]                     = ITEM_QUALITY7_DESC

L["Already known"] = ITEM_SPELL_KNOWN

L["Requires %s - %s"] = ITEM_REQ_REPUTATION

L["<Random enchantment>"] = ITEM_RANDOM_ENCHANT

L["%s (%d/%d)"] = ITEM_SET_NAME

L["(%d) Set: %s"]                                             = ITEM_SET_BONUS_GRAY
L["Set: %s"]                                                  = ITEM_SET_BONUS
L["Bonus effects vary based on the player's specialization."] = ITEM_SET_BONUS_NO_VALID_SPEC

L["Cooldown remaining: %s"] = ITEM_COOLDOWN_TIME

L["If you replace this item, the following stat changes will occur:"]   = ITEM_DELTA_DESCRIPTION
L["If you replace these items, the following stat changes will occur:"] = ITEM_DELTA_MULTIPLE_COMPARISON_DESCRIPTION

L["Requires %s"] = LOCKED_WITH_ITEM

L["Cooldown remaining: %d min"] = ITEM_COOLDOWN_TIME_MIN










L["%d |4hour:hrs;"] = INT_SPELL_DURATION_HOURS

L["%d |4Charge:Charges;"] = ITEM_SPELL_CHARGES
L["No charges"]           = ITEM_SPELL_CHARGES_NONE

L["<Made by %s>"]   = {function() return Addon:StripColorCode(ITEM_CREATED_BY) end, ITEM_CREATED_BY}
L["<Gift from %s>"] = {function() return Addon:StripColorCode(ITEM_WRAPPED_BY) end, ITEM_WRAPPED_BY}
L["Written by %s"]  = ITEM_WRITTEN_BY






L["%c%d %s Resistance"] = ITEM_RESIST_SINGLE

if locale == "zhTW" and not Addon.isEra then
  Addon.L["%c%d to All Resistances"] = strGsub(ITEM_RESIST_ALL, "%%d", "%1 ")
else
  L["%c%d to All Resistances"] = ITEM_RESIST_ALL
end


if locale == "ruRU" then
  if Addon.isEra then
    L["Holy"]   = SPELL_SCHOOL1_CAP
    L["Fire"]   = SPELL_SCHOOL2_CAP
    L["Nature"] = SPELL_SCHOOL3_CAP
    L["Frost"]  = SPELL_SCHOOL4_CAP
    L["Shadow"] = SPELL_SCHOOL5_CAP
    L["Arcane"] = SPELL_SCHOOL6_CAP
  else
    L["Holy"]   = "свету"
    L["Fire"]   = "огню"
    L["Nature"] = "силам природы"
    L["Frost"]  = "магии льда"
    L["Shadow"] = "темной магии"
    L["Arcane"] = "тайной магии"
  end
else
  L["Holy"]   = DAMAGE_SCHOOL2
  L["Fire"]   = DAMAGE_SCHOOL3
  L["Nature"] = DAMAGE_SCHOOL4
  L["Frost"]  = DAMAGE_SCHOOL5
  L["Shadow"] = DAMAGE_SCHOOL6
  L["Arcane"] = DAMAGE_SCHOOL7
end

L["Holy Resistance"]   = RESISTANCE1_NAME
L["Fire Resistance"]   = RESISTANCE2_NAME
L["Nature Resistance"] = RESISTANCE3_NAME
L["Frost Resistance"]  = RESISTANCE4_NAME
L["Shadow Resistance"] = RESISTANCE5_NAME
L["Arcane Resistance"] = RESISTANCE6_NAME



L["Strength"]  = SPELL_STAT1_NAME
L["Agility"]   = SPELL_STAT2_NAME
L["Stamina"]   = SPELL_STAT3_NAME
L["Intellect"] = SPELL_STAT4_NAME
L["Spirit"]    = SPELL_STAT5_NAME


if locale == "esES" then
  L["%c%d Stamina"]   = strLower(ITEM_MOD_STAMINA)
  L["%c%d Strength"]  = strLower(ITEM_MOD_STRENGTH)
  L["%c%d Agility"]   = strLower(ITEM_MOD_AGILITY)
  L["%c%d Intellect"] = strLower(ITEM_MOD_INTELLECT)
  L["%c%d Spirit"]    = strLower(ITEM_MOD_SPIRIT)
elseif locale == "esMX" then
  L["%c%d Stamina"]   = Addon:ChainGsub(ITEM_MOD_STAMINA,   {strLower(L["Stamina"]),   L["Stamina"]})
  L["%c%d Strength"]  = Addon:ChainGsub(ITEM_MOD_STRENGTH,  {strLower(L["Strength"]),  L["Strength"]})
  L["%c%d Agility"]   = Addon:ChainGsub(ITEM_MOD_AGILITY,   {strLower(L["Agility"]),   L["Agility"]})
  L["%c%d Intellect"] = Addon:ChainGsub(ITEM_MOD_INTELLECT, {strLower(L["Intellect"]), L["Intellect"]})
  L["%c%d Spirit"]    = Addon:ChainGsub(ITEM_MOD_SPIRIT,    {strLower(L["Spirit"]),    L["Spirit"]})
elseif locale == "zhTW" and Addon.isEra then
  L["%c%d Stamina"]   = strGsub(ITEM_MOD_STAMINA,   " ", "", 1)
  L["%c%d Strength"]  = strGsub(ITEM_MOD_STRENGTH,  " ", "", 1)
  L["%c%d Agility"]   = strGsub(ITEM_MOD_AGILITY,   " ", "", 1)
  L["%c%d Intellect"] = strGsub(ITEM_MOD_INTELLECT, " ", "", 1)
  L["%c%d Spirit"]    = strGsub(ITEM_MOD_SPIRIT,    " ", "", 1)
else
  L["%c%d Stamina"]   = ITEM_MOD_STAMINA
  L["%c%d Strength"]  = ITEM_MOD_STRENGTH
  L["%c%d Agility"]   = ITEM_MOD_AGILITY
  L["%c%d Intellect"] = ITEM_MOD_INTELLECT
  L["%c%d Spirit"]    = ITEM_MOD_SPIRIT
end







L["Bonus Armor"] = ITEM_MOD_EXTRA_ARMOR_SHORT
L["Mastery"] = ITEM_MOD_MASTERY_RATING_SHORT

if strFind(L["%c%d Stamina"], "^%%") then
  if strFind(L["%c%d Stamina"], " ") then
    L["%c%s Bonus Armor"] = "%c%s " .. L["Bonus Armor"]
    L["%c%s Mastery"] = "%c%s " .. L["Mastery"]
  else
    L["%c%s Bonus Armor"] = "%c%s" .. L["Bonus Armor"]
    L["%c%s Mastery"] = "%c%s" .. L["Mastery"]
  end
else
    L["%c%s Bonus Armor"] = L["Bonus Armor"] .. " %c%s"
    L["%c%s Mastery"] = L["Mastery"] .. " %c%s"
end

L["Defense Rating"] = ITEM_MOD_DEFENSE_SKILL_RATING_SHORT
L["Increases defense rating by %s."] = ITEM_MOD_DEFENSE_SKILL_RATING

L["Dodge Rating"] = ITEM_MOD_DODGE_RATING_SHORT
L["Increases your dodge rating by %s."] = ITEM_MOD_DODGE_RATING

L["Parry Rating"] = ITEM_MOD_PARRY_RATING_SHORT
L["Increases your parry rating by %s."] = ITEM_MOD_PARRY_RATING

L["Block Rating"] = ITEM_MOD_BLOCK_RATING_SHORT
L["Increases your shield block rating by %s."] = ITEM_MOD_BLOCK_RATING

L["Block Value"] = ITEM_MOD_BLOCK_VALUE_SHORT
L["Increases the block value of your shield by %s."] = ITEM_MOD_BLOCK_VALUE

L["Resilience Rating"] = ITEM_MOD_RESILIENCE_RATING_SHORT
L["Improves your resilience rating by %s."] = ITEM_MOD_RESILIENCE_RATING

L["Expertise Rating"] = ITEM_MOD_EXPERTISE_RATING_SHORT
L["Increases your expertise rating by %s."] = ITEM_MOD_EXPERTISE_RATING

L["Attack Power"] = ITEM_MOD_ATTACK_POWER_SHORT
L["Increases attack power by %s."] = ITEM_MOD_ATTACK_POWER

L["Ranged Attack Power"] = ITEM_MOD_RANGED_ATTACK_POWER_SHORT
L["Increases ranged attack power by %s."] = ITEM_MOD_RANGED_ATTACK_POWER

L["Attack Power In Forms"] = ITEM_MOD_FERAL_ATTACK_POWER_SHORT
L["Increases attack power by %s in Cat, Bear, Dire Bear, and Moonkin forms only."] = ITEM_MOD_FERAL_ATTACK_POWER

L["Armor Penetration Rating"] = ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT
L["Increases your armor penetration by %s."] = ITEM_MOD_ARMOR_PENETRATION_RATING

L["Spell Power"] = ITEM_MOD_SPELL_POWER_SHORT
L["Increases spell power by %s."] = ITEM_MOD_SPELL_POWER

L["Bonus Healing"] = ITEM_MOD_SPELL_HEALING_DONE_SHORT
L["Increases healing done by magical spells and effects by up to %s."] = ITEM_MOD_SPELL_HEALING_DONE

L["Bonus Damage"] = ITEM_MOD_SPELL_DAMAGE_DONE_SHORT
L["Increases damage done by magical spells and effects by up to %s."] = ITEM_MOD_SPELL_DAMAGE_DONE

L["Spell Penetration"] = ITEM_MOD_SPELL_PENETRATION_SHORT
L["Increases spell penetration by %s."] = ITEM_MOD_SPELL_PENETRATION

L["Hit Rating"] = ITEM_MOD_HIT_RATING_SHORT
L["Improves hit rating by %s."] = ITEM_MOD_HIT_RATING

L["Critical Strike Rating"] = ITEM_MOD_CRIT_RATING_SHORT
L["Improves critical strike rating by %s."] = ITEM_MOD_CRIT_RATING

L["Haste Rating"] = ITEM_MOD_HASTE_RATING_SHORT
L["Improves haste rating by %s."] = ITEM_MOD_HASTE_RATING

L["Hit Rating (Spell)"] = ITEM_MOD_HIT_SPELL_RATING_SHORT
L["Improves spell hit rating by %s."] = ITEM_MOD_HIT_SPELL_RATING

L["Critical Strike Rating (Spell)"] = ITEM_MOD_CRIT_SPELL_RATING_SHORT
L["Improves spell critical strike rating by %s."] = ITEM_MOD_CRIT_SPELL_RATING

L["Haste Rating (Spell)"] = {ITEM_MOD_HASTE_SPELL_RATING_SHORT or false, function() return strGsub(ITEM_MOD_CRIT_SPELL_RATING_SHORT, Addon:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING_SHORT), Addon:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING_SHORT)) end}
L["Improves spell haste rating by %s."] = {ITEM_MOD_HASTE_SPELL_RATING or false, function() return strGsub(ITEM_MOD_CRIT_SPELL_RATING, Addon:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING), Addon:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING)) end}

L["Health Regeneration"] = ITEM_MOD_HEALTH_REGENERATION_SHORT
L["Restores %s health per 5 sec."] = ITEM_MOD_HEALTH_REGEN

L["Mana Regeneration"] = ITEM_MOD_MANA_REGENERATION_SHORT
L["Restores %s mana per 5 sec."] = ITEM_MOD_MANA_REGENERATION




