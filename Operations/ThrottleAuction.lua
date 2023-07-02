
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- the inspect frame doesn't respect TOOLTIP_UPDATE_TIME
-- this has a significant performance impact
-- let's slow it down to the standard tooltip refresh interval


local ThrottleAuctionFrameItem

do
  local lastUpdate = TOOLTIP_UPDATE_TIME * (-1) - 1
  
  function ThrottleAuctionFrameItem()
    local AuctionFrameItem_OnEnter_old = AuctionFrameItem_OnEnter
    function AuctionFrameItem_OnEnter(self, typ, index, ...)
      if Addon:GetGlobalOption("throttle", "AuctionFrame") and GameTooltip:GetOwner() == self and GetTime() - lastUpdate < TOOLTIP_UPDATE_TIME then return end
      lastUpdate = GetTime()
      AuctionFrameItem_OnEnter_old(self, typ, index, ...)
    end
  end
end


function Addon:ThrottleAuctionUpdates()
  if AuctionFrameItem_OnEnter then
    ThrottleAuctionFrameItem()
  else
    self.addonLoadHooks["Blizzard_AuctionUI"] = function()
      if AuctionFrameItem_OnEnter then
        ThrottleAuctionFrameItem()
      else -- this probably can't happen, but do the hook next frame if it does
        C_Timer.After(0, ThrottleAuctionFrameItem)
      end
    end
  end
  
  self:RegisterEvent("MODIFIER_STATE_CHANGED", function()
    lastUpdate = -1 - TOOLTIP_UPDATE_TIME 
  end)
end