

local ADDON_NAME, Shared = ...

ZeraTooltip = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME)
local L

local AceConfig       = LibStub"AceConfig-3.0"
local AceConfigDialog = LibStub"AceConfigDialog-3.0"
local AceDB           = LibStub"AceDB-3.0"
local AceDBOptions    = LibStub("AceDBOptions-3.0")


ZeraTooltip.ENABLED           = true

ZeraTooltip.DEBUG             = false
ZeraTooltip.SHOW_LABELS       = false
ZeraTooltip.SHIFT_SUPPRESSION = false

-- Curseforge automatic packaging will comment this out
-- https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging
--@debug@
ZeraTooltip.ENABLED           = true

ZeraTooltip.DEBUG             = true
ZeraTooltip.SHOW_LABELS       = false
ZeraTooltip.SHIFT_SUPPRESSION = true
--@end-debug@



-- Fastest weapon speed
ZeraTooltip.WEAPON_SPEED_MIN = 1.2

-- Slowest weapon speed
ZeraTooltip.WEAPON_SPEED_MAX = 4.0


local function rgb(r, g, b)
  return {r, g, b}
end

ZeraTooltip.WEAPON_SPEED_DIF = ZeraTooltip.WEAPON_SPEED_MAX - ZeraTooltip.WEAPON_SPEED_MIN
ZeraTooltip.COLOR_CODE = "|c%x%x%x%x%x%x%x%x"
ZeraTooltip.GRAY  = rgb(127, 127, 127)
ZeraTooltip.GREEN = rgb(  0, 255,   0)







ZeraTooltip.COLORS = {}

ZeraTooltip.COLORS.WHITE = rgb(255, 255, 255)
ZeraTooltip.COLORS.GREEN = rgb(  0, 255,   0)
ZeraTooltip.COLORS.BLUE  = rgb(  0,   0, 255)

ZeraTooltip.COLORS.ARCANE = rgb(255, 127, 255)
ZeraTooltip.COLORS.FIRE   = rgb(255, 128,   0)
ZeraTooltip.COLORS.NATURE = rgb( 76, 255,  76)
ZeraTooltip.COLORS.FROST  = rgb(127, 255, 255)
ZeraTooltip.COLORS.SHADOW = rgb(127, 127, 255)
ZeraTooltip.COLORS.HOLY   = rgb(255, 229, 127)

ZeraTooltip.COLORS.HONEYSUCKLE        = rgb(237, 252, 132)
ZeraTooltip.COLORS.LIGHT_YELLOW_GREEN = rgb(204, 253, 127)
ZeraTooltip.COLORS.REEF               = rgb(201, 255, 162)
ZeraTooltip.COLORS.PALE_LIGHT_GREEN   = rgb(177, 252, 153)
ZeraTooltip.COLORS.FOAM_GREEN         = rgb(144, 253, 169)
ZeraTooltip.COLORS.PARIS_GREEN        = rgb( 80, 200, 120)
ZeraTooltip.COLORS.LEMON_LIME         = rgb(191, 254,  40)

ZeraTooltip.COLORS.YELLOW             = rgb(255, 255,   0)
ZeraTooltip.COLORS.SANDY_YELLOW       = rgb(253, 238, 115)

ZeraTooltip.COLORS.CITRON             = rgb(158, 169,  31)
ZeraTooltip.COLORS.BRASS              = rgb(181, 166,  66)

ZeraTooltip.COLORS.TUMBLEWEED         = rgb(222, 166, 129)
ZeraTooltip.COLORS.ATOMIC_TANGERINE   = rgb(255, 153, 102)
ZeraTooltip.COLORS.PUMPKIN_ORANGE     = rgb(248, 114,  23)

ZeraTooltip.COLORS.SUNSET_ORANGE      = rgb(253,  94,  83)
ZeraTooltip.COLORS.ROSSO_CORSA        = rgb(212,   0,   0)

