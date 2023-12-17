
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strFind  = string.find
local strMatch = string.match

local tinsert = tinsert


local ITEM_CREATED_BY    = Addon.ITEM_CREATED_BY
local ITEM_WRAPPED_BY    = Addon.ITEM_WRAPPED_BY
local ITEM_MOD_STAMINA   = Addon.ITEM_MOD_STAMINA
local ITEM_MOD_STRENGTH  = Addon.ITEM_MOD_STRENGTH
local ITEM_MOD_AGILITY   = Addon.ITEM_MOD_AGILITY
local ITEM_MOD_INTELLECT = Addon.ITEM_MOD_INTELLECT
local ITEM_MOD_SPIRIT    = Addon.ITEM_MOD_SPIRIT




local numberPattern = "[%d%"..DECIMAL_SEPERATOR.."]+"


local bindTypes = {
  [ITEM_SOULBOUND]           = "AlreadyBound",
  [ITEM_BIND_ON_EQUIP]       = "Tradeable",
  [ITEM_BIND_ON_USE]         = "Tradeable",
  [ITEM_BIND_ON_PICKUP]      = "CharacterBound",
  [ITEM_BIND_TO_ACCOUNT]     = "AccountBound",
  [ITEM_BIND_TO_BNETACCOUNT] = "AccountBound",
}

local function strStarts(text, matchStr)
  return strFind(text, matchStr) == 1
end

local matchCache = {}

local function MatchesAny(text, ...)
  for _, pattern in ipairs{...} do
    matchCache[pattern] = matchCache[pattern] or Addon:ReversePattern(pattern)
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

