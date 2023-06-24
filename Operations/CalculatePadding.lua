
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local lastUse

local lineOffsets = {
  before = -1,
  after  =  1,
}

local easyLines = {
  BaseStat        = "BaseStat",
  Enchant         = "Enchant",
  RequiredEnchant = "Enchant",
  ProposedEnchant = "Enchant",
  EnchantHint     = "Enchant",
  WeaponEnchant   = "WeaponEnchant",
  Socket          = "Socket",
  RequiredSocket  = "Socket",
  SocketBonus     = "SocketBonus",
  SetName         = "SetBonus",
  SetPiece        = "SetBonus",
  SetBonus        = "SetBonus",
}
local hardLines = Addon:MakeLookupTable{"SecondaryStat", "EnchantOnUse", "RequiredEnchantOnUse", "Charges", "Cooldown", "SocketHint"}


local function GetPadType(offset, lineType, lastUse)
  local easy = easyLines[lineType]
  if easy then
    return easy
  end
  
  if not hardLines[lineType] then
    return
  end
  
  if lineType == "SecondaryStat" then
    if Addon:GetOption"combineStats" then
      return "BaseStat"
    end
  elseif lineType == "EnchantOnUse" or lineType == "RequiredEnchantOnUse" then
    if Addon:GetOption("doReorder", "EnchantOnUse") then
      if Addon:GetOption"combineStats" then
        return "BaseStat"
      else
        return "SecondaryStat"
      end
    else
      return "Enchant"
    end
  elseif lineType == "Charges" or lineType == "Cooldown" then
    if lastUse == "SecondaryStat" and Addon:GetOption"combineStats" then
      return "BaseStat"
    else
      return lastUse
    end
  elseif lineType == "SocketHint" then
    if Addon:GetOption("doReorder", "SocketHint") then
      return "SocketBonus"
    end
  end
  
  return lineType
end

function Addon:CalculatePadding(tooltipData, tooltip, methodName)
  local lastUse = tooltipData.lastUse
  
  for cat, offset in pairs(lineOffsets) do
    local padded = {}
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
        local padType = GetPadType2(offset, line.type, lastUse)
        self:DebugfIfOutput("paddingDecisions", "Pad type for line %d (%s) of type %s with offset %d is %s", i, line.textLeftText or "nil", line.type or "nil", offset, padType or "nil")
        if padType then
          if self:GetOption("pad", cat, padType) and not padded[padType] then
            if otherLine then
              if otherLine.type == "Padding" then
                if not usedPaddingRecently then
                  otherLine.used = true
                  self:DebugfIfOutput("paddingDecisions", "Marking padding on line %d (%s) as used, due to %s with offset %d", i, line.textLeftText or "", padType, offset)
                end
              else
                if offset == 1 then
                  self:DebugfIfOutput("paddingDecisions", "Padding line %d (%s) with type %s and offset %d", i + offset, otherLine.textLeftText or "", padType, offset)
                  otherLine.pad = true
                else
                  self:DebugfIfOutput("paddingDecisions", "Padding line %d (%s) with type %s and offset %d", i, line.textLeftText or "", padType, offset)
                  line.pad = true
                end
              end
            end
            padded[padType] = true
          end
        end
        usedPaddingRecently = false
      end
      i = i - offset
    end
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