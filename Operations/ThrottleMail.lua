
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- the mail frame doesn't respect TOOLTIP_UPDATE_TIME
-- this has a significant performance impact
-- let's slow it down to the standard tooltip refresh interval


local function Throttle()
  Addon.lastTooltipUpdate = -1 - TOOLTIP_UPDATE_TIME
  if not Addon.throttleRegistrationID then
    Addon.throttleRegistrationID = Addon:RegisterEventCallback("MODIFIER_STATE_CHANGED", function()
      Addon.lastTooltipUpdate = -1 - TOOLTIP_UPDATE_TIME
    end)
  end
  
  local InboxFrameItem_OnEnter_old = InboxFrameItem_OnEnter
  _G.InboxFrameItem_OnEnter = function(self, ...)
    if Addon:GetGlobalOption("throttle", "MailFrame") and GameTooltip:GetOwner() == self and GetTime() - Addon.lastTooltipUpdate < TOOLTIP_UPDATE_TIME then return end
    Addon.lastTooltipUpdate = GetTime()
    InboxFrameItem_OnEnter_old(self, ...)
  end
  
  local OpenMailAttachment_OnEnter_old = OpenMailAttachment_OnEnter
  _G.OpenMailAttachment_OnEnter = function(self, index, ...)
    if Addon:GetGlobalOption("throttle", "MailFrame") and GameTooltip:GetOwner() == self and GetTime() - Addon.lastTooltipUpdate < TOOLTIP_UPDATE_TIME then return end
    Addon.lastTooltipUpdate = GetTime()
    OpenMailAttachment_OnEnter_old(self, index, ...)
  end
end


Addon:RegisterEnableCallback(Throttle)