ZeraTooltip.COLORS.PINK_SHERBET       = rgb(247, 143, 167)
ZeraTooltip.COLORS.BLUSH_PINK         = rgb(230, 169, 236)
ZeraTooltip.COLORS.LIGHT_FUSCHIA_PINK = rgb(249, 132, 239)
ZeraTooltip.COLORS.BRIGHT_NEON_PINK   = rgb(244,  51, 255)

ZeraTooltip.COLORS.LILAC              = rgb(206, 162, 253)
ZeraTooltip.COLORS.PURPLE_MIMOSA      = rgb(158, 123, 255)
ZeraTooltip.COLORS.HELIOTROPE_PURPLE  = rgb(212,  98, 255)
ZeraTooltip.COLORS.NEON_PURPLE        = rgb(188,  19, 254)

ZeraTooltip.COLORS.LIGHT_AQUA         = rgb(140, 255, 219)
ZeraTooltip.COLORS.LIGHT_CYAN         = rgb(172, 255, 252)
ZeraTooltip.COLORS.FRENCH_PASS        = rgb(189, 237, 253)
ZeraTooltip.COLORS.BABY_BLUE          = rgb(162, 207, 254)
ZeraTooltip.COLORS.JORDY_BLUE         = rgb(138, 185, 241)
ZeraTooltip.COLORS.DENIM_BLUE         = rgb(121, 186, 236)
ZeraTooltip.COLORS.CRYSTAL_BLUE       = rgb( 92, 179, 255)






