
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local lastUse

local lineOffsets = {
  before = -1,
  after  =  1,
}
local enchantLines = {
  Enchant         = true,
  ProposedEnchant = true,
  EnchantHint     = true,
}
local padLocations = {
  [-1] = {
    BaseStat      = function(line) return line.type == "BaseStat"      or Addon:GetOption"combineStats" and (line.type == "SecondaryStat" or Addon:GetOption("doReorder", "EnchantOnUse") and line.type == "EnchantOnUse") end,
    SecondaryStat = function(line) return(line.type == "SecondaryStat" or Addon:GetOption("doReorder", "EnchantOnUse") and (line.type == "EnchantOnUse" or line.type == "RequiredEnchantOnUse")) and not Addon:GetOption"combineStats" end,
    Enchant       = function(line) return enchantLines[line.type]      or not Addon:GetOption("doReorder", "EnchantOnUse") and line.type == "EnchantOnUse" end,
    WeaponEnchant = function(line) return line.type == "WeaponEnchant" end,
    Socket        = function(line) return line.type == "Socket"        end,
    SetName       = function(line) return line.type == "SetName"       end,
    SetBonus      = function(line) return line.type == "SetBonus"      end,
  },
  [1] = {
    BaseStat      = function(line) return line.type == "BaseStat"      or Addon:GetOption"combineStats" and (line.type == "SecondaryStat" or lastUse == "SecondaryStat" and (line.type == "Charges" or line.type == "Cooldown") or Addon:GetOption("doReorder", "EnchantOnUse") and (line.type == "EnchantOnUse" or line.type == "RequiredEnchantOnUse")) end,
    SecondaryStat = function(line) return(line.type == "SecondaryStat" or lastUse == "SecondaryStat" and (line.type == "Charges" or line.type == "Cooldown") or Addon:GetOption("doReorder", "EnchantOnUse") and (line.type == "EnchantOnUse" or line.type == "RequiredEnchantOnUse")) and not Addon:GetOption"combineStats" end,
    Enchant       = function(line) return enchantLines[line.type]      or lastUse == "EnchantOnUse" and (line.type == "Charges" or line.type == "Cooldown") or line.type == "RequiredEnchant" or not Addon:GetOption("doReorder", "EnchantOnUse") and (line.type == "EnchantOnUse" or line.type == "RequiredEnchantOnUse") end,
    WeaponEnchant = function(line) return line.type == "WeaponEnchant" end,
    SocketBonus   = function(line) return line.type == "SocketBonus"   or line.type == "Socket" or Addon:GetOption("doReorder", "SocketHint") and line.type == "SocketHint" end,
    SetPiece      = function(line) return line.type == "SetPiece"      end,
    SetBonus      = function(line) return line.type == "SetBonus"      end,
  }
}

function Addon:CalculatePadding(tooltipData)
  lastUse = tooltipData.lastUse
  local padded  = {}
  
  for cat, offset in pairs(lineOffsets) do
    local padLocation = padLocations[offset]
    local i = offset == 1 and #tooltipData or 1
    local usedPaddingRecently = false
    while tooltipData[i] do
      local line = tooltipData[i]
      if line.type == "Padding" then
        if line.used then
          usedPaddingRecently = true
        end
      else
        local otherLine = tooltipData[i + offset]
        for padType, Recognize in pairs(padLocation) do
          if self:GetOption("pad", cat, padType) and not padded[padType] and Recognize(line) then
            if otherLine then
              if otherLine.type == "Padding" then
                if not usedPaddingRecently then
                  otherLine.used = true
                end
              else
                if offset == 1 then
                  otherLine.pad = true
                else
                  line.pad = true
                end
              end
            -- elseif offset == 1 then
              -- tooltipData.padLast = true
            end
            padded[padType] = true
          end
        end
        usedPaddingRecently = false
      end
      i = i - offset
    end
    wipe(padded)
  end
  
  local found
  if self:GetOption("pad", "before", "BonusEffect") then
    for i, line in ipairs(tooltipData) do
      if line.type == "SecondaryStat" or Addon:GetOption("doReorder", "EnchantOnUse") and line.type == "EnchantOnUse" then
        found = true
        if not line.stat then
          local lastLine = tooltipData[i-1]
          if lastLine then
            if lastLine.type == "Padding" then
              lastLine.used = true
            else
              line.pad = true
            end
            break
          end
        end
      elseif found then
        break
      end
    end
  end
  
  -- hide unused padding
  for i, line in ipairs(tooltipData) do
    if line.type == "Padding" and not line.used then
      if Addon:GetDebugView"paddingConversionFailures" then
        local pre = Addon:GetDebugView"tooltipLineNumbers" and format("[%d] ", line.i) or ""
        line.rewordLeft = pre .. "[Padding Failure] " .. line.textLeftText
      else
        line.hide = true
      end
    end
  end
  
  -- pad last line
  do
    local lastLine = tooltipData[#tooltipData]
    if self:GetOption"padLastLine" then
      if lastLine.type == "Padding" then
        if lastLine.hide then
          lastLine.hide = nil
        end
      else
        tooltipData.padLast = true
      end
    else
      if lastLine.type == "Padding" then
        lastLine.hide = true
      end
    end
  end
end
