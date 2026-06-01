
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local StatLogic

local strMatch  = string.match
local strSub    = string.sub
local strGsub   = string.gsub
local strFind   = string.find
local strLower  = string.lower

local tblSort   = table.sort

local cacheSize = 0
local textCache = {}
function Addon:WipeTextCache()
  wipe(textCache)
  cacheSize = 0
end
function Addon:PrintTextCache()
  for lineType, leftTexts in pairs(textCache) do
    self:Debugf("Line Type: %s", lineType)
    for leftText, rightTexts in pairs(leftTexts) do
      for rightText, rewords in pairs(rightTexts) do
        self:Debugf("  %s -> %s", leftText, rewords[1])
      end
    end
  end
end
function Addon:GetTextCacheSize()
  return cacheSize
end
Addon:RegisterAddonEventCallback("WIPE_CACHE", Addon.WipeTextCache)
Addon:RegisterAddonEventCallback("OPTION_SET", Addon.WipeTextCache)
Addon:RegisterCVarCallback("colorblindMode", Addon.WipeTextCache)
Addon:RegisterEventCallback("PLAYER_LEVEL_UP", Addon.WipeTextCache) -- for ratingbuster compatibility


cacheLineTypes = setmetatable({
  Title                 = false,
  Damage                = false,
  DamagePerSecond       = false,
}, {__index = function() return true end})

cacheLineStats = setmetatable({
  ["All Resistance"]    = false,
  ["Arcane Resistance"] = false,
}, {__index = function() return true end})

rewordBlacklist = setmetatable({
  Cooldown = true,
}, {__index = function() return false end})

-- lines that may contain stats embedded in arbitrary text
local embeddedStatLines = Addon:MakeLookupTable{
  "SecondaryStat",
  "Enchant",
  "EnchantOnUse",
  "Socket",
  "SetBonus",
}

-- lines on which to run miscellaneous replacement rules
local miscRewordLines = Addon:MakeLookupTable{
  "SecondaryStat",
  "Enchant",
  "EnchantOnUse",
  "Socket",
  "SetBonus",
}

