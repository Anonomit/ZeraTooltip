local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ruRU", false, not Addon:IsDebugEnabled())
if not L then return end
-- Translator ZamestoTV
L["Whether to modify tooltips."]                   = "Изменять ли всплывающие подсказки."
L["Reverse behavior when modifier keys are held."] = "Изменять поведение при зажатии модификаторов."

L["Reorder"] = "Переупорядочить"
L["Recolor"] = "Перекрасить"
L["Cache"]   = "Кэш"

L["Allow or prohibit all reordering."]                                                            = "Разрешить или запретить все переупорядочивание."
L["Allow or prohibit all rewording."]                                                             = "Разрешить или запретить все переформулировки."
L["Allow or prohibit all recoloring."]                                                            = "Разрешить или запретить все перекрашивание."
L["Greatly speeds up processing, but may occasionally cause tooltip formatting issues."]          = "Значительно ускоряет обработку, но иногда может вызывать проблемы с форматированием подсказок."
L["If a tooltip appears to be formatted incorrectly, hide it for %d seconds to clear the cache."] = "Если всплывающая подсказка отформатирована некорректно, скрыть её на %d секунд для очистки кэша."

L["Use custom decimal separator."]                                                     = "Использовать пользовательский разделитель десятичных."
L["Use custom thousands separator."]                                                   = "Использовать пользовательский разделитель тысяч."
L["Four Digit Exception"]                                                              = "Исключение для четырёх цифр"
L["Don't group digits if there are four or fewer on that side of the decimal marker."] = "Не группировать цифры, если их четыре или меньше с этой стороны десятичного разделителя."
L["Group decimal digits"]                                                              = "Группировать десятичные цифры"
L["Group digits to the right of the decimal marker."]                                  = "Группировать цифры справа от десятичного разделителя."
L["Recommended by NIST (National Institute of Standards and Technology)."]             = "Рекомендуется NIST (Национальным институтом стандартов и технологий)."

L["Multiply"]   = "Умножить"
L["Multiplier"] = "Множитель"

L["Number of decimal places."] = "Количество десятичных знаков."
L["Use thousands separator."] = "Использовать разделитель тысяч."

L["Group Secondary Stats with Base Stats"] = "Группировать вторичные характеристики с основными"
L["Add Space Above Bonus Effects"]         = "Добавить пробел над бонусными эффектами"

L["Move secondary effects (such as Attack Power and Spell Power), up to where the base stats (such as Stamina) are located."] = "Переместить вторичные эффекты (например, сила атаки и сила заклинаний) туда, где находятся основные характеристики (например, выносливость)."
L["Bonus effects are secondary effects that aren't just adding a stat (example: Hearthstone)."] = "Бонусные эффекты — это вторичные эффекты, которые не просто добавляют характеристику (пример: Камень возвращения)."

-- padding locations
L["Spacing"]            = "Интервалы"
L["Hide Extra Spacing"] = "Скрыть дополнительные интервалы"
L["Space Above"]        = "Пробел сверху"
L["Space Below"]        = "Пробел снизу"
L["Secondary Stats"]    = "Вторичные характеристики"
L["Sockets"]            = "Гнёзда"
L["Set List"]           = "Список комплектов"
L["Set Bonus"]          = "Бонус комплекта"
L["Place an empty line above this line."] = "Разместить пустую строку над этой строкой."
L["Place an empty line below this line."] = "Разместить пустую строку под этой строкой."
L["Place an empty line at the end of the tooltip, before other addons add lines."] = "Разместить пустую строку в конце всплывающей подсказки, перед добавлением строк другими аддонами."

-- title
L["Hearthstone"] = "Камень возвращения"

-- item level
L["Show %s instead of %s."]                                                       = "Показывать %s вместо %s."
L["Show Non Equipment"]                                                           = "Показывать неэкипируемые предметы"
L["Show item level on items that cannot be equipped by anyone."]                  = "Показывать уровень предмета для предметов, которые никто не может экипировать."
L["Show Waylaid Supplies"]                                                        = "Показывать припасы с пути"
L["Show item level on Waylaid Supplies and Supply Shipments."]                    = "Показывать уровень предмета для припасов с пути и поставок."
L["Show this line where it was originally positioned in Wrath of The Lich King."] = "Показывать эту строку в том месте, где она была изначально расположена в Wrath of The Lich King."

