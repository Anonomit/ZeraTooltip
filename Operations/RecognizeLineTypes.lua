
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strLower = string.lower
local strGsub  = string.gsub
local strFind  = string.find
local strMatch = string.match

local tinsert = tinsert


local L_ITEM_MOD_STAMINA        = Addon.L["%c%d Stamina"]
local L_ITEM_MOD_STRENGTH       = Addon.L["%c%d Strength"]
local L_ITEM_MOD_AGILITY        = Addon.L["%c%d Agility"]
local L_ITEM_MOD_INTELLECT      = Addon.L["%c%d Intellect"]
local L_ITEM_MOD_SPIRIT         = Addon.L["%c%d Spirit"]
local L_ITEM_RESIST_SINGLE      = Addon.L["%c%d %s Resistance"]

local L_ITEM_MOD_BONUS_ARMOR_SHORT    = Addon.L["%c%s Bonus Armor"]
local L_ITEM_MOD_MASTERY_RATING_SHORT = Addon.L["%c%s Mastery"]

local L_CURRENTLY_EQUIPPED = Addon.L["Currently Equipped"]
local L_DESTROY_GEM        = Addon.L["Gem to be destroyed"]

local L_TRANSMOGRIFIED = Addon.L["Transmogrified to:"]

local L_ITEM_HEROIC = Addon.L["Heroic"]

local L_ITEM_CREATED_BY = Addon.L["<Made by %s>"]
local L_ITEM_WRAPPED_BY = Addon.L["<Gift from %s>"]
local L_ITEM_WRITTEN_BY = Addon.L["Written by %s"]

local L_ITEM_UNIQUE                  = Addon.L["Unique"]
local L_ITEM_UNIQUE_MULTIPLE         = Addon.L["Unique (%d)"]
local L_ITEM_UNIQUE_EQUIPPABLE       = Addon.L["Unique-Equipped"]
local L_ITEM_LIMIT_CATEGORY_MULTIPLE = Addon.L["Unique-Equipped: %s (%d)"]
local L_ITEM_LIMIT_CATEGORY          = Addon.L["Unique: %s (%d)"]

local L_ITEM_MIN_SKILL = Addon.L["Requires %s (%d)"]
local L_ITEM_REQ_SKILL = Addon.L["Requires %s"]

local L_DAMAGE_TEMPLATE             = Addon.L["%s - %s Damage"]
local L_DAMAGE_TEMPLATE_WITH_SCHOOL = Addon.L["%s - %s %s Damage"]
local L_SINGLE_DAMAGE_TEMPLATE      = Addon.L["%s Damage"]

local L_PLUS_SINGLE_DAMAGE_TEMPLATE             = Addon.L["+ %s Damage"]
local L_PLUS_DAMAGE_TEMPLATE                    = Addon.L["+ %s - %s Damage"]
local L_PLUS_SINGLE_DAMAGE_TEMPLATE_WITH_SCHOOL = Addon.L["+%s %s Damage"]
local L_PLUS_DAMAGE_TEMPLATE_WITH_SCHOOL        = Addon.L["+ %s - %s %s Damage"]

local L_DPS_TEMPLATE = Addon.L["(%s damage per second)"]

local L_ARMOR_TEMPLATE = Addon.L["%s Armor"]

local L_SHIELD_BLOCK_TEMPLATE = Addon.L["%d Block"]

local L_ENCHANT_ITEM_REQ_SKILL = Addon.L["Enchantment Requires %s"]
local L_ENCHANT_ITEM_MIN_SKILL = Addon.L["Enchantment Requires %s (%d)"]
local L_ENCHANT_ITEM_REQ_LEVEL = Addon.L["Enchantment Requires Level %d"]

local L_SOCKET_ITEM_REQ_SKILL = Addon.L["Socket Requires %s"]

local L_ITEM_PROPOSED_ENCHANT = Addon.L["Will receive %s."]

local L_ITEM_ENCHANT_DISCLAIMER = Addon.L["Item will not be traded!"]

local L_ITEM_SOCKET_BONUS = Addon.L["Socket Bonus: %s"]

local L_DURABILITY_TEMPLATE = Addon.L["Durability %d / %d"]

local L_ITEM_RACES_ALLOWED = Addon.L["Races: %s"]

local L_ITEM_CLASSES_ALLOWED = Addon.L["Classes: %s"]

