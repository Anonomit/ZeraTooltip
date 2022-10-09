
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match


local stat = "MadeBy"
function Addon:ShouldHideMadeBy(text, madeType)
  if self:GetOption("hide", stat) then
    return true
  else
    local crafter = strMatch(text, self:ReversePattern(madeType))
    if crafter == self.MY_NAME then
      if self:GetOption("hide", "MadeByMe") then
        return true
      end
    elseif self:GetOption("hide", "MadeByOther") then
      return true
    end
  end
  return false
end