-- stack size
L["Hide Single Stacks"]                                                        = "Скрыть одиночные стопки"
L["Hide stack size on unstackable items."]                                     = "Скрыть размер стопки для предметов, которые не складываются."
L["Hide Equipment"]                                                            = "Скрыть экипировку"
L["Hide stack size on unstackable items that can be equipped on a character."] = "Скрыть размер стопки для не складываемых предметов, которые можно экипировать на персонажа."

-- transmog
L["Teebu's Blazing Longsword"] = "Пылающий меч Тибу"

-- unique
L["Hide redundant lines when multiple Unique lines exist."] = "Скрывать избыточные строки, когда существует несколько строк с уникальностью."

-- trainable
L["Trainable Equipment"]                             = "Обучаемая экипировка"
L["Equipment that a trainer can teach you to wear."] = "Экипировка, которой может научить вас тренер."

-- weapon damage
L["Show Minimum and Maximum"]              = "Показывать минимум и максимум"
L["Show Average"]                          = "Показывать среднее"
L["Show Variance"]                         = "Показывать разброс"
L["Variance Prefix"]                       = "Префикс разброса"
L["Show Percent"]                          = "Показывать процент"
L["Merge Bonus Damage into Weapon Damage"] = "Объединить бонусный урон с уроном оружия"

-- dps
L["Remove Brackets"] = "Удалить скобки"

-- speed
L["Prefix"]    = "Префикс"
L["Precision"] = "Точность"

-- speed bar
L["Speed Bar"]       = "Полоса скорости"
L["Test"]            = "Тест"
L["Show Speed"]      = "Показывать скорость"
L["Fill Character"]  = "Символ заполнения"
L["Blank Character"] = "Пустой символ"

L["Character to use for filled section of the speed bar."] = "Символ для заполненной части полосы скорости."
L["Character to use for empty section of the speed bar."]  = "Символ для пустой части полосы скорости."
L["Fastest speed on the speed bar."]                       = "Максимальная скорость на полосе скорости."
L["Slowest speed on the speed bar."]                       = "Минимальная скорость на полосе скорости."
L["Width of the speed bar."]                               = "Ширина полосы скорости."

-- enchant
L["This applies to most enchantments."]                                  = "Это относится к большинству зачарований."
L["This applies to enchantments that add an On Use effect to the item."] = "Это относится к зачарованиям, которые добавляют эффект при использовании к предмету."
L["This applies to temporary weapon enchantments."]                      = "Это относится к временным зачарованиям оружия."
L["Whether to position this line with other On Use effects rather than the normal enchantment location."] = "Размещать ли эту строку вместе с другими эффектами при использовании, а не в обычном месте зачарования."

-- rune
L["This applies to runes."] = "Это относится к рунам."

-- durability
L["Show Current"] = "Показывать текущую"

-- requirements
L["Whether to show this line much higher up on the tooltip rather than its usual location."] = "Показывать ли эту строку гораздо выше во всплывающей подсказке, чем её обычное место."

-- races
L["Hide Pointless Lines"]              = "Скрыть бессмысленные строки"
L["Hide lines that contain my race."]  = "Скрыть строки, содержащие мою расу."
L["Hide lines which list every race."] = "Скрыть строки, которые перечисляют все расы."

-- classes
L["Hide lines that contain only my class."] = "Скрыть строки, содержащие только мой класс."

-- level
L["Hide white level requirements."]                                  = "Скрыть белые требования к уровню."
L["Hide maximum level requirements when you are the maximum level."] = "Скрыть требования к максимальному уровню, когда вы на максимальном уровне."
L["Hide level range requirements."]                                  = "Скрыть требования к диапазону уровней."

-- prefixes
L["Remove Space"] = "Удалить пробел"
L["Icon Size"]    = "Размер иконки"
L["Icon Space"]   = "Пространство иконки"

-- made by
L["Made by myself."] = "Сделано мной."
L["Made by others."] = "Сделано другими."

-- gift from
L["Gift from myself."] = "Подарок от меня."
L["Gift from others."] = "Подарок от других."

-- written by
L["Written by myself."] = "Написано мной."
L["Written by others."] = "Написано другими."

-- socket hint
L["Move this line to the socket bonus."] = "Переместить эту строку к бонусу гнезда."

-- refundable
L["Refund"] = "Возврат"

-- misc rewording
L["Reword some various small things, such as mana potions and speed enchantments. This option is different for each locale."] = "Переформулировать некоторые мелкие вещи, такие как зелья маны и зачарования на скорость. Эта опция отличается для каждой локализации."

-- reset
L["Order"] = "Порядок"
L["Mod"]   = "Модификатор"

L["Celestial"] = "Небожители"
end