local L_ITEM_MIN_LEVEL = Addon.L["Requires Level %d"]

local L_ITEM_LEVEL = Addon.L["Item Level %d"]

local L_ITEM_SPELL_KNOWN = Addon.L["Already known"]

local L_ITEM_REQ_REPUTATION = Addon.L["Requires %s - %s"]

local L_ITEM_SPELL_TRIGGER_ONEQUIP = Addon.L["Equip:"]
local L_ITEM_SPELL_TRIGGER_ONUSE   = Addon.L["Use:"]
local L_ITEM_SPELL_TRIGGER_ONPROC  = Addon.L["Chance on hit:"]

local L_ITEM_RANDOM_ENCHANT         = Addon.L["<Random enchantment>"]
local L_ITEM_MOD_FERAL_ATTACK_POWER = Addon.L["Increases attack power by %s in Cat, Bear, Dire Bear, and Moonkin forms only."]


local L_ITEM_SPELL_CHARGES_1
local L_ITEM_SPELL_CHARGES_2
do
  local head, single, plural, tail = strMatch(Addon.L["%d |4Charge:Charges;"], "(.*)|4([^:]+):([^;]+);(.*)")
  if single then
    L_ITEM_SPELL_CHARGES_1 = head .. single .. tail
    L_ITEM_SPELL_CHARGES_2 = head .. plural .. tail
  else
    L_ITEM_SPELL_CHARGES_1 = Addon.L["%d |4Charge:Charges;"]
  end
end
local L_ITEM_SPELL_CHARGES_NONE = Addon.L["No charges"]


local L_ITEM_SET_NAME = Addon.L["%s (%d/%d)"]

local L_ITEM_SET_BONUS_GRAY          = Addon.L["(%d) Set: %s"]
local L_ITEM_SET_BONUS               = Addon.L["Set: %s"]
local L_ITEM_SET_BONUS_NO_VALID_SPEC = Addon.L["Bonus effects vary based on the player's specialization."]

local L_ITEM_COOLDOWN_TIME = Addon.L["Cooldown remaining: %s"]

local L_ITEM_SOCKETABLE = Addon.L["<Shift Right Click to Socket>"]

local L_REFUND_TIME_REMAINING     = Addon.L["You may sell this item to a vendor within %s for a full refund."]
local L_BIND_TRADE_TIME_REMAINING = Addon.L["You may trade this item with players that were also eligible to loot this item for the next %s."]

local L_ITEM_DELTA_DESCRIPTION                     = Addon.L["If you replace this item, the following stat changes will occur:"]
local L_ITEM_DELTA_MULTIPLE_COMPARISON_DESCRIPTION = Addon.L["If you replace these items, the following stat changes will occur:"]

local L_LOCKED_WITH_ITEM = Addon.L["Requires %s"]


local L_ITEM_SOULBOUND           = Addon.L["Soulbound"]
local L_ITEM_BIND_ON_EQUIP       = Addon.L["Binds when equipped"]
local L_ITEM_BIND_ON_USE         = Addon.L["Binds when used"]
local L_ITEM_BIND_ON_PICKUP      = Addon.L["Binds when picked up"]
local L_ITEM_BIND_TO_ACCOUNT     = Addon.L["Binds to account"]
local L_ITEM_BIND_TO_BNETACCOUNT = Addon.L["Binds to Blizzard account"]

local bindTypes = {
  [L_ITEM_SOULBOUND]           = "AlreadyBound",
  [L_ITEM_BIND_ON_EQUIP]       = "Tradeable",
  [L_ITEM_BIND_ON_USE]         = "Tradeable",
  [L_ITEM_BIND_ON_PICKUP]      = "CharacterBound",
  [L_ITEM_BIND_TO_ACCOUNT]     = "AccountBound",
  [L_ITEM_BIND_TO_BNETACCOUNT] = "AccountBound",
}


local numberPattern = Addon.L["[%d,%.]+"]
local lockedPattern = "%s" .. Addon.L["Locked"]




local function strStarts(text, matchStr)
  return strFind(text, matchStr) == 1
end


local loweredPatternsCache = {}
local function Lower(text)
  loweredPatternsCache[text] = loweredPatternsCache[text] or strLower(text)
  return loweredPatternsCache[text]
end

