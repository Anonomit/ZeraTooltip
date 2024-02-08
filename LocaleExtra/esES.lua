if GetLocale() ~= "esES" then return end

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



if Addon.isEra then
  Addon:AddExtraStatCapture("Stamina",
    {INPUT = "^(%+)(%d+) de aguante$"})
  
  Addon:AddExtraStatCapture("Strength",
    {INPUT = "^(%+)(%d+) de fuerza$"})
  
  Addon:AddExtraStatCapture("Agility",
    {INPUT = "^(%+)(%d+) de agilidad$"})
  
  Addon:AddExtraStatCapture("Intellect",
    {INPUT = "^(%+)(%d+) de intelecto$"})
  
  Addon:AddExtraStatCapture("Spirit",
    {INPUT = "^(%+)(%d+) de espíritu$"})
  
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Defensa aumentada %+(%d+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta la probabilidad de esquivar un ataque en un (%d+%%)%.$"},
    {INPUT = "^%+(%d+%%) de esquivar$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta la probabilidad de parar un ataque en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta la probabilidad de bloquear ataques con un escudo en un (%d+%%)%.$"},
    {INPUT = "^%+(%d+%%) de bloquear$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Aumenta el valor de bloqueo de tu escudo en (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^%+(%d+) p%. de poder de ataque%.$"},
    {INPUT = "^%+(%d+) de poder de ataque$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^%+(%d+) p%. de poder de ataque a distancia%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+(%d+) p%. de poder de ataque solo bajo formas felinas, de oso y de oso nefasto%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta el daño y la curación de los hechizos mágicos y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño y Hechizos de curación$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Aumenta el daño causado por los hechizos Arcanos y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño de Hechizos Arcanos?$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Aumenta el daño causado por los hechizos de Fuego y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño de Hechizos de Fuego$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Aumenta el daño causado por los hechizos de Naturaleza y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño de Hechizos de Naturaleza$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Aumenta el daño causado por los hechizos de Escarcha y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño de Hechizos de Escarcha$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Aumenta el daño causado por los hechizos de Sombras y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño de Hechizos de Sombras?$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Aumenta el daño causado por los hechizos Sagrados y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de daño de Hechizos Sagrados?$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Aumenta la curación de los hechizos y los efectos hasta en (%d+) p%.$"},
    {INPUT = "^%+(%d+) de Hechizos de curación$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Reduce las resistencias mágicas de los objetivos de tus hechizos en (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Aumenta en un (%d+%%) tu probabilidad de golpear con hechizos, ataques cuerpo a cuerpo y ataques a distancia%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Mejora tu probabilidad de alcanzar el objetivo en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Mejora tu probabilidad de conseguir un golpe crítico en (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Mejora tu probabilidad de alcanzar el objetivo con hechizos en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Mejora tu probabilidad de conseguir un golpe crítico en (%d+%%) con los hechizos%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^%+(%d+) de salud cada 5 seg%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^%+(%d+) de maná cada 5 seg%.$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Aumenta el índice de defensa (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta tu índice de esquivar (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta tu índice de parada (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta tu índice de bloqueo (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^Aumenta (%d+) p%. el poder de ataque%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Aumenta (%d+) p%. el poder de ataque a distancia%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Aumenta el poder de ataque (%d+) p%. solo con las formas de gato, oso, oso temible y lechúcico lunar%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Aumenta el índice de penetración de armadura (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta tu poder con hechizos hasta (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^%+(%d+) daño con Hechizos Arcano$"},
    {INPUT = "^%+(%d+) daño con Hechizos Arcanos$"})

  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^%+(%d+) daño con Hechizos de Fuego$"})

  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^%+(%d+) daño con Hechizos de Naturaleza$"})

  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^%+(%d+) daño con Hechizos de Escarcha$"})

  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^%+(%d+) daño con Hechizos de las Sombra$"},
    {INPUT = "^%+(%d+) daño con Hechizos de las Sombras$"})

  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^%+(%d+) daño con Hechizos Sagrado$"},
    {INPUT = "^%+(%d+) daño con Hechizos Sagrados$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Aumenta la penetración de tus hechizos (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Aumenta tu índice de golpe (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Aumenta tu índice de golpe crítico (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^%+(%d+) salud cada 5 s$"})
end


