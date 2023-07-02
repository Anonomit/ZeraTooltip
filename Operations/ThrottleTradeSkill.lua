
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- the inspect frame doesn't respect TOOLTIP_UPDATE_TIME
-- this has a significant performance impact
-- let's slow it down to the standard tooltip refresh interval


local ThrottleTradeSkillFrameItem

do
  local lastUpdate = TOOLTIP_UPDATE_TIME * (-1) - 1
  
  function ThrottleTradeSkillFrameItem()
    local TradeSkillItem_OnEnter_old = TradeSkillItem_OnEnter
    function TradeSkillItem_OnEnter(self, ...)
      if Addon:GetGlobalOption("throttle", "TradeSkillFrame") and GameTooltip:GetOwner() == self and GetTime() - lastUpdate < TOOLTIP_UPDATE_TIME then return end
      lastUpdate = GetTime()
      TradeSkillItem_OnEnter_old(self, ...)
    end
  end
end


function Addon:ThrottleTradeSkillUpdates()
  if TradeSkillItem_OnEnter then
    ThrottleTradeSkillFrameItem()
  else
    self.addonLoadHooks["Blizzard_TradeSkillUI"] = function()
      if TradeSkillItem_OnEnter then
        ThrottleTradeSkillFrameItem()
      else -- this probably can't happen, but do the hook next frame if it does
        C_Timer.After(0, ThrottleTradeSkillFrameItem)
      end
    end
  end
  
  self:RegisterEvent("MODIFIER_STATE_CHANGED", function()
    lastUpdate = -1 - TOOLTIP_UPDATE_TIME 
  end)
end