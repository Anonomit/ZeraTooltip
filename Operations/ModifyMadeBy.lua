
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match



local pattern = Addon:ReversePattern(Addon.L["<Made by %s>"])

local stat = "MadeBy"
function Addon:ShouldHideMadeBy(text, madeType)
  if self:GetOption("hide", stat) then
    return true
  else
    local crafter = strMatch(text, pattern)
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



local pattern = Addon:ReversePattern(Addon.L["<Gift from %s>"])

local stat = "GiftFrom"
function Addon:ShouldHideGiftFrom(text, madeType)
  if self:GetOption("hide", stat) then
    return true
  else
    local crafter = strMatch(text, pattern)
    if crafter == self.MY_NAME then
      if self:GetOption("hide", "GiftFromMe") then
        return true
      end
    elseif self:GetOption("hide", "GiftFromOther") then
      return true
    end
  end
  return false
end



local pattern = Addon:ReversePattern(Addon.L["Written by %s"])

local stat = "WrittenBy"
function Addon:ShouldHideWrittenBy(text, madeType)
  if self:GetOption("hide", stat) then
    return true
  else
    local crafter = strMatch(text, pattern)
    if crafter == self.MY_NAME then
      if self:GetOption("hide", "WrittenByMe") then
        return true
      end
    elseif self:GetOption("hide", "WrittenByOther") then
      return true
    end
  end
  return false
end