local OPTION_DEFAULTS = {
  profile = {
    SIMPLIFY = true,
    REORDER  = true,
    RECOLOR  = true,
    
    SHOW_SPEEDBAR = true,
    
    -- Bar width. Longer is more accurate but can cause a wider tooltip
    SPEEDBAR_SIZE  = 10,
    
    -- Number of significant decimal places on weapon speeds
    SPEED_ACCURACY = 1,
    
    COLORS = {
      SPEED         = ZeraTooltip.COLORS.WHITE,
      
      ENCHANT       = ZeraTooltip.COLORS.GREEN,
      
      ARMOR         = ZeraTooltip.COLORS.PALE_LIGHT_GREEN,
      
      STAMINA       = ZeraTooltip.COLORS.PALE_LIGHT_GREEN,
      STRENGTH      = ZeraTooltip.COLORS.TUMBLEWEED,
      AGILITY       = ZeraTooltip.COLORS.SANDY_YELLOW,
      INTELLECT     = ZeraTooltip.COLORS.JORDY_BLUE,
      SPIRIT        = ZeraTooltip.COLORS.LIGHT_AQUA,
      
      ARCANE_RESIST = ZeraTooltip.COLORS.ARCANE,
      FIRE_RESIST   = ZeraTooltip.COLORS.FIRE,
      NATURE_RESIST = ZeraTooltip.COLORS.NATURE,
      FROST_RESIST  = ZeraTooltip.COLORS.FROST,
      SHADOW_RESIST = ZeraTooltip.COLORS.SHADOW,
      HOLY_RESIST   = ZeraTooltip.COLORS.HOLY,
      
      ARCANE_DAMAGE = ZeraTooltip.COLORS.ARCANE,
      FIRE_DAMAGE   = ZeraTooltip.COLORS.FIRE,
      NATURE_DAMAGE = ZeraTooltip.COLORS.NATURE,
      FROST_DAMAGE  = ZeraTooltip.COLORS.FROST,
      SHADOW_DAMAGE = ZeraTooltip.COLORS.SHADOW,
      HOLY_DAMAGE   = ZeraTooltip.COLORS.HOLY,
      
      DEFENSE       = ZeraTooltip.COLORS.PALE_LIGHT_GREEN,
      RESILIENCE    = ZeraTooltip.COLORS.HONEYSUCKLE,
      DODGE         = ZeraTooltip.COLORS.HONEYSUCKLE,
      PARRY         = ZeraTooltip.COLORS.PARIS_GREEN,
      BLOCK_RATING  = ZeraTooltip.COLORS.LEMON_LIME,
      BLOCK_VALUE   = ZeraTooltip.COLORS.LEMON_LIME,
      RESIST_ALL    = ZeraTooltip.COLORS.PALE_LIGHT_GREEN,
      
      ATTACK_POW    = ZeraTooltip.COLORS.TUMBLEWEED,
      R_ATTACK_POW  = ZeraTooltip.COLORS.TUMBLEWEED,
      PHYS_HIT      = ZeraTooltip.COLORS.SANDY_YELLOW,
      PHYS_CRIT     = ZeraTooltip.COLORS.ATOMIC_TANGERINE,
      PHYS_HASTE    = ZeraTooltip.COLORS.CITRON,
      PHYS_PEN      = ZeraTooltip.COLORS.PUMPKIN_ORANGE,
      EXPERTISE     = ZeraTooltip.COLORS.TUMBLEWEED,
      
      MAGICAL       = ZeraTooltip.COLORS.LIGHT_FUSCHIA_PINK,
      MAGIC_HIT     = ZeraTooltip.COLORS.BLUSH_PINK,
      MAGIC_CRIT    = ZeraTooltip.COLORS.PURPLE_MIMOSA,
      MAGIC_HASTE   = ZeraTooltip.COLORS.LILAC,
      MAGIC_PEN     = ZeraTooltip.COLORS.HELIOTROPE_PURPLE,
      
      HEALING       = ZeraTooltip.COLORS.LIGHT_CYAN,
      HEALTH        = ZeraTooltip.COLORS.PALE_LIGHT_GREEN,
      MANA          = ZeraTooltip.COLORS.JORDY_BLUE,
    },
    
    RECOLOR_STAT = {
      SPEED         = false,
      
      ENCHANT       = false,
      
      ARMOR         = true,
      
      STAMINA       = true,
      STRENGTH      = true,
      AGILITY       = true,
      INTELLECT     = true,
      SPIRIT        = true,
      
      ARCANE_RESIST = true,
      FIRE_RESIST   = true,
      NATURE_RESIST = true,
      FROST_RESIST  = true,
      SHADOW_RESIST = true,
      HOLY_RESIST   = true,
      
      ARCANE_DAMAGE = true,
      FIRE_DAMAGE   = true,
      NATURE_DAMAGE = true,
      FROST_DAMAGE  = true,
      SHADOW_DAMAGE = true,
      HOLY_DAMAGE   = true,
      
      DEFENSE       = true,
      RESILIENCE    = true,
      DODGE         = true,
      PARRY         = true,
      BLOCK_RATING  = true,
      BLOCK_VALUE   = true,
      RESIST_ALL    = true,
      
      ATTACK_POW    = true,
      R_ATTACK_POW  = true,
      PHYS_HIT      = true,
      PHYS_CRIT     = true,
      PHYS_HASTE    = true,
      PHYS_PEN      = true,
      EXPERTISE     = true,

      MAGICAL       = true,
      MAGIC_HIT     = true,
      MAGIC_CRIT    = true,
      MAGIC_HASTE   = true,
      MAGIC_PEN     = true,

      HEALING       = true,
      HEALTH        = true,
      MANA          = true,
    },
  },
}






function ZeraTooltip:FontifyColor(color)
  return color[1]/255, color[2]/255, color[3]/255, 1
end
function ZeraTooltip:DefontifyColor(r, g, b)
  return {r*255, g*255, b*255}
end

function ZeraTooltip:IsSameColor(color1, color2)
  for k, v in pairs(color1) do
    if color2[k] ~= v then
      return false
    end
  end
  return true
end

function ZeraTooltip:IsSameColorFuzzy(color1, color2, fuzziness)
  fuzziness = fuzziness or 0.02 * 255
  for k, v in pairs(color1) do
    if math.abs(color2[k] - v) > fuzziness then
      return false
    end
  end
  return true
end

function ZeraTooltip:GetColor(key)
  if not self.db then return end
  assert(self.db.profile.COLORS[key], ("Missing Color entry: %s"):format(key))
  return self.db.profile.RECOLOR_STAT[key] and self.db.profile.COLORS[key] or nil
end



function ZeraTooltip:TrimLine(text)
  return text:gsub(L["Equip Pattern"], "")
