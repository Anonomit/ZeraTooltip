if GetLocale() ~= "zhCN" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^防御技能提高(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^使你躲闪攻击的几率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^使你招架攻击的几率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^使你用盾牌格挡攻击的几率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^使你的盾牌的格挡值提高(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^在猎豹、熊和巨熊形态下的攻击强度提高(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^提高所有法术和魔法效果所造成的伤害和治疗效果，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^提高奥术法术和效果所造成的伤害，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^提高火焰法术和效果所造成的伤害，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^提高自然法术和效果所造成的伤害，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^提高冰霜法术和效果所造成的伤害，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^提高暗影法术和效果所造成的伤害，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^提高法术所造成的治疗效果，最多(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^使你的法术目标的魔法抗性降低(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^使你击中目标的几率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^使你造成爆击的几率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^使你的法术击中敌人的几率提高(%d+%%)。$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^使你的法术造成爆击的几率提高(%d+%%)。$"})
else
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^使你的躲闪等级提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^使你的招架等级提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^使你的格挡等级提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^护甲穿透等级提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^使你的法术强度提高(%d+)点。$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^使你的法术穿透提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^使你的命中等级提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^使你的爆击等级提高(%d+)。$"},
    {INPUT = "^爆击等级提高(%d+)。$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^每5秒恢复(%d+)点法力值。$"})
end


