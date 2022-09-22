
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


-- TODO: check for more ways of setting tooltip
-- TODO: wipe only certain hashmap sections on relevant events? probably not necessary since the link is in the hash

local CACHE_WIPE_DELAY  = 10
local SEEN_BEFORE_CACHE = 5


local constructorCleanup = {}
local constructorCount   = {}

local constructorCache = {}
local function WipeConstructorCache()
  wipe(constructorCache)
end
Addon.onSetHandlers["WipeConstructorCache"] = WipeConstructorCache

local hashMaps = {
  SetHyperlink            = function(link, itemStringOrLink) return itemStringOrLink end,
  SetBagItem              = function(link, bag, slot) return format("%s-%d-%d", link, bag, slot) end,
  SetInventoryItem        = function(link, unit, slot, nameOnly) if nameOnly then return end return format("%s-%s-%d", link, unit, slot) end,
  -- auction
  SetAuctionItem          = function(link, typ, index) return format("%s-%s-%d", link, typ, index) end,
  SetAuctionSellItem      = function(link) return link end,
  -- loot
  SetLootItem             = function(link, slot) return format("%s-%d", link, slot) end,
  SetLootRollItem         = function(link, id) return id end,
  -- crafting
  -- SetCraftSpell           = function(link) end,
  -- SetCraftItem            = function(link) end,
  SetTradeSkillItem       = function(link, index, reagent) return format("%s-%d-%d", link, index, reagent or 0) end,
  SetTrainerService       = function(link) end,
  -- mail
  SetInboxItem            = function(link, mailSlot, index) return format("%s-%d-%d", link, mailSlot, index or 0) end,
  SetSendMailItem         = function(link, index) return format("%s-%s", link, index) end,
  -- quest log
  SetQuestItem            = function(link, typ, index) return format("%s-%s-%d", link, typ, index) end,
  SetQuestLogItem         = function(link, typ, index) return format("%s-%s-%d", link, typ, index) end,
  -- trade
  SetTradePlayerItem      = function(link, slot) return format("%s-%d", link, slot) end,
  SetTradeTargetItem      = function(link, slot) return format("%s-%d", link, slot) end,
  -- vendor tooltip
  SetMerchantItem         = function(link, slot) return format("%s-%d", link, slot) end,
  SetBuybackItem          = function(link, slot) return format("%s-%d", link, slot) end,
  SetMerchantCostItem     = function(link, slot, item) return format("%s-%d-%d", link, slot, item) end,
  -- socketing interface
  SetSocketGem            = function(link, index) return format("%s-%d", link, index) end,
  SetExistingSocketGem    = function(link, index, toDestroy) return format("%s-%d-%s", link, index, tostring(toDestroy)) end,
  -- 2.1.0
  SetHyperlinkCompareItem = function(link) end,
  -- 2.3.0
  SetGuildBankItem        = function(link, tab, id) return format("%s-%d-%d", link, tab, id) end,
  -- 3.0
  SetCurrencyToken        = function(link) end,
  SetBackpackToken        = function(link) end,
  -- 4.0
  SetReforgeItem          = function(link) return link end,
  -- 4.2.0
  SetItemByID             = function(link, id) return id end,
  -- 6.0.2
  SetCompareItem          = function(link, shoppingTooltipTwo, primaryMouseover) return format("%s-%s-%s", link, shoppingTooltipTwo:GetName(), primaryMouseover:GetName()) end,
  
  SetAction               = function(link, id) return format("%s-%s", link, id) end,
}

local function GetHash(tooltip, methodName, link, ...)
  local hash = Addon:GetOption("cache", "constructor") and hashMaps[methodName] and hashMaps[methodName](link, ...) or nil
  if not hash then
    Addon:Debug(link, methodName, ...)
    return
  end
  
  return format("%s-%s-%s", tooltip:GetName(), methodName, hash)
end

local function Cleanup(hash)
  constructorCount[hash]   = nil
  constructorCache[hash]   = nil
  constructorCleanup[hash] = nil
end

local function StartCleanup(hash)
  constructorCount[hash] = (constructorCount[hash] or 0) + 1
  if constructorCleanup[hash] then
    constructorCleanup[hash]:Cancel()
  end
  constructorCleanup[hash] = C_Timer.NewTicker(CACHE_WIPE_DELAY, function() Cleanup(hash) end, 1)
end


function Addon:GetConstructor(tooltip, link, methodName, ...)
  local hash = GetHash(tooltip, methodName, link, ...)
  if not hash then return end
  
  StartCleanup(hash)
  
  return constructorCache[hash]
end
function Addon:SetConstructor(constructor, tooltip, link, methodName, ...)
  local hash = GetHash(tooltip, methodName, link, ...)
  if not hash then return end
  
  StartCleanup(hash)
  
  if constructorCount[hash] >= SEEN_BEFORE_CACHE then
    constructorCache[hash] = constructor
  end
end


