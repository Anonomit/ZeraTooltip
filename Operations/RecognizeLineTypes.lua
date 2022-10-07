
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strFind  = string.find
local strMatch = string.match


local ITEM_CREATED_BY = ITEM_CREATED_BY
do
  local hex, text = strMatch(ITEM_CREATED_BY, "^|c%x%x(%x%x%x%x%x%x)(.*)|r$")
  ITEM_CREATED_BY = text or ITEM_CREATED_BY
end
local numberPattern = "[%d%"..DECIMAL_SEPERATOR.."]+"

local function strStarts(text, matchStr)
  return strFind(text, matchStr) == 1
end

local matchCache = {}

local function MatchesAny(text, ...)
  for _, pattern in ipairs{...} do
    if not matchCache[pattern] then
      matchCache[pattern] = Addon:ReversePattern(pattern)
    end
    local startI, endI, match = strFind(text, matchCache[pattern])
    if startI then
      return pattern, match
    end
  end
  return nil
end

local function StartsWithAny(text, ...)
  for _, pattern in ipairs{...} do
    if strStarts(text, pattern) then
      return pattern
    end
  end
  return nil
end

-- TODO: recognize charges. requires dealing with UI escape sequences
local contexts = Addon:MakeLookupTable({
  "Init",
  "PreTitle",
  "Title",
  "Difficulty",
  "Binding",
  "Unique",
  "LastUnique",
  "LockedWithProfession",
  "Embed",
  "Type",
  "RedType",
  "Damage",
  "DamagePerSecond",
  "Armor",
  "Block",
  "BaseStat",
  "LastBaseStat",
  "Enchant",
  "RequiredEnchant",
  "WeaponEnchant",
  "Socket",
  "LastSocket",
  "SocketBonus",
  "Durability",
  "RequiredRaces",
  "RequiredClasses",
  "RequiredLevel",
  "RequiredSkill",
  "AlreadyKnown",
  "RequiredRep",
  "SecondaryStat",
  "LastSecondaryStat",
  "SetName",
  "setPiece",
  "LastSetPiece",
  "SetBonus",
  "LastSetBonus",
  "MadeBy",
  "SocketHint",
  "Refundable",
  "SoulboundTradeable",
  "Delta",
  "RecipeMats",
  "RecipeTitle",
}, nil, true)

