
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local lineOffsets = {
  before = -1,
  after  =  1,
}
local padLocations = {
  [-1] = {
    BaseStat      = function(line) return line.type == "BaseStat"      or Addon:GetOption"combineStats" and line.type == "SecondaryStat" end,
    SecondaryStat = function(line) return line.type == "SecondaryStat" and not Addon:GetOption"combineStats" end,
    Enchant       = function(line) return line.type == "Enchant"       end,
    Socket        = function(line) return line.type == "Socket"        end,
    SetName       = function(line) return line.type == "SetName"       end,
    SetBonus      = function(line) return line.type == "SetBonus"      end,
  },
  [1] = {
    BaseStat      = function(line) return line.type == "BaseStat"      or Addon:GetOption"combineStats" and line.type == "SecondaryStat" end,
    SecondaryStat = function(line) return line.type == "SecondaryStat" and not Addon:GetOption"combineStats" end,
    Enchant       = function(line) return line.type == "Enchant"       or line.type == "RequiredEnchant" end,
    SocketBonus   = function(line) return line.type == "SocketBonus"   end,
    SetPiece      = function(line) return line.type == "SetPiece"      end,
    SetBonus      = function(line) return line.type == "SetBonus"      end,
  }
}

function Addon:CalculatePadding(tooltipData)
  local padded = {}
  
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
            elseif offset == 1 then
              tooltipData.padLast = true
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
    for _, line in ipairs(tooltipData) do
      if line.type == "SecondaryStat" then
        found = true
        if not line.stat then
          line.pad = true
          break
        end
      elseif found then
        break
      end
    end
  end
  
  -- hide unused padding
  for i, line in ipairs(tooltipData) do
    if line.type == "Padding" and not line.used then
      line.hide = true
    end
  end
  
  -- pad last line
  -- note that there are some cases where this will not work
  -- I could maybe fix those by hooking AddLine and AddDoubleLine
  -- I would need to add the padding after some other addon adds a line
  -- TODO: investigate this
  if self:GetOption"padLastLine" then
    local lastLine = tooltipData[#tooltipData]
    if lastLine.type == "Padding" then
      lastLine.hide = nil
    else
      tooltipData.padLast = #tooltipData
    end
  end
end
