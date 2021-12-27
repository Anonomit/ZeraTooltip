

local ADDON_NAME, Data = ...

ZeraTooltip = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

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




function ZeraTooltip:GetColor(key)
  if not self.db then return end
  assert(self.db.profile.COLORS[key], ("Missing Color entry: %s"):format(key))
  return self.db.profile.RECOLOR_STAT[key] and self.db.profile.COLORS[key] or nil
end



function ZeraTooltip:TrimLine(text)
  return text:gsub(L["Equip Pattern"], "")
end

function ZeraTooltip:RewordLine(text)
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

function ZeraTooltip:RewordStats(tooltip)
  local textLeft = tooltip:GetName().."TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft..i]
    local text = fontString:GetText()
    if text then
      if text:find"%d" then
        text = self:RewordLine(text)
        if text then
          fontString:SetText(text)
        end
      end
    end
  end
end



function ZeraTooltip:ReorderStats(tooltip, simplified, enchanted)
  local enchantLineFound = not enchanted
  local groups = { }
  
  local textLeft = tooltip:GetName() .. "TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft .. i]
    local text = fontString:GetText()
    if text then
      local color = Data:DefontifyColor(fontString:GetTextColor())
      
      if Data:IsSameColorFuzzy(color, Data.GREEN) and not enchantLineFound and not text:match(("^%%d+%%s+%s$"):format(L["Armor"])) then
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
              if #groups == 0 or not Data:IsSameColor(groups[#groups].color, color) or groups[#groups].line + #groups[#groups] ~= i then
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
        local fontString = _G[textLeft .. (group.line + i - 1)]
        fontString:SetText(line.text)
      end
    end
  end
end



function ZeraTooltip:RecolorStats(tooltip, simplified, enchanted)
  local enchantLineFound = not enchanted
  
  local textLeft = tooltip:GetName() .. "TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft .. i]
    local text = fontString:GetText()
    if text then
      local color = Data:DefontifyColor(fontString:GetTextColor())
      
      if Data:IsSameColorFuzzy(color, Data.GREEN) and not enchantLineFound and not text:match(("^%%d+%%s+%s$"):format(L["Armor"])) then
        fontString:SetTextColor(Data:FontifyColor(self.db.profile.COLORS.ENCHANT))
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
                  if not Data:IsSameColorFuzzy(color, Data.GRAY) and not text:match(L["SocketBonus Pattern"]) then
                    fontString:SetTextColor(Data:FontifyColor(newColor))
                    if text:find(Data.COLOR_CODE) then
                      local newText = text:gsub(Data.COLOR_CODE, "")
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



function ZeraTooltip:RewriteSpeed(tooltip)
  local textRight = tooltip:GetName().."TextRight"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textRight..i]
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
        
        local fill = math.max(0, math.min(Data:Round((speed - Data.WEAPON_SPEED_MIN) / Data.WEAPON_SPEED_DIF * self.db.profile.SPEEDBAR_SIZE, 0), self.db.profile.SPEEDBAR_SIZE))
        local bar = ""
        if self.db.profile.SHOW_SPEEDBAR then
          bar = ("  [%s%s]"):format(("I"):rep(fill), (" "):rep(self.db.profile.SPEEDBAR_SIZE - fill))
        end
        fontString:SetText(("%%s %%.%df%%s"):format(self.db.profile.SPEED_ACCURACY):format(word, speed, bar))
        
        local color = self:GetColor"SPEED"
        if self.db.profile.RECOLOR and color then
          fontString:SetTextColor(Data:FontifyColor(color))
        end
      end
    end
  end
end



function ZeraTooltip:RecolorLearnable(tooltip, itemType, itemSubType, invType)
  local redWeapon, redSlot
  if Data:IsUsable(itemType, itemSubType, invType) then
    redWeapon, redSlot = Data:GetRedText(itemType, itemSubType, invType)
  end
  if not redWeapon then return end
  
  local textLeft  = tooltip:GetName().."TextLeft"
  local textRight = tooltip:GetName().."TextRight"
  for i = 2, tooltip:NumLines() do
    local leftString  = _G[textLeft..i]
    local rightString = _G[textRight..i]
    local leftText  =  leftString:GetText()
    local rightText = rightString:GetText()
    
    local completed = false
    if leftText == redWeapon or leftText == redSlot then
      local color = Data:DefontifyColor(leftString:GetTextColor())
      if Data:IsSameColorFuzzy(color, Data.RED) then
        leftString:SetTextColor(Data:FontifyColor(self:GetColor"TRAINABLE"))
      end
      completed = true
    end
    if rightText == redWeapon then
      local color = Data:DefontifyColor(rightString:GetTextColor())
      if Data:IsSameColorFuzzy(color, Data.RED) then
        rightString:SetTextColor(Data:FontifyColor(self:GetColor"TRAINABLE"))
      end
      completed = true
    end
    if completed then return end
  end
end



function ZeraTooltip:OnTooltipSetHyperlink(tooltip)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  local name, link = tooltip:GetItem()
  if not link then return end
  
  local enchanted = not not link:find"item:%d+:%d+"
  local itemType, itemSubType, _, invType = select(6, GetItemInfo(link))
  
  if self.db.profile.SIMPLIFY then
    ZeraTooltip:RewordStats(tooltip)
  end
  
  if self.db.profile.REORDER then
    ZeraTooltip:ReorderStats(tooltip, self.db.profile.SIMPLIFY, enchanted)
  end
  
  if self.db.profile.RECOLOR then
    ZeraTooltip:RecolorStats(tooltip, self.db.profile.SIMPLIFY, enchanted)
    self:RecolorLearnable(tooltip, itemType, itemSubType, invType)
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




function ZeraTooltip:CreateOptions()
  AceConfig:RegisterOptionsTable(ADDON_NAME, Data:MakeOptionsTable(self.db.profile, L))
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
  Data:OnInitialize(L)
  
  self.db = AceDB:New("ZeraTooltipDB", Data:GetDefaultOptions(), true)
  
end

function ZeraTooltip:OnEnable()
  self:CreateOptions()
  self:CreateHooks()
end

function ZeraTooltip:OnDisable()
  
end