local matchCache = {}
local function MatchesAny(text, ...)
  for _, pattern in ipairs{...} do
    matchCache[pattern] = matchCache[pattern] or Lower(Addon:ReversePattern(pattern))
    local startI, endI, match = strFind(text, matchCache[pattern])
    if startI then
      return pattern, match
    end
  end
  return nil
end

local function StartsWithAny(text, ...)
  for _, pattern in ipairs{...} do
    if strStarts(text, Lower(pattern)) then
      return pattern
    end
  end
  return nil
end

local contexts = Addon:MakeLookupTable(Addon:Squish{
  "Init",
  "PreTitle",
  "Title",
  "Quality",
  "Heroic", -- Don't need to match this, but leave the category in
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.cata, "TransmogHeader", nil),
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.cata, "Transmog",       nil),
  "Binding",
  "Unique",
  "LastUnique",
  "Locked",
  "LockedWithProfession",
  "Type",
  "RedType",
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.cata, "Reforged", nil),
  "Damage",
  "DamageBonus",
  "DamagePerSecond",
  "Armor",
  "BonusArmor",
  "Block",
  "BaseStat",
  "LastBaseStat",
  "Enchant",
  "RequiredEnchant",
  "WeaponEnchant",
  Addon:ShortCircuit(Addon.isSoD, "Rune", nil),
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.tbc, "Socket",             nil),
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.tbc, "RequiredSocket",     nil),
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.tbc, "LastSocket",         nil),
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.tbc, "LastRequiredSocket", nil),
  "ProposedEnchant",
  "EnchantHint",
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.tbc, "SocketBonus", nil),
  "Durability",
  "RequiredRaces",
  "RequiredClasses",
  "RequiredLevel",
  "ItemLevel",
  "RequiredSkill",
  "AlreadyKnown",
  "RequiredRep",
  "SecondaryStat",
  "LastSecondaryStat",
  "RecipeUse",
  "Charges",
  "Embed",
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.wrath, "EnchantOnUse",         nil),
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.wrath, "RequiredEnchantOnUse", nil),
  "SetName",
  "SetPiece",
  "LastSetPiece",
  "SetBonus",
  "LastSetBonus",
  "Cooldown",
  "Description",
  "MadeBy",
  "GiftFrom",
  "WrittenBy",
  Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.tbc, "SocketHint", nil),
  "Refundable",
  "SoulboundTradeable",
  "Delta",
  "RecipeMats",
  "Tail",
}, function(v, k) return k end, true)

