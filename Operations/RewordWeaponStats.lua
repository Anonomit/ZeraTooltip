
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strMatch = string.match
local strGsub  = string.gsub
local strRep   = string.rep

local defaultDamageBonus = {0, 0}

local stat = "Damage"
function Addon:ModifyWeaponDamage(text, dps, speed, damageBonus)
  if not self:GetOption("allow", "reword") then return text end
  
  damageBonus = damageBonus or defaultDamageBonus
  
  local showAverage  = self:GetOption("allow", "reword") and self:GetOption("damage", "showAverage")
  local showVariance = self:GetOption("allow", "reword") and self:GetOption("damage", "showVariance")
  local showMinMax   = self:GetOption("allow", "reword") and self:GetOption("damage", "showMinMax")
  
  local noThousandsSeparator = self:GetOption("allow", "reword") and not self:GetOption("separateThousands", stat)
  local precision = self:GetOption("allow", "reword") and (1 / 10^self:GetOption("precision", stat)) or 1
  
  local minMax, min, gap, max = strMatch(text, "((" .. self.L["[%d,%.]+"] .. ")( ?%- ?)(" .. self.L["[%d,%.]+"] .. "))")
  if min then
    min, max = self:ToNumber(min), self:ToNumber(max)
    local mid = dps * speed
    if self:GetOption("hide", "DamageBonus") then
      min = min + (damageBonus[1])
      max = max + (damageBonus[2])
    else
      mid = mid - (damageBonus[1] + damageBonus[2]) / 2
    end
    minMax = self:ToFormattedNumber(min, nil, "") .. gap .. self:ToFormattedNumber(max, nil, nil, noThousandsSeparator and "" or nil)
    
    local average = showAverage and self:ToFormattedNumber(self:Round(mid, precision), nil, nil, noThousandsSeparator and "" or nil) or nil
    local usePercent = self:GetOption("damage", "variancePercent")
    
    local varianceDecimal
    if mid == 0 then
      varianceDecimal = 0
    else
      varianceDecimal = max/mid
    end
    local variance = showVariance and format("%s%d%s", self:GetOption("damage", "variancePrefix"), usePercent and self:Round((varianceDecimal-1)*100, 5) or self:Round(max-mid, 1), usePercent and "%%" or "") or nil
    minMax = showMinMax and minMax or nil
    
    local pattern
    if average then
      pattern = average
      if variance then
        pattern = format("%s %s", pattern, variance)
      end
      if minMax then
        pattern = format("%s (%s)", pattern, minMax)
      end
    else
      pattern = minMax
      if variance then
        pattern = format("%s (%s)", pattern, variance)
      end
    end
    
    return strGsub(text, self.L["[%d,%.]+"] .. " ?%- ?" .. self.L["[%d,%.]+"], pattern)
  end
  return text
end


function Addon:ModifyWeaponDamageBonus(text, damageBonus)
  text = strGsub(text, " +", " ") -- Fix weird spacing (ex. 7730)
  
  local showAverage  = self:GetOption("allow", "reword") and self:GetOption("damage", "showAverage")
  local showVariance = self:GetOption("allow", "reword") and self:GetOption("damage", "showVariance")
  if not (showAverage or showVariance) then return text end -- no changes to make
  
  local showMinMax = self:GetOption("allow", "reword") and self:GetOption("damage", "showMinMax")
  
  local noThousandsSeparator = self:GetOption("allow", "reword") and not self:GetOption("separateThousands", stat)
  local precision = self:GetOption("allow", "reword") and (1 / 10^self:GetOption("precision", stat)) or 1
  
  local minMax, min, gap, max = strMatch(text, "((" .. self.L["[%d,%.]+"] .. ")( ?%- ?)(" .. self.L["[%d,%.]+"] .. "))")
  if min then
    min, max = self:ToNumber(min), self:ToNumber(max)
    local mid = (damageBonus[1] + damageBonus[2]) / 2
    local average = showAverage and self:ToFormattedNumber(self:Round(mid, precision), nil, nil, noThousandsSeparator and "" or nil) or nil
    local usePercent = self:GetOption("damage", "variancePercent")
    
    local varianceDecimal
    if mid == 0 then
      varianceDecimal = 0
    else
      varianceDecimal = max/mid
    end
    local variance = showVariance and format("%s%d%s", self:GetOption("damage", "variancePrefix"), usePercent and self:Round((varianceDecimal-1)*100, 5) or self:Round(max-mid, 1), usePercent and "%%" or "") or nil
    
    minMax = self:ToFormattedNumber(min, nil, nil, noThousandsSeparator and "" or nil) .. gap .. self:ToFormattedNumber(max, nil, nil, noThousandsSeparator and "" or nil)
    minMax = showMinMax and minMax or nil
    
    local pattern
    if average then
      pattern = average
      if variance then
        pattern = format("%s %s", pattern, variance)
      end
      if minMax then
        pattern = format("%s (%s)", pattern, minMax)
      end
    else
      pattern = minMax
      if variance then
        pattern = format("%s (%s)", pattern, variance)
      end
    end
    
    return strGsub(text, self.L["[%d,%.]+"] .. " ?%- ?" .. self.L["[%d,%.]+"], pattern)
  end
  return text
