

local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")


Addon.AceConfig         = LibStub"AceConfig-3.0"
Addon.AceConfigDialog   = LibStub"AceConfigDialog-3.0"
Addon.AceConfigRegistry = LibStub"AceConfigRegistry-3.0"
Addon.AceDB             = LibStub"AceDB-3.0"
Addon.AceDBOptions      = LibStub"AceDBOptions-3.0"

Addon.SemVer = LibStub"SemVer"




local strMatch     = string.match
local strSub       = string.sub
local strGsub      = string.gsub

local tblConcat    = table.concat
local tblSort      = table.sort
local tblRemove    = table.remove

local mathFloor    = math.floor
local mathMin      = math.min
local mathMax      = math.max
local mathRandom   = math.random

local ipairs       = ipairs
local next         = next
local unpack       = unpack
local select       = select
local type         = type
local format       = format
local tinsert      = tinsert
local strjoin      = strjoin
local tostring     = tostring
local tonumber     = tonumber
local getmetatable = getmetatable
local setmetatable = setmetatable
local assert       = assert
local random       = random








--  ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--  ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--  ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--  ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--  ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


do
  Addon.debugPrefix = "[" .. (BINDING_HEADER_DEBUG or "Debug") .. "]"
  Addon.warnPrefix  = "[" .. (LUA_WARNING or "Warning") .. "]"
  
  local debugMode = false
  
  --@debug@
  do
    debugMode = true
    
    -- GAME_LOCALE = "enUS" -- AceLocale override
    
    -- TOOLTIP_UPDATE_TIME = 10000
  end
  --@end-debug@
  
  
  local function CheckOptionSafe(default, ...)
    if Addon.db then
      return Addon:CheckTable(Addon.db, ...)
    else
      return default
    end
  end
  
  function Addon:IsDebugEnabled()
    return CheckOptionSafe(debugMode, "global", "debug")
  end
  local function IsDebugSuppressed()
    return not Addon:IsDebugEnabled() or CheckOptionSafe(not debugMode, "global", "debugOutput", "suppressAll")
  end
  local function ShouldShowLuaErrors()
    return Addon:IsDebugEnabled() and CheckOptionSafe(debugMode, "global", "debugShowLuaErrors")
  end
  local function ShouldShowWarnings()
    return Addon:IsDebugEnabled() and CheckOptionSafe(debugMode, "global", "debugShowLuaWarnings")
  end
  function Addon:GetDebugView(key)
    return self:IsDebugEnabled() and not CheckOptionSafe(debugMode, "global", "suppressAll") and CheckOptionSafe(debugMode, "global", "debugView", key)
  end
  
  function Addon:Dump(t)
    return DevTools_Dump(t)
  end
  
  local function Debug(self, methodName, ...)
    if IsDebugSuppressed() then return end
    return self[methodName](self, ...)
  end
  function Addon:Debug(...)
    return Debug(self, "Print", self.debugPrefix, ...)
  end
  function Addon:Debugf(...)
    return Debug(self, "Printf", "%s " .. select(1, ...), self.debugPrefix, select(2, ...))
  end
  function Addon:DebugDump(t, header)
    if header then
      Debug(self, "Print", self.debugPrefix, tostring(header) .. ":")
    end
    return self:Dump(t)
  end
  
  
  local function Warn(self, methodName, ...)
    if not ShouldShowWarnings() then return end
    return self[methodName](self, ...)
  end
  function Addon:Warn(...)
    return Warn(self, "Print", self.warnPrefix, ...)
  end
  function Addon:Warnf(...)
    return Warn(self, "Printf", "%s " .. select(1, ...), self.warnPrefix, select(2, ...))
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
  function Addon:DebugDumpIf(keys, ...)
    return DebugIf(self, "DebugDump", keys, ...)
  end
  
  local function DebugIfOutput(self, methodName, key, ...)
    if self.GetGlobalOption and self:GetGlobalOptionSafe("debugOutput", key) then
      return self[methodName](self, ...)
    end
  end
  function Addon:DebugIfOutput(key, ...)
    return DebugIfOutput(self, "Debug", key, ...)
  end
  function Addon:DebugfIfOutput(key, ...)
    return DebugIfOutput(self, "Debugf", key, ...)
  end
  function Addon:DebugDumpIfOutput(key, ...)
    return DebugIfOutput(self, "DebugDump", key, ...)
  end
  
  function Addon:DebugData(t)
    local texts = {}
    for _, data in ipairs(t) do
      if data[2] ~= nil then
        if type(data[2]) == "string" then
          tinsert(texts, data[1] .. ": '" .. data[2] .. "'")
        else
          tinsert(texts, data[1] .. ": " .. tostring(data[2]))
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
  
  
  do
    local function GetErrorHandler(errFunc)
      if Addon:IsDebugEnabled() and ShouldShowLuaErrors() then
        return function(...)
          geterrorhandler()(...)
          if errFunc then
            Addon:xpcall(errFunc)
          end
        end
      end
      return nop
    end
    function Addon:xpcall(func, errFunc)
      return xpcall(func, GetErrorHandler(errFunc))
    end
    function Addon:xpcallSilent(func, errFunc)
      return xpcall(func, nop)
    end
    function Addon:Throw(...)
      if Addon:IsDebugEnabled() and ShouldShowLuaErrors() then
        geterrorhandler()(...)
      end
    end
    function Addon:Throwf(...)
      local args = {...}
      local count = select("#", ...)
      self:xpcall(function() self:Throw(format(unpack(args, 1, count))) end)
    end
    function Addon:Assert(bool, ...)
      if not bool then
        self:Throw(...)
      end
    end
    function Addon:Assertf(bool, ...)
      if not bool then
        self:Throwf(...)
      end
    end
  end