local contextAscensions = Addon:Map({
  Title = function(context, tooltipData, line, currentContext)
    -- mark where the title would be if it existed on this item
    tooltipData.locs.title = tooltipData.locs.title or line.i - 1
  end,
  Quality = function(context, tooltipData, line, currentContext)
    -- mark where the quality would be if it existed on this item
    tooltipData.locs.quality = tooltipData.locs.quality or line.i - 1
  end,
  Binding = function(context, tooltipData, line, currentContext)
    -- mark where the binding would be if it existed on this item
    tooltipData.locs.binding = tooltipData.locs.binding or line.i - 1
  end,
  -- Damage = function(context, tooltipData, line)
  --   local lastLine = tooltipData[line.i-1]
  --   if not lastLine.type then
  --     lastLine.type = "Type"
  --   end
  -- end,
  BaseStat = function(context, tooltipData, line, currentContext)
    -- mark where the base stats would be if they existed on this item
    tooltipData.locs.statStart = tooltipData.locs.statStart or line.i - 1
  end,
  Enchant = function(context, tooltipData, line, currentContext)
    -- mark red enchantment lines if I found an "enchantment disabled" line
    if currentContext == contexts.RequiredEnchant then
      local lastLine = tooltipData[line.i-2]
      lastLine.type = "Enchant"
      tooltipData.foundEnchant = true
    end
    
    -- mark where the enchant would be if it existed on this item
    tooltipData.locs.enchant = tooltipData.locs.enchant or line.i - 1
  end,
  SocketBonus = function(context, tooltipData, line, currentContext)
    -- mark where the socket bonus would be if it existed on this item
    tooltipData.locs.socketBonus = tooltipData.locs.socketBonus or line.i - 1
  end,
  ItemLevel = function(context, tooltipData, line, currentContext)
    -- mark where the item level would be if it existed on this item
    tooltipData.locs.itemLevel = tooltipData.locs.itemLevel or line.i - 1
  end,
  SecondaryStat = function(context, tooltipData, line, currentContext)
    -- mark where the secondary stats would be if they existed on this item
    tooltipData.locs.secondaryStatStart = tooltipData.locs.secondaryStatStart or line.i - 1
  end,
  Embed = function(context, tooltipData, line, currentContext)
    if currentContext == contexts.Embed then
      -- reset the base stat location
      tooltipData.embedLocs = tooltipData.locs
      tooltipData.locs      = {}
      tooltipData.context   = contexts.Title
    end
  end,
  EnchantOnUse = function(context, tooltipData, line, currentContext)
    -- mark red enchantment lines if I found an "enchantment disabled" line
    if currentContext == contexts.RequiredEnchantOnUse then
      local lastLine = tooltipData[line.i-1]
      lastLine.type = "EnchantOnUse"
      lastLine.prefix = Addon.L["Use:"]
      tooltipData.foundEnchant = true
    end
  end,
  Description = function(context, tooltipData, line, currentContext)
    -- mark where the description would be if it existed on this item
    tooltipData.locs.description = tooltipData.locs.description or line.i - 1
  end,
  Tail = function(context, tooltipData, line, currentContext)
    -- do everything that needs to be done if the tooltip only has a title
    
    -- mark where the title would be if it existed on this item
    tooltipData.locs.title = tooltipData.locs.title or line.i
    
    -- mark where the quality would be if it existed on this item
    tooltipData.locs.quality = tooltipData.locs.quality or line.i
    
    -- mark where the binding would be if it existed on this item
    tooltipData.locs.binding = tooltipData.locs.binding or line.i
    
    -- mark where the base stats would be if they existed on this item
    tooltipData.locs.statStart = tooltipData.locs.statStart or line.i
    
    -- mark where the enchant would be if it existed on this item
    tooltipData.locs.enchant = tooltipData.locs.enchant or line.i
    
    -- mark where the socket bonus would be if it existed on this item
    tooltipData.locs.socketBonus = tooltipData.locs.socketBonus or line.i
    
    -- mark where the item level would be if it existed on this item
    tooltipData.locs.itemLevel = tooltipData.locs.itemLevel or line.i
    
    -- mark where the secondary stats would be if they existed on this item
    tooltipData.locs.secondaryStatStart = tooltipData.locs.secondaryStatStart or line.i
    
    -- mark where the description would be if it existed on this item
    tooltipData.locs.description = tooltipData.locs.description or line.i
  end,
}, nil, contexts)

local function SetContext(context, tooltipData, line)
  local oldContext = tooltipData.context
  tooltipData.context = context
  for i = oldContext + 1, context do
    if contextAscensions[i] then
      contextAscensions[i](i, tooltipData, line, context)
    end
  end
  if line then
    line.type = contexts[context]
    return 0
  end
  return -1
end

