
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub = string.gsub


local defaultText = Addon.L["<Shift Right Click to Socket>"]
local coveredDefaultText = Addon:CoverSpecialCharacters(defaultText)

local stat = "SocketHint"
function Addon:RewordSocketHint(text)
  if self:GetOption("allow", "reword") and self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredDefaultText then
      text = strGsub(text, coveredDefaultText, alias)
    end
  end
  return text
end