end





--  ███████╗██╗  ██╗██████╗  █████╗ ███╗   ██╗███████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗████╗  ██║██╔════╝██║██╔═══██╗████╗  ██║██╔════╝
--  █████╗   ╚███╔╝ ██████╔╝███████║██╔██╗ ██║███████╗██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══╝   ██╔██╗ ██╔═══╝ ██╔══██║██║╚██╗██║╚════██║██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗██╔╝ ██╗██║     ██║  ██║██║ ╚████║███████║██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  Addon.expansions = {
    retail  = 11,
    tww     = 11,
    df      = 10,
    sl      = 9,
    bfa     = 8,
    legion  = 7,
    wod     = 6,
    mop     = 5,
    cata    = 4,
    wrath   = 3,
    tbc     = 2,
    era     = 1,
    vanilla = 1,
  }
  
  Addon.expansionLevel = tonumber(GetBuildInfo():match"^(%d+)%.")
  
  Addon.isRetail  = Addon.expansionLevel >= Addon.expansions.retail
  Addon.isClassic = not Addon.isRetail
  
  Addon.isTWW     = Addon.expansionLevel == Addon.expansions.tww
  Addon.isDF      = Addon.expansionLevel == Addon.expansions.df
  Addon.isSL      = Addon.expansionLevel == Addon.expansions.sl
  Addon.isBfA     = Addon.expansionLevel == Addon.expansions.bfa
  Addon.isLegion  = Addon.expansionLevel == Addon.expansions.legion
  Addon.isWoD     = Addon.expansionLevel == Addon.expansions.wod
  Addon.isMoP     = Addon.expansionLevel == Addon.expansions.mop
  Addon.isCata    = Addon.expansionLevel == Addon.expansions.cata
  Addon.isWrath   = Addon.expansionLevel == Addon.expansions.wrath
  Addon.isTBC     = Addon.expansionLevel == Addon.expansions.tbc
  Addon.isEra     = Addon.expansionLevel == Addon.expansions.era
  
  local season = ((C_Seasons or {}).GetActiveSeason or nop)() or 0
  Addon.isSoM = season == Enum.SeasonID.SeasonOfMastery
  Addon.isSoD = season == Enum.SeasonID.SeasonOfDiscovery
end






--  ████████╗ █████╗ ██████╗ ██╗     ███████╗███████╗
--  ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
--     ██║   ███████║██████╔╝██║     █████╗  ███████╗
--     ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--     ██║   ██║  ██║██████╔╝███████╗███████╗███████║
--     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝

