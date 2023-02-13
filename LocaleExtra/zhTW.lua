if GetLocale() ~= "zhTW" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^防禦技能提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^使你躲閃攻擊的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^使你招架攻擊的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^使你用盾牌格擋攻擊的機率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^使你的盾牌格擋值提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^%+(%d+)遠程攻擊強度。$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^在獵豹、熊或巨熊形態下的攻擊強度提高(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^提高法術和魔法效果所造成的傷害和治療效果，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^提高法術和魔法效果所造成的治療效果，最多(%d+)點。$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^使你法術目標的魔法抗性降低(%d+)點。$"})
  
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
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^使你的法術穿透力提高(%d+)點。$"})
end