local contextAscensions = Addon:Map({
  Binding = function(context, tooltipData, line, currentContext)
    -- mark where the binding would be if it existed on this item
    if not tooltipData.binding then
      tooltipData.binding = line.i
    end
  end,
  -- Damage = function(context, tooltipData, line)
  --   local lastLine = tooltipData[line.i-1]
  --   if not lastLine.type then
  --     lastLine.type = "Type"
  --   end
  -- end,
  BaseStat = function(context, tooltipData, line, currentContext)
    -- mark where the base stats would be if they existed on this item
    if not tooltipData.statStart then
      tooltipData.statStart = line.i - 1
    end
  end,
  Enchant = function(context, tooltipData, line, currentContext)
    -- mark red enchantment lines if I found an "enchantment disabled" line
    if currentContext == contexts.RequiredEnchant then
      local lastLine = tooltipData[line.i-2]
      lastLine.type = "Enchant"
    end
  end,
  RecipeTitle = function(context, tooltipData, line, currentContext)
  -- reset the base stat location
    tooltipData.statStart = nil
    tooltipData.context = contexts.Title
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
    if line.textLeftText == CURRENTLY_EQUIPPED or line.textLeftText == DESTROY_GEM  then
      return SetContext(i, tooltipData, line)
    end
  end,
  Title = function(i, tooltipData, line)
    return SetContext(i, tooltipData, line)
  end,
  Difficulty = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_HEROIC, ITEM_HEROIC_EPIC) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Binding = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_SOULBOUND, ITEM_BIND_ON_EQUIP, ITEM_BIND_ON_USE, ITEM_BIND_ON_PICKUP, ITEM_BIND_TO_ACCOUNT, ITEM_BIND_TO_BNETACCOUNT) then
      tooltipData.binding = line.i
      return SetContext(i, tooltipData, line)
    end
  end,
  LastUnique = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_UNIQUE, ITEM_UNIQUE_MULTIPLE, ITEM_UNIQUE_EQUIPPABLE, ITEM_LIMIT_CATEGORY_MULTIPLE, ITEM_LIMIT_CATEGORY) then
      return SetContext(i-1, tooltipData, line)
    end
  end,
  LockedWithProfession = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.RED and MatchesAny(line.textLeftTextStripped, ITEM_MIN_SKILL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Embed = function(i, tooltipData, line)
    if StartsWithAny(line.textLeftTextStripped, "\n") then -- TODO: get recipes working better... if I really need to?
      return SetContext(i, tooltipData, line)
    end
  end,
  RedType = function(i, tooltipData, line)
    if line.colorRight == Addon.COLORS.RED then
      return SetContext(i, tooltipData, line)
    elseif line.colorLeft == Addon.COLORS.RED then
      for _, alt in ipairs{
        contexts.RequiredEnchant,
        contexts.RequiredClasses,
        contexts.RequiredRaces,
        contexts.RequiredLevel,
        contexts.RequiredRep,
      } do
        local increment = contextActions[alt](alt, tooltipData, line)
        if increment then
          return alt - i + increment
        end
      end
      -- didn't match any other possible red line
      return SetContext(i, tooltipData, line)
    end
  end,
  Damage = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, DAMAGE_TEMPLATE, DAMAGE_TEMPLATE_WITH_SCHOOL, SINGLE_DAMAGE_TEMPLATE) then
      local speed = strMatch(line.textRightText or "", numberPattern)
      if not speed then return end -- SINGLE_DAMAGE_TEMPLATE can match unrelated lines, like in Chaotic gems
      tooltipData.speedStringFull = line.textRightText
      tooltipData.speedString     = speed
      if DECIMAL_SEPERATOR ~= "." then
        speed = strGsub(speed, "%"..DECIMAL_SEPERATOR, ".")
      end
      tooltipData.speed = tonumber(speed)
      return SetContext(i, tooltipData, line)
    end
  end,
  DamagePerSecond = function(i, tooltipData, line)
  local _, dps = MatchesAny(line.textLeftTextStripped, DPS_TEMPLATE)
    if dps then
      tooltipData.dps = tonumber(dps)
      return SetContext(i, tooltipData, line)
    end
  end,
  Armor = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ARMOR_TEMPLATE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Block = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, SHIELD_BLOCK_TEMPLATE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  LastBaseStat = function(i, tooltipData, line)
    if not line.texture and line.colorLeft == Addon.COLORS.WHITE then
      local stat = MatchesAny(line.textLeftTextStripped, ITEM_MOD_STAMINA, ITEM_MOD_STRENGTH, ITEM_MOD_AGILITY, ITEM_MOD_INTELLECT, ITEM_MOD_SPIRIT, ITEM_RESIST_SINGLE, ITEM_RESIST_ALL)
      if stat then
        -- tooltipData.statHint = stat
        return SetContext(i-1, tooltipData, line)
      end
    end
  end,
  Enchant = function(i, tooltipData, line)
    if tooltipData.hasEnchant and line.colorLeft == Addon.COLORS.GREEN then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredEnchant = function(i, tooltipData, line)
    if tooltipData.hasEnchant and line.colorLeft == Addon.COLORS.RED and MatchesAny(line.textLeftTextStripped, ENCHANT_ITEM_REQ_SKILL, ENCHANT_ITEM_MIN_SKILL, ENCHANT_ITEM_REQ_LEVEL) then
      SetContext(i, tooltipData, line)
      return SetContext(i, tooltipData, line)
    end
  end,
  WeaponEnchant = function(i, tooltipData, line)
    if tooltipData.isWeapon and line.colorLeft == Addon.COLORS.GREEN then
      for _, alt in ipairs{
        contexts.LastSecondaryStat,
        contexts.MadeBy,
        contexts.SocketHint,
      } do
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
      return SetContext(i-1, tooltipData, line)
    end
  end,
  SocketBonus = function(i, tooltipData, line)
  local prefix = MatchesAny(line.textLeftTextStripped, ITEM_SOCKET_BONUS)
    if prefix then
      line.prefix = prefix
      return SetContext(i, tooltipData, line)
    end
  end,
  Durability = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, DURABILITY_TEMPLATE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredRaces = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_RACES_ALLOWED) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredClasses = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_CLASSES_ALLOWED) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredLevel = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_MIN_LEVEL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredSkill = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_MIN_SKILL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  AlreadyKnown = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_SPELL_KNOWN) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredRep = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_REQ_REPUTATION) then
      return SetContext(i, tooltipData, line)
    end
  end,
  LastSecondaryStat = function(i, tooltipData, line)
    local prefix = line.colorLeft == Addon.COLORS.GREEN and StartsWithAny(line.textLeftTextStripped, ITEM_SPELL_TRIGGER_ONEQUIP, ITEM_SPELL_TRIGGER_ONUSE, ITEM_SPELL_TRIGGER_ONPROC)
    if prefix then
      line.prefix = prefix
      return SetContext(i-1, tooltipData, line)
    end
    if MatchesAny(line.textLeftTextStripped, ITEM_RANDOM_ENCHANT, ITEM_MOD_FERAL_ATTACK_POWER) then
      return SetContext(i-1, tooltipData, line)
    end
  end,
  MadeBy = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.GREEN and MatchesAny(line.textLeftTextStripped, ITEM_CREATED_BY, ITEM_WRITTEN_BY, ITEM_WRAPPED_BY) then
      return SetContext(i, tooltipData, line)
    end
  end,
  SetName = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_SET_NAME) then
      return SetContext(i, tooltipData, line)
    end
  end,
  LastSetPiece = function(i, tooltipData, line)
    if strStarts(line.textLeftText, "  ") then
      return SetContext(i-1, tooltipData, line)
    end
  end,
  LastSetBonus = function(i, tooltipData, line)
  local prefix = (line.colorLeft == Addon.COLORS.GRAY or line.colorLeft == Addon.COLORS.GREEN) and MatchesAny(line.textLeftTextStripped, ITEM_SET_BONUS_GRAY, ITEM_SET_BONUS)
    if prefix then
      line.prefix = prefix
      return SetContext(i-1, tooltipData, line)
    end
  end,
  SocketHint = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.GREEN and StartsWithAny(line.textLeftTextStripped, ITEM_SOCKETABLE) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Refundable = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.SKY_BLUE and MatchesAny(line.textLeftTextStripped, REFUND_TIME_REMAINING) then
      return SetContext(i, tooltipData, line)
    end
  end,
  SoulboundTradeable = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.SKY_BLUE and MatchesAny(line.textLeftTextStripped, BIND_TRADE_TIME_REMAINING) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Delta = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_DELTA_DESCRIPTION, ITEM_DELTA_MULTIPLE_COMPARISON_DESCRIPTION) then
      -- crop the tooltip here
      tooltipData.numLines = line.i - 2
      for i = #tooltipData, tooltipData.numLines + 1, -1 do
        table.remove(tooltipData, i)
      end
      return SetContext(i, tooltipData, line)
    end
  end,
  RecipeMats = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, "\n" .. LOCKED_WITH_ITEM) then
      return SetContext(i, tooltipData, line)
    end
  end,
  RecipeTitle = function(i, tooltipData, line)
    if StartsWithAny(line.textLeftTextStripped, "\n") then
      return SetContext(i, tooltipData, line)
    end
  end,
}, nil, contexts)

function Addon:RecognizeLineTypes(tooltipData)
  tooltipData.context = contexts.Init
  local line
  local i = 1
  while i <= #tooltipData do
    line = tooltipData[i]
    if line.textLeftTextStripped == "" and not line.texture and not line.moneyFrame then
      line.type = "Padding"
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
end