function Addon:RewordLine(tooltip, line, tooltipData)
  if not line.type or line.type == "Padding" then
    if Addon:GetDebugView"tooltipLineNumbers" then
      line.rewordLeft = format("[%d] ", line.i) .. line.textLeftText
    end
    return
  end
  
  local text = line.textLeftText
  
  local cache = self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "text") and Addon:CheckTable(textCache, line.type, line.textLeftText, line.textRightText or "")
  if cache then
    text, line.rewordRight = unpack(cache, 1, 2)
  else
    
    if not line.stat and miscRewordLines[line.type] and self:GetOption("doReword", "Miscellaneous") then
      -- localeExtra replacements
      if self:GetOption("allow", "reword") then
        for _, definition in ipairs(self:GetExtraReplacements()) do
          for _, rule in ipairs(definition) do
            local foundMatch = false
            for i = 1, 5 do -- attempt applying this rule if it keeps finding matches
              local input = rule.INPUT .. "%[.。]$"
              local matches = {strMatch(text, input)}
              if #matches == 0 then
                input = rule.INPUT
                matches = {strMatch(text, input)}
              end
              if #matches > 0 then
                local output = rule.OUTPUT
                if type(rule.OUTPUT) == "function" then
                  output = rule.OUTPUT(unpack(matches))
                end
                text = strGsub(text, input, output, 1)
                foundMatch = true
              else
                break -- found no matches, so stop checking this pattern
              end
              if i == 5 then
                self:Throwf("Potential recursive pattern found: %s", definition.label)
              end
            end
            if foundMatch then
              break -- found a matching rule for this named definition, so move onto the next one
            end
          end
        end
      end
    end
    
    if line.stat then
      if self:GetOption("allow", "reword") and self:GetOption("doReword", line.stat) then
        text = line.normalForm
      end
    else
      Addon:Switch(line.type, {
        Title = function()
          text = self:RewordTitle(text, tooltipData.icon)
        end,
        TransmogHeader = function()
          text = self:RewordTransmogHeader(text)
        end,
        Transmog = function()
          text = self:RewordTransmog(text)
        end,
        Quality = function()
          text = self:RewordQuality(text, tooltipData)
        end,
        Binding = function()
          text = self:RewordBinding(text, line.bindType)
        end,
        Unique = function()
          text = self:RewordUnique(text, line.uniqueType)
        end,
        Reforged = function()
          text = self:RewordReforged(text)
        end,
        Damage = function()
          text = self:ModifyWeaponDamage(text, tooltipData.dps, tooltipData.speed, tooltipData.damageBonus)
          if not line.hideRight then
            local rightText = self:ModifyWeaponSpeed(line.textRightText, tooltipData.speed, tooltipData.speedString)
            if rightText ~= line.textRightText then
              line.rewordRight = rightText
            end
          end
        end,
        DamageBonus = function()
          text = self:ModifyWeaponDamageBonus(text, tooltipData.damageBonus)
        end,
        DamagePerSecond = function()
          text = self:ModifyWeaponDamagePerSecond(text)
          if not line.hideRight and tooltipData.speed then
            local rightText = self:ModifyWeaponSpeedbar(tooltipData.speed, tooltipData.speedString, tooltipData.speedStringFull)
            if rightText then
              line.rewordRight = rightText
            end
          end
        end,
        Armor = function()
          text = self:RewordArmor(text)
        end,
        BonusArmor = function()
          text = self:RewordBonusArmor(text)
        end,
        Block = function()
          text = self:RewordBlock(text)
        end,
        Enchant = function()
          text = self:ModifyEnchantment(text)
        end,
        WeaponEnchant = function()
          text = self:ModifyWeaponEnchantment(text)
        end,
        Rune = function()
          text = self:ModifyRune(text)
        end,
        Durability = function()
          text = self:ModifyDurability(text)
        end,
        RequiredRaces = function()
          text = self:ModifyRequiredRaces(text)
        end,
        RequiredClasses = function()
          text = self:ModifyRequiredClasses(text)
        end,
        EnchantOnUse = function()
          -- Reworded after prefix rewording takes place
        end,
        Refundable = function()
          if self:GetOption("doReword", line.type) then
            text = self:RewordRefundable(text)
          end
        end,
        SoulboundTradeable = function()
          if self:GetOption("doReword", line.type) then
            text = self:RewordTradeable(text)
          end
        end,
        SocketHint = function()
          text = self:RewordSocketHint(text)
        end,
      })
    end
    
    -- swap in localized nickname, fix prefix
    if line.stat then
      if self:GetOption("allow", "reword") then
        text = self.statsInfo[line.stat]:Reword(text, line.normalForm)
        if line.newPrefix then
          if strFind(line.newPrefix, "%%") then
            text = format(line.newPrefix, text)
          else
            text = line.newPrefix .. text
          end
        end
      end
    elseif embeddedStatLines[line.type] and (self:GetOption("allow", "reword") or self:GetOption("allow", "recolor")) then
      -- rename and recolor stats in the middle of non-stat lines
      local lowerText = strLower(text)
      local replacements = {}
      for stat, statInfo in pairs(self.statsInfo) do
        if statInfo.GetNormalName then
          local normalName = strLower(statInfo:GetNormalName())
          local capturePattern = "%+?" .. self.L["[%d,%.]+"] .. " *" .. self:CoverSpecialCharacters(normalName)
          local startI, endI = strFind(lowerText, capturePattern)
          while startI do
            tinsert(replacements, {startI, endI, stat})
            startI, endI = strFind(lowerText, self:CoverSpecialCharacters(normalName), endI+1)
          end
        end
      end
      tblSort(replacements, function(a, b) return b[1] < a[1] end)
      local highest, failed
      for _, replacement in ipairs(replacements) do
        local startI, endI, stat = unpack(replacement)
        if highest and highest >= startI then
          failed = true
        end
        highest = endI
      end
      if not failed then
        for _, replacement in ipairs(replacements) do
          local startI, endI, stat = unpack(replacement)
          local statInfo = self.statsInfo[stat]
          
          local statText = strSub(text, startI, endI)
          local replacementText = statText
          if self:GetOption("allow", "reword") then
            local plus, number = strMatch(statText, "(%+?)(" .. self.L["[%d,%.]+"] .. ")")
            if number and strFind(number, "%d") then -- needed for dealing with false positives like title line of 103945
              local defaultForm = statInfo:GetDefaultForm(number)
              local normalForm = statInfo:ConvertToNormalForm(defaultForm)
              local aliasForm = statInfo:Reword(normalForm, normalForm)
              if plus == "" then
                aliasForm = strGsub(aliasForm, "^%+", "") -- won't work in some locales
              end
              
              replacementText = aliasForm
              if self:GetOption("allow", "recolor") then
                replacementText = self:MakeColorCode(statInfo.color, replacementText)
              end
            end
          else
            if self:GetOption("allow", "recolor") then
              replacementText = self:MakeColorCode(statInfo.color, replacementText)
            end
          end
          
          text = strSub(text, 1, startI-1) .. replacementText .. strSub(text, endI+1)
        end
      end
    end
    
    -- add back in reforge info
    if line.reforgeText then
      text = text .. format(self:ChainGsub(self.L[" (Reforged from %s)"], {"%%%d%$", "%%"}), line.reforgeStat or line.reforgeText)
    end
    
    if line.prefix and not line.stat then
      text = self:ModifyPrefix(text, line.prefix)
      if line.type == "EnchantOnUse" then
        text = self:ModifyOnUseEnchantment(text)
      end
    end
    
    -- check compatibility with RatingBuster
    self:xpcall(function()
      if RatingBuster and RatingBuster.ProcessLine then
        if not StatLogic then
          StatLogic = LibStub"StatLogic"
        end
        
        local itemMinLevel, _, _, _, _, _, _, itemClass = select(5, C_Item.GetItemInfo(tooltipData.link))
        if itemMinLevel and itemClass then
          local statModContext = StatLogic:NewStatModContext({
            specGroup = RatingBuster:GetDisplayedSpecGroup(),
            level = math.max(itemMinLevel, self.MY_LEVEL),
            itemClass = itemClass,
          })
          
          if line.stat then
            local editedText = RatingBuster:ProcessLine(line.validationText, tooltipData.link, CreateColor(self:ConvertHexToRGB(line.colorLeft)), statModContext)
            if text ~= editedText then
              local addition = strMatch(editedText, " |cff%x%x%x%x%x%x%(.-%)|r")
              if addition then
                text = text .. addition
              end
            end
          else
            local editedText = RatingBuster:ProcessLine(text, tooltipData.link, CreateColor(self:ConvertHexToRGB(line.colorLeft)), statModContext)
            if text ~= editedText then
              local addition = strMatch(editedText, " |cff%x%x%x%x%x%x%(.-%)|r")
              if addition then
                text = editedText
              end
            end
          end
        end
      end
    end)
    
    if not RatingBuster and self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "text") and cacheLineTypes[line.type] and cacheLineStats[line.stat or ""] then
      Addon:StoreInTable(textCache, line.type, line.textLeftText, line.textRightText or "", {text, line.rewordRight})
      cacheSize = cacheSize + 1
    end
  end
  
  if Addon:GetDebugView"tooltipLineNumbers" and not line.fake then
    text = format("[%d] ", line.i) .. text
  end
  
  if text ~= line.realTextLeft and (text ~= line.textLeftText or line.recolorLeft) and not rewordBlacklist[line.type] then
    line.rewordLeft = text
  end
end
