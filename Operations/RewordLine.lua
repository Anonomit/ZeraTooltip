
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
Addon.onOptionSetHandlers["WipeTextCache"] = true


local miscRewordLines = {
  SecondaryStat = true,
  Enchant       = true,
  SetBonus      = true,
}

function Addon:RewordLine(tooltip, line, tooltipData)
  if not line.type or line.type == "Padding" then return end
  
  local text = line.textLeftText
  
  -- TODO: config options for indenting negative stats
  if self:GetOption("cache", "text") and textCache[line.type] and textCache[line.type][line.textLeftText] then
    text, line.rewordRight = unpack(textCache[line.type][line.textLeftText], 1, 2)
  else
    
    
    if line.stat then
      if Addon:GetOption("allow", "reword") and self:GetOption("doReword", line.stat) then
        text = line.normalForm
      end
    elseif line.type == "Binding" then
      text = self:RewordBinding(text, line.bindType)
    elseif line.type == "Damage" then
      text = self:ModifyWeaponDamage(text, tooltipData.dps, tooltipData.speed)
      if not line.hideRight then
        local rightText = Addon:ModifyWeaponSpeed(line.textRightText, tooltipData.speed, tooltipData.speedString)
        if rightText ~= line.textRightText then
          line.rewordRight = rightText
        end
      end
    elseif line.type == "DamagePerSecond" then
      text = self:ModifyWeaponDamagePerSecond(text)
      if not line.hideRight then
        local rightText = Addon:ModifyWeaponSpeedbar(tooltipData.speed, tooltipData.speedString, tooltipData.speedStringFull)
        if rightText then
          line.rewordRight = rightText
        end
      end
    elseif line.type == "Enchant" then
      text = Addon:ModifyEnchantment(text)
    elseif line.type == "WeaponEnchant" then
      text = Addon:ModifyWeaponEnchantment(text)
    elseif line.type == "Durability" then
      text = self:ModifyDurability(text)
    elseif line.type == "RequiredClasses" then
      if self:GetOption("doRecolor", line.type) then
        text = self:ChainGsub(text, unpack(self.classColorReplacements))
      end
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
      if Addon:GetOption("allow", "reword") then
        for _, definition in ipairs(self.localeExtraReplacements) do
          for _, rule in ipairs(definition) do
            local input = rule.INPUT .. "%.$"
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
              -- TODO: break again possibly? decide if I want to allow chain matching
            end
          end
        end
      end
    end
    
    -- check compatibility
    if line.realTextLeft ~= line.textLeftText then
      -- some other addon is modifying tooltip text
      
      -- RatingBuster compatibility
      -- TODO: make sure to hook after RatingBuster? optional dependency would work. or I could do the same as with InspectFrame
      -- TODO: ensure compatibility with old versions of ratingbuster?
      if RatingBuster and RatingBuster.ProcessLine then
        -- TODO: warning in case ratingbuster isn't updated?
        text = RatingBuster:ProcessLine(text) or text
      end
      
      -- TODO: LittleBuster compatibility? will have to download and look at it
      
    end
    
    -- swap in localized nickname, fix prefix
    if Addon:GetOption("allow", "reword") then
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
    end
    
    if self:GetOption("cache", "text") then
      if not textCache[line.type] then
        textCache[line.type] = {}
      end
      textCache[line.type][line.textLeftText] = {text, line.rewordRight}
      cacheSize = cacheSize + 1
    end
  end
  
  if text ~= line.realTextLeft then
    line.rewordLeft = text
  end
end
