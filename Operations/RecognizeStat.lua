
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strFind  = string.find
local strMatch = string.match
local strGsub  = string.gsub


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
Addon.onOptionSetHandlers["WipeStatCache"] = true


function Addon:RecognizeStat(line)
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
  
  if line.statHint and false then
    -- TODO: could this be reimplemented to save a bit of pattern matching?
  else
    for stat, StatInfo in pairs(self.statsInfo) do
      local normalForm = StatInfo.ConvertToNormalForm and StatInfo:ConvertToNormalForm(text)
      if normalForm then
        line.stat       = stat
        line.normalForm = normalForm
        break
      end
    end
  end
  
  if self:GetOption("cache", "enabled") and self:GetOption("cache", "stat") then
    statCache[line.textLeftText] = {stat = line.stat, normalForm = line.normalForm, prefix = line.prefix, newPrefix = line.newPrefix}
    cacheSize = cacheSize + 1
  end
end