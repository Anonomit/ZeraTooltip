
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

local strGsub = string.gsub
local strSub  = string.sub

local tblConcat = table.concat


function Addon:DestructTooltip(tooltip, halfDestructor, noShow)
  for i = #halfDestructor, 1, -1 do
    halfDestructor[i]()
  end
  tooltip:Show()
end



local function FakeoutLastLine(fullDestructor, halfDestructor, tooltip, destFrame, hide)
  tooltip:AddLine(" ")
  local padOffset = 0
  local frame     = _G[tooltip:GetName().."TextLeft"..tooltip:NumLines()]
  local numPoints = frame:GetNumPoints()
  for i = 1, numPoints do
    local point = {frame:GetPoint(i)}
    table.insert(fullDestructor, function() frame:SetPoint(unpack(point, 1, 5)) end)
  end
  table.insert(fullDestructor, function() frame:ClearAllPoints() end)
  for i = 1, numPoints do
    local point = {frame:GetPoint(i)}
    if strSub(point[1], 1, 3) == "TOP" then
      point[4] = point[4] or 0
      point[5] = point[5] or 0
      local current = {unpack(point, 1, 5)}
      padOffset = padOffset + point[5]
      point[2] = destFrame
      point[3] = strGsub(point[3], "BOTTOM", "TOP")
      point[5] = 0
      frame:SetPoint(unpack(point, 1, 5))
    end
  end
  padOffset = padOffset - frame:GetHeight()
  frame:SetPoint("BOTTOM", destFrame, "BOTTOM")
  frame:SetShown(not hide)
  if not hide then
    table.insert(halfDestructor, function() frame:Hide() end)
    table.insert(fullDestructor, function() frame:Show() end)
  end
  -- pad frame is now in the same position of the second last frame
  return padOffset
end

local append = ""
local lastTooltip
local lastTooltipName
local builtTextureMap
local builtMoneyMap
local textureMap = {}
local moneyMap   = {}

setmetatable(textureMap, {
  __index = function(t, k)
    if not builtTextureMap then
      local textureName = lastTooltipName .. "Texture"
      for i = 1, 10 do
        local texture = _G[textureName .. i]
        if texture and texture:IsShown() then
          local _, parent = texture:GetPoint()
          if parent then
            textureMap[parent] = {i, texture}
          end
        else
          break
        end
      end
      builtTextureMap = true
    end
    return rawget(t, k)
  end
})
setmetatable(moneyMap, {
  __index = function(t, k)
    if not builtMoneyMap then
      local moneyFrameName = lastTooltipName .. "MoneyFrame"
      if lastTooltip.hasMoney then
        for i = 1, lastTooltip.shownMoneyFrames or 0 do
          local moneyFrame = _G[moneyFrameName .. i]
          if moneyFrame and moneyFrame:IsShown() then
            local _, parent = moneyFrame:GetPoint()
            if parent then
              moneyMap[parent] = {i, moneyFrame}
            end
          end
        end
      end
      builtMoneyMap = true
    end
    return rawget(t, k)
  end
})

local function MoveLine(fullDestructor, halfDestructor, tooltip, tooltipName, frame, source, dest, pad, lastFrame, extraLinesMap)
  dest = extraLinesMap[dest] or dest
  local destFrame = _G[tooltipName.."TextLeft"..dest]
  local padOffset = 0
  if pad then
    -- if this line should be padded, add a new line and put it behind the current last line
    -- but don't do that if this line is already padding. that can happen if another addon adds a padding line
    local rightFrame = _G[tooltipName.."TextRight"..source]
    if not (frame:IsShown() and Addon:StripText(frame:GetText()) == "" and not (rightFrame and rightFrame:IsShown() or textureMap[frame] or moneyMap[frame])) then
      padOffset = FakeoutLastLine(fullDestructor, halfDestructor, tooltip, lastFrame)
    end
  end
  
  Addon:DebugfIf({"debugOutput", "constructorLineMove"}, "Attaching line %s to line %s", source, dest)
  
  -- attach the source line to the dest line, with padding offset
  local numPoints = frame:GetNumPoints()
  for i = 1, numPoints do
    local point = {frame:GetPoint(i)}
    if strSub(point[1], 1, 3) == "TOP" then
      point[4] = point[4] or 0
      point[5] = point[5] or 0
      local current = {unpack(point, 1, 5)}
      table.insert(halfDestructor, function() frame:SetPoint(unpack(current, 1, 5)) end)
      point[2] = destFrame
      if padOffset ~= 0 then
        point[5] = point[5] + padOffset
      end
      frame:SetPoint(unpack(point, 1, 5))
    end
  end