local contexts = Addon:MakeLookupTable({
  "Init",
  "PreTitle",
  "Title",
  "Quality",
  "Heroic",
  "Binding",
  "Unique",
  "LastUnique",
  "Locked",
  "LockedWithProfession",
  "Embed",
  "Type",
  "RedType",
  "Damage",
  "DamagePerSecond",
  "Armor",
  "BonusArmor",
  "Block",
  "BaseStat",
  "LastBaseStat",
  "Enchant",
  "RequiredEnchant",
  "WeaponEnchant",
  "Rune",
  "Socket",
  "RequiredSocket",
  "LastSocket",
  "LastRequiredSocket",
  "ProposedEnchant",
  "EnchantHint",
  "SocketBonus",
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
  "Charges",
  "EnchantOnUse",
  "RequiredEnchantOnUse",
  "SetName",
  "setPiece",
  "LastSetPiece",
  "SetBonus",
  "LastSetBonus",
  "Cooldown",
  "MadeBy",
  "SocketHint",
  "Refundable",
  "SoulboundTradeable",
  "Delta",
  "RecipeMats",
  "RecipeTitle",
  "Tail",
}, nil, true)

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
  EnchantOnUse = function(context, tooltipData, line, currentContext)
    -- mark red enchantment lines if I found an "enchantment disabled" line
    if currentContext == contexts.RequiredEnchantOnUse then
      local lastLine = tooltipData[line.i-1]
      lastLine.type = "EnchantOnUse"
      lastLine.prefix = ITEM_SPELL_TRIGGER_ONUSE
      tooltipData.foundEnchant = true
    end
  end,
  RecipeTitle = function(context, tooltipData, line, currentContext)
  -- reset the base stat location
    tooltipData.locs.statStart = nil
    tooltipData.context = contexts.Title
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
    tooltipData.locs.title = line.i
    return SetContext(i, tooltipData, line)
  end,
  Quality = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.WHITE and Addon.ITEM_QUALITY_DESCRIPTIONS[line.textLeftText] or line.colorLeft == Addon.COLORS.GREEN and MatchesAny(line.textLeftTextStripped, ITEM_HEROIC) then
      tooltipData.locs.quality = line.i
      if GetCVarBool"colorblindMode" then
        return SetContext(i, tooltipData, line)
      else
        return SetContext(i+1, tooltipData, line)
      end
    end
  end,
  Binding = function(i, tooltipData, line)
    local bindType = MatchesAny(line.textLeftTextStripped, ITEM_SOULBOUND, ITEM_BIND_ON_EQUIP, ITEM_BIND_ON_USE, ITEM_BIND_ON_PICKUP, ITEM_BIND_TO_ACCOUNT, ITEM_BIND_TO_BNETACCOUNT)
    if bindType then
      tooltipData.locs.binding = line.i
      line.bindType            = bindTypes[bindType]
      return SetContext(i, tooltipData, line)
    end
  end,
  LastUnique = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_UNIQUE, ITEM_UNIQUE_MULTIPLE, ITEM_UNIQUE_EQUIPPABLE, ITEM_LIMIT_CATEGORY_MULTIPLE, ITEM_LIMIT_CATEGORY) then
      return SetContext(i-1, tooltipData, line)
    end
  end,
  Locked = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, LOCKED) then -- text isn't always red
      return SetContext(i, tooltipData, line)
    end
  end,
  LockedWithProfession = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.RED and MatchesAny(line.textLeftTextStripped, ITEM_MIN_SKILL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  Embed = function(i, tooltipData, line)
    if StartsWithAny(line.textLeftTextStripped, "\n") then
      return SetContext(i, tooltipData, line)
    end
  end,
  RedType = function(i, tooltipData, line)
    if line.colorRight == Addon.COLORS.RED then
      return SetContext(i, tooltipData, line)
    elseif line.colorLeft == Addon.COLORS.RED then
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
      if line.colorLeft == Addon.COLORS.GREEN then
        return SetContext(contexts.BonusArmor, tooltipData, line)
      else
        return SetContext(i, tooltipData, line)
      end
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
        if stat == ITEM_RESIST_SINGLE then
          local n = strMatch(line.textLeftTextStripped, "(%d+)")
          tooltipData.resistN = tooltipData.resistN or n
          if tooltipData.resistN == n then
            tooltipData.resists = tooltipData.resists + 1
          end
        end
        return SetContext(i-1, tooltipData, line)
      else
        for _, stat in ipairs{"Attack Power In Forms", "Arcane Damage", "Fire Damage", "Nature Damage", "Frost Damage", "Shadow Damage", "Holy Damage"} do
          for _, rule in ipairs(Addon:GetExtraStatCapture(stat) or {}) do
            if strMatch(line.textLeftTextStripped, rule.INPUT) then
              return SetContext(i-1, tooltipData, line)
            end
          end
        end
      end
    end
  end,
  Enchant = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.COLORS.GREEN then
      tooltipData.locs.enchant = line.i
      tooltipData.foundEnchant = true
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredEnchant = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.COLORS.RED and MatchesAny(line.textLeftTextStripped, ENCHANT_ITEM_REQ_SKILL, ENCHANT_ITEM_MIN_SKILL, ENCHANT_ITEM_REQ_LEVEL) then
      return SetContext(i, tooltipData, line)
    end
  end,
  WeaponEnchant = function(i, tooltipData, line)
    if tooltipData.isWeapon and line.colorLeft == Addon.COLORS.GREEN then
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
  Rune = Addon.isSoD and function(i, tooltipData, line)
    if tooltipData.isEngravable and line.colorLeft == Addon.COLORS.GREEN then
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
  end or nil,
  LastSocket = Addon.expansionLevel >= Addon.expansions.tbc and function(i, tooltipData, line)
    if line.texture then
      if line.colorLeft == Addon.COLORS.RED then
        tooltipData.unmatchedRedSockets = (tooltipData.unmatchedRedSockets or 0) + 1
      end
      line.socketType = Addon:GetGemColor(line.texture[1], line.textLeftText)
      return SetContext(i-2, tooltipData, line)
    end
  end or nil,
  LastRequiredSocket = Addon.expansionLevel >= Addon.expansions.tbc and function(i, tooltipData, line)
    if (tooltipData.unmatchedRedSockets or 0) > 0 and line.colorLeft == Addon.COLORS.RED and MatchesAny(line.textLeftTextStripped, SOCKET_ITEM_REQ_SKILL, ENCHANT_ITEM_REQ_SKILL, ENCHANT_ITEM_MIN_SKILL, ENCHANT_ITEM_REQ_LEVEL) then
      return SetContext(i-2, tooltipData, line)
    end
  end or nil,
  ProposedEnchant = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.GREEN and MatchesAny(line.textLeftTextStripped, ITEM_PROPOSED_ENCHANT) then
      return SetContext(i, tooltipData, line)
    end
  end,
  EnchantHint = function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.PURE_RED and MatchesAny(line.textLeftTextStripped, ITEM_ENCHANT_DISCLAIMER) then
      return SetContext(i, tooltipData, line)
    end
  end,
  SocketBonus = Addon.expansionLevel >= Addon.expansions.tbc and function(i, tooltipData, line)
  local prefix = MatchesAny(line.textLeftTextStripped, ITEM_SOCKET_BONUS)
    if prefix then
      line.prefix                  = prefix
      tooltipData.locs.socketBonus = line.i
      return SetContext(i, tooltipData, line)
    end
  end or nil,
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
    if line.colorLeft == Addon.COLORS.GREEN then
      local prefix = StartsWithAny(line.textLeftTextStripped, ITEM_SPELL_TRIGGER_ONEQUIP, ITEM_SPELL_TRIGGER_ONUSE, ITEM_SPELL_TRIGGER_ONPROC)
      if prefix then
        line.prefix = prefix
        return SetContext(i-1, tooltipData, line)
      elseif MatchesAny(line.textLeftTextStripped, ITEM_RANDOM_ENCHANT, ITEM_MOD_FERAL_ATTACK_POWER) then
        return SetContext(i-1, tooltipData, line)
      else -- check for extra stat captures
        for _, stat in ipairs{"Attack Power In Forms"} do
          for _, rule in ipairs(Addon:GetExtraStatCapture(stat) or {}) do
            if strMatch(line.textLeftTextStripped, rule.INPUT) then
              return SetContext(i-1, tooltipData, line)
            end
          end
        end
      end
    end
  end,
  Charges = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, Addon.ITEM_SPELL_CHARGES1, ITEM_SPELL_CHARGES_NONE) or Addon.ITEM_SPELL_CHARGES2 and MatchesAny(line.textLeftTextStripped, Addon.ITEM_SPELL_CHARGES2) then
      return SetContext(i, tooltipData, line)
    end
  end,
  EnchantOnUse = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.COLORS.GREEN and StartsWithAny(line.textLeftTextStripped, ITEM_SPELL_TRIGGER_ONUSE) then
      tooltipData.locs.enchant = line.i
      line.prefix              = ITEM_SPELL_TRIGGER_ONUSE
      tooltipData.foundEnchant = true
      return SetContext(i, tooltipData, line)
    end
  end,
  RequiredEnchantOnUse = function(i, tooltipData, line)
    if tooltipData.hasEnchant and not tooltipData.foundEnchant and line.colorLeft == Addon.COLORS.RED and MatchesAny(line.textLeftTextStripped, ENCHANT_ITEM_REQ_SKILL, ENCHANT_ITEM_MIN_SKILL, ENCHANT_ITEM_REQ_LEVEL) then
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
  Cooldown = function(i, tooltipData, line)
    if MatchesAny(line.textLeftTextStripped, ITEM_COOLDOWN_TIME) then
      return SetContext(i, tooltipData, line)
    end
  end,
  MadeBy = function(i, tooltipData, line)
    local madeType = line.colorLeft == Addon.COLORS.GREEN and MatchesAny(line.textLeftTextStripped, ITEM_CREATED_BY, ITEM_WRAPPED_BY, ITEM_WRITTEN_BY)
    if madeType then
      line.madeType = madeType
      return SetContext(i, tooltipData, line)
    end
  end,
  SocketHint = Addon.expansionLevel >= Addon.expansions.tbc and function(i, tooltipData, line)
    if line.colorLeft == Addon.COLORS.GREEN and StartsWithAny(line.textLeftTextStripped, ITEM_SOCKETABLE) then
      return SetContext(i, tooltipData, line)
    end
  end or nil,
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
  local i = 1
  while i <= #tooltipData do
    local line = tooltipData[i]
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
  
  -- this might not ever be necessary
  if #tooltipData > 0 then
    contextAscensions[contexts.Tail](contexts.Tail, tooltipData, tooltipData[#tooltipData], tooltipData.context)
  end
  
  -- Retroactively find enchant if it was missed.
  -- Assume that it was an on use enchant which appeared after secondary stats
  if tooltipData.hasEnchant and not tooltipData.foundEnchant then
    for i = #tooltipData, 1, -1 do
      local line = tooltipData[i]
      if line.type == "SecondaryStat" and line.prefix == ITEM_SPELL_TRIGGER_ONUSE then
        local lastLine = tooltipData[i-1]
        if lastLine and lastLine.type == "Padding" then
          line.type = "EnchantOnUse"
          tooltipData.foundEnchant = true
          break
        end
      end
    end
  end
end