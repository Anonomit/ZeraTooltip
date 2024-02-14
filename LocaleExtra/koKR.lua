if GetLocale() ~= "koKR" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



-- override the default stat rewords for this locale
do
  -- Addon:AddDefaultRewordByLocale(stat, val)
  
  if Addon.isSoD then
    Addon:AddDefaultRewordByLocale("Physical Hit Rating",             format("%s (%s)", ITEM_MOD_HIT_RATING_SHORT,  SPELL_SCHOOL0_CAP))
    Addon:AddDefaultRewordByLocale("Physical Critical Strike Rating", format("%s (%s)", ITEM_MOD_CRIT_RATING_SHORT, SPELL_SCHOOL0_CAP))
  end
end



Addon:AddExtraStatCapture("Arcane Damage",
  {INPUT = "^비전 주문 공격력 %+(%d+)$"})

Addon:AddExtraStatCapture("Fire Damage",
  {INPUT = "^화염 주문 공격력 %+(%d+)$"})

Addon:AddExtraStatCapture("Nature Damage",
  {INPUT = "^자연 주문 공격력 %+(%d+)$"})

Addon:AddExtraStatCapture("Frost Damage",
  {INPUT = "^냉기 주문 공격력 %+(%d+)$"})

Addon:AddExtraStatCapture("Shadow Damage",
  {INPUT = "^암흑 주문 공격력 %+(%d+)$"})

Addon:AddExtraStatCapture("Holy Damage",
  {INPUT = "^신성 주문 공격력 %+(%d+)$"})

Addon:AddExtraStatCapture("Health Regeneration",
  {INPUT = "^매 5초마다 (%d+)의 생명력이 회복됩니다%.$"},
  {INPUT = "^5초당 생명력 회복 %+(%d+)$"})


if Addon.isEra then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^방어 숙련도 %+(%d+)%.?$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^공격을 회피할 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^무기 막기 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^방패로 적의 공격을 방어할 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^표범, 광포한 곰, 곰 변신 상태일 때 전투력이 (%d+)만큼 증가합니다%.$"},
    {INPUT = "^표범, 곰, 광포한 곰 변신 상태일 때 전투력이 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^모든 주문 및 효과에 의한 피해와 치유량이 최대 (%d+)만큼 증가합니다%.$"},
    {INPUT = "^치유 및 주문 공격력 %+(%d+)$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^비전 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^화염 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^자연 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^냉기 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^암흑 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^신성 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^모든 주문 및 효과에 의한 치유량이 최대 (%d+)만큼 증가합니다%.$"},
    {INPUT = "^치유 효과 증가 %+(%d+)$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^자신의 주문에 대한 대상의 마법 저항력을 (%d+)만큼 감소시킵니다%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^주문, 근접 및 원거리 공격 적중률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^근접 및 원거리 공격과 주문 사용 시 치명타 및 극대화 효과를 낼 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^무기의 적중률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^치명타를 적중시킬 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^주문의 적중률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^주문이 극대화 효과를 낼 확률이 (%d+%%)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^5초당 마나 회복 %+(%d+)$"})
else
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^방어구 관통력이 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^주문이 최대 (%d+)만큼 증가합니다%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^치명타 및 주문 극대화 적중도가 (%d+)만큼 증가합니다%.$"})
end


