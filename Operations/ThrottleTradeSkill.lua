
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- the inspect frame doesn't respect TOOLTIP_UPDATE_TIME
-- this has a significant performance impact
-- let's slow it down to the standard tooltip refresh interval


local function Throttle()
  Addon.lastTooltipUpdate = -1 - TOOLTIP_UPDATE_TIME
  if not Addon.throttleRegistrationID then
    Addon.throttleRegistrationID = Addon:RegisterEventCallback("MODIFIER_STATE_CHANGED", function()
      Addon.lastTooltipUpdate = -1 - TOOLTIP_UPDATE_TIME
    end)
  end
  
  local TradeSkillItem_OnEnter_old = TradeSkillItem_OnEnter
  _G.TradeSkillItem_OnEnter = function(self, ...)
    if Addon:GetGlobalOption("throttle", "TradeSkillFrame") and GameTooltip:GetOwner() == self and GetTime() - Addon.lastTooltipUpdate < TOOLTIP_UPDATE_TIME then return end
    Addon.lastTooltipUpdate = GetTime()
    TradeSkillItem_OnEnter_old(self, ...)
  end
end


Addon:RegisterEnableCallback(function() Addon:OnAddonLoad("Blizzard_TradeSkillUI", Throttle) end)