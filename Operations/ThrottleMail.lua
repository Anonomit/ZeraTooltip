
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- the mail frame doesn't respect TOOLTIP_UPDATE_TIME
-- this has a significant performance impact
-- let's slow it down to the standard tooltip refresh interval


local ThrottleInboxFrameItem
local ThrottleOpenMailAttachment

do
  local lastUpdate = TOOLTIP_UPDATE_TIME * (-1) - 1
  
  function ThrottleInboxFrameItem()
    local InboxFrameItem_OnEnter_old = InboxFrameItem_OnEnter
    function InboxFrameItem_OnEnter(self, ...)
      if Addon:GetOption("throttle", "MailFrame") and GameTooltip:GetOwner() == self and GetTime() - lastUpdate < TOOLTIP_UPDATE_TIME then return end
      lastUpdate = GetTime()
      Addon:Debug"me"
      InboxFrameItem_OnEnter_old(self, ...)
    end
  end
end

do
  local lastUpdate = TOOLTIP_UPDATE_TIME * (-1) - 1
  
  function ThrottleOpenMailAttachment()
    local OpenMailAttachment_OnEnter_old = OpenMailAttachment_OnEnter
    function OpenMailAttachment_OnEnter(self, index, ...)
      if Addon:GetOption("throttle", "MailFrame") and GameTooltip:GetOwner() == self and GetTime() - lastUpdate < TOOLTIP_UPDATE_TIME then return end
      lastUpdate = GetTime()
      OpenMailAttachment_OnEnter_old(self, index, ...)
    end
  end
end





function Addon:ThrottleMailUpdates()
  assert(MailFrame)
  ThrottleInboxFrameItem()
  ThrottleOpenMailAttachment()
  
  self:RegisterEvent("MODIFIER_STATE_CHANGED", function()
    lastUpdate = -1 - TOOLTIP_UPDATE_TIME 
  end)
end