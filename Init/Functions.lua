
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




local strLower  = string.lower
local strSub    = string.sub
local strGsub   = string.gsub
local strGmatch = string.gmatch

local tinsert   = table.insert
local tblConcat = table.concat
local tblRemove = table.remove

local mathMin   = math.min
local mathMax   = math.max











--  ██████╗  █████╗ ████████╗ █████╗ ██████╗  █████╗ ███████╗███████╗
--  ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
--  ██║  ██║███████║   ██║   ███████║██████╔╝███████║███████╗█████╗  
--  ██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗██╔══██║╚════██║██╔══╝  
--  ██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝██║  ██║███████║███████╗
--  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝

do
  local function DeepCopy(orig, seen)
    local new
    if type(orig) == "table" then
      if seen[orig] then
        new = seen[orig]
      else
        new = {}
        seen[orig] = copy
        for k, v in next, orig, nil do
          new[DeepCopy(k, seen)] = DeepCopy(v, seen)
        end
        setmetatable(new, DeepCopy(getmetatable(orig), seen))
      end
    else
      new = orig
    end
    return new
  end
  function Addon:Copy(val)
    return DeepCopy(val, {})
  end
  
  function Addon:GetDB()
    return self.db
  end
  function Addon:GetDefaultDB()
    return self.dbDefault
  end
  function Addon:GetProfile()
    return Addon.GetDB(self).profile
  end
  function Addon:GetDefaultProfile()
    return Addon.GetDefaultDB(self).profile
  end
  local function GetOption(self, db, ...)
    local val = db
    for _, key in ipairs{...} do
      assert(type(val) == "table", format("Bad database access: %s", tblConcat({...}, " > ")))
      val = val[key]
    end
    return val
  end
  function Addon:GetOption(...)
    return GetOption(self, Addon.GetProfile(self), ...)
  end
  function Addon:GetDefaultOption(...)
    return GetOption(self, Addon.GetDefaultProfile(self), ...)
  end
  local function SetOption(self, db, val, ...)
    local keys = {...}
    local lastKey = tblRemove(keys, #keys)
    local tbl = db
    for _, key in ipairs(keys) do
      tbl = tbl[key]
    end
    tbl[lastKey] = val
    Addon.OnOptionSet(Addon, db, val, ...)
  end
  function Addon:SetOption(val, ...)
    return SetOption(self, Addon.GetProfile(self), val, ...)
  end
  function Addon:ResetOption(...)
    return Addon.SetOption(self, Addon.Copy(self, Addon.GetDefaultOption(self, ...)), ...)
  end
  
  function Addon:OnOptionSet(...)
    if not self:GetDB() then return end -- db hasn't loaded yet
    for funcName, func in next, Addon.onOptionSetHandlers, nil do
      if type(func) == "function" then
        func(self, ...)
      else
        self[funcName](self, ...)
      end
    end
  end
end






--   ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--   ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  -- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
  -- Originally from BlizzBugsSuck (https://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html) and edited to not be global
  local function GetPanelName(panel)
    local tp = type(panel)
    local cat = INTERFACEOPTIONS_ADDONCATEGORIES
    if tp == "string" then
      for i = 1, #cat do
        local p = cat[i]
        if p.name == panel then
          if p.parent then
            return GetPanelName(p.parent)
          else
            return panel
          end
        end
      end
    elseif tp == "table" then
      for i = 1, #cat do
        local p = cat[i]
        if p == panel then
          if p.parent then
            return GetPanelName(p.parent)
          else
            return panel.name
          end
        end
      end
    end
  end
  
  local skip
  local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
    if skip --[[or InCombatLockdown()--]] then return end
    local panelName = GetPanelName(panel)
    if not panelName then return end -- if its not part of our list return early
    local noncollapsedHeaders = {}
    local shownPanels = 0
    local myPanel
    local t = {}
    local cat = INTERFACEOPTIONS_ADDONCATEGORIES
    for i = 1, #cat do
      local panel = cat[i]
      if not panel.parent or noncollapsedHeaders[panel.parent] then
        if panel.name == panelName then
          panel.collapsed = true
          t.element = panel
          InterfaceOptionsListButton_ToggleSubCategories(t)
          noncollapsedHeaders[panel.name] = true
          myPanel = shownPanels + 1
        end
        if not panel.collapsed then
          noncollapsedHeaders[panel.name] = true
        end
        shownPanels = shownPanels + 1
      end
    end
    local min, max = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
    if shownPanels > 15 and min < max then
      local val = (max/(shownPanels-15))*(myPanel-2)
      InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
    end
    skip = true
    InterfaceOptionsFrame_OpenToCategory(panel)
    skip = false
  end
  
  local isMe = false
  hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", function(...)
    if skip then return end
    if Addon:GetOption("fix", "InterfaceOptionsFrameForAll") or Addon:GetOption("fix", "InterfaceOptionsFrameForMe") and isMe then
      Addon:DebugIf({"debugOutput", "InterfaceOptionsFrameFix"}, "Patching Interface Options")
      InterfaceOptionsFrame_OpenToCategory_Fix(...)
      isMe = false
    end
  end)
  
  function Addon:OpenConfig(category)
    isMe = Addon:GetOption("fix", "InterfaceOptionsFrameForMe")
    if isMe then
      InterfaceOptionsFrame_OpenToCategory(category)
      isMe = true
    end
    InterfaceOptionsFrame_OpenToCategory(category)
  end
  
  
  
  function Addon:ResetProfile(category)
    self:GetDB():ResetProfile()
    self.AceConfigRegistry:NotifyChange(category)
  end
  
  function Addon:CreateOptionsCategory(categoryName, options)
    local category = ADDON_NAME .. (categoryName and ("." .. categoryName) or "")
    self.AceConfig:RegisterOptionsTable(category, options)
    local Panel = self.AceConfigDialog:AddToBlizOptions(category, categoryName, categoryName and ADDON_NAME or nil)
    Panel.default = function() self:ResetProfile(category) end
    return Panel
  end
end






--  ███╗   ██╗██╗   ██╗███╗   ███╗██████╗ ███████╗██████╗ ███████╗
--  ████╗  ██║██║   ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔════╝
--  ██╔██╗ ██║██║   ██║██╔████╔██║██████╔╝█████╗  ██████╔╝███████╗
--  ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══██╗██╔══╝  ██╔══██╗╚════██║
--  ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗██║  ██║███████║
--  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝

do
  function Addon:Round(num, nearest)
    nearest = nearest or 1
    local lower = math.floor(num / nearest) * nearest
    local upper = lower + nearest
    return (upper - num < num - lower) and upper or lower
  end
  
  function Addon:Clamp(min, num, max)
    assert(type(min) == "number", "Can't clamp. min is " .. type(min))
    assert(type(max) == "number", "Can't clamp. max is " .. type(max))
    assert(min <= max, format("Can't clamp. min (%d) > max (%d)", min, max))
    return mathMin(mathMax(num, min), max)
  end
end






--  ████████╗ █████╗ ██████╗ ██╗     ███████╗███████╗
--  ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
--     ██║   ███████║██████╔╝██║     █████╗  ███████╗
--     ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--     ██║   ██║  ██║██████╔╝███████╗███████╗███████║
--     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝

do
  function Addon:Map(t, ValMap, KeyMap)
    if type(KeyMap) == "table" then
      local keyTbl = KeyMap
      KeyMap = function(v, k, self) return keyTbl[k] end
    end
    if type(ValMap) == "table" then
      local valTbl = KeyMap
      ValMap = function(v, k, self) return valTbl[k] end
    end
    local new = {}
    for k, v in next, t, nil do
      local key, val = k, v
      if KeyMap then
        key = KeyMap(v, k, t)
      end
      if ValMap then
        val = ValMap(v, k, t)
      end
      if key then
        new[key] = val
      end
    end
    local meta = getmetatable(t)
    if meta then
      setmetatable(new, meta)
    end
    return new
  end
  
  function Addon:MakeLookupTable(t, val, keepOrigVals)
    local ValFunc
    if val ~= nil then
      if type(val) == "function" then
        ValFunc = val
      else
        ValFunc = function() return val end
      end
    end
    local new = {}
    for k, v in next, t, nil do
      if ValFunc then
        new[v] = ValFunc(v, k, t)
      else
        new[v] = k
      end
      if keepOrigVals and new[k] == nil then
        new[k] = v
      end
    end
    return new
  end
end




--  ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
--  ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
--  ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║╚════██║
--  ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

do
  local function strRemove(text, ...)
    for _, pattern in ipairs{...} do
      text = strGsub(text, pattern, "")
    end
    return text
  end
  
  function Addon:StripText(text)
    return strRemove(text, "|c%x%x%x%x%x%x%x%x", "|r", "^ +", " +$")
  end
  
  function Addon:ChainGsub(text, ...)
    for i, patterns in ipairs{...} do
      local newText = patterns[#patterns]
      for i = 1, #patterns - 1 do
        local oldText = patterns[i]
        text = strGsub(text, oldText, newText)
      end
    end
    return text
  end
  
  local chainGsubPattern = {{"%%%d%$", "%%"}, {"[+-]", "%%%1"}, {"[%(%)%.]", "%%%0"}, {"%%c", "([+-])"}, {"%%d", "(%%d+)"}, {"%%s", "(.*)"}, {"|4[^:]-:[^:]-:[^:]-;", ".-"}, {"|4[^:]-:[^:]-;", ".-"}}
  local reversedPatternsCache = {}
  function Addon:ReversePattern(text)
    if not reversedPatternsCache[text] then
      reversedPatternsCache[text] = "^" .. self:ChainGsub(text, unpack(chainGsubPattern)) .. "$"
    end
    return reversedPatternsCache[text]
  end
  
  
  function Addon:CoverSpecialCharacters(text)
    return self:ChainGsub(text, {"%p", "%%%0"})
  end
  function Addon:UncoverSpecialCharacters(text)
    return (strGsub(text, "%%(.)", "%1"))
  end
  
  
  
  function Addon:MakeIcon(texture, size)
    return "|T" .. texture .. ":" .. tostring(size or "0") .. "|t"
  end
  function Addon:UnmakeIcon(texture)
    return self:ChainGsub(texture, {"^|T", ":%d+|t$", ""})
  end
  
  function Addon:InsertIcon(text, stat, customTexture)
    if self:GetOption("doIcon", stat) then
      if self:GetOption("iconSpace", stat) then
        text = " " .. text
      end
      text = self:MakeIcon(customTexture or self:GetOption("icon", stat), self:GetOption("iconSizeManual", stat) and self:GetOption("iconSize", stat) or 0) .. text
    end
    return text
  end
end




--   ██████╗ ██████╗ ██╗      ██████╗ ██████╗ ███████╗
--  ██╔════╝██╔═══██╗██║     ██╔═══██╗██╔══██╗██╔════╝
--  ██║     ██║   ██║██║     ██║   ██║██████╔╝███████╗
--  ██║     ██║   ██║██║     ██║   ██║██╔══██╗╚════██║
--  ╚██████╗╚██████╔╝███████╗╚██████╔╝██║  ██║███████║
--   ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

do
  function Addon:GetHexFromColor(r, g, b)
    return format("%02x%02x%02x", r, g, b)
  end
  function Addon:ConvertColorFromBlizzard(r, g, b)
    return self:GetHexFromColor(self:Round(r*255, 1), self:Round(g*255, 1), self:Round(b*255, 1))
  end
  function Addon:GetTextColorAsHex(frame)
    return self:ConvertColorFromBlizzard(frame:GetTextColor())
  end
  
  function Addon:ConvertColorToBlizzard(hex)
    return tonumber(strSub(hex, 1, 2), 16) / 255, tonumber(strSub(hex, 3, 4), 16) / 255, tonumber(strSub(hex, 5, 6), 16) / 255, 1
  end
  function Addon:SetTextColorFromHex(frame, hex)
    frame:SetTextColor(self:ConvertColorToBlizzard(hex))
  end
  
  function Addon:MakeColorCode(hex, text)
    return format("|cff%s%s%s", hex, text or "", text and "|r" or "")
  end
  
  function Addon:StripColorCode(text, hex)
    local pattern = hex and ("|c%x%x" .. hex) or "|c%x%x%x%x%x%x%x%x"
    return self:ChainGsub(text, {pattern, "|r", ""})
  end
end




--  ███████╗████████╗ █████╗ ████████╗███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
--  ███████╗   ██║   ███████║   ██║   ███████╗
--  ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
--  ███████║   ██║   ██║  ██║   ██║   ███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝

do
  function Addon:RegenerateStatOrder()
    wipe(self.statList[self.expansionLevel])
    wipe(self.statOrder)
    for stat in strGmatch(self:GetOption("order", self.expansionLevel), "[^,]+") do
      tinsert(self.statList[self.expansionLevel], stat)
      self.statOrder[stat] = #self.statList[self.expansionLevel]
    end
  end
  
  function Addon:ChangeOrder(from, to)
    tinsert(self.statList[self.expansionLevel], to, tblRemove(self.statList[self.expansionLevel], from))
    self:SetOption(tblConcat(self.statList[self.expansionLevel], ","), "order", self.expansionLevel)
    self:RegenerateStatOrder()
  end
  function Addon:ResetOrder()
    self:ResetOption("order", self.expansionLevel)
    self:RegenerateStatOrder()
  end
  function Addon:ResetReword(stat)
    self:ResetOption("reword", stat)
    self:SetDefaultRewordByLocale(stat)
  end
  function Addon:ResetMod(stat)
    self:ResetOption("mod", stat)
    self:SetDefaultModByLocale(stat)
  end
  function Addon:ResetPrecision(stat)
    self:ResetOption("precision", stat)
    self:SetDefaultPrecisionByLocale(stat)
  end
end




--  ██╗      ██████╗  ██████╗ █████╗ ██╗     ███████╗    ███████╗██╗  ██╗████████╗██████╗  █████╗ ███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██╔════╝    ██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝
--  ██║     ██║   ██║██║     ███████║██║     █████╗      █████╗   ╚███╔╝    ██║   ██████╔╝███████║███████╗
--  ██║     ██║   ██║██║     ██╔══██║██║     ██╔══╝      ██╔══╝   ██╔██╗    ██║   ██╔══██╗██╔══██║╚════██║
--  ███████╗╚██████╔╝╚██████╗██║  ██║███████╗███████╗    ███████╗██╔╝ ██╗   ██║   ██║  ██║██║  ██║███████║
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

do
  local defaultRewordLocaleOverrides    = {}
  local defaultModLocaleOverrides       = {}
  local defaultPrecisionLocaleOverrides = {}
  local localeExtraStatCaptures         = {}
  local localeExtraReplacements         = {}
  
  function Addon:AddDefaultRewordByLocale(stat, val)
    defaultRewordLocaleOverrides[stat] = val
  end
  function Addon:AddDefaultModByLocale(stat, val)
    defaultModLocaleOverrides[stat] = val
  end
  function Addon:AddDefaultPrecisionByLocale(stat, val)
    defaultPrecisionLocaleOverrides[stat] = val
  end
  
  function Addon:GetExtraStatCapture(stat)
    return localeExtraStatCaptures[stat]
  end
  function Addon:AddExtraStatCapture(stat, ...)
    if not localeExtraStatCaptures[stat] then
      localeExtraStatCaptures[stat] = {}
    end
    for i, rule in ipairs{...} do
      tinsert(localeExtraStatCaptures[stat], rule)
    end
  end
  
  local replacementKeys = {}
  function Addon:GetExtraReplacements()
    return localeExtraReplacements
  end
  function Addon:AddExtraReplacement(label, ...)
    if not replacementKeys[label] then
      tinsert(localeExtraReplacements, {label = label})
      replacementKeys[label] = #localeExtraReplacements
    end
    for i, rule in ipairs{...} do
      tinsert(localeExtraReplacements[replacementKeys[label]], rule)
    end
  end
  
  
  -- these functions are run when relevant settings are reset/initialized
  local localeDefaultOverrideMethods = {
    SetDefaultRewordByLocale    = {"reword"   , defaultRewordLocaleOverrides},
    SetDefaultModByLocale       = {"mod"      , defaultModLocaleOverrides},
    SetDefaultPrecisionByLocale = {"precision", defaultPrecisionLocaleOverrides},
  }
  for method, data in pairs(localeDefaultOverrideMethods) do
    local field, overrides = unpack(data, 1, 2)
    Addon[method] = function(self, stat)
      if stat then
        if overrides[stat] then
          Addon.SetOption(self, overrides[stat], field, stat)
        end
      else
        for stat, val in pairs(overrides) do
          Addon.SetOption(self, val, field, stat)
        end
      end
    end
  end
  
  function Addon:OverrideAllLocaleDefaults()
    for method in pairs(localeDefaultOverrideMethods) do
      Addon[method](self)
    end
  end
end