local contextActions
contextActions = Addon:Map({
  PreTitle = function(i, tooltipData, line)
    if line.textLeftText == L_CURRENTLY_EQUIPPED or line.textLeftText == L_DESTROY_GEM  then
      return SetContext(i, tooltipData, line)
    end
  end,
  Title = function(i, tooltipData, line)
    tooltipData.locs.title = line.i
    return SetContext(i, tooltipData, line)
  end,
  Quality = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.WHITE and Addon.itemQualityDescriptions[line.textLeftText] or line.colorLeft == Addon.colors.GREEN and MatchesAny(line.textLeftTextStripped, L_ITEM_HEROIC) then
      tooltipData.locs.quality = line.i
      if GetCVarBool"colorblindMode" then
        return SetContext(i, tooltipData, line)
      else
        return SetContext(i+1, tooltipData, line)
      end
    end
  end,
  Transmog = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.TRANSMOG then
      if tooltipData.seekingTransmog then
        tooltipData.seekingTransmog = nil
        return SetContext(i, tooltipData, line)
      elseif MatchesAny(line.textLeftTextStripped, L_TRANSMOGRIFIED) then
        tooltipData.seekingTransmog = true
        return SetContext(i-1, tooltipData, line)
      end
    end
  end,
  Binding = function(i, tooltipData, line)
    local bindType = MatchesAny(line.textLeftTextStripped, L_ITEM_SOULBOUND, L_ITEM_BIND_ON_EQUIP, L_ITEM_BIND_ON_USE, L_ITEM_BIND_ON_PICKUP, L_ITEM_BIND_TO_ACCOUNT, L_ITEM_BIND_TO_BNETACCOUNT)
    if bindType then
      tooltipData.locs.binding = line.i
      line.bindType            = bindTypes[bindType]
      return SetContext(i, tooltipData, line)
    end
  end,
  LastUnique = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_UNIQUE, L_ITEM_UNIQUE_MULTIPLE, L_ITEM_UNIQUE_EQUIPPABLE, L_ITEM_LIMIT_CATEGORY_MULTIPLE, L_ITEM_LIMIT_CATEGORY) then
      return SetContext(i-1, tooltipData, line)
    end
  end,
  Locked = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, lockedPattern) then -- text isn't always red
      return SetContext(i, tooltipData, line)
    end
  end,
  LockedWithProfession = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.RED and MatchesAny(line.textLeftTextStripped, L_ITEM_MIN_SKILL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RedType = function(i, tooltipData, line)
    if line.colorRight == Addon.colors.RED then
      return SetContext(i, tooltipData, line)
    elseif line.colorLeft == Addon.colors.RED then
      for _, alt in ipairs(Addon:Squish{
        contexts.RequiredEnchant,
        contexts.RequiredClasses,
        contexts.RequiredRaces,
        contexts.RequiredLevel,
        contexts.RequiredRep,
        contexts.RequiredEnchantOnUse,
      }) do
        local increment = contextActions[alt](alt, tooltipData, line)
        if increment then
          return alt - i + increment
        end
      end
      -- didn't match any other possible red line
      if not MatchesAny(line.textLeftTextStripped, L_ITEM_REQ_SKILL) then
        return SetContext(i, tooltipData, line)
      end
    end
  end,
  Reforged = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.GREEN and MatchesAny(line.textLeftTextStripped, Addon.L["Reforged"]) then -- don't replace locale reference with local version since the globalstring doesn't exist in older flavors
      return SetContext(i, tooltipData, line)
    end
  end,
  Damage = function(i, tooltipData, line)
    if tooltipData.isWeapon and MatchesAny(line.textLeftTextStripped, L_DAMAGE_TEMPLATE, L_DAMAGE_TEMPLATE_WITH_SCHOOL, L_SINGLE_DAMAGE_TEMPLATE) then
      local speed = strMatch(line.textRightText or "", numberPattern)
      if not speed then return end -- SINGLE_DAMAGE_TEMPLATE can match unrelated lines, like in Chaotic gems
      tooltipData.speedStringFull = line.textRightText
      tooltipData.speedString     = speed
       -- actual DECIMAL_SEPERATOR is used to write speed
      if DECIMAL_SEPERATOR ~= "." then
        speed = strGsub(speed, "%"..DECIMAL_SEPERATOR, ".")
      end
      tooltipData.speed = tonumber(speed)
      return SetContext(i, tooltipData, line)
    end
  end,
  DamageBonus = function(i, tooltipData, line)
    if tooltipData.speed and line.colorLeft == Addon.colors.WHITE and MatchesAny(line.textLeftTextStripped, L_PLUS_SINGLE_DAMAGE_TEMPLATE, L_PLUS_DAMAGE_TEMPLATE, L_PLUS_SINGLE_DAMAGE_TEMPLATE_WITH_SCHOOL, L_PLUS_DAMAGE_TEMPLATE_WITH_SCHOOL) then
      for _, alt in ipairs(Addon:Squish{
        contexts.LastBaseStat,
      }) do
        local increment = contextActions[alt](alt, tooltipData, line)
        if increment then
          return alt - i + increment
        end
      end
      -- didn't match any other possible line
      local min, max = strMatch(line.textLeftTextStripped, "(" .. numberPattern .. ") ?%- ?(" .. numberPattern .. ")")
      if min then
        tooltipData.damageBonus = {Addon:ToNumber(min), Addon:ToNumber(max)}
      else
        local n = Addon:ToNumber(strMatch(line.textLeftTextStripped, numberPattern))
        tooltipData.damageBonus = {n, n}
      end
      return SetContext(i, tooltipData, line)
    end
  end,
  DamagePerSecond = function(i, tooltipData, line)
  if tooltipData.speed then
    local _, dps = MatchesAny(line.textLeftTextStripped, L_DPS_TEMPLATE)
      if dps then
        tooltipData.dps = tonumber(dps) -- always uses period as decimal
        return SetContext(i, tooltipData, line)
      end
    end
  end,
  Armor = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ARMOR_TEMPLATE) and not strFind(line.textLeftTextStripped, "%+") then
      if line.colorLeft == Addon.colors.GREEN then
        return SetContext(contexts.BonusArmor, tooltipData, line)
      else
        return SetContext(i, tooltipData, line)
      end
    end
  end,
  Block = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_SHIELD_BLOCK_TEMPLATE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  LastBaseStat = function(i, tooltipData, line)
    if not line.texture then
      if line.colorLeft == Addon.colors.WHITE and strFind(line.textLeftTextStripped, "[%+%-5]") then
        local stat = MatchesAny(line.textLeftTextStripped, L_ITEM_MOD_STAMINA, L_ITEM_MOD_STRENGTH, L_ITEM_MOD_AGILITY, L_ITEM_MOD_INTELLECT, L_ITEM_MOD_SPIRIT, L_ITEM_RESIST_SINGLE)
        if stat then
          if stat == L_ITEM_RESIST_SINGLE then
            local n = strMatch(line.textLeftTextStripped, numberPattern)
            tooltipData.resistN = tooltipData.resistN or n
            if tooltipData.resistN == n then
              tooltipData.resists = tooltipData.resists + 1
            end
          end
          return SetContext(i-1, tooltipData, line)
        else
          for stat, statInfo in pairs(Addon.statsInfo) do
            local normalForm = statInfo.ConvertToNormalForm and statInfo:ConvertToNormalForm(line.textLeftTextStripped)
            if normalForm then
              line.stat       = stat
              line.normalForm = normalForm
              return SetContext(i-1, tooltipData, line)
            end
          end
        end
      elseif line.colorLeft == Addon.colors.GREEN then
        if MatchesAny(line.textLeftTextStripped, L_ITEM_MOD_MASTERY_RATING_SHORT) then
          line.stat       = "Mastery Rating"
          line.normalForm = Addon.statsInfo["Mastery Rating"]:ConvertToNormalForm(line.textLeftTextStripped)
          return SetContext(i-1, tooltipData, line)
        elseif MatchesAny(line.textLeftTextStripped, L_ITEM_MOD_BONUS_ARMOR_SHORT) then
          line.stat       = "Bonus Armor"
          line.normalForm = Addon.statsInfo["Bonus Armor"]:ConvertToNormalForm(line.textLeftTextStripped)
          return SetContext(i-1, tooltipData, line)
        end
      end
    end
  end,
  Enchant = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.colors.GREEN then
      tooltipData.locs.enchant = line.i
      tooltipData.foundEnchant = true
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredEnchant = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.colors.RED and MatchesAny(line.textLeftTextStripped, L_ENCHANT_ITEM_REQ_SKILL, L_ENCHANT_ITEM_MIN_SKILL, L_ENCHANT_ITEM_REQ_LEVEL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  WeaponEnchant = function(i, tooltipData, line)
    if tooltipData.isWeapon and line.colorLeft == Addon.colors.GREEN then
      for _, alt in ipairs(Addon:Squish{
        contexts.ProposedEnchant,
        contexts.LastSecondaryStat,
        contexts.MadeBy,
        contexts.SocketHint,
      }) do
        local increment = contextActions[alt](alt, tooltipData, line)
        if increment then
          return alt - i + increment
        end
      end
      -- didn't match any other possible green line
      return SetContext(i, tooltipData, line)
    end
  end,
  Rune = function(i, tooltipData, line)
    if tooltipData.isEngravable and line.colorLeft == Addon.colors.GREEN then
      for _, alt in ipairs(Addon:Squish{
        contexts.ProposedEnchant,
        contexts.LastSecondaryStat,
        contexts.MadeBy,
        contexts.SocketHint,
      }) do
        local increment = contextActions[alt](alt, tooltipData, line)
        if increment then
          return alt - i + increment
        end
      end
      -- didn't match any other possible green line
      return SetContext(i, tooltipData, line)
    end
  end,
  LastSocket = function(i, tooltipData, line)
    if line.texture then
      if line.colorLeft == Addon.colors.RED then
        tooltipData.unmatchedRedSockets = (tooltipData.unmatchedRedSockets or 0) + 1
      end
      line.socketType = Addon:GetGemColor(line.texture[1], line.textLeftText)
      return SetContext(i-2, tooltipData, line)
    end
  end,
  LastRequiredSocket = function(i, tooltipData, line)
    if (tooltipData.unmatchedRedSockets or 0) > 0 and line.colorLeft == Addon.colors.RED and MatchesAny(line.textLeftTextStripped, L_SOCKET_ITEM_REQ_SKILL, L_ENCHANT_ITEM_REQ_SKILL, L_ENCHANT_ITEM_MIN_SKILL, L_ENCHANT_ITEM_REQ_LEVEL) then
      return SetContext(i-2, tooltipData, line)
    end
  end,
  ProposedEnchant = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.GREEN and MatchesAny(line.textLeftTextStripped, L_ITEM_PROPOSED_ENCHANT) then
      return SetContext(i, tooltipData, line)
    end
  end,
  EnchantHint = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.PURE_RED and MatchesAny(line.textLeftTextStripped, L_ITEM_ENCHANT_DISCLAIMER) then
      return SetContext(i, tooltipData, line)
    end
  end,
  SocketBonus = function(i, tooltipData, line)
    local prefix = MatchesAny(line.textLeftTextStripped, L_ITEM_SOCKET_BONUS)
    if prefix then
      line.prefix                  = prefix
      tooltipData.locs.socketBonus = line.i
      return SetContext(i, tooltipData, line)
    end
  end,
  Durability = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_DURABILITY_TEMPLATE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredRaces = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_RACES_ALLOWED) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredClasses = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_CLASSES_ALLOWED) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredLevel = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_MIN_LEVEL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  ItemLevel = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_LEVEL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredSkill = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_MIN_SKILL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  AlreadyKnown = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_SPELL_KNOWN) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredRep = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_REQ_REPUTATION) then
      return SetContext(i, tooltipData, line)
    end
  end,
  LastSecondaryStat = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.GREEN then
      local prefix = StartsWithAny(line.textLeftTextStripped, L_ITEM_SPELL_TRIGGER_ONEQUIP, L_ITEM_SPELL_TRIGGER_ONUSE, L_ITEM_SPELL_TRIGGER_ONPROC)
      if prefix then
        line.prefix = prefix
        return SetContext(i-1, tooltipData, line)
      elseif MatchesAny(line.textLeftTextStripped, L_ITEM_RANDOM_ENCHANT, L_ITEM_MOD_FERAL_ATTACK_POWER) then
        return SetContext(i-1, tooltipData, line)
      else -- check for extra stat captures
        for _, stat in ipairs{"Attack Power In Forms"} do
          local StatInfo = Addon.statsInfo[stat]
          local normalForm = StatInfo and StatInfo.ConvertToNormalForm and StatInfo:ConvertToNormalForm(line.textLeftTextStripped)
          if normalForm then
            line.stat       = stat
            line.normalForm = normalForm
            return SetContext(i-1, tooltipData, line)
          end
        end
      end
    end
  end,
  RecipeUse = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.WHITE then
      local prefix = StartsWithAny(line.textLeftTextStripped, L_ITEM_SPELL_TRIGGER_ONUSE)
      if prefix then
        line.prefix = prefix
        return SetContext(i, tooltipData, line)
      end
    end
  end,
  Charges = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_SPELL_CHARGES_1, L_ITEM_SPELL_CHARGES_NONE) or L_ITEM_SPELL_CHARGES_2 and MatchesAny(line.textLeftTextStripped, L_ITEM_SPELL_CHARGES_2) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Embed = function(i, tooltipData, line)
    if StartsWithAny(line.textLeftTextStripped, "\n") then
      return SetContext(i, tooltipData, line)
    end
  end,
  EnchantOnUse = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.colors.GREEN and StartsWithAny(line.textLeftTextStripped, L_ITEM_SPELL_TRIGGER_ONUSE) then
      tooltipData.locs.enchant = line.i
      line.prefix              = L_ITEM_SPELL_TRIGGER_ONUSE
      tooltipData.foundEnchant = true
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredEnchantOnUse = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.colors.RED and MatchesAny(line.textLeftTextStripped, L_ENCHANT_ITEM_REQ_SKILL, L_ENCHANT_ITEM_MIN_SKILL, L_ENCHANT_ITEM_REQ_LEVEL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  SetName = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_SET_NAME) then
      return SetContext(i, tooltipData, line)
    end
  end,
  LastSetPiece = function(i, tooltipData, line)
    if not tooltipData.isGem and strStarts(line.textLeftText, "  ") then
      return SetContext(i-1, tooltipData, line)
    end
  end,
  LastSetBonus = function(i, tooltipData, line)
    local prefix = (line.colorLeft == Addon.colors.GRAY or line.colorLeft == Addon.colors.GREEN) and MatchesAny(line.textLeftTextStripped, L_ITEM_SET_BONUS_GRAY, L_ITEM_SET_BONUS, L_ITEM_SET_BONUS_NO_VALID_SPEC)
    if prefix then
      line.prefix = prefix
      return SetContext(i-1, tooltipData, line)
    end
  end,
  Cooldown = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_COOLDOWN_TIME) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Description = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.FLAVOR and MatchesAny(line.textLeftTextStripped, "\"%s\"") then
      tooltipData.locs.description = line.i
      return SetContext(i, tooltipData, line)
    end
  end,
  MadeBy = function(i, tooltipData, line)
    local madeType = line.colorLeft == Addon.colors.GREEN and MatchesAny(line.textLeftTextStripped, L_ITEM_CREATED_BY, L_ITEM_WRAPPED_BY, L_ITEM_WRITTEN_BY)
    if madeType then
      if madeType == L_ITEM_CREATED_BY then
        return SetContext(i, tooltipData, line)
      elseif madeType == L_ITEM_WRAPPED_BY then
        return SetContext(i+1, tooltipData, line)
      elseif madeType == L_ITEM_WRITTEN_BY then
        return SetContext(i+2, tooltipData, line)
      end
    end
  end,
  SocketHint = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.GREEN and StartsWithAny(line.textLeftTextStripped, L_ITEM_SOCKETABLE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Refundable = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.SKY_BLUE and MatchesAny(line.textLeftTextStripped, L_REFUND_TIME_REMAINING) then
      return SetContext(i, tooltipData, line)
    end
  end,
  SoulboundTradeable = function(i, tooltipData, line)
    if line.colorLeft == Addon.colors.SKY_BLUE and MatchesAny(line.textLeftTextStripped, L_BIND_TRADE_TIME_REMAINING) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Delta = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, L_ITEM_DELTA_DESCRIPTION, L_ITEM_DELTA_MULTIPLE_COMPARISON_DESCRIPTION) then
      -- crop the tooltip here
      tooltipData.numLines = line.i - 2
      for i = #tooltipData, tooltipData.numLines + 1, -1 do
        table.remove(tooltipData, i)
      end
      return SetContext(i, tooltipData, line)
    end
  end,
  RecipeMats = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, "\n" .. L_LOCKED_WITH_ITEM) then
      return SetContext(i, tooltipData, line)
    end
  end,
}, nil, contexts)