do
  do
    local privates = setmetatable({}, {__mode = "k"})
    function Addon:GetPrivate(obj)
      return privates[obj]
    end
    function Addon:SetPrivate(obj, p)
      privates[obj] = p
      return obj
    end
  end
  
  do
    local Link
    do
      local meta = {
        __index = {
          Get = function(self)
            return Addon:GetPrivate(self).obj
          end,
        },
      }
      Link = function(obj)
        return setmetatable(Addon:SetPrivate({}, {obj = obj}), meta)
      end
    end
    
    local funcs = {
      Add = function(self, v)
        local p = Addon:GetPrivate(self)
        p.count = p.count + 1
        
        local id = p.next  + 1
        p.next   = id
        
        local link = Link(v)
        local prev = p.tail
        if prev then
          prev.next = link
          link.prev = prev
        end
        p.indices[id] = link
        p.tail = link
        if not p.head then
          p.head = link
        end
        
        return id
      end,
      Remove = function(self, id)
        local p = Addon:GetPrivate(self)
        
        local link = p.indices[id]
        if not link then return false end
        p.count = p.count - 1
        
        local prev = link.prev
        local next = link.next
        if prev and next then
          prev.next = next
          next.prev = prev
        end
        if p.head == link then
          p.head = next
        end
        if p.tail == link then
          p.tail = prev
        end
        p.indices[id] = nil
        
        return true
      end,
      Wipe = function(self)
        local p = Addon:GetPrivate(self)
        p.indices = {}
        p.count   = 0
        p.next    = 0
        return self
      end,
      GetCount = function(self)
        return Addon:GetPrivate(self).count
      end,
      iter = function(self)
        local link
        return function()
          if link then
            link = link.next
          else
            link = Addon:GetPrivate(self).head
          end
          return link and link:Get()
        end
      end,
    }
    local meta = {
      __index = function(self, k)
        if type(k) == "number" then
          return Addon:GetPrivate(self)[k]
        else
          return funcs[k]
        end
      end,
    }
    
    function Addon.IndexedLinkedList()
      return setmetatable(Addon:SetPrivate({}, {}), meta):Wipe()
    end
  end
  
  function Addon.TimedTable(defaultDuration)
    local duration = defaultDuration
    local db       = {}
    local timers   = {}
    local count    = 0
    
    local funcs = {
      SetDuration = function(self, d)
        duration = d
        return self
      end,
      
      GetDuration = function(self)
        return duration
      end,
      
      Bump = function(self, k)
        if timers[k] then
          timers[k]:Cancel()
        end
        
        if db[k] ~= nil then
          timers[k] = C_Timer.NewTicker(duration, function() self[k] = nil end, 1)
        else
          timers[k] = nil
        end
        
        return self
      end,
      
      Set = function(self, k, v)
        local before = db[k] ~= nil and 1 or 0
        db[k] = v
        local after  = db[k] ~= nil and 1 or 0
        count = count + after - before
        
        self:Bump(k)
        return self
      end,
      
      Get = function(self, k)
        self:Bump(k)
        return db[k]
      end,
      
      GetCount = function(self)
        return count
      end,
      
      iter = function(self)
        return pairs(db)
      end,
      
      Wipe = function(self)
        for k, timer in pairs(timers) do
          timer:Cancel()
        end
        wipe(db)
        wipe(timers)
        count = 0
      end,
    }
    local meta = {
      __index = function(self, k)
        return funcs[k] or funcs.Get(self, k)
      end,
      __newindex = function(self, k, v)
        return self:Set(k, v)
      end,
    }
    
    return setmetatable({}, meta)
  end
  
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
  
  function Addon:Filter(t, ...)
    local new = {}
    
    for i, v in pairs(t) do
      local pass = true
      for j = 1, select("#", ...) do
        local filter = select(j, ...)
        if not filter(v, i, t) then
          pass = false
          break
        end
      end
      if pass then
        tinsert(new, v)
      end
    end
    
    local meta = getmetatable(self)
    if meta then
      setmetatable(new, meta)
    end
    
    return new
  end
  
  function Addon:Squish(t)
    local new = {}
    for k in pairs(t) do
      tinsert(new, k)
    end
    tblSort(new)
    for i, k in ipairs(new) do
      new[i] = t[k]
    end
    return new
  end
  
  function Addon:Shuffle(t)
    for i = #t, 2, -1 do
      local j = math.random(i)
      t[i], t[j] = t[j], t[i]
    end
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
        new[v] = true
      end
      if keepOrigVals and new[k] == nil then
        new[k] = v
      end
    end
    return new
  end
  
  function Addon:MakeBoolTable(t)
    return setmetatable(self:MakeLookupTable(t), {__index = function() return false end})
  end
  
  
  function Addon:MakeTable(t, ...)
    local parent = t
    
    local keys = {...}
    local val = tblRemove(keys)
    local last = #keys
    for i, key in ipairs(keys) do
      if i == last then
        t[key] = val
      elseif not t[key] then
        t[key] = {}
      end
      t = t[key]
    end
    return parent
  end
  
  function Addon:CheckTable(t, ...)
    local val = t
    for _, key in ipairs{...} do
      val = (val or {})[key]
    end
    return val
  end
  
  function Addon:Concatenate(t1, t2)
    for i = 1, #t2 do
      t1[#t1+1] = t2[i]
    end
    for k, v in pairs(t2) do
      if type(k) ~= "number" then
        t1[k] = v
      end
    end
  end
  
  function Addon:Random(t)
    return t[random(#t)]
  end
  
  do
    cycleMemory = setmetatable({}, {__mode = "k"})
    function Addon:Cycle(t, offset)
      if cycleMemory[t] then
        cycleMemory[t] = next(t, cycleMemory[t]) or next(t)
      else
        cycleMemory[t] = offset or next(t)
      end
      return cycleMemory[t], t[cycleMemory[t]]
    end
  end
  
  do
    cycleMemory = setmetatable({}, {__mode = "k"})
    function Addon:ICycle(t, offset)
      cycleMemory[t] = ((cycleMemory[t] or (offset - 1) or 0) % #t) + 1
      return cycleMemory[t], t[cycleMemory[t]]
    end
  end
  
  local function SwitchHelper(result, val)
    if type(result) == "function" then
      return result(val)
    else
      return result
    end
  end
  function Addon:Switch(val, t, fallback)
    fallback = fallback or nop
    if val == nil then
      return SwitchHelper(fallback, val)
    else
      return SwitchHelper(setmetatable(t, {__index = function() return fallback end})[val], val)
    end
  end
  
  
  function Addon:ShortCircuit(expression, trueVal, falseVal)
    if expression then
      return trueVal
    else
      return falseVal
    end
  end
end






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
  
  local function NotifyChange()
    Addon:xpcall(function()
      if Addon.AceConfigRegistry then
        Addon.AceConfigRegistry:NotifyChange(ADDON_NAME)
      end
    end)
  end
  
  local onOptionSetHandlers = {}
  function Addon:RegisterOptionSetHandler(func)
    tinsert(onOptionSetHandlers, func)
    return #onOptionSetHandlers
  end
  function Addon:UnregisterOptionSetHandler(id)
    onOptionSetHandlers[id] = nil
  end
  
  local function OnOptionSet(self, val, ...)
    if not self:GetDB() then return end -- db hasn't loaded yet
    self:DebugfIfOutput("optionSet", "Setting %s: %s", strjoin(" > ", ...), tostring(val))
    for id, func in next, onOptionSetHandlers, nil do
      if type(func) == "function" then
        func(self, val, ...)
      else
        self[func](self, val, ...)
      end
    end
  end
  
  local dbTables = {
    {"dbDefault", "Default", true},
    {"db", ""},
  }
  local dbTypes = {
    {"profile", ""},
    {"global", "Global"},
  }
  
  local defaultKey, defaultName
  
  for _, dbType in ipairs(dbTables) do
    local dbKey, dbName, isDefault = unpack(dbType, 1, 3)
    if isDefault then
      defaultKey  = dbKey
      defaultName = dbName
    end
    
    local IsDBLoaded = format("Is%sDBLoaded", dbName)
    local GetDB      = format("Get%sDB",      dbName)
    
    Addon[IsDBLoaded] = function(self)
    return self[dbKey] ~= nil
    end
    Addon[GetDB] = function(self)
      return self[dbKey]
    end
    
    for _, dbSection in ipairs(dbTypes) do
      local typeKey, typeName = unpack(dbSection, 1, 2)
      
      local GetOptionSafe    = format("Get%s%sOptionSafe", dbName,      typeName)
      local GetOption        = format("Get%s%sOption",     dbName,      typeName)
      local GetDefaultOption = format("Get%s%sOption",     defaultName, typeName)
      
      Addon[GetOptionSafe] = function(self, ...)
        assert(self[dbKey], format("Attempted to access database before initialization: %s", tblConcat({dbKey, typeKey, ...}, " > ")))
        local val = self[dbKey][typeKey]
        for _, key in ipairs{...} do
          assert(type(val) == "table", format("Bad database access: %s", tblConcat({dbKey, typeKey, ...}, " > ")))
          val = val[key]
        end
        return val
      end
      
      Addon[GetOption] = function(self, ...)
        local val = Addon[GetOptionSafe](self, ...)
        if type(val) == "table" then
          self:Warnf("Database request returned a table: %s", tblConcat({dbKey, typeKey, ...}, " > "))
        end
        if val == nil then
          self:Warnf("Database request found empty value: %s", tblConcat({dbKey, typeKey, ...}, " > "))
        end
        return val
      end
      
      if not isDefault then
        local SetOptionConfig    = format("Set%s%sOptionConfig",    dbName, typeName)
        local SetOption          = format("Set%s%sOption",          dbName, typeName)
        local ToggleOptionConfig = format("Toggle%s%sOptionConfig", dbName, typeName)
        local ToggleOption       = format("Toggle%s%sOption",       dbName, typeName)
        local ResetOptionConfig  = format("Reset%s%sOptionConfig",  dbName, typeName)
        local ResetOption        = format("Reset%s%sOption",        dbName, typeName)
      
        Addon[SetOptionConfig] = function(self, val, ...)
          assert(self[dbKey], format("Attempted to access database before initialization: %s = %s", tblConcat({dbKey, typeKey, ...}, " > "), tostring(val)))
          local keys = {...}
          local lastKey = tblRemove(keys, #keys)
          local tbl = self[dbKey][typeKey]
          for _, key in ipairs(keys) do
            assert(type(tbl[key]) == "table", format("Bad database access: %s = %s", tblConcat({dbKey, typeKey, ...}, " > "), tostring(val)))
            tbl = tbl[key]
          end
          local lastVal = tbl[lastKey]
          if type(lastVal) == "table" then
            self:Warnf("Database access overwriting a table: %s", tblConcat({dbKey, typeKey, ...}, " > "))
          end
          tbl[lastKey] = val
          OnOptionSet(Addon, val, dbKey, typeKey, ...)
          return lastVal ~= val
        end
      
        Addon[SetOption] = function(self, val, ...)
          local result = Addon[SetOptionConfig](self, val, ...)
          NotifyChange()
          return result
        end
        
        Addon[ToggleOptionConfig] = function(self, ...)
          return self[SetOptionConfig](self, not self[GetOption](self, ...), ...)
        end
        
        Addon[ToggleOption] = function(self, ...)
          return self[SetOption](self, not self[GetOption](self, ...), ...)
        end
        
        Addon[ResetOption] = function(self, ...)
          return self[SetOption](self, Addon.Copy(self, self[GetDefaultOption](self, ...)), ...)
        end
        
        Addon[ResetOptionConfig] = function(self, ...)
          return self[SetOptionConfig](self, Addon.Copy(self, self[GetDefaultOption](self, ...)), ...)
        end
      end
      
    end
  end
end





--  ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
--  ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
--  █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
--  ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
--  ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
--  ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

do
  local function Call(func, ...)
    local args = {...}
    if type(func) == "function" then
      Addon:xpcall(function() func(unpack(args)) end)
    else
      Addon:xpcall(function() Addon[func](unpack(args)) end)
    end
  end
  
  local onEventCallbacks = {}
  local function OnEvent(event, ...)
    local t = onEventCallbacks[event]
    Addon:Assertf(t, "Event %s is registered, but no callbacks were found", event)
    for func in t:iter() do
      Call(func, Addon, event, ...)
    end
  end
  
  function Addon:RegisterEventCallback(event, func)
    local callbacks = onEventCallbacks[event] or Addon.IndexedLinkedList()
    local id = callbacks:Add(func)
    if callbacks:GetCount() == 1 then
      onEventCallbacks[event] = callbacks
      self:RegisterEvent(event, OnEvent)
    end
    return id
  end
  function Addon:RegisterSingleEventCallback(event, ...)
    local id = self:RegisterEventCallback(event, ...)
    local func = onEventCallbacks[event][id]
    onEventCallbacks[event][id] = function(...) func(...) self:UnregisterEventCallback(event, id) end
    return id
  end
  function Addon:UnregisterEventCallbacks(event)
    self:Assertf(onEventCallbacks[event], "Attempted to unregister event %s, but no callbacks were found", event)
    onEventCallbacks[event] = nil
    self:UnregisterEvent(event)
  end
  function Addon:UnregisterEventCallback(event, id)
    local callbacks = onEventCallbacks[event] or Addon.IndexedLinkedList()
    self:Assertf(callbacks:Remove(id), "Attempted to unregister callback %s from event %s, but it was not found", id, event)
    if callbacks:GetCount() == 0 then
      self:UnregisterEventCallbacks(event)
    end
  end
  
  
  do
    local onInitializeCallbacks = Addon.IndexedLinkedList()
    local onEnableCallbacks     = Addon.IndexedLinkedList()
    local events = {}
    
    for _, event in ipairs{"Initialize", "Enable"} do
      local callbacks = Addon.IndexedLinkedList()
      events[event] = callbacks
      
      Addon["Run" .. event .. "Callbacks"] = function(self)
        for func in callbacks:iter() do
          Call(func, Addon)
        end
      end
      Addon["Register" .. event .. "Callback"] = function(self, func)
        return callbacks:Add(func)
      end
      Addon["Unregister" .. event .. "Callbacks"] = function(self)
        self:Assert(callbacks:GetCount() > 0, "Attempted to unregister " .. event .. " callbacks, but none were found")
        callbacks:Wipe()
      end
      Addon["Unregister" .. event .. "Callback"] = function(self, id)
        self:Assertf(callbacks:Remove(id), "Attempted to unregister " .. event .. " callback %s, but it was not found", id)
      end
    end
  end
  
  
  function Addon:RegisterCVarCallback(cvar, func)
    return self:RegisterEventCallback("CVAR_UPDATE", function(self, event, ...)
      if cvar == ... then
        self:DebugfIfOutput("cvarSet", "CVar set: %s = %s", cvar, tostring(C_CVar.GetCVar(cvar)))
        func(self, event, ...)
      end
    end)
  end
  
  
  onAddonLoadCallbacks = {}
  function Addon:OnAddonLoad(addonName, func)
    local loaded, finished = IsAddOnLoaded(addonName)
    if finished then
      Call(func, self)
    else
      local id
      id = self:RegisterEventCallback("ADDON_LOADED", function(self, event, addon)
        if addon == addonName then
          Call(func, self)
          self:UnregisterEventCallback("ADDON_LOADED", id)
        end
      end)
    end
  end
  
  function Addon:WhenOutOfCombat(func)
    if not InCombatLockdown() then
      Call(func, self)
    else
      self:RegisterSingleEventCallback("PLAYER_REGEN_ENABLED", function() Call(func, self) end)
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
  Addon.GUI = {}
  local GUI = Addon.GUI
  
  local defaultInc   = 1000
  local defaultOrder = 1000
  local order        = defaultOrder
  
  local dbType = ""
  local GetFunction      = function(keys) local funcName = format("Get%sOption",         dbType) return function(info)      return Addon[funcName](Addon, unpack(keys))      end end
  local SetFunction      = function(keys) local funcName = format("Set%sOptionConfig",   dbType) return function(info, val)        Addon[funcName](Addon, val, unpack(keys)) end end
  local ResetFunction    = function(keys) local funcName = format("Reset%sOptionConfig", dbType) return function(info, val)        Addon[funcName](Addon, unpack(keys))      end end
  local GetColorFunction = function(keys) local funcName = format("Get%sOption",         dbType) return function(info)          return Addon:ConvertColorToBlizzard(Addon[funcName](Addon, unpack(keys)))            end end
  local SetColorFunction = function(keys) local funcName = format("Set%sOption",         dbType) return function(info, r, g, b)        Addon[funcName](Addon, Addon:ConvertColorFromBlizzard(r, g, b), unpack(keys)) end end
  -- options window needs to redraw if color changes
  
  function GUI:SetDBType(typ)
    dbType = typ or ""
  end
  function GUI:ResetDBType()
    self:SetDBType()
  end
  
  function GUI:GetOrder()
    return order
  end
  function GUI:SetOrder(newOrder)
    order = newOrder
    return self
  end
  function GUI:ResetOrder()
    order = defaultOrder
    return self
  end
  function GUI:Order(inc)
    self:SetOrder(self:GetOrder() + (inc or defaultInc))
    return self:GetOrder()
  end
  
  function GUI:CreateEntry(opts, keys, name, desc, widgetType, disabled, order)
    order = order or self:Order()
    if type(keys) ~= "table" then keys = {keys} end
    local key = widgetType .. "_" .. (tblConcat(keys, ".") or "") .. "_" .. order
    opts.args[key] = {name = name, desc = desc, type = widgetType, order = order, disabled = disabled}
    opts.args[key].set = SetFunction(keys)
    opts.args[key].get = GetFunction(keys)
    return opts.args[key]
  end
  
  function GUI:CreateHeader(opts, name)
    return self:CreateEntry(opts, {"header"}, name, nil, "header")
  end
  
  function GUI:CreateDescription(opts, desc, fontSize)
    local option = self:CreateEntry(opts, {"description"}, desc, nil, "description")
    option.fontSize = fontSize or "large"
    return option
  end
  function GUI:CreateDivider(opts, count, fontSize)
    for i = 1, count or 1 do
      self:CreateDescription(opts, " ", fontSize or "small")
    end
  end
  function GUI:CreateNewline(opts)
    return self:CreateDescription(opts, " ", fontSize or "small")
  end
  
  function GUI:CreateToggle(opts, keys, name, desc, disabled)
    return self:CreateEntry(opts, keys, name, desc, "toggle", disabled)
  end
  
  function GUI:CreateReverseToggle(opts, keys, name, desc, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "toggle", disabled)
    local set, get = option.set, option.get
    option.get = function(info)      return not get()          end
    option.set = function(info, val)        set(info, not val) end
    return option
  end
  
  function GUI:CreateSelect(opts, keys, name, desc, values, sorting, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "select", disabled)
    option.values  = values
    option.sorting = sorting
    return option
  end
  
  function GUI:CreateDropdown(...)
    local option = self:CreateSelect(...)
    option.style = "dropdown"
    return option
  end
  
  function GUI:CreateRadio(...)
    local option = self:CreateSelect(...)
    option.style = "radio"
    return option
  end
  
  function GUI:CreateMultiSelect(opts, keys, name, desc, values, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "multiselect", disabled)
    option.values  = values
    return option
  end
  
  function GUI:CreateRange(opts, keys, name, desc, min, max, step, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "range", disabled)
    option.min   = min
    option.max   = max
    option.step  = step
    return option
  end
  
  function GUI:CreateInput(opts, keys, name, desc, multiline, disabled)
    local option     = self:CreateEntry(opts, keys, name, desc, "input", disabled)
    option.multiline = multiline
    return option
  end
  
  function GUI:CreateColor(opts, keys, name, desc, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "color", disabled)
    option.get   = GetColorFunction(keys)
    option.set   = SetColorFunction(keys)
    return option
  end
  
  function GUI:CreateExecute(opts, key, name, desc, func, disabled)
    local option = self:CreateEntry(opts, key, name, desc, "execute", disabled)
    option.func  = func
    return option
  end
  function GUI:CreateReset(opts, keys, func, disabled)
    local option = self:CreateEntry(opts, {"reset", unpack(keys)}, Addon.L["Reset"], nil, "execute", disabled)
    option.func  = func or ResetFunction(keys)
    option.width = 0.6
    return option
  end
  
  function GUI:CreateGroup(opts, key, name, desc, groupType, disabled)
    local order = self:Order()
    key = tostring(key or order)
    opts.args[key] = {name = name, desc = desc, type = "group", childGroups = groupType or "tab", args = {}, order = order, disabled = disabled}
    return opts.args[key]
  end
  function GUI:CreateGroupBox(opts, name)
    local option = self:CreateGroup(opts, nil, name or " ")
    option.inline = true
    return option
  end
  
  function GUI:CreateOpts(name, groupType, disabled)
    return {name = name, type = "group", childGroups = groupType or "tab", args = {}, order = self:Order()}
  end
  
  
  
  local usingSettingsPanel = Settings and Settings.RegisterCanvasLayoutCategory -- from AceConfigDialog
  local SettingsFrame = usingSettingsPanel and SettingsPanel or InterfaceOptionsFrame
  local blizzardCategory
  
  -- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
  -- Originally from BlizzBugsSuck (https://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html) and edited to not be global
  if not usingSettingsPanel then
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
      if Addon:GetGlobalOption("fix", "InterfaceOptionsFrameForAll") or Addon:GetGlobalOption("fix", "InterfaceOptionsFrameForMe") and isMe then
        Addon:DebugIfOutput("InterfaceOptionsFrameFix", "Patching Interface Options")
        InterfaceOptionsFrame_OpenToCategory_Fix(...)
        isMe = false
      end
    end)
  end
  
  function Addon:OpenBlizzardConfig(category)
    if usingSettingsPanel then
      Settings.OpenToCategory(blizzardCategory)
    else
      isMe = Addon:GetGlobalOption("fix", "InterfaceOptionsFrameForMe")
      if isMe then
        InterfaceOptionsFrame_OpenToCategory(blizzardCategory)
        isMe = true
      end
      InterfaceOptionsFrame_OpenToCategory(blizzardCategory)
    end
  end
  function Addon:CloseBlizzardConfig()
    if usingSettingsPanel then
      SettingsFrame:Close(true)
    else
      SettingsFrame:Hide()
    end
  end
  function Addon:ToggleBlizzardConfig(...)
    if SettingsFrame:IsShown() then
      self:CloseBlizzardConfig(...)
    else
      self:OpenBlizzardConfig(...)
    end
  end
  
  function Addon:OpenConfig(...)
    self.AceConfigDialog:Open(ADDON_NAME)
    if select("#", ...) > 0 then
      self.AceConfigDialog:SelectGroup(ADDON_NAME, ...)
    end
  end
  function Addon:CloseConfig()
    self.AceConfigDialog:Close(ADDON_NAME)
  end
  function Addon:ToggleConfig(...)
    if self.AceConfigDialog.OpenFrames[ADDON_NAME] then
      self:CloseConfig()
    else
      self:OpenConfig(...)
      self.AceConfigDialog:SelectGroup(ADDON_NAME, ...)
    end
  end
  
  function Addon:RefreshDebugOptions()
    if self:CheckTable(self.AceConfigDialog:GetStatusTable(ADDON_NAME), "groups", "selected") == "Debug" then
      self.AceConfigRegistry:NotifyChange(ADDON_NAME)
    end
  end
  
  function Addon:ResetProfile(category)
    self:GetDB():ResetProfile()
    self.AceConfigRegistry:NotifyChange(category)
  end
  
  function Addon:CreateBlizzardOptionsCategory(options)
    local blizzardOptions = ADDON_NAME .. ".Blizzard"
    self.AceConfig:RegisterOptionsTable(blizzardOptions, options)
    local Panel, id = self.AceConfigDialog:AddToBlizOptions(blizzardOptions, ADDON_NAME)
    blizzardCategory = id
    Panel.default = function() self:ResetProfile(blizzardOptions) end
    return Panel
  end
end




--   ██████╗██╗  ██╗ █████╗ ████████╗
--  ██╔════╝██║  ██║██╔══██╗╚══██╔══╝
--  ██║     ███████║███████║   ██║   
--  ██║     ██╔══██║██╔══██║   ██║   
--  ╚██████╗██║  ██║██║  ██║   ██║   
--   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   

do
  Addon.chatArgs = {}

  function Addon:RegisterChatArg(arg, func)
    Addon.chatArgs[arg] = func
  end

  function Addon:RegisterChatArgAliases(arg, func)
    for i = #arg, 1, -1 do
      local alias = strSub(arg, 1, i)
      if not self.chatArgs[alias] then
        self:RegisterChatArg(alias, func)
      end
    end
    Addon.chatArgs[arg] = func
  end

  function Addon:OnChatCommand(input)
    local args = {self:GetArgs(input, 1)}
    
    local func = args[1] and self.chatArgs[args[1]] or nil
    if func then
      func(self, unpack(args))
    else
      self:OpenConfig()
    end
  end

  function Addon:InitChatCommands(slashKeywords)
    for i, chatCommand in ipairs(slashKeywords) do
      if i == 1 then
        self:MakeAddonOptions(chatCommand)
        self:MakeBlizzardOptions(chatCommand)
      end
      self:RegisterChatCommand(chatCommand, "OnChatCommand", true)
    end

    local function PrintVersion() self:Printf("Version: %s", tostring(self.version)) end
    self:RegisterChatArgAliases("version", PrintVersion)
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
  
  function Addon:ConvertHexToRGB(hex)
    return tonumber(strSub(hex, 1, 2), 16), tonumber(strSub(hex, 3, 4), 16), tonumber(strSub(hex, 5, 6), 16), 1
  end
  function Addon:ConvertColorToBlizzard(hex)
    return tonumber(strSub(hex, 1, 2), 16) / 255, tonumber(strSub(hex, 3, 4), 16) / 255, tonumber(strSub(hex, 5, 6), 16) / 255, 1
  end
  function Addon:SetTextColorFromHex(frame, hex)
    frame:SetTextColor(self:ConvertColorToBlizzard(hex))
  end
  
  function Addon:TrimAlpha(hex)
    return strMatch(hex, "%x?%x?(%x%x%x%x%x%x)") or hex
  end
  function Addon:MakeColorCode(hex, text)
    return format("|cff%s%s%s", hex, text or "", text and "|r" or "")
  end
  
  function Addon:StripColorCode(text, hex)
    local pattern = hex and ("|c%x%x" .. hex) or "|c%x%x%x%x%x%x%x%x"
    return self:ChainGsub(text, {pattern, "|r", ""})
  end
end





--  ███╗   ██╗██╗   ██╗███╗   ███╗██████╗ ███████╗██████╗ ███████╗
--  ████╗  ██║██║   ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔════╝
--  ██╔██╗ ██║██║   ██║██╔████╔██║██████╔╝█████╗  ██████╔╝███████╗
--  ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══██╗██╔══╝  ██╔══██╗╚════██║
--  ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗██║  ██║███████║
--  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝

do
  function Addon:ToNumber(text)
    if type(text) == "number" then
      return text
    end
    if type(text) ~= "string" then return nil end
    
    -- strip percentage
    text = strGsub(text, "%%*$", "")
    
    -- strip thousands separators, convert decimal separator into period
    if self.L["."] == "." then
      text = strGsub(text, "(%d)" .. self.L[","] .. "(%d%d%d)", "%1%2")
    else
      text = self:ChainGsub(text, {"(%d)%" .. self.L[","] .. "(%d%d%d)", "%1%2"}, {"%" .. self.L["."], "."})
    end
    
    return tonumber(text)
  end
  
  function Addon:ToFormattedNumber(text, numDecimalPlaces, decimalChar, thousandsChar, forceFourDigitException, forceSeparateDecimals)
    local decimal   = decimalChar   or self:GetOption("overwriteSeparator", ".") and self:GetOption("separator", ".") or self.L["."]
    local separator = thousandsChar or self:GetOption("overwriteSeparator", ",") and self:GetOption("separator", ",") or self.L[","]
    
    local fourDigitException
    if forceFourDigitException ~= nil then
      fourDigitException = forceFourDigitException
    else
      fourDigitException = self:GetOption("separator", "fourDigitException")
    end
    local separateDecimals
    if forceSeparateDecimals ~= nil then
      separateDecimals = forceSeparateDecimals
    else
      separateDecimals = self:GetOption("separator", "separateDecimals")
    end
    
    local number = self:ToNumber(text)
    if numDecimalPlaces then
      number = self:Round(number, 1 / 10^numDecimalPlaces)
    end
    
    local text  = tostring(abs(number))
    local left  = strMatch(text,  "^%-?%d+")
    local right = strMatch(text, "%.(%d*)$") or ""
    
    if numDecimalPlaces then
      while #right < numDecimalPlaces do
        right = right .. "0"
      end
    end
    
    if decimal ~= "" and #left > 3 and not (fourDigitException and #left <= 4) then
      local result = {}
      
      for i = #left, 0, -3 do
        result[mathFloor(i/3)+1] = strSub(left, mathMax(i-2, 0), i)
      end
      left = tblConcat(result, separator)
    end
    
    if separator ~= "" and #right > 3 and not (fourDigitException and #right <= 4) and separateDecimals then
      local result = {}
      
      for i = 1, #right, 3 do
        result[mathFloor(i/3)+1] = strSub(right, i, mathMin(i+2, #right))
      end
      right = tblConcat(result, separator)
    end
    
    text = left
    if #right > 0 then
      text = text .. decimal .. right
    end
    
    if number < 0 then
      text = "-" .. text
    end
    
    return text
  end
  
  
  do
    local function CompareMin(a, b) return a < b end
    local function CompareMax(a, b) return a > b end
    local function Store(compare, defaultNum, ...)
      local storedNum  = defaultNum
      local storedData = {...}
      local dataCount  = select("#", ...)
      local Store = setmetatable({}, {
        __index = {
          Store = function(self, num, ...)
            if not storedNum or compare(num, storedNum) then
              storedNum  = num
              storedData = {...}
              dataCount  = select("#", ...)
            end
            return self
          end,
          
          Get = function()
            return storedNum, unpack(storedData, 1, dataCount)
          end,
        }
      })
      return Store
    end
    
    function Addon:MinStore(...)
      return Store(CompareMin, ...)
    end
    function Addon:MaxStore(...)
      return Store(CompareMax, ...)
    end
  end
  
  
  function Addon:Round(num, nearest)
    nearest = nearest or 1
    local lower = mathFloor(num / nearest) * nearest
    local upper = lower + nearest
    return (upper - num < num - lower) and upper or lower
  end
  
  function Addon:Clamp(min, num, max)
    assert(not min or type(min) == "number", "Can't clamp. min is " .. type(min))
    assert(not max or type(max) == "number", "Can't clamp. max is " .. type(max))
    assert(not min or not max or (min <= max), format("Can't clamp. min (%d) > max (%d)", min, max))
    if min then
      num = mathMax(num, min)
    end
    if max then
      num = mathMin(num, max)
    end
    return num
  end
end