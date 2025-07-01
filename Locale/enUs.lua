
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, not Addon:IsDebugEnabled())
if not L then return end




L["Whether to modify tooltips."]                   = true
L["Reverse behavior when modifier keys are held."] = true

L["Reorder"] = true
L["Recolor"] = true
L["Cache"]   = true

L["Allow or prohibit all reordering."]                                                            = true
L["Allow or prohibit all rewording."]                                                             = true
L["Allow or prohibit all recoloring."]                                                            = true
L["Greatly speeds up processing, but may occasionally cause tooltip formatting issues."]          = true
L["If a tooltip appears to be formatted incorrectly, hide it for %d seconds to clear the cache."] = true

L["Use custom decimal separator."]                                                     = true
L["Use custom thousands separator."]                                                   = true
L["Four Digit Exception"]                                                              = true
L["Don't group digits if there are four or fewer on that side of the decimal marker."] = true
L["Group decimal digits"]                                                              = true
L["Group digits to the right of the decimal marker."]                                  = true
L["Recommended by NIST (National Institute of Standards and Technology)."]             = true

L["Multiply"]   = true
L["Multiplier"] = true

L["Number of decimal places."] = true
L["Use thousands separator."] = true

L["Group Secondary Stats with Base Stats"] = true
L["Add Space Above Bonus Effects"]         = true

L["Move secondary effects (such as Attack Power and Spell Power), up to where the base stats (such as Stamina) are located."] = true
L["Bonus effects are secondary effects that aren't just adding a stat (example: Hearthstone)."] = true


-- padding locations
L["Spacing"]            = true
L["Hide Extra Spacing"] = true
L["Space Above"]        = true
L["Space Below"]        = true
L["Secondary Stats"]    = true
L["Sockets"]            = true
L["Set List"]           = true
L["Set Bonus"]          = true
L["Place an empty line above this line."] = true
L["Place an empty line below this line."] = true
L["Place an empty line at the end of the tooltip, before other addons add lines."] = true


-- title
L["Hearthstone"] = true

-- item level
L["Show %s instead of %s."]                                                       = true
L["Show Non Equipment"]                                                           = true
L["Show item level on items that cannot be equipped by anyone."]                  = true
L["Show Waylaid Supplies"]                                                        = true
L["Show item level on Waylaid Supplies and Supply Shipments."]                    = true
L["Show this line where it was originally positioned in Wrath of The Lich King."] = true

-- stack size
L["Hide Single Stacks"]                                                        = true
L["Hide stack size on unstackable items."]                                     = true
L["Hide Equipment"]                                                            = true
L["Hide stack size on unstackable items that can be equipped on a character."] = true

-- transmog
L["Teebu's Blazing Longsword"] = true

-- unique
L["Hide redundant lines when multiple Unique lines exist."] = true

-- trainable
L["Trainable Equipment"]                             = true
L["Equipment that a trainer can teach you to wear."] = true

-- weapon damage
L["Show Minimum and Maximum"]              = true
L["Show Average"]                          = true
L["Show Variance"]                         = true
L["Variance Prefix"]                       = true
L["Show Percent"]                          = true
L["Merge Bonus Damage into Weapon Damage"] = true

-- dps
L["Remove Brackets"] = true

-- speed
L["Prefix"]    = true
L["Precision"] = true

-- speed bar
L["Speed Bar"]       = true
L["Test"]            = true
L["Show Speed"]      = true
L["Fill Character"]  = true
L["Blank Character"] = true

L["Character to use for filled section of the speed bar."] = true
L["Character to use for empty section of the speed bar."]  = true
L["Fastest speed on the speed bar."]                       = true
L["Slowest speed on the speed bar."]                       = true
L["Width of the speed bar."]                               = true

-- enchant
L["This applies to most enchantments."]                                  = true
L["This applies to enchantments that add an On Use effect to the item."] = true
L["This applies to temporary weapon enchantments."]                      = true
L["Whether to position this line with other On Use effects rather than the normal enchantment location."] = true

-- rune
L["This applies to runes."] = true

-- durability
L["Show Current"] = true

-- requirements
L["Whether to show this line much higher up on the tooltip rather than its usual location."] = true

-- races
L["Hide Pointless Lines"]              = true
L["Hide lines that contain my race."]  = true
L["Hide lines which list every race."] = true

-- classes
L["Hide lines that contain only my class."] = true

-- level
L["Hide white level requirements."]                                  = true
L["Hide maximum level requirements when you are the maximum level."] = true
L["Hide level range requirements."]                                  = true

-- prefixes
L["Remove Space"] = true
L["Icon Size"]    = true
L["Icon Space"]   = true

-- made by
L["Made by myself."] = true
L["Made by others."] = true

-- gift from
L["Gift from myself."] = true
L["Gift from others."] = true

-- written by
L["Written by myself."] = true
L["Written by others."] = true

-- socket hint
L["Move this line to the socket bonus."] = true

-- refundable
L["Refund"] = true

-- misc rewording
L["Reword some various small things, such as mana potions and speed enchantments. This option is different for each locale."] = true

-- reset
L["Order"] = true
L["Mod"]   = true




L["Celestial"] = "Celestial"