end



local stat = "Speed"
local coveredSpeed = Addon:CoverSpecialCharacters(SPEED)
function Addon:ModifyWeaponSpeed(text, speed, speedString)
  if self:GetOption("allow", "reword") then
    if self:GetOption("doReword", stat) then -- whether to add a prefix
      local alias = self:GetOption("reword", stat)
      if alias and alias ~= "" and alias ~= coveredSpeed then
        text = strGsub(text, coveredSpeed, alias)
      end
    else
      text = speedString
    end
  end
  
  if self:GetOption("allow", "reword") then
    local newSpeed = self:ToFormattedNumber(speed, self:GetOption("precision", stat))
    text = strGsub(text, self:CoverSpecialCharacters(speedString), newSpeed)
  end
  return text
end


local dpsPattern = Addon:ReversePattern(Addon.L["(%s damage per second)"])
local dpsText = Addon.L["DPS"]

local stat = "DamagePerSecond"
function Addon:ModifyWeaponDamagePerSecond(text)
  if not self:GetOption("allow", "reword") then return text end
  
  local origNumber = strMatch(text, "[%d,%.]+") -- doesn't use localized separators
  if not origNumber then return text end
  
  local noThousandsSeparator = not self:GetOption("separateThousands", stat)
  local numDecimalPlaces = self:GetOption("precision", stat)
  local precision = (1 / 10^numDecimalPlaces) or 1
  
  local strNumber = self:ToFormattedNumber(self:Round(self:ToNumber(origNumber), precision), numDecimalPlaces, nil, noThousandsSeparator and "" or nil)
  text = strGsub(text, self:CoverSpecialCharacters(origNumber), strNumber)
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" then
      text = format("(%s %s)", strMatch(text, dpsPattern), alias)
    end
  end
  if self:GetOption("dps", "removeBrackets") then
    text = self:ChainGsub(text, {"^%(", "%)$", ""})
  end
  return text
end


local stat = "Speedbar"
function Addon:ModifyWeaponSpeedbar(speed, speedString, speedStringFull)
  if self:GetOption("allow", "reword") and self:GetOption("doReword", stat) then
    local min       = self:GetOption("speedBar", "min")
    local max       = self:GetOption("speedBar", "max")
    local size      = self:GetOption("speedBar", "size")
    local color     = self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and self:GetOption("color", stat) or nil
    local fillChar  = self:MakeIcon(self.speedbarFillIconPath, nil, 0.25, color)
    local blankChar = self.speedbarEmptyIcon
    local showSpeed = self:GetOption("speedBar", "speedPrefix") and self:ModifyWeaponSpeed(speedStringFull, speed, speedString) or nil
    local delta     = max - min
    
    local fill = self:Clamp(0, self:Round((speed - min) / delta * size, 1), size)
    local bar = ("[%s%s]"):format(strRep(fillChar, fill), strRep(blankChar, size - fill))
    if color then
      bar = self:MakeColorCode(color, bar)
    end
    if showSpeed then
      if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", "Speed") then
        showSpeed = self:MakeColorCode(self:GetOption("color", "Speed"), showSpeed)
      end
      bar = showSpeed .. " " .. bar
    end
    return bar
  end
  return nil
end
