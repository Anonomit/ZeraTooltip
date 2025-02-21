
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strLower = string.lower
local strFind  = string.find
local strMatch = string.match
local strGsub  = string.gsub
local strByte  = string.byte



local typesToSearch = {
  BaseStat      = true,
  SecondaryStat = true,
  Socket        = true,
  SocketBonus   = true,
  SetBonus      = true,
}


local cacheSize = 0
local statCache = {}
function Addon:WipeStatCache()
  wipe(statCache)
  cacheSize = 0
end
function Addon:GetStatCacheSize()
  return cacheSize
end
Addon:RegisterAddonEventCallback("WIPE_CACHE", Addon.WipeStatCache)
Addon:RegisterAddonEventCallback("OPTION_SET", Addon.WipeStatCache)
Addon:RegisterCVarCallback("colorblindMode", Addon.WipeStatCache)

local function RecognizeStatHelper(line)
  local self = Addon
  if not line.type or not typesToSearch[line.type] then return end
  
  -- check cache, skip processing if this line has already been recognized
  local cache = statCache[line.textLeftText]
  if cache then
    line.stat       = cache.stat
    line.normalForm = cache.normalForm
    line.prefix     = cache.prefix
    line.newPrefix  = cache.newPrefix
    return
  end
  
  local text = line.textLeftText
  if line.prefix then
    line.newPrefix = line.prefix
    if line.prefix == ITEM_SET_BONUS_GRAY then
      local strNumber
      strNumber, text = strMatch(text, self:ReversePattern(line.prefix))
      line.newPrefix = strGsub(line.prefix, "%%%d?%$?d", self:CoverSpecialCharacters(strNumber))
    elseif strFind(line.prefix, "%%") then
      text = strMatch(text, self:ReversePattern(line.prefix))
      line.newPrefix = line.prefix
    else
      text = strGsub(text, self:CoverSpecialCharacters(line.prefix), "")
      local append, strippedText = strMatch(text, "^( *)(.*)")
      if strippedText then
        text = strippedText
        if line.prefix == ITEM_SPELL_TRIGGER_ONEQUIP then
          line.newPrefix = nil
        else
          line.newPrefix = line.prefix .. append
        end
      end
    end
  end
  
  
  if not line.normalForm then
    if line.stat then
      local normalForm = self.statsInfo[line.stat].ConvertToNormalForm and self.statsInfo[line.stat]:ConvertToNormalForm(strLower(text))
      if normalForm then
        line.normalForm = normalForm
      end
    else
      local text = strLower(text)
      for stat, StatInfo in pairs(self.statsInfo) do
        local normalForm = StatInfo.ConvertToNormalForm and StatInfo:ConvertToNormalForm(text)
        if normalForm then
          line.stat       = stat
          line.normalForm = normalForm
          break
        end
      end
    end
  end
  
  if self:GetGlobalOption("cache", "enabled") and self:GetGlobalOption("cache", "stat") then
    statCache[line.textLeftText] = {stat = line.stat, normalForm = line.normalForm, prefix = line.prefix, newPrefix = line.newPrefix}
    cacheSize = cacheSize + 1
  end
end

do
  function Addon:RecognizeStat(line, tooltipData, allResist)
    RecognizeStatHelper(line)
    
    if line.prefix == ITEM_SPELL_TRIGGER_ONUSE then
      tooltipData.lastUse = line.type
    end
    
    if allResist then
      if line.stat == "Arcane Resistance" then
        local n         = strMatch(line.normalForm, self.L["[%d,%.]+"])
        line.stat       = "All Resistance"
        line.normalForm = format(self.L["%c%d to All Resistances"], strByte"+", n)
      end
    end
  end
end