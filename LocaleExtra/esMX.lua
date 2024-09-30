if GetLocale() ~= "esMX" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



-- override the default stat rewords for this locale
do
  -- Addon:AddDefaultRewordByLocale(stat, val)
  
  if Addon.isSoD then
    Addon:AddDefaultRewordByLocale("Physical Hit Rating",             format("%s (%s)", ITEM_MOD_HIT_RATING_SHORT,  SPELL_SCHOOL0_NAME))
    Addon:AddDefaultRewordByLocale("Physical Critical Strike Rating", format("%s (%s)", ITEM_MOD_CRIT_RATING_SHORT, SPELL_SCHOOL0_NAME))
  end
end



Addon:AddExtraStatCapture("Block Value",
  {INPUT = "^Aumenta el valor de bloqueo de tu escudo ([%d,]+) p%.$"})

Addon:AddExtraStatCapture("Arcane Damage",
  {INPUT = "^%+([%d,]+) daño con hechizos Arcano$"})

Addon:AddExtraStatCapture("Fire Damage",
  {INPUT = "^%+([%d,]+) daño con hechizos de Fuego$"})

Addon:AddExtraStatCapture("Nature Damage",
  {INPUT = "^%+([%d,]+) daño con hechizos de Naturaleza$"})

Addon:AddExtraStatCapture("Frost Damage",
  {INPUT = "^%+([%d,]+) daño con hechizos de Escarcha$"})

Addon:AddExtraStatCapture("Shadow Damage",
  {INPUT = "^%+([%d,]+) daño con hechizos de las Sombras$"})

Addon:AddExtraStatCapture("Holy Damage",
  {INPUT = "^%+([%d,]+) daño con hechizos Sagrado$"})

Addon:AddExtraStatCapture("Health Regeneration",
  {INPUT = "^%+([%d,]+) salud cada 5 s$"})


if Addon.isEra then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Aumenta ([%d,]+) p%. el índice de defensa%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta un ([%d,]+%%) tu probabilidad de esquivar un ataque%.$"},
    {INPUT = "^%+([%d,]+%%) de Esquivar$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta un ([%d,]+%%) tu probabilidad de parar un ataque%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta la probabilidad de bloquear ataques con un escudo un ([%d,]+%%)%.$"},
    {INPUT = "^Aumenta un ([%d,]+%%) tu probabilidad de bloquear ataques con un escudo%.$"},
    {INPUT = "^%+([%d,]+%%) de Bloqueo$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+([%d,]+) p%. de poder de ataque solo en las formas felina, de oso y de oso temible%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño y la sanación de los hechizos y efectos mágicos%.$"},
    {INPUT = "^Daño y hechizos de sanación %+([%d,]+)$"},
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño y la sanación de los efectos y hechizos mágicos%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. la sanación de los hechizos y efectos%.$"},
    {INPUT = "^%+([%d,]+) de hechizos de sanación$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño que infligen los hechizos y efectos Arcanos%.$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño que infligen los hechizos y efectos de Fuego%.$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño que infligen los hechizos y efectos de Naturaleza%.$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño que infligen los hechizos y efectos de Escarcha%.$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño que infligen los hechizos y efectos de las Sombras%.$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. el daño que infligen los hechizos y efectos Sagrados%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Las resistencias mágicas de los objetivos de tus hechizos se reducen ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Mejora un ([%d,]+%%) tu probabilidad de golpear con todos tus hechizos y ataques%.$"},
    {INPUT = "^Aumenta un ([%d,]+%%) tu probabilidad de golpear con todos los hechizos y ataques%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Aumenta un ([%d,]+%%) tu probabilidad de golpe crítico con hechizos y ataques cuerpo a cuerpo y a distancia%.$"},
    {INPUT = "^Mejora un ([%d,]+%%) tu probabilidad de obtener un golpe crítico con todos tus hechizos y ataques%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Mejora tu probabilidad de golpear un ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Mejora un ([%d,]+%%) tu probabilidad de conseguir un golpe crítico%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Mejora un ([%d,]+%%) tu probabilidad de golpear con hechizos%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Mejora tu probabilidad de asestar un golpe crítico con hechizos un ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^%+([%d,]+) maná cada 5 s$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Aumenta el índice de defensa ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta tu índice de esquivar ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta tu índice de parada ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta tu índice de bloqueo ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Aumenta el poder de ataque ([%d,]+) p%. solo con las formas de gato, oso, oso temible y lechúcico lunar%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Aumenta el índice de penetración de armadura ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta el poder con hechizos ([%d,]+) p%.$"},
    {INPUT = "^Aumenta tu poder con hechizos hasta ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Aumenta la penetración de tus hechizos ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Aumenta tu índice de golpe ([%d,]+) p%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Aumenta tu índice de golpe crítico ([%d,]+) p%.$"})
end

if Addon.isSoD or Addon.isTBC then
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Aumenta hasta ([%d,]+) p%. la sanación realizada y hasta [%d,]+ p%. el daño que infligen todos los efectos y hechizos mágicos%.$"})
end


