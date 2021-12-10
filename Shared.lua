

local ADDON_NAME, Shared = ...


Shared.ELEMENTS = {"Arcane", "Fire", "Nature", "Frost", "Shadow", "Holy"}

function Shared.Round(num, decimalPlaces)
  local mult = 10^(decimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Shared.GetColor(key)
  if not Shared.db then return end
  assert(Shared.db.profile.COLORS[key], ("Missing Color entry: %s"):format(key))
  return Shared.db.profile.COLORS[key]
end