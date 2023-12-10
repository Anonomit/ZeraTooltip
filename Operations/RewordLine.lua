
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match
local strGsub  = string.gsub
local strFind  = string.find

local cacheSize = 0
local textCache = {}
function Addon:WipeTextCache()
  wipe(textCache)
  cacheSize = 0
end
function Addon:GetTextCacheSize()
  return cacheSize
end
Addon:RegisterOptionSetHandler(Addon.WipeTextCache)
Addon:RegisterCVarCallback("colorblindMode", Addon.WipeTextCache)


local miscRewordLines = {
  SecondaryStat = true,
  Enchant       = true,
  EnchantOnUse  = true,
  Socket        = true,
  SetBonus      = true,
}

function Addon:RewordLine(tooltip, line, tooltipData)
  if not line.type or line.type == "Padding" then
    if Addon:GetDebugView"tooltipLineNumbers" then
      line.rewordLeft = format("[%d] ", line.i) .. line.textLeftText
    end
    return
  end
  
  local text = line.textLeftText
  
  if self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "text") and textCache[line.type] and textCache[line.type][line.textLeftText] then
    text, line.rewordRight = unpack(textCache[line.type][line.textLeftText], 1, 2)
  else
    
    
    if line.stat then
      if self:GetOption("allow", "reword") and self:GetOption("doReword", line.stat) then
        text = line.normalForm
      end
    elseif line.type == "Title" then
      text = self:RewordTitle(text, tooltipData.icon)
    elseif line.type == "Quality" then
      text = self:RewordQuality(text, tooltipData)
    elseif line.type == "Binding" then
      text = self:RewordBinding(text, line.bindType)
    elseif line.type == "Damage" then
      text = self:ModifyWeaponDamage(text, tooltipData.dps, tooltipData.speed)
      if not line.hideRight then
        local rightText = self:ModifyWeaponSpeed(line.textRightText, tooltipData.speed, tooltipData.speedString)
        if rightText ~= line.textRightText then
          line.rewordRight = rightText
        end
      end
    elseif line.type == "DamagePerSecond" then
      text = self:ModifyWeaponDamagePerSecond(text)
      if not line.hideRight and tooltipData.speed then
        local rightText = self:ModifyWeaponSpeedbar(tooltipData.speed, tooltipData.speedString, tooltipData.speedStringFull)
        if rightText then
          line.rewordRight = rightText
        end
      end
    elseif line.type == "Armor" then
      text = self:RewordArmor(text)
    elseif line.type == "BonusArmor" then
      text = self:RewordBonusArmor(text)
    elseif line.type == "Block" then
      text = self:RewordBlock(text)
    elseif line.type == "Enchant" then
      text = self:ModifyEnchantment(text)
    elseif line.type == "WeaponEnchant" then
      text = self:ModifyWeaponEnchantment(text)
    elseif line.type == "Durability" then
      text = self:ModifyDurability(text)
    elseif line.type == "RequiredClasses" then
      text = self:ModifyRequiredClasses(text)
    elseif line.type == "EnchantOnUse" then
      -- Reworded after prefix rewording takes place
    elseif line.type == "Refundable" then
      if self:GetOption("doReword", line.type) then
        text = self:RewordRefundable(text)
      end
    elseif line.type == "SoulboundTradeable" then
      if self:GetOption("doReword", line.type) then
        text = self:RewordTradeable(text)
      end
    elseif line.type == "SocketHint" then
      text = self:RewordSocketHint(text)
    end
    if not line.stat and miscRewordLines[line.type] and self:GetOption("doReword", "Miscellaneous") then
      -- localeExtra replacements
      if self:GetOption("allow", "reword") then
        for _, definition in ipairs(self:GetExtraReplacements()) do
          for _, rule in ipairs(definition) do
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
              text = strGsub(text, input, output)
              break
            end
          end
        end
      end
    end
    
    -- check compatibility
    if line.realTextLeft ~= line.textLeftText then
      -- some other addon is modifying tooltip text
      
      -- RatingBuster compatibility
      if RatingBuster and RatingBuster.ProcessLine then
        text = RatingBuster:ProcessLine(text) or text
      end
    end
    
    -- swap in localized nickname, fix prefix
    if self:GetOption("allow", "reword") then
      if line.stat then
        text = self.statsInfo[line.stat]:Reword(text, line.normalForm)
        if line.newPrefix then
          if strFind(line.newPrefix, "%%") then
            text = format(line.newPrefix, text)
          else
            text = line.newPrefix .. text
          end
        end
      end
    end
    
    if line.prefix and not line.stat then
      text = self:ModifyPrefix(text, line.prefix)
      if line.type == "EnchantOnUse" then
        text = self:ModifyOnUseEnchantment(text)
      end
    end
    
    if self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "text") then
      textCache[line.type] = textCache[line.type] or {}
      textCache[line.type][line.textLeftText] = {text, line.rewordRight}
      cacheSize = cacheSize + 1
    end
  end
  
  if Addon:GetDebugView"tooltipLineNumbers" then
    text = format("[%d] ", line.i) .. text
  end
  
  if text ~= line.realTextLeft and (text ~= line.textLeftText or line.recolorLeft) then
    line.rewordLeft = text
  end
end
