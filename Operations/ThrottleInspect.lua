
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- the inspect frame doesn't respect TOOLTIP_UPDATE_TIME
-- this has a significant performance impact
-- let's slow it down to the standard tooltip refresh interval


local ThrottleInspectPaperDollItemSlotButton

do
  local lastUpdate = TOOLTIP_UPDATE_TIME * (-1) - 1
  local lastButton
  
  function ThrottleInspectPaperDollItemSlotButton()
    local InspectPaperDollItemSlotButton_OnEnter_old = InspectPaperDollItemSlotButton_OnEnter
    function InspectPaperDollItemSlotButton_OnEnter(self, ...)
      if Addon:GetOption"fixInspectFrame" and GetTime() - lastUpdate < TOOLTIP_UPDATE_TIME and lastButton == self then return end
      lastUpdate = GetTime()
      lastButton = self
      InspectPaperDollItemSlotButton_OnEnter_old(self, ...)
    end
  end
end


function Addon:ThrottleInspectUpdates()
  if InspectPaperDollItemSlotButton_OnEnter then
    ThrottleInspectPaperDollItemSlotButton()
  else
    self.addonLoadHooks["Blizzard_InspectUI"] = function()
      if InspectPaperDollItemSlotButton_OnEnter then
        ThrottleInspectPaperDollItemSlotButton()
      else -- this probably can't happen, but do the hook next frame if it does
        C_Timer.After(0, ThrottleInspectPaperDollItemSlotButton)
      end
    end
  end
  
  self:RegisterEvent("MODIFIER_STATE_CHANGED", function()
    lastUpdate = -1 - TOOLTIP_UPDATE_TIME 
  end)
end