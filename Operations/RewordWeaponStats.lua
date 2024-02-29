
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match
local strGsub  = string.gsub
local strRep   = string.rep

local defaultDamageBonus = {0, 0}

function Addon:ModifyWeaponDamage(text, dps, speed, damageBonus)
  damageBonus = damageBonus or defaultDamageBonus
  
  local showAverage  = self:GetOption("allow", "reword") and self:GetOption("damage", "showAverage")
  local showVariance = self:GetOption("allow", "reword") and self:GetOption("damage", "showVariance")
  local showMinMax   = self:GetOption("allow", "reword") and self:GetOption("damage", "showMinMax")
  
  local minMax, min, gap, max = strMatch(text, "((%d+)( ?%- ?)(%d+))")
  if min then
    min, max = tonumber(min), tonumber(max)
    local mid = dps * speed
    if self:GetOption("hide", "DamageBonus") then
      min = min + (damageBonus[1])
      max = max + (damageBonus[2])
      minMax = min .. gap .. max
    else
      mid = mid - (damageBonus[1] + damageBonus[2]) / 2
    end
    
    local average = showAverage and format("%d", mid) or nil
    local usePercent = self:GetOption("damage", "variancePercent")
    
    local varianceDecimal
    if mid == 0 then
      varianceDecimal = 0
    else
      varianceDecimal = max/mid
    end
    local variance = showVariance and format("%s%d%s", self:GetOption("damage", "variancePrefix"), usePercent and self:Round((varianceDecimal-1)*100, 5) or self:Round(max-mid, 1), usePercent and "%%" or "") or nil
    local minMax = showMinMax and minMax or nil
    
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
    
    return strGsub(text, "%d+ ?%- ?%d+", pattern)
  end
  return text
end


function Addon:ModifyWeaponDamageBonus(text, damageBonus)
  text = strGsub(text, " +", " ") -- Fix weird spacing (ex. 7730)
  
  local showAverage  = self:GetOption("allow", "reword") and self:GetOption("damage", "showAverage")
  local showVariance = self:GetOption("allow", "reword") and self:GetOption("damage", "showVariance")
  if not (showAverage or showVariance) then return text end -- no changes to make
  local showMinMax   = self:GetOption("allow", "reword") and self:GetOption("damage", "showMinMax")
  
  local minMax, min, max = strMatch(text, "((%d+) ?%- ?(%d+))")
  if min then
    min, max = tonumber(min), tonumber(max)
    local mid = (damageBonus[1] + damageBonus[2]) / 2
    local average = showAverage and format("%d", mid) or nil
    local usePercent = self:GetOption("damage", "variancePercent")
    
    local varianceDecimal
    if mid == 0 then
      varianceDecimal = 0
    else
      varianceDecimal = max/mid
    end
    local variance = showVariance and format("%s%d%s", self:GetOption("damage", "variancePrefix"), usePercent and self:Round((varianceDecimal-1)*100, 5) or self:Round(max-mid, 1), usePercent and "%%" or "") or nil
    local minMax = showMinMax and minMax or nil
    
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
    
    return strGsub(text, "%d+ ?%- ?%d+", pattern)
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
    local precision = self:GetOption("precision", stat)
    if precision ~= 2 then
      local newSpeed = format("%." .. precision .. "f", speed)
      if DECIMAL_SEPERATOR ~= "." then
        newSpeed = strGsub(newSpeed, "%.", DECIMAL_SEPERATOR)
      end
      text = strGsub(text, speedString, newSpeed)
    end
  end
  return text
end


local stat = "DamagePerSecond"
function Addon:ModifyWeaponDamagePerSecond(text)
  if self:GetOption("allow", "reword") then
    if self:GetOption("doReword", stat) then
      text = format("(%s %s)", strMatch(text, self:ReversePattern(DPS_TEMPLATE)), STAT_DPS_SHORT)
    end
    if self:GetOption("dps", "removeBrackets") then
      text = self:ChainGsub(text, {"^%(", "%)$", ""})
    end
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
