
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub = string.gsub


local stat = "SocketHint"
local defaultText = ITEM_SOCKETABLE
local coveredDefaultText = Addon:CoverSpecialCharacters(ITEM_SOCKETABLE)
function Addon:RewordSocketHint(text)
  if self:GetOption("allow", "reword") and self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredDefaultText then
      text = strGsub(text, coveredDefaultText, alias)
    end
  end
  return text
end