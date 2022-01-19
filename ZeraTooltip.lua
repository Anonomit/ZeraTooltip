

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceHook-3.0")
ZeraTooltip = Addon
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local AceConfig       = LibStub"AceConfig-3.0"
local AceConfigDialog = LibStub"AceConfigDialog-3.0"
local AceDB           = LibStub"AceDB-3.0"
local AceDBOptions    = LibStub"AceDBOptions-3.0"

local SemVer          = LibStub"SemVer"


function Addon:GetDB()
  return self.db
end
function Addon:GetDefaultDB()
  return self.dbDefault
end
function Addon:GetProfile()
  return self:GetDB().profile
end
function Addon:GetDefaultProfile()
  return self:GetDefaultDB().profile
end
local function GetOption(self, db, ...)
  local val = db
  for _, key in ipairs{...} do
    val = val[key]
  end
  return val
end
function Addon:GetOption(...)
  return GetOption(self, self:GetProfile(), ...)
end
function Addon:GetDefaultOption(...)
  return GetOption(self, self:GetDefaultProfile(), ...)
end
local function SetOption(self, db, val, ...)
  local keys = {...}
  local lastKey = table.remove(keys, #keys)
  local tbl = db
  for _, key in ipairs(keys) do
    tbl = tbl[key]
  end
  tbl[lastKey] = val
end
function Addon:SetOption(val, ...)
  return SetOption(self, self:GetProfile(), val, ...)
end
function Addon:ResetOption(...)
  return self:SetOption(self:GetDefaultOption(...), ...)
end



function Addon:GetColor(key)
  assert(self:GetOption("COLORS", key), ("Missing Color entry: %s"):format(key))
  return self:GetOption("RECOLOR_STAT", key) and self:GetOption("COLORS", key) or nil
end
function Addon:ConvertColorToHex(r, g, b)
  return ("|cff%2x%2x%2x"):format(r, g, b)
end
function Addon:ConvertColorFromHex(hex)
  return tonumber(hex:sub(5, 6), 16), tonumber(hex:sub(7, 8), 16), tonumber(hex:sub(9, 10), 16)
end



function Addon:RemoveColorText(text)
  return text:gsub(Data.COLOR_CODE, "", 1):gsub(Data.COLOR_CODE_RESET, "")
end

function Addon:CleanColoring(tooltip)
  local textLeft = tooltip:GetName().."TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft..i]
    local text = fontString:GetText()
    if text then
      local color, colorlessText = text:match("^(" .. Data.COLOR_CODE .. ")(.*)" .. Data.COLOR_CODE_RESET .. "$")
      if color and colorlessText then
        if not colorlessText:find(Data.COLOR_CODE) and not colorlessText:find(Data.COLOR_CODE_RESET) then
          fontString:SetText(colorlessText)
          local r, g, b = self:ConvertColorFromHex(color)
          fontString:SetTextColor(Data:FontifyColor{r, g, b})
        end
      end
    end
  end
end



function Addon:TrimLine(text)
  return text:gsub(L["Equip PATTERN"], "")
end

function Addon:RewordLine(text)
  for i, data in ipairs(L) do
    for j, map in ipairs(data.MAP or {}) do
      local input, output = map.INPUT, map.OUTPUT
      local matches = {text:match(input)}
      if #matches > 0 then
        local newInput = input
        newInput = (input:find"%$$" and newInput:sub(1, #newInput-1) or newInput) .. "%.$"
        local newMatches = {text:match(newInput)}
        if #newMatches > 0 then
          matches = newMatches
          input = newInput
        end
        local pattern = type(output) == "function" and output(unpack(matches)) or output:format(unpack(matches))
        local newText = text:gsub(input, pattern)
        if (not newText:find(L["ConjunctiveWord PATTERN"]) or pattern:find(L["ConjunctiveWord PATTERN"])) then
          return text:gsub(input, pattern) .. (self:GetOption("Debug", "showLabels") and ("  [%s %d]"):format(data.LABEL, j) or "")
        end
      end
    end
  end
end

function Addon:RewordStats(tooltip)
  local textLeft = tooltip:GetName().."TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft..i]
    local text = fontString:GetText()
    if text then
      if text:match(L["Equip PATTERN"]) then
        text = text:gsub(L["Equip PATTERN"], "")
        fontString:SetText(text)
      end
      local setPrefix = text:match(L["Set PATTERN"])
      if setPrefix then
        text = text:sub(#setPrefix + 1, #text)
      end
      text = self:RewordLine(text)
      if text then
        if setPrefix then
          text = setPrefix .. text
        end
        fontString:SetText(text)
      end
    end
  end
end



function Addon:ReorderStats(tooltip, simplified, enchanted, gems)
  local enchantLineFound = not enchanted
  local groups           = {}
  local gemLines         = {}
  
  -- Exclude lines with gems from reordering
  local textLeft = tooltip:GetName() .. "TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft .. i]
    local text = fontString:GetText()
    if text then
      if text:match(L["SocketBonus PATTERN"]) then
        local gemsRemaining = gems
        for j = i-1, 2, -1 do
          if gemsRemaining <= 0 then break end
          gemLines[j] = true
          local fontString = _G[textLeft .. j]
          local text = fontString:GetText()
          if not text:match(L["Socket PATTERN"]) then
            gemsRemaining = gemsRemaining - 1
          end
        end
      end
    end
  end
  
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft .. i]
    local text = fontString:GetText()
    if text then
      local color = Data:DefontifyColor(fontString:GetTextColor())
      
      if Data:IsSameColorFuzzy(color, Data.GREEN) and not enchantLineFound and not text:match(("^%%d+%%s+%s$"):format(L["Armor"])) then
        enchantLineFound = true
      elseif not gemLines[i] then
        if not text:match(L["Set PATTERN"]) then
          for j, data in ipairs(L) do
            local captures = {}
            for _, capture in ipairs(data.CAPTURES or {}) do
              table.insert(captures, "^" .. capture)
            end
            if not simplified then
              for _, map in ipairs(data.MAP or {}) do
                table.insert(captures, map.INPUT)
              end
            end
            local found = false
            for k, pattern in ipairs(captures) do
              if text:match(pattern) then
                if #groups == 0 or not Data:IsSameColor(groups[#groups].color, color) or groups[#groups].line + #groups[#groups] ~= i then
                  table.insert(groups, {color = color, line = i})
                end
                table.insert(groups[#groups], {order = j, text = text})
                found = true
                break
              end
            end
            if found then break end
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



function Addon:RecolorStats(tooltip, simplified, enchanted)
  local enchantLineFound = not enchanted
  
  local textLeft = tooltip:GetName() .. "TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textLeft .. i]
    local text = fontString:GetText()
    if text then
      local color = Data:DefontifyColor(fontString:GetTextColor())
      
      if Data:IsSameColorFuzzy(color, Data.GREEN) and not enchantLineFound and not text:match(("^%%d+%%s+%s$"):format(L["Armor"])) then
        fontString:SetTextColor(Data:FontifyColor(self:GetOption("COLORS", "ENCHANT")))
        enchantLineFound = true
      elseif not self:GetOption"RECOLOR_USABLE" and text:find(L["Use PATTERN"]) then
        -- continue
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
          local found = false
          for k, pattern in ipairs(captures) do
            if text:match(pattern) and (not text:find(L["ConjunctiveWord PATTERN"]) or pattern:find(L["ConjunctiveWord PATTERN"])) then
              if data.COLOR then
                local newColor = self:GetColor(data.COLOR)
                if newColor then
                  if not Data:IsSameColorFuzzy(color, Data.GRAY) and not text:match(L["SocketBonus PATTERN"]) then
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
          if found then break end
        end
      end
    end
  end
end



function Addon:RewriteSpeed(tooltip)
  local textRight = tooltip:GetName().."TextRight"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[textRight..i]
    local text = fontString:GetText()
    if text then
      if text:find(L["Weapon Speed PATTERN"]) then
        
        -- This should match weapon speed values with any number of decimal places, though by default I think it's always two.
        local word, speed = text:match(L["Weapon Speed PATTERN"])
        speed = tonumber(speed)
        
        local fill = math.max(0, math.min(Data:Round((speed - Data.WEAPON_SPEED_MIN) / Data.WEAPON_SPEED_DIF * self:GetOption"SPEEDBAR_SIZE", 0), self:GetOption"SPEEDBAR_SIZE"))
        local bar = ""
        if self:GetOption"SHOW_SPEEDBAR" then
          bar = ("  [%s%s]"):format(("I"):rep(fill), (" "):rep(self:GetOption"SPEEDBAR_SIZE" - fill))
        end
        fontString:SetText(("%%s %%.%df%%s"):format(self:GetOption"SPEED_ACCURACY"):format(word, speed, bar))
        
        local color = self:GetColor"SPEED"
        if self:GetOption"RECOLOR" and color then
          fontString:SetTextColor(Data:FontifyColor(color))
        end
      end
    end
  end
end



function Addon:RecolorLearnable(tooltip, itemType, itemSubType, invType)
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



function Addon:OnTooltipSetHyperlink(tooltip)
  if not self:GetOption("Debug", "enabled") then return end
  if self:GetOption("Debug", "ctrlSuppression") and IsControlKeyDown() then return end
  local name, link = tooltip:GetItem()
  if not link then return end
  
  local enchant, gem1, gem2, gem3, gem4 = link:match"item:%d+:(%d*):(%d*):(%d*):(%d*):(%d*)"
  local enchanted = not not tonumber(enchant)
  local gems = (tonumber(gem1) and 1 or 0) + (tonumber(gem2) and 1 or 0) + (tonumber(gem3) and 1 or 0) + (tonumber(gem4) and 1 or 0)
  
  local itemType, itemSubType, _, invType = select(6, GetItemInfo(link))
  
  self:CleanColoring(tooltip)
  
  if self:GetOption"SIMPLIFY" then
    Addon:RewordStats(tooltip)
  end
  
  if self:GetOption"REORDER" then
    Addon:ReorderStats(tooltip, self:GetOption"SIMPLIFY", enchanted, gems)
  end
  
  if self:GetOption"RECOLOR" then
    Addon:RecolorStats(tooltip, self:GetOption"SIMPLIFY", enchanted)
    self:RecolorLearnable(tooltip, itemType, itemSubType, invType)
  end
  
  self:RewriteSpeed(tooltip)
end


function Addon:HookTooltip(tooltip)
  tooltip:HookScript("OnTooltipSetItem", function(...) return self:OnTooltipSetHyperlink(...) end)
end


function Addon:CreateHooks()
  self:HookTooltip(GameTooltip)
  self:HookTooltip(ItemRefTooltip)
  self:HookTooltip(ItemRefShoppingTooltip1)
  self:HookTooltip(ItemRefShoppingTooltip2)
  self:HookTooltip(ShoppingTooltip1)
  self:HookTooltip(ShoppingTooltip2)
end


function Addon:OnChatCommand(input)
  self:OpenConfig(ADDON_NAME, true)
end

function Addon:OpenConfig(category, expandSection)
  InterfaceAddOnsList_Update()
  InterfaceOptionsFrame_OpenToCategory(category)
  
  if expandSection then
    -- Expand config if it's collapsed
    local i = 1
    while _G["InterfaceOptionsFrameAddOnsButton"..i] do
      local frame = _G["InterfaceOptionsFrameAddOnsButton"..i]
      if frame.element then
        if frame.element.name == ADDON_NAME then
          if frame.element.hasChildren and frame.element.collapsed then
            if _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"] and _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"].Click then
              _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
              break
            end
          end
          break
        end
      end
      
      i = i + 1
    end
  end
end
function Addon:MakeDefaultFunc(category)
  return function()
    self:GetDB():ResetProfile()
    self:Printf(L["Profile reset to default."])
    AceConfigRegistry:NotifyChange(category)
  end
end
function Addon:CreateOptionsCategory(categoryName, options)
  local category = ADDON_NAME
  if categoryName then
    category = ("%s.%s"):format(category, categoryName)
  end
  AceConfig:RegisterOptionsTable(category, options)
  local Panel = AceConfigDialog:AddToBlizOptions(category, categoryName, categoryName and ADDON_NAME or nil)
  Panel.default = self:MakeDefaultFunc(category)
  return Panel
end

function Addon:CreateOptions()
  self:CreateOptionsCategory(nil, Data:MakeOptionsTable(ADDON_NAME, self, L))
  
  self:CreateOptionsCategory("Speedbar", Data:MakeSpeedbarOptionsTable(L["Speedbar Configuration"], self, L))
  self:CreateOptionsCategory("Colors"  , Data:MakeColorsOptionsTable(L["Colors Configuration"], self, L))
  
  self:CreateOptionsCategory("Profiles", AceDBOptions:GetOptionsTable(self:GetDB()))
  
  if self:GetOption("Debug", "menu") then
    self:CreateOptionsCategory("Debug" , Data:MakeDebugOptionsTable("Debug", self, L))
  end
end



function Addon:InitDB()
  local configVersion = SemVer(self:GetOption"version" or self.Version)
  -- Update data schema here
  
  self:SetOption(tostring(self.Version), "version")
end


function Addon:OnInitialize()
  self.db        = AceDB:New(("%sDB"):format(ADDON_NAME), Data:MakeDefaultOptions(), true)
  self.dbDefault = AceDB:New({}                         , Data:MakeDefaultOptions(), true)
  
  Data:OnInitialize(L)
  
  self:RegisterChatCommand(Data.CHAT_COMMAND, "OnChatCommand", true)
end

function Addon:OnEnable()
  self.Version = SemVer(GetAddOnMetadata(ADDON_NAME, "Version"))
  self:InitDB()
  
  self:CreateOptions()
  self:CreateHooks()
end

function Addon:OnDisable()
  
end
