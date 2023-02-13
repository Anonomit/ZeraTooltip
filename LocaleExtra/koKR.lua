if GetLocale() ~= "koKR" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^방어 숙련도 %+(%d+)%.?$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^공격을 회피할 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^무기 막기 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^방패로 적의 공격을 방어할 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^표범, 광포한 곰, 곰 변신 상태일 때 전투력이 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^모든 주문 및 효과에 의한 피해와 치유량이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^모든 주문 및 효과에 의한 치유량이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^자신의 주문에 대한 대상의 마법 저항력을 (%d+)만큼 감소시킵니다%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^무기의 적중률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^치명타를 적중시킬 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^주문의 적중률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^주문이 극대화 효과를 낼 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^매 5초마다 (%d+)의 생명력이 회복됩니다%.$"})
else
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^방어구 관통력이 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^주문이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^치명타 및 주문 극대화 적중도가 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^매 5초마다 (%d+)의 생명력이 회복됩니다%.$"})
end