function Addon:RecognizeLineTypes(tooltipData)
  tooltipData.context = contexts.Init
  local i = 1
  while i <= #tooltipData do
    local line = tooltipData[i]
    if line.textLeftTextStripped == "" and not line.texture and not line.moneyFrame then
      line.oldType = line.type
      line.type    = "Padding"
    else
      for j = tooltipData.context + 1, #contexts do
        if contextActions[j] then
          local increment = contextActions[j](j, tooltipData, line)
          if increment then
            j = j + increment
            break
          end
        end
      end
    end
    i = i + 1
  end
  
  if #tooltipData > 0 then
    contextAscensions[contexts.Tail](contexts.Tail, tooltipData, tooltipData[#tooltipData], tooltipData.context)
  end
  
  -- Retroactively find enchant if it was missed.
  -- Assume that it was an on use enchant which appeared after secondary stats
  if tooltipData.hasEnchant and not tooltipData.foundEnchant then
    for i = #tooltipData, 1, -1 do
      local line = tooltipData[i]
      if line.type == "SecondaryStat" and line.prefix == L_ITEM_SPELL_TRIGGER_ONUSE then
        local lastLine = tooltipData[i-1]
        if lastLine and lastLine.type == "Padding" then
          line.type = "EnchantOnUse"
          tooltipData.foundEnchant = true
          break
        end
      end
    end
  end
  
  -- should have found the second transmog line
  if tooltipData.seekingTransmog then
    self:Warnf("Didn't find second transmog line on %s", tooltipData.link)
  end
  
  tooltipData.locs, tooltipData.embedLocs = tooltipData.embedLocs or tooltipData.locs, tooltipData.locs
end