

local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
ZeraTooltip = Addon


Addon.AceConfig         = LibStub"AceConfig-3.0"
Addon.AceConfigDialog   = LibStub"AceConfigDialog-3.0"
Addon.AceConfigRegistry = LibStub"AceConfigRegistry-3.0"
Addon.AceDB             = LibStub"AceDB-3.0"
Addon.AceDBOptions      = LibStub"AceDBOptions-3.0"

Addon.TipHooker  = LibStub"LibTipHooker-1.1-ZeraTooltip"
Addon.TipHooker2 = LibStub"LibTipHooker-1.0-ZeraTooltip"
Addon.SemVer     = LibStub"SemVer"



Addon.onOptionSetHandlers = {}


Addon.debugPrefix = "[" .. BINDING_HEADER_DEBUG .. "]"



--@debug@
  local debugMode = true
  
  -- GAME_LOCALE = "enUS" -- AceLocale override
  
  -- TOOLTIP_UPDATE_TIME = 10000
  
  -- DECIMAL_SEPERATOR = ","
--@end-debug@

function Addon:IsDebugEnabled()
  if self.db then
    return self:GetOption"debug"
  else
    return debugMode
  end
end


local function Debug(self, methodName, ...)
  if not self:IsDebugEnabled() then return end
  if self.GetOption and self:GetOption("debugOutput", "suppressAll") then return end
  return self[methodName](self, ...)
end
function Addon:Debug(...)
  return Debug(self, "Print", self.debugPrefix, ...)
end
function Addon:Debugf(...)
  return Debug(self, "Printf", "%s " .. select(1, ...), self.debugPrefix, select(2, ...))
end

local function DebugIf(self, methodName, keys, ...)
  if self.GetOption and self:GetOption(unpack(keys)) then
    return self[methodName](self, ...)
  end
end
function Addon:DebugIf(keys, ...)
  return DebugIf(self, "Debug", keys, ...)
end
function Addon:DebugfIf(keys, ...)
  return DebugIf(self, "Debugf", keys, ...)
end

local tblConcat = table.concat
function Addon:DebugData(t)
  local texts = {}
  for _, data in ipairs(t) do
    if data[2] then
      if type(data[2]) == "string" then
        table.insert(texts, data[1] .. ": '" .. data[2] .. "'")
      else
        table.insert(texts, data[1] .. ": " .. tostring(data[2]))
      end
    end
  end
  self:Debug(tblConcat(texts, ", "))
end
function Addon:DebugDataIf(keys, ...)
  if self.GetOption and self:GetOption(unpack(keys)) then
    return self:DebugData(...)
  end
end


function Addon:GetDebugView(key)
  return self:IsDebugEnabled() and not self:GetOption("debugView", "suppressAll") and self:GetOption("debugView", key)
end