end


function Addon:ConstructTooltip(tooltip, constructor)
  local fullDestructor = {}
  local halfDestructor = {}
  
  local tooltipName = tooltip:GetName()
  lastTooltip       = tooltip
  lastTooltipName   = tooltipName
  local numLines    = tooltip:NumLines()
  local lastLine    = constructor.numLines == numLines and constructor.lastLine or numLines
  local lastFrame   = _G[tooltipName.."TextLeft"..lastLine]
  
  wipe(textureMap)
  wipe(moneyMap)
  builtTextureMap = false
  builtMoneyMap   = false
  
  local extraLinesMap = {}
  local addedExtraLine
  for _, data in ipairs(constructor.addLines or {}) do
    local double = data[1]
    if double then
      local textLeft, hexLeft, textRight, hexRight = unpack(data, 3, 5)
      local rLeft, gLeft, bLeft, rRight, gRight, bRight
      if hexLeft then
        rLeft, gLeft, bLeft = self:ConvertColorToBlizzard(hexLeft)
      end
      if hexRight then
        rRight, gRight, bRight = self:ConvertColorToBlizzard(hexRight)
      end
      tooltip:AddDoubleLine(textLeft, textRight, rLeft, gLeft, bLeft, rRight, gRight, bRight)
    else
      local textLeft, hex, wordWrap = unpack(data, 3, 4)
      local r, g, b
      if hex then
        r, g, b = self:ConvertColorToBlizzard(hex)
      end
      tooltip:AddLine(textLeft, r, g, b, wordWrap)
    end
    local source = tooltip:NumLines()
    local frame = _G[tooltipName.."TextLeft"..source]
    table.insert(halfDestructor, function() frame:Hide() end)
    local dest = data[2]
    MoveLine(fullDestructor, halfDestructor, tooltip, tooltipName, frame, source, dest, nil, lastFrame, extraLinesMap)
    extraLinesMap[dest] = source
    addedExtraLine      = true
  end
  
  -- do rewording first so that recycled padding can be detected
  for _, change in ipairs(constructor) do
    local source, _, _, rewordLeft, rewordRight = unpack(change, 1, 5)
    if rewordRight then
      local frame = _G[tooltipName.."TextRight"..source]
      if frame then
        local current = frame:GetText()
        table.insert(halfDestructor, function() frame:SetText(current) end)
        frame:SetText(rewordRight)
        if not frame:IsShown() then
          table.insert(halfDestructor, function() frame:Hide() end)
          frame:Show()
        end
      end
    end
    if rewordLeft then
      local frame = _G[tooltipName.."TextLeft"..source]
      if frame and frame:IsShown() then
        local current = frame:GetText()
        table.insert(halfDestructor, function() frame:SetText(current) end)
        frame:SetText(rewordLeft)
      end
    end
  end
  
  for _, change in ipairs(constructor) do
    local source, dest, hideLeft, _, _, pad, recolorLeft, recolorRight, hideRight = unpack(change, 1, 9)
    local frame = _G[tooltipName.."TextLeft"..source]
    local rightFrame = _G[tooltipName.."TextRight"..source]
    
    if hideLeft and frame then
      frame:Hide()
      for _, frame in pairs{frame, rightFrame, textureMap[frame], moneyMap[frame]} do
        if frame and frame:IsShown() then
          local closureFrame = frame
          table.insert(halfDestructor, function() closureFrame:Show() end)
          frame:Hide()
        end
      end
      frame = nil
    end
    
    if frame and frame:IsShown() then
      if hideRight and rightFrame and rightFrame:IsShown() then
        local closureFrame = rightFrame
        table.insert(halfDestructor, function() closureFrame:Show() end)
        rightFrame:Hide()
        rightFrame = nil
      end
      if recolorLeft then
        local current = Addon:GetTextColorAsHex(frame)
        table.insert(halfDestructor, function() self:SetTextColorFromHex(frame, current) end)
        self:SetTextColorFromHex(frame, recolorLeft)
      end
      if recolorRight and rightFrame and rightFrame:IsShown() then
        local current = Addon:GetTextColorAsHex(rightFrame)
        table.insert(halfDestructor, function() self:SetTextColorFromHex(rightFrame, current) end)
        self:SetTextColorFromHex(rightFrame, recolorRight)
      end
      if dest then
        local success, err = pcall(function() MoveLine(fullDestructor, halfDestructor, tooltip, tooltipName, frame, source, dest, pad, lastFrame, extraLinesMap) end)
        if not success then
          -- just in case some frame anchoring doesn't work as expected
          table.insert(halfDestructor, 1, function() tooltip:AddDoubleLine(ADDON_NAME, self.L["ERROR"], 1, 0, 0, 1, 0, 0) end)
          self:DestructTooltip(tooltip, halfDestructor)
          if self:GetOption("debugOutput", "constructorError") then
            self:DebugData{
              {"tooltip",    tooltipName},
              {"source",     source},
              {"dest",       dest},
              {"actualDest", extraLinesMap[dest]},
              {"pad",        pad},
            }
            if self:IsDebugEnabled() then
              geterrorhandler()(err)
            end
          end
          return fullDestructor
        end
      end
    end
  end
  
  if addedExtraLine or constructor.lastLine ~= numLines and constructor.numLines == tooltip:NumLines() then
    -- the last tooltip line is not positioned at the end. this should only happen if no lines have been added yet by any addon
    -- in this case, final padding must be abandoned. this causes bad padding only if another addon adds a line after this
    -- TODO: it is probably possible to fix this by hooking AddLine and AddDoubleLine
    FakeoutLastLine(fullDestructor, halfDestructor, tooltip, lastFrame, true)
  end
  
  tooltip:Show()
  for _, v in ipairs(halfDestructor) do
    table.insert(fullDestructor, v)
  end
  return fullDestructor
end


function Addon:ValidateConstructor(tooltip, constructor)
  if not self:GetOption("constructor", "doValidation") then
    return true
  end
  if not constructor.validation then
    self:DebugIf({"debugOutput", "constructorValidationFail"}, "Constructor validation failed. Constructor has no validation table")
    return false
  end
  
  local tooltipName = tooltip:GetName()
  
  for i = constructor.numLines, 1, -1 do
    local validation = constructor.validation[i]
    if not validation then
      self:DebugfIf({"debugOutput", "constructorValidationFail"}, "Constructor validation failed. Line %d, Missing validation data", i)
    end
    
    local frame = _G[tooltipName.."TextLeft"..i]
    if not frame then
      self:DebugfIf({"debugOutput", "constructorValidationFail"}, "Constructor validation failed. Line %d, Expected '%s', Could not find %s", i, validation, tooltipName.."TextLeft"..i)
      return false
    end
    if frame:GetText() ~= validation then
      self:DebugfIf({"debugOutput", "constructorValidationFail"}, "Constructor validation failed. Line %d, Expected '%s', Found '%s'", i, validation, frame:GetText())
      return false
    end
  end
  
  return true
end