end

function ZeraTooltip:SimplifyLine(text)
  for i, data in ipairs(L) do
    for j, map in ipairs(data.MAP or {}) do
      local input, output = map.INPUT, map.OUTPUT
      local matches = {text:match(input)}
      if #matches > 0 then
        local pattern = type(output) == "function" and output(unpack(matches)) or output:format(unpack(matches))
        return self:TrimLine(text:gsub(input, pattern)) .. (ZeraTooltip.SHOW_LABELS and ("  [%s]"):format(data.LABEL) or "")
      end
    end
  end
end


function ZeraTooltip:SimplifyLines(tooltip)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  
  local leftText = tooltip:GetName().."TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText..i]
    local text = fontString:GetText()
    if text then
      if text:find"%d" then
        text = self:SimplifyLine(text)
        if text then
          fontString:SetText(text)
        end
      end
    end
  end
end


function ZeraTooltip:ReorderLines(tooltip, simplified, enchanted)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  
  local enchantLineFound = not enchanted
  local groups = { }
  
  local leftText = tooltip:GetName() .. "TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText .. i]
    local text = fontString:GetText()
    if text then
      local color = self:DefontifyColor(fontString:GetTextColor())
      
      if self:IsSameColorFuzzy(color, ZeraTooltip.GREEN) and not enchantLineFound then
        enchantLineFound = true
      else
        for j, data in ipairs(L) do
          local captures = {}
          for i, capture in ipairs(data.CAPTURES or {}) do
            table.insert(captures, "^" .. capture)
          end
          if not simplified then
            for i, map in ipairs(data.MAP or {}) do
              table.insert(captures, map.INPUT)
            end
          end
          for k, pattern in ipairs(captures) do
            if text:match(pattern) then
              if #groups == 0 or not self:IsSameColor(groups[#groups].color, color) or groups[#groups].line + #groups[#groups] ~= i then
                table.insert(groups, {color = color, line = i})
              end
              table.insert(groups[#groups], {order = j, text = text})
              break
            end
          end
        end
      end
    end
  end
  
  for _, group in ipairs(groups) do
    if #group > 1 then
      table.sort(group, function(a, b) if a.order == b.order then return a.text < b.text end return a.order < b.order end)
      for i, line in ipairs(group) do
        local fontString = _G[leftText .. (group.line + i - 1)]
        fontString:SetText(line.text)
      end
    end
  end
end


function ZeraTooltip:RecolorLines(tooltip, simplified, enchanted)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  
  local enchantLineFound = not enchanted
  
  local leftText = tooltip:GetName() .. "TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText .. i]
    local text = fontString:GetText()
    if text then
      local color = self:DefontifyColor(fontString:GetTextColor())
      
      if self:IsSameColorFuzzy(color, ZeraTooltip.GREEN) and not enchantLineFound then
        fontString:SetTextColor(self:FontifyColor(self.db.profile.COLORS.ENCHANT))
        enchantLineFound = true
      else
        for j, data in ipairs(L) do
          local captures = {}
          for i, capture in ipairs(data.CAPTURES or {}) do
            table.insert(captures, capture)
          end
          if not simplified then
            for i, map in ipairs(data.MAP or {}) do
              table.insert(captures, map.INPUT)
            end
          end
          for k, pattern in ipairs(captures) do
            if text:match(pattern) and (not text:find(L["ConjunctiveWord Pattern"]) or pattern:find(L["ConjunctiveWord Pattern"])) then
              if data.COLOR then
                local newColor = self:GetColor(data.COLOR)
                if newColor then
                  if not self:IsSameColorFuzzy(color, ZeraTooltip.GRAY) and not text:match(L["SocketBonus Pattern"]) then
                    fontString:SetTextColor(self:FontifyColor(newColor))
                    if text:find(ZeraTooltip.COLOR_CODE) then
                      local newText = text:gsub(ZeraTooltip.COLOR_CODE, "")
                      fontString:SetText(newText)
                    end
                  end
                end
              end
              break
            end
          end
        end
      end
    end
  end
end

function ZeraTooltip:SimplifyLine(text)
  for i, data in ipairs(L) do
    for j, map in ipairs(data.MAP or {}) do
      local input, output = map.INPUT, map.OUTPUT
      local matches = {text:match(input)}
      if #matches > 0 then
        local pattern = type(output) == "function" and output(unpack(matches)) or output:format(unpack(matches))
        return self:TrimLine(text:gsub(input, pattern)) .. (ZeraTooltip.SHOW_LABELS and ("  [%s]"):format(data.LABEL) or "")
      end
    end
  end
end


function ZeraTooltip:RewriteSpeed(tooltip)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  
  local rightText = tooltip:GetName().."TextRight"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[rightText..i]
    local text = fontString:GetText()
    if text then
      if text:find(L["Speed Pattern"]) then
        
        -- This should match weapon speed values with any number of decimal places, though by default I think it's always two.
        local word, s, decimals = text:match(L["Speed Pattern"])
        local speed = s
        local i = 0
        for digit in tostring(decimals):gmatch"(%d)" do
          i = i + 1
          speed = speed + digit/(10^i)
        end
        
        local fill = math.max(0, math.min(Shared.Round((speed - ZeraTooltip.WEAPON_SPEED_MIN) / ZeraTooltip.WEAPON_SPEED_DIF * self.db.profile.SPEEDBAR_SIZE, 0), self.db.profile.SPEEDBAR_SIZE))
        local bar = ""
        if self.db.profile.SHOW_SPEEDBAR then
          bar = ("  [%s%s]"):format(("I"):rep(fill), (" "):rep(self.db.profile.SPEEDBAR_SIZE - fill))
        end
        fontString:SetText(("%%s %%.%df%%s"):format(self.db.profile.SPEED_ACCURACY):format(word, speed, bar))
        
        local color = self:GetColor"SPEED"
        if self.db.profile.RECOLOR and color then
          fontString:SetTextColor(self:FontifyColor(color))
        end
      end
    end
  end
end



function ZeraTooltip:OnTooltipSetHyperlink(tooltip)
  local name, link = tooltip:GetItem()
  if not link then return end
  
  local enchanted = not not link:find"item:%d+:%d+"
  
  if self.db.profile.SIMPLIFY then
    ZeraTooltip:SimplifyLines(tooltip)
  end
  if self.db.profile.REORDER then
    ZeraTooltip:ReorderLines(tooltip, self.db.profile.SIMPLIFY, enchanted)
  end
  if self.db.profile.RECOLOR then
    ZeraTooltip:RecolorLines(tooltip, self.db.profile.SIMPLIFY, enchanted)
  end
  self:RewriteSpeed(tooltip)
end


function ZeraTooltip:HookTooltip(tooltip)
  tooltip:HookScript("OnTooltipSetItem", function(...) return self:OnTooltipSetHyperlink(...) end)
end


function ZeraTooltip:CreateHooks()
  self:HookTooltip(GameTooltip)
  self:HookTooltip(ItemRefTooltip)
  self:HookTooltip(ItemRefShoppingTooltip1)
  self:HookTooltip(ItemRefShoppingTooltip2)
  self:HookTooltip(ShoppingTooltip1)
  self:HookTooltip(ShoppingTooltip2)
end



local order = 99
local function Order(inc)
  order = order + (inc and inc or 0) + 1
  return order
end

function ZeraTooltip:CreateColorOption(args, name, key)
  args[key] = {
    name = name,
    order = Order(),
    type = "toggle",
    set = function(info, val)        self.db.profile.RECOLOR_STAT[key] = val end,
    get = function(info)      return self.db.profile.RECOLOR_STAT[key]       end,
  }
  
  args[key .. " Color"] = {
    name = "Color",
    order = Order(),
    type = "color",
    set = function(_, r, g, b)        self.db.profile.COLORS[key] = self:DefontifyColor(r, g, b) end,
    get = function(info)       return self:FontifyColor(self.db.profile.COLORS[key])             end,
  }
  
  args[key .. " Reset"] = {
    name = "Reset",
    order = Order(),
    type = "execute",
    func = function()
      self.db.profile.RECOLOR_STAT[key] = OPTION_DEFAULTS.profile.RECOLOR_STAT[key]
      self.db.profile.COLORS[key] = OPTION_DEFAULTS.profile.COLORS[key]
    end,
  }
  
  args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
end


function ZeraTooltip:CreateOptions()
  local addonOptions = {
    type = "group",
    args = {}
  }
  
  addonOptions.args["simplify"] = {
    name = L["Reword tooltips"],
    desc = L["REWORD TOOLTIPS DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        self.db.profile.SIMPLIFY = val end,
    get = function(info)      return self.db.profile.SIMPLIFY       end,
  }
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  addonOptions.args["reorder"] = {
    name = L["Reorder stats"],
    desc = L["REORDER STATS DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        self.db.profile.REORDER = val end,
    get = function(info)      return self.db.profile.REORDER       end,
  }
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  addonOptions.args["recolor"] = {
    name = L["Recolor lines"],
    desc = L["RECOLOR LINES DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        self.db.profile.RECOLOR = val end,
    get = function(info)      return self.db.profile.RECOLOR       end,
  }
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  addonOptions.args["show_speedbar"] = {
    name = L["Show Speedbar"],
    desc = L["SHOW SPEEDBAR DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        self.db.profile.SHOW_SPEEDBAR = val end,
    get = function(info)      return self.db.profile.SHOW_SPEEDBAR       end,
  }
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  addonOptions.args["speedbar_size"] = {
    name = L["Speedbar width"],
    desc = L["SPEEDBAR SIZE DESCRIPTION"],
    order = Order(),
    type = "range",
    min = 5,
    max = 25,
    step = 1,
    set = function(info, val)        self.db.profile.SPEEDBAR_SIZE = val end,
    get = function(info)      return self.db.profile.SPEEDBAR_SIZE       end,
  }
  
  addonOptions.args["speedbar_size Reset"] = {
    name = "Reset",
    order = Order(),
    type = "execute",
    func = function() self.db.profile.SPEEDBAR_SIZE = OPTION_DEFAULTS.profile.SPEEDBAR_SIZE end,
  }
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  addonOptions.args["speed_accuracy"] = {
    name = L["Speed accuracy"],
    desc = L["SPEED ACCURACY DESCRIPTION"],
    order = Order(),
    type = "range",
    min = 1,
    max = 5,
    step = 1,
    set = function(info, val)        self.db.profile.SPEED_ACCURACY = val end,
    get = function(info)      return self.db.profile.SPEED_ACCURACY       end,
  }
  
  addonOptions.args["speed_accuracy Reset"] = {
    name = "Reset",
    order = Order(),
    type = "execute",
    func = function() self.db.profile.SPEED_ACCURACY = OPTION_DEFAULTS.profile.SPEED_ACCURACY end,
  }
  
  
  addonOptions.args["divider" .. Order()] = {name  = L["Colors"], order = Order(-1), type  = "header"}
  
  addonOptions.args["ResetAll"] = {
    name = "Reset All",
    order = Order(),
    type = "execute",
    func =  function()
      for _, tbl in ipairs{"RECOLOR_STAT", "COLORS"} do
        for key, default in pairs(OPTION_DEFAULTS.profile[tbl]) do
          self.db.profile[tbl][key] = default
        end
      end
    end,
  }
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Speed"], "SPEED")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Enchantment"], "ENCHANT")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Armor"], "ARMOR")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Stamina"]  , "STAMINA")
  self:CreateColorOption(addonOptions.args, L["Strength"] , "STRENGTH")
  self:CreateColorOption(addonOptions.args, L["Agility"]  , "AGILITY")
  self:CreateColorOption(addonOptions.args, L["Intellect"], "INTELLECT")
  self:CreateColorOption(addonOptions.args, L["Spirit"]   , "SPIRIT")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Arcane Resist"], "ARCANE_RESIST")
  self:CreateColorOption(addonOptions.args, L["Fire Resist"]  , "FIRE_RESIST")
  self:CreateColorOption(addonOptions.args, L["Nature Resist"], "NATURE_RESIST")
  self:CreateColorOption(addonOptions.args, L["Frost Resist"] , "FROST_RESIST")
  self:CreateColorOption(addonOptions.args, L["Shadow Resist"], "SHADOW_RESIST")
  self:CreateColorOption(addonOptions.args, L["Holy Resist"]  , "HOLY_RESIST")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}

  self:CreateColorOption(addonOptions.args, L["Arcane Damage"], "ARCANE_DAMAGE")
  self:CreateColorOption(addonOptions.args, L["Fire Damage"]  , "FIRE_DAMAGE")
  self:CreateColorOption(addonOptions.args, L["Nature Damage"], "NATURE_DAMAGE")
  self:CreateColorOption(addonOptions.args, L["Frost Damage"] , "FROST_DAMAGE")
  self:CreateColorOption(addonOptions.args, L["Shadow Damage"], "SHADOW_DAMAGE")
  self:CreateColorOption(addonOptions.args, L["Holy Damage"]  , "HOLY_DAMAGE")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Defense"]     , "DEFENSE")
  self:CreateColorOption(addonOptions.args, L["Resilience"]  , "RESILIENCE")
  self:CreateColorOption(addonOptions.args, L["Dodge"]       , "DODGE")
  self:CreateColorOption(addonOptions.args, L["Parry"]       , "PARRY")
  self:CreateColorOption(addonOptions.args, L["Block Rating"], "BLOCK_RATING")
  self:CreateColorOption(addonOptions.args, L["Block Value"] , "BLOCK_VALUE")
  self:CreateColorOption(addonOptions.args, L["Resist All"]  , "RESIST_ALL")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Attack Power"]       , "ATTACK_POW")
  self:CreateColorOption(addonOptions.args, L["Ranged Attack Power"], "R_ATTACK_POW")
  self:CreateColorOption(addonOptions.args, L["Physical Hit"]       , "PHYS_HIT")
  self:CreateColorOption(addonOptions.args, L["Physical Crit"]      , "PHYS_CRIT")
  self:CreateColorOption(addonOptions.args, L["Physical Haste"]     , "PHYS_HASTE")
  self:CreateColorOption(addonOptions.args, L["Armor Pen"]          , "PHYS_PEN")
  self:CreateColorOption(addonOptions.args, L["Expertise"]          , "EXPERTISE")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Spell Damage"], "MAGICAL")
  self:CreateColorOption(addonOptions.args, L["Spell Hit"]   , "MAGIC_HIT")
  self:CreateColorOption(addonOptions.args, L["Spell Crit"]  , "MAGIC_CRIT")
  self:CreateColorOption(addonOptions.args, L["Spell Haste"] , "MAGIC_HASTE")
  self:CreateColorOption(addonOptions.args, L["Spell Pen"]   , "MAGIC_PEN")
  
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  addonOptions.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
  
  self:CreateColorOption(addonOptions.args, L["Healing"], "HEALING")
  self:CreateColorOption(addonOptions.args, L["Health"] , "HEALTH")
  self:CreateColorOption(addonOptions.args, L["Mana"]   , "MANA")
  
  
  AceConfig:RegisterOptionsTable(ADDON_NAME, addonOptions)
  AceConfigDialog:AddToBlizOptions(ADDON_NAME)
  
  local profiles = AceDBOptions:GetOptionsTable(self.db)
  AceConfig:RegisterOptionsTable("ZeraTooltip.profiles", profiles)
  AceConfigDialog:AddToBlizOptions("ZeraTooltip.profiles", "Profiles", ADDON_NAME)
  
end






local function SetDefault(val, default)
  if val == nil then
    return default
  end
  return val
end

function ZeraTooltip:OnInitialize()
  
  self.db = AceDB:New("ZeraTooltipDB", OPTION_DEFAULTS, true)
  
  L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
  
end

function ZeraTooltip:OnEnable()
  self:CreateOptions()
  self:CreateHooks()
end

function ZeraTooltip:OnDisable()
  
end
