
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


cacheLineTypes = setmetatable({
  Title           = false,
  Damage          = false,
  DamagePerSecond = false,
}, {__index = function() return true end})

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
  
  local cache = self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "text") and not RatingBuster and Addon:CheckTable(textCache, line.type, line.textLeftText, line.textRightText or "")
  if cache then
    text, line.rewordRight = unpack(cache, 1, 2)
  else
    
    
    if line.stat then
      if self:GetOption("allow", "reword") and self:GetOption("doReword", line.stat) then
        text = line.normalForm
      end
    else
      Addon:Switch(line.type, {
        Title = function()
          text = self:RewordTitle(text, tooltipData.icon)
        end,
        Quality = function()
          text = self:RewordQuality(text, tooltipData)
        end,
        Binding = function()
          text = self:RewordBinding(text, line.bindType)
        end,
        Damage = function()
          text = self:ModifyWeaponDamage(text, tooltipData.dps, tooltipData.speed)
          if not line.hideRight then
            local rightText = self:ModifyWeaponSpeed(line.textRightText, tooltipData.speed, tooltipData.speedString)
            if rightText ~= line.textRightText then
              line.rewordRight = rightText
            end
          end
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
    
    if self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "text") and cacheLineTypes[line.type] then
      Addon:MakeTable(textCache, line.type, line.textLeftText, line.textRightText or "", {text, line.rewordRight})
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
