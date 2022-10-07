
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match
local strGsub  = string.gsub
local strRep   = string.rep



function Addon:ModifyWeaponDamage(text, dps, speed)
  local showAverage  = self:GetOption("allow", "reword") and self:GetOption("damage", "showAverage")
  local showVariance = self:GetOption("allow", "reword") and self:GetOption("damage", "showVariance")
  if not (showAverage or showVariance) then return text end -- no changes to make
  local showMinMax   = self:GetOption("allow", "reword") and self:GetOption("damage", "showMinMax")
  
  local minMax, min, max = strMatch(text, "((%d+) ?%- ?(%d+))")
  if min then
    min, max = tonumber(min), tonumber(max)
    local mid = dps * speed
    local average = showAverage and format("%d", mid) or nil
    local usePercent = self:GetOption("damage", "variancePercent")
    local variance = showVariance and format("%s%d%s", self:GetOption("damage", "variancePrefix"), usePercent and self:Round((max/mid-1)*100, 10) or self:Round(max-mid, 1), usePercent and "%%" or "") or nil
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
      if alias and alias ~= "" and alias ~= SPEED then
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
    local fillChar  = self:GetOption("speedBar", "fillChar")
    local blankChar = self:GetOption("speedBar", "blankChar")
    local showSpeed = self:GetOption("speedBar", "speedPrefix") and self:ModifyWeaponSpeed(speedStringFull, speed, speedString) or nil
    local delta     = max - min
    
    local fill = self:Clamp(0, self:Round((speed - min) / delta * size, 1), size)
    local bar = ("[%s%s]"):format(strRep(fillChar, fill), strRep(blankChar, size - fill))
    if showSpeed then
      bar = showSpeed .. " " .. bar
    end
    return bar
  end
  return nil
end
