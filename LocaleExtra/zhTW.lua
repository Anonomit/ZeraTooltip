if GetLocale() ~= "zhTW" then return end

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
  {INPUT = "^%+(%d+)秘法法術傷害$"},
  {INPUT = "^%+(%d+) 秘法法術傷害$"})

Addon:AddExtraStatCapture("Fire Damage",
  {INPUT = "^%+(%d+)火焰法術傷害$"},
  {INPUT = "^%+(%d+) 火焰法術傷害$"})

Addon:AddExtraStatCapture("Nature Damage",
  {INPUT = "^%+(%d+)自然法術傷害$"},
  {INPUT = "^%+(%d+) 自然法術傷害$"})

Addon:AddExtraStatCapture("Frost Damage",
  {INPUT = "^%+(%d+)冰霜法術傷害$"},
  {INPUT = "^%+(%d+) 冰霜法術傷害$"})

Addon:AddExtraStatCapture("Shadow Damage",
  {INPUT = "^%+(%d+)暗影法術傷害$"},
  {INPUT = "^%+(%d+) 暗影法術傷害$"})

Addon:AddExtraStatCapture("Holy Damage",
  {INPUT = "^%+(%d+)神聖法術傷害$"},
  {INPUT = "^%+(%d+) 神聖法術傷害$"})

if Addon.isEra then
  Addon:AddExtraStatCapture("Shadow Resistance",
    {INPUT = "^(%+)(%d+) 陰影抗性$"})
  
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^防禦技能提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^使你躲閃攻擊的機率提高(%d+%%)。$"},
    {INPUT = "^%+(%d+%%) 躲避$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^使你招架攻擊的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^使你用盾牌格擋攻擊的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^使你的盾牌格擋值提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^%+(%d+)遠程攻擊強度。$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^在獵豹、熊或巨熊形態下的攻擊強度提高(%d+)點。$"},
    {INPUT = "^在獵豹、熊和巨熊形態下的攻擊強度提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^提高法術和魔法效果所造成的傷害和治療效果，最多(%d+)點。$"},
    {INPUT = "^%+(%d+) 傷害及治療法術$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^秘法法術和效果造成的傷害提高最多(%d+)點。$"},
    {INPUT = "^祕法法術和效果造成的傷害提高最多(%d+)點。$"},
    {INPUT = "^%+(%d+) 祕法法術傷害$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^提高火焰法術和效果所造成的傷害，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^提高自然法術和效果所造成的傷害，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^提高冰霜法術和效果所造成的傷害，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^提高暗影法術和效果所造成的傷害，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^提高神聖法術和效果所造成的傷害，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^提高法術和魔法效果所造成的治療效果，最多(%d+)點。$"},
    {INPUT = "^%+(%d+) 治療法術$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^使你法術目標的魔法抗性降低(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^使你的所有攻擊和法術命中的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^使你的所有攻擊和法術造成致命一擊的機率提高(%d+%%)。$"},
    {INPUT = "^使你的所有法術和攻擊造成致命一擊的機率提高(%d+%%)。$"},
    {INPUT = "^使你近戰攻擊、遠程攻擊和法術的致命一擊機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^使你擊中目標的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^使你造成致命一擊的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^使你的法術擊中敵人的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^使你的法術造成致命一擊的機率提高(%d+%%)。$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^提高(%d+)點防禦等級。$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^使你的閃躲等級提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^使你的招架等級提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^提高(%d+)點格擋等級。$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^提高(%d+)點護甲穿透等級。$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^使你的法術能量提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^%+(%d+)秘法法術傷害$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^使你的法術穿透力提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^每5秒恢復(%d+)生命力$"})
end


