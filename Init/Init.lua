

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
  
  
  -- shows a lua warning in the chat frame, if lua warnings are enabled in debug settings
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
    if self.GetGlobalOption and self:GetGlobalOptionQuiet("debugOutput", key) then
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
    if IsDebugSuppressed() then return end
    return self:Debug(self:DataToString(t))
  end
  function Addon:DebugDataIf(keys, ...)
    if self.GetOption and self:GetOption(unpack(keys)) then
      return self:DebugData(...)
    end
  end
  
  function Addon:DataToString(t)
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
    return tblConcat(texts, ", ")
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
    -- calls func in protected mode. errors are announced (if lua errors are enabled in debug settings) and then passed to errFunc. errFunc errors silently. non-blocking.
    function Addon:xpcall(func, errFunc, ...)
      return xpcall(func, GetErrorHandler(errFunc), ...)
    end
    -- calls func in protected mode. errors passed to errFunc if it exists. errFunc errors silently. non-blocking.
    function Addon:xpcallSilent(func, errFunc, ...)
      return xpcall(func, errFunc or nop, ...)
    end
    -- calls func in protected mode. errors silently passed to errFunc. blocking, as long as errFunc errors. error is never silent.
    function Addon:pcall(func, errFunc, ...)
      local t = {pcall(func, ...)}
      if not t[1] then
        errFunc(unpack(t, 2))
      end
      return unpack(t, 2)
    end
    -- Creates a non-blocking error. only announces error if lua errors are enabled in debug settings.
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
    -- Creates a non-blocking error if bool is falsy. errors are only announced if lua errors are enabled in debug settings.
    function Addon:ThrowAssert(bool, ...)
      if bool then return bool end
      if Addon:IsDebugEnabled() and ShouldShowLuaErrors() then
        geterrorhandler()(...)
      end
      return false
    end
    function Addon:ThrowfAssert(bool, ...)
      if bool then return bool end
      local args = {...}
      local count = select("#", ...)
      self:xpcall(function() self:Throw(format(unpack(args, 1, count))) end)
      return false
    end
    -- Creates a blocking error. error is never silent.
    function Addon:Error(str)
      error(str, 2)
    end
    function Addon:Errorf(...)
      error(format(...), 2)
    end
    function Addon:ErrorLevel(lvl, str)
      error(str, lvl + 1)
    end
    function Addon:ErrorfLevel(lvl, ...)
      error(format(...), lvl + 1)
    end
    -- Creates a blocking error if bool is falsy. error is never silent.
    function Addon:Assert(bool, str)
      if not bool then
        error(str, 2)
      end
    end
    function Addon:Assertf(bool, ...)
      if not bool then
        error(format(...), 2)
      end
    end
    function Addon:AssertLevel(lvl, bool, str)
      if not bool then
        error(str, lvl + 1)
      end
    end
    function Addon:AssertfLevel(lvl, bool, ...)
      if not bool then
        error(format(...), lvl + 1)
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
  Addon.isSoM = C_Seasons and season == Enum.SeasonID.SeasonOfMastery   or false
  Addon.isSoD = C_Seasons and season == Enum.SeasonID.SeasonOfDiscovery or false
end







--  ████████╗ █████╗ ██████╗ ██╗     ███████╗███████╗
--  ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
--     ██║   ███████║██████╔╝██║     █████╗  ███████╗
--     ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--     ██║   ██║  ██║██████╔╝███████╗███████╗███████║
--     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝

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
  
  function Addon:Concat(separator, ...)
    local t = {...}
    for i = 1, select("#", ...) do
      local v = t[i]
      if type(v) ~= "string" then
        t[i] = tostring(v)
      end
    end
    return tblConcat(t, separator)
  end
  
  function Addon:TableConcat(tbl, separator)
    local t = {}
    for i, v in ipairs(tbl) do
      if type(v) == "string" then
        t[i] = v
      else
        t[i] = tostring(v)
      end
    end
    return tblConcat(t, separator)
  end
  
  
  
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
  
  function Addon:CountKeys(t)
    local count = 0
    for _ in pairs(t) do
      count = count + 1
    end
    return count
  end
  function Addon:Sum(t)
    local sum = 0
    for _, n in pairs(t) do
      sum = sum + n
    end
    return sum
  end
  
  do
    local function Compare(a, b)
      if type(a) == type(b) then
        return a < b
      else
        if type(a) == "number" then
          return true
        elseif type(b) == "number" then
          return false
        else
          return tostring(a) < tostring(b)
        end
      end
    end
    
    -- iterator cannot be reused
    -- for k, v in ...
    function Addon:Ordered(t, func)
      local keys = {}
      for k, v in pairs(t) do
        keys[#keys+1] = k
      end
      tblSort(keys, func or Compare)
      local i = 0
      return function()
        i = i + 1
        local k = keys[i]
        if k == nil then
          return nil
        end
        return k, t[k]
      end
    end
    
    -- iterator can be reused. a bit slower
    -- for k, v in ...
    function Addon:OrderedStateless(t, func)
      local keys       = {}
      local keyIndices = {}
      local keysQueue  = Addon.PriorityQueue(nil, func or Compare)
      for k, v in pairs(t) do
        keysQueue:Add(k)
      end
      for k in keysQueue:iter() do
        local i = #keys+1
        
        keys[i]       = k
        keyIndices[k] = i
      end
      return function(a, k)
        local i
        if k == nil then
          i = 0
        else
          i = keyIndices[k]
        end
        i = i + 1
        k = keys[i]
        if k == nil then
          return nil
        end
        return k, a[k]
      end, t, nil
    end
    
    -- iterator can be reused
    -- for i, k, v in ...
    function Addon:OrderedStatelessCount(t, func)
      local keys = {}
      for k, v in pairs(t) do
        keys[#keys+1] = k
      end
      tblSort(keys, func or Compare)
      return function(a, i)
        i = i + 1
        local k = keys[i]
        if k == nil then
          return nil
        end
        return i, k, a[k]
      end, t, 0
    end
  end
  
  
  function Addon:MapIter(map, iter, a, k, ...)
    return function(a, k, ...)
      local vals = {iter(a, k, ...)}
      if vals[1] then
        return map(unpack(vals, 1, select("#", ...) + 2))
      end
    end, a, k, ...
  end
  
  
  -- IndexedQueue
  do
    local function GetPrev(t, i)
      return Addon:CheckTable(t, "links", i, 1) or i-1
    end
    local function GetNext(t, i)
      return Addon:CheckTable(t, "links", i, 2) or i+1
    end
    local function Link(t, pre, nex)
      local actual = rawget(t, "actual")
      if Addon:CheckTable(actual, pre) ~= nil and Addon:CheckTable(actual, nex) ~= nil then
        Addon:StoreInTable(t, "links", pre, 2, nex)
        Addon:StoreInTable(t, "links", nex, 1, pre)
      else
        if Addon:CheckTable(actual, pre) ~= nil then
          if Addon:CheckTable(t, "links", pre, 1) then
            Addon:RemoveInTable(t, "links", pre, 2)
          elseif Addon:CheckTable(t, "links", pre) then
            local links  = rawget(t, "links")
            rawset(links, pre, nil)
            if not next(links) then
              rawset(t, "links", nil)
            end
          end
        else
          if Addon:CheckTable(t, "links", nex, 2) then
            Addon:RemoveInTable(t, "links", nex, 1)
          elseif Addon:CheckTable(t, "links", nex, 2) then
            local links  = rawget(t, "links")
            rawset(links, nex, nil)
            if not next(links) then
              rawset(t, "links", nil)
            end
          end
        end
      end
    end
    
    local IndexedQueue = setmetatable({}, {__call = function(self, ...) return self:Create(...) end})
    Addon.IndexedQueue = IndexedQueue
    
    function IndexedQueue:Add(v)
      Addon:AssertfLevel(2, v ~= nil, "Attempted to add a nil value")
      
      local id  = Addon:CheckTable(self, "nextIndex")
      Addon:StoreInTable(self, "nextIndex", id + 1)
      
      local pre = Addon:CheckTable(self, "tail")
      if pre then
        if pre ~= id-1 then
          Addon:StoreInTable(self, "links", pre, 2, id)
          Addon:StoreInTable(self, "links", id,   1, pre)
        end
      end
      Addon:StoreInTable(self, "tail", id)
      Addon:StoreDefault(self, "head", id)
      
      Addon:StoreInTable(self, "actual", id, v)
      Addon:StoreInTable(self, "count", Addon:CheckTable(self, "count") + 1)
      
      return id
    end
    
    function IndexedQueue:Replace(id, v)
      Addon:AssertfLevel(2, type(id) == "number", "Attempted to replace a non-number index: %s (%s)", tostring(id), type(id))
      Addon:AssertfLevel(2, Addon:CheckTable(self, "actual", id) ~= nil, "Attempted to replace a non-existent index: %s", tostring(id))
      Addon:AssertfLevel(2, v ~= nil, "Attempted to add a nil value")
      
      Addon:StoreInTable(self, "actual", id, v)
      
      return self
    end
    
    function IndexedQueue:Remove(id)
      Addon:AssertfLevel(2, type(id) == "number", "Attempted to remove a non-number index: %s (%s)", tostring(id), type(id))
      local v = rawget(Addon:CheckTable(self, "actual"), id)
      Addon:AssertfLevel(2, v ~= nil, "Attempted to remove a nil value from index: %s (%s)", tostring(id), type(id))
      
      local pre = GetPrev(self, id)
      local nex = GetNext(self, id)
      if Addon:CheckTable(self, "links", id) then
        Addon:RemoveInTable(self, "links", id)
      end
      Link(self, pre, nex)
      
      if Addon:CheckTable(self, "head") == id then
        if Addon:CheckTable(self, "actual", nex) then
          Addon:StoreInTable(self, "head", nex)
        else
          Addon:RemoveInTable(self, "head")
        end
      end
      if Addon:CheckTable(self, "tail") == id then
        if Addon:CheckTable(self, "actual", pre) then
          Addon:StoreInTable(self, "tail", pre)
        else
          Addon:RemoveInTable(self, "tail")
        end
      end
      
      local value = Addon:CheckTable(self, "actual", id)
      Addon:RemoveInTable(self, "actual", id)
      Addon:StoreInTable(self, "count", Addon:CheckTable(self, "count") - 1)
      
      return value
    end
    
    function IndexedQueue:PopHead()
      local head = Addon:CheckTable(self, "head")
      Addon:AssertLevel(2, head, "Attempted to pop head while empty")
      return IndexedQueue.Remove(self, head)
    end
    function IndexedQueue:PopTail()
      local tail = Addon:CheckTable(self, "tail")
      Addon:AssertLevel(2, tail, "Attempted to pop tail while empty")
      return IndexedQueue.Remove(self, tail)
    end
    
    function IndexedQueue:Get(id)
      Addon:AssertfLevel(2, type(id) == "number", "Attempted to access a non-number index: %s (%s)", tostring(id), type(id))
      return Addon:CheckTable(self, "actual", id)
    end
    
    function IndexedQueue:Wipe()
      wipe(Addon:CheckTable(self, "actual"))
      Addon:RemoveInTable(self, "links")
      Addon:RemoveInTable(self, "head")
      Addon:RemoveInTable(self, "tail")
      Addon:StoreInTable(self,  "count", 0)
      Addon:StoreInTable(self,  "nextIndex",  1)
      
      return self
    end
    
    function IndexedQueue:CanDefrag()
      return Addon:CheckTable(self, "nextIndex") ~= Addon:CheckTable(self, "count") + 1
    end
    function IndexedQueue:Defrag()
      if not IndexedQueue.CanDefrag(self) then return end
      
      local head, tail
      local nex = 1
      for i, v in IndexedQueue.iter(self) do
        if Addon:CheckTable(self, "head") == i then
          head = nex
        end
        if Addon:CheckTable(self, "tail") == i then
          tail = nex
        end
        if i ~= nex then
          Addon:StoreInTable(self,  "actual", nex, v)
          Addon:RemoveInTable(self, "actual", i)
        end
        nex = nex + 1
      end
      Addon:RemoveInTable(self, "links")
      Addon:StoreInTable(self, "nextIndex", nex)
      Addon:StoreInTable(self, "head",      head)
      Addon:StoreInTable(self, "tail",      tail)
      
      return self
    end
    
    function IndexedQueue:GetCount()
      return Addon:CheckTable(self, "count")
    end
    
    function IndexedQueue:next(id)
      if id ~= nil then
        id = GetNext(self, id)
      else
        id = Addon:CheckTable(self, "head")
      end
      if not id then return end
      local v = rawget(Addon:CheckTable(self, "actual"), id)
      if v ~= nil then
        return id, v
      end
    end
    function IndexedQueue:prev(id)
      if id ~= nil then
        id = GetPrev(self, id)
      else
        id = Addon:CheckTable(self, "tail")
      end
      if not id then return end
      local v = rawget(Addon:CheckTable(self, "actual"), id)
      if v ~= nil then
        return id, v
      end
    end
    
    function IndexedQueue:iter(initial)
      return IndexedQueue.next, self, initial and GetPrev(self, initial) or nil
    end
    function IndexedQueue:riter(initial)
      return IndexedQueue.prev, self, initial and GetNext(self, initial) or nil
    end
    
    function IndexedQueue:GetHead()
      return IndexedQueue.next(self)
    end
    function IndexedQueue:GetTail()
      return IndexedQueue.prev(self)
    end
    
    local meta = {
      __index = function(self, k)
        if IndexedQueue[k] then
          return IndexedQueue[k]
        else
          return IndexedQueue.Get(self, k)
        end
      end,
      __newindex = function(self, k, v)
        if v ~= nil then
          return IndexedQueue.Replace(self, k, v)
        else
          return IndexedQueue.Remove(self, k)
        end
        
      end,
    }
    
    function IndexedQueue:Create(t)
      t = t or {}
      if getmetatable(t) == meta then return t end
      
      if Addon:CheckTable(t, "actual") == nil then
        t = {actual = t}
      end
      
      local actual = Addon:CheckTable(t, "actual")
      
      Addon:StoreDefault(t, "count",     #actual)
      Addon:StoreDefault(t, "nextIndex", #actual + 1)
      
      if next(actual) ~= nil then
        if not Addon:CheckTable(t, "head") then
          Addon:StoreInTable(t, "head", 1)
        end
        if not Addon:CheckTable(t, "tail") then
          Addon:StoreInTable(t, "tail", #actual)
        end
        Addon:StoreDefault(t, "head",  1)
        Addon:StoreDefault(t, "tail",  #actual)
      end
      
      return setmetatable(t, meta)
    end
  end
  
  -- PriorityQueue
  do
    local PriorityQueue = setmetatable({}, {__call = function(self, ...) return self:Create(...) end})
    Addon.PriorityQueue = PriorityQueue
    
    local function GetParent(i)
      return mathFloor(i/2)
    end
    local function GetLeft(i)
      return 2*i
    end
    local function GetRight(i)
      return 2*i + 1
    end
    
    local function Swap(actual, i, j)
      local temp = rawget(actual, i)
      rawset(actual, i, rawget(actual, j))
      rawset(actual, j, temp)
    end
    
    local function ShiftUp(actual, i, SortFunc)
      if SortFunc then
        while i > 1 and SortFunc(rawget(actual, i), rawget(actual, GetParent(i))) do
          Swap(actual, GetParent(i), i)
          i = GetParent(i)
        end
      else
        while i > 1 and rawget(actual, i) < rawget(actual, GetParent(i)) do
          Swap(actual, GetParent(i), i)
          i = GetParent(i)
        end
      end
    end
    
    local function ShiftDown(actual, i, SortFunc)
      local min   = i
      local left  = GetLeft(i)
      local right = GetRight(i)
      
      if SortFunc then
        if rawget(actual, left) and SortFunc(rawget(actual, left), rawget(actual, min)) then
          min = left
        end
        if rawget(actual, right) and SortFunc(rawget(actual, right), rawget(actual, min)) then
          min = right
        end
      else
        if rawget(actual, left) and rawget(actual, left) < rawget(actual, min) then
          min = left
        end
        if rawget(actual, right) and rawget(actual, right) < rawget(actual, min) then
          min = right
        end
      end
      
      if i ~= min then
        Swap(actual, i, min)
        ShiftDown(actual, min, SortFunc)
      end
    end
    
    
    function PriorityQueue:Add(v)
      local actual = rawget(self, "actual")
      local new = #actual+1
      rawset(actual, new, v)
      ShiftUp(actual, new, rawget(self, "SortFunc"))
    end
    
    function PriorityQueue:Pop()
      local actual = rawget(self, "actual")
      local output = rawget(actual, 1)
      
      rawset(actual, 1, rawget(actual, #actual))
      rawset(actual, #actual, nil)
      ShiftDown(actual, 1, rawget(self, "SortFunc"))
      
      return output
    end
    
    function PriorityQueue:Peek()
      return Addon:CheckTable(self, "actual", 1)
    end
    
    function PriorityQueue:iter()
      local sorted = Addon:Copy(rawget(self, "actual"))
      tblSort(sorted, rawget(self, "SortFunc"))
      local i = 0
      return function()
        i = i + 1
        return sorted[i]
      end
    end
    
    function PriorityQueue:riter()
      local sorted = tblSort(Addon:Copy(rawget(self, "actual")), rawget(self, "SortFunc"))
      tblSort(sorted, rawget(self, "SortFunc"))
      local i = #sorted + 1
      return function()
        i = i - 1
        return sorted[i]
      end
    end
    
    
    local meta = {
      __index = function(self, k)
        Addon:Assertf(k and PriorityQueue[k], "Attempt to index PriorityQueue with key %s", tostring(k))
        return PriorityQueue[k]
      end,
      __newindex = function(self, k, v)
        Addon:Errorf("Attempted to insert an element into a PriorityQueue: %s = %s", tostring(k), tostring(v))
      end,
    }
    
    function PriorityQueue:Create(t, SortFunc)
      t = t or {}
      if getmetatable(t) == meta then return t end
      
      if Addon:CheckTable(t, "actual") == nil then
        t = {actual = t}
      end
      
      Addon:StoreDefault(t, "SortFunc", SortFunc)
      
      return setmetatable(t, meta)
    end
  end
  
  -- MergeSorted
  do
    
    --[[
    input = {
      {ipairs(t)},
      {pairs(t)},
      {iter, t, 0},
      {next, t, nil},
      {t2:iter()},
    }
    ]]
    function Addon:MergeSorted(input, SortFunc, outputSizeLimit, ticker)
      local nodeMeta = {
        __lt = SortFunc and function(self, o)
          return SortFunc(self.val, o.val)
        end or function(self, o)
          return self.val < o.val
        end,
      }
      local function Node(val, row, col)
        return setmetatable({
          val = val,
          row = row,
          col = col,
        }, nodeMeta)
      end
      
      local count = 0
      
      local output = {}
      local pq = self.PriorityQueue(SortFunc)
      
      for row, iter in ipairs(input) do
        local iter, a, z = unpack(iter)
        local i, v = iter(a, z)
        
        if i then
          pq:Add(Node(v, row, 1))
        end
        if ticker then
          ticker:Tick()
        end
      end
      
      while pq:Peek() and (not outputSizeLimit or #output < outputSizeLimit) do
        local node = pq:Pop()
        output[#output+1] = node.val
        
        local row = input[node.row]
        
        local i, v = row[1](row[2], node.col)
        if i then
          pq:Add(Node(v, node.row, i))
        end
        if ticker then
          ticker:Tick()
        end
      end
      
      return output
    end
  end
  
  function Addon.TimedTable(defaultDuration)
    local duration = defaultDuration or 10
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
    
    for i, key in ipairs{...} do
      if not rawget(t, key) then
        rawset(t, key, {})
      end
      t = rawget(t, key)
    end
    return t
  end
  
  function Addon:StoreInTable(t, ...)
    local parent = t
    
    local keys = {...}
    local val = tblRemove(keys)
    local last = #keys
    for i, key in ipairs(keys) do
      if i == last then
        rawset(t, key, val)
      elseif not rawget(t, key) then
        rawset(t, key, {})
      end
      t = rawget(t, key)
    end
    return parent
  end
  
  function Addon:RemoveInTable(t, ...)
    local parent = t
    
    local keys = {...}
    local last = #keys
    for i, key in ipairs(keys) do
      if i == last then
        rawset(t, key, nil)
      elseif not rawget(t, key) then
        rawset(t, key, {})
      end
      t = rawget(t, key)
    end
    return parent
  end
  
  function Addon:StoreDefault(t, ...)
    local parent = t
    
    local keys = {...}
    local val = tblRemove(keys)
    local last = #keys
    for i, key in ipairs(keys) do
      if i == last then
        if rawget(t, key) == nil then
          rawset(t, key, val)
        end
      elseif not rawget(t, key) then
        rawset(t, key, {})
      end
      t = rawget(t, key)
    end
    return parent
  end
  
  function Addon:CheckTable(t, ...)
    local val = t
    for _, key in ipairs{...} do
      val = rawget(val or {}, key)
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
  
  
  function Addon:Ternary(expression, trueVal, falseVal) -- Does not use short-circuit evaluation
    if expression then
      return trueVal
    else
      return falseVal
    end
  end
  
  function Addon:ShortCircuit(expression, trueFunc, falseFunc) -- Uses short-circuit evaluation
    if expression then
      return trueFunc()
    else
      return falseFunc()
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
  local addonEventSalt = ADDON_NAME .. "_"
  local function TransformEventName(event, isAddonEvent)
    if isAddonEvent then
      event = addonEventSalt .. event
    end
    return event
  end
  local isDBShutdown = false
  local blacklistedEvents = Addon:MakeBoolTable{
    "PLAYER_LOGOUT",
    "ADDONS_UNLOADING",
  }
  local registrations    = Addon.IndexedQueue()
  local suspended        = {}
  local onEventCallbacks = setmetatable({}, {__index = function(self, k)
    rawset(self, k, Addon.IndexedQueue())
    return rawget(self, k)
  end})
  
  function Addon:ShutdownDB()
    isDBShutdown = true
    registrations:Wipe()
  end
  
  local function Call(func, ...)
    local args = {...}
    local nArgs = select("#", ...)
    if type(func) == "function" then
      Addon:xpcall(function() func(unpack(args, 1, nArgs)) end)
    else
      Addon:xpcall(function() Addon[func](unpack(args, 1, nArgs)) end)
    end
  end
  
  local function RunCallbacks(isAddonEvent, event, ...)
    local t = onEventCallbacks[event]
    if Addon:IsGlobalDBLoaded() and Addon:GetGlobalOption("debugOutput", isAddonEvent and "onAddonEvent" or "onEvent") then
      local args = {...}
      local nArgs = select("#", ...)
      if t:GetCount() > 0 then
        Addon:Debugf("Running %d |4callback:callbacks; for event with %d args: %s", t:GetCount(), nArgs+2, Addon:Concat(", ", Addon, event, ...))
      else
        Addon:Debugf("Fired empty event with %d args: %s", nArgs+2, Addon:Concat(", ", Addon, event, ...))
      end
    end
    for i, func in t:iter() do
      Call(func, Addon, event, ...)
    end
    if t:GetCount() == 0 then
      onEventCallbacks[event] = nil
    end
  end
  
  local function OnEvent(event, ...)
    if suspended[event] or isDBShutdown then return end
    RunCallbacks(false, event, ...)
  end
  local function OnAddonEvent(event, ...)
    if isDBShutdown then return end
    event = TransformEventName(event, true)
    if suspended[event] then return end
    RunCallbacks(true, event, ...)
  end
  
  local function UnregisterEventCallback(isAddonEvent, id)
    if isDBShutdown then return end
    local registration = registrations[id]
    for event, index in pairs(registration) do
      local callbacks = onEventCallbacks[event]
      Addon:Assertf(callbacks:Remove(index), "Attempted to unregister callback %s from event %s, but it was not found", index, event)
      if callbacks:GetCount() == 0 then
        onEventCallbacks[event] = nil
        if not isAddonEvent then
          Addon:UnregisterEvent(event)
        end
      end
    end
    registrations[id] = nil
  end
  
  local function RegisterEventCallback(isAddonEvent, ...)
    if isDBShutdown then return end
    local events = {...}
    local callback = tblRemove(events, #events)
    assert(#events > 0 and type(callback) == "function", "Expected events and function")
    
    local registration = {}
    local id = registrations:Add(registration)
    
    func = function(...) if callback(...) then UnregisterEventCallback(isAddonEvent, id) end end
    
    for _, event in ipairs(events) do
      Addon:Assertf(not blacklistedEvents[event], "Cannot register event: %s", event)
      event = TransformEventName(event, isAddonEvent)
      local callbacks = onEventCallbacks[event]
      local index = callbacks:Add(func)
      if not isAddonEvent and callbacks:GetCount() == 1 then
        Addon:RegisterEvent(event, OnEvent)
      end
      registration[event] = index
    end
    return id
  end
  local function RegisterOneTimeEventCallback(isAddonEvent, ...)
    local args = {...}
    local nArgs = select("#", ...)
    local callback = args[#args]
    args[#args] = function(...) callback(...) return true end
    
    return RegisterEventCallback(isAddonEvent, unpack(args, 1, nArgs))
  end
  
  local function SuspendEventWhile(isAddonEvent, ...)
    if isDBShutdown then return end
    local events = {...}
    local callback = tblRemove(events, #events)
    assert(#events > 0 and type(callback) == "function", "Expected events and function")
    
    local mySuspensions = {}
    for _, event in ipairs(events) do
      event = TransformEventName(event, isAddonEvent)
      if not suspended[event] then
        suspended[event]     = true
        mySuspensions[event] = true
      end
    end
    
    Addon:xpcall(function() callback(Addon) end)
    
    for event in pairs(mySuspensions) do
      suspended[event] = nil
    end
  end
  
  
  
  function Addon:RegisterEventCallback(...)
    return RegisterEventCallback(false, ...)
  end
  function Addon:RegisterOneTimeEventCallback(...)
    return RegisterOneTimeEventCallback(false, ...)
  end
  function Addon:UnregisterEventCallback(id)
    return UnregisterEventCallback(false, id)
  end
  function Addon:FireEvent(event, ...)
    OnEvent(event, ...)
  end
  function Addon:SuspendEventWhile(...)
    return SuspendEventWhile(false, ...)
  end
  
  
  function Addon:RegisterAddonEventCallback(...)
    return RegisterEventCallback(true, ...)
  end
  function Addon:RegisterOneTimeAddonEventCallback(...)
    return RegisterOneTimeEventCallback(true, ...)
  end
  function Addon:UnregisterAddonEventCallback(id)
    return UnregisterEventCallback(true, id)
  end
  function Addon:FireAddonEvent(event, ...)
    OnAddonEvent(event, ...)
  end
  function Addon:SuspendAddonEventWhile(...)
    return SuspendEventWhile(true, ...)
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
    local loadedOrLoading, loaded
    if C_AddOns and C_AddOns.IsAddOnLoaded then
      loadedOrLoading, loaded = C_AddOns.IsAddOnLoaded(addonName)
    else
      loadedOrLoading, loaded = IsAddOnLoaded(addonName)
    end
    if loaded then
      Call(func, self)
    else
      self:RegisterEventCallback("ADDON_LOADED", function(self, event, addon)
        if addon == addonName then
          Call(func, self)
          return true
        end
      end)
    end
  end
  
  function Addon:WhenOutOfCombat(func)
    if not InCombatLockdown() then
      Call(func, self)
    else
      self:RegisterOneTimeEventCallback("PLAYER_REGEN_ENABLED", function() Call(func, self) end)
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
  local dbTables = {
    {"dbDefault", "Default", true},
    {"db", ""},
  }
  local dbTypes = {
    {"global", "Global"},
    {"profile", ""},
  }
  local initialized = {}
  
  local defaultKey, defaultName
  
  for _, dbType in ipairs(dbTables) do
    local dbKey, dbName, isDefault = unpack(dbType, 1, 3)
    if isDefault then
      defaultKey  = dbKey
      defaultName = dbName
    end
    
    for _, dbSection in ipairs(dbTypes) do
      local typeKey, typeName = unpack(dbSection, 1, 2)
      
      
      local GetDB      = format("Get%s%sDB",      dbName, typeName)
      local IsDBLoaded = format("Is%s%sDBLoaded", dbName, typeName)
      
      Addon[GetDB] = function(self)
        return self[dbKey]
      end
      Addon[IsDBLoaded] = function(self)
        return Addon[GetDB](self) ~= nil and initialized[typeKey]
      end
      
      
      local GetOption             = format("Get%s%sOption",      dbName,      typeName)
      local GetOptionQuiet        = format("Get%s%sOptionQuiet", dbName,      typeName)
      local GetDefaultOption      = format("Get%s%sOption",      defaultName, typeName)
      local GetDefaultOptionQuiet = format("Get%s%sOptionQuiet", defaultName, typeName)
      
      local function Get(self, quiet, ...)
        assert(Addon[IsDBLoaded](self), format("Attempted to access %s database before initialization: %s", typeKey, Addon:Concat(" > ", dbKey, typeKey, ...)))
        local val = self[dbKey][typeKey]
        for _, key in ipairs{...} do
          assert(type(val) == "table", format("Bad database access (%s is not a table): %s", tostring(val), Addon:Concat(" > ", dbKey, typeKey, ...)))
          val = val[key]
        end
        
        if not quiet then
          if type(val) == "table" then
            Addon:Warnf("Database request returned a table: %s", Addon:Concat(" > ", dbKey, typeKey, ...))
          end
          if val == nil then
            Addon:Warnf("Database request found empty value: %s", Addon:Concat(" > ", dbKey, typeKey, ...))
          end
        end
        
        return val
      end
      
      Addon[GetOption] = function(self, ...)
        return Get(self, false, ...)
      end
      Addon[GetOptionQuiet] = function(self, ...)
        return Get(self, true, ...)
      end
      
      
      if not isDefault then
        local SetOption               = format("Set%s%sOption",               dbName, typeName)
        local ToggleOption            = format("Toggle%s%sOption",            dbName, typeName)
        local ResetOption             = format("Reset%s%sOption",             dbName, typeName)
        local ResetOptionQuiet        = format("Reset%s%sOptionQuiet",        dbName, typeName)
        
        local function Set(self, val, ...)
          assert(Addon[IsDBLoaded](self), format("Attempted to access %s database before initialization: %s = %s", typeKey, Addon:Concat(" > ", dbKey, typeKey, ...), tostring(val)))
          local keys = {...}
          local nKeys = select("#", ...)
          local lastKey = tblRemove(keys, nKeys)
          nKeys = nKeys - 1
          Addon:Assertf(lastKey ~= nil, "Bad database access: %s = %s", Addon:Concat(" > ", dbKey, typeKey, ...), tostring(val))
          local tbl = self[dbKey][typeKey]
          for i = 1, nKeys do
            local key = keys[i]
            Addon:Assertf(key ~= nil and type(tbl[key]) == "table", "Bad database access: %s = %s", Addon:Concat(" > ", dbKey, typeKey, ...), tostring(val))
            tbl = tbl[key]
          end
          local lastVal = tbl[lastKey]
          if type(lastVal) == "table" then
            if type(val) ~= "table" and val ~= nil then
              Addon:Warnf("Database access overwriting a table: %s", Addon:Concat(" > ", dbKey, typeKey, ...))
            end
          end
          tbl[lastKey] = val
          Addon:DebugfIfOutput("optionSet", "Setting %s = %s", Addon:Concat(" > ", ...), tostring(val))
          Addon:FireAddonEvent("OPTION_SET", val, dbKey, typeKey, ...)
          return Addon
        end
        
        Addon[SetOption] = function(self, val, ...)
          return Set(self, val, ...)
        end
        
        Addon[ToggleOption] = function(self, ...)
          return Addon[SetOption](self, not Addon[GetOption](self, ...), ...)
        end
        
        Addon[ResetOption] = function(self, ...)
          return Addon[SetOption](self, Addon.Copy(self, Addon[GetDefaultOption](self, ...)), ...)
        end
        Addon[ResetOptionQuiet] = function(self, ...)
          return Addon[SetOption](self, Addon.Copy(self, Addon[GetDefaultOptionQuiet](self, ...)), ...)
        end
      end
    end
  end
  
  
  local function GetOrderedUpgrades(upgrades)
    local versions = {}
    for version, func in pairs(upgrades) do
      versions[#versions+1] = version
    end
    
    tblSort(versions, function(a, b) return Addon.SemVer(a) < Addon.SemVer(b) end)
    
    local i = 0
    return function()
      i = i + 1
      local version = versions[i]
      if version then
        return version, upgrades[version]
      end
    end
  end
  
  local function InitDB(dbInitFuncs, configType)
    local init = dbInitFuncs[configType]
    if not init then return end
    
    initialized[configType] = true
    
    local db = Addon:GetDB()[configType]
    local oldVersion = db.version
    local currentVersion = tostring(Addon.version)
    
    if not oldVersion then
      if init.FirstRun then
        Addon:Debugf("Performing first run for %s db", tostring(configType))
        
        Addon:pcall(init.FirstRun, function(err)
          Addon:Errorf("FirstRun failed for %s db\n%s", tostring(configType))
        end)
      end
    elseif oldVersion ~= currentVersion then
      if init.upgrades then
        for version, Upgrade in GetOrderedUpgrades(init.upgrades) do
          if Addon.SemVer(oldVersion) < Addon.SemVer(version) then
            Addon:Debugf("Updating %s db from %s to %s", tostring(configType), tostring(oldVersion), version)
            if Addon:pcall(Upgrade, function(err)
              Addon:Errorf("Data upgrade from %s to %s failed for %s db\n%s", tostring(oldVersion), tostring(version), tostring(configType), tostring(err))
            end) then
              break -- the upgrade function returned true, so run any further upgrades
            end
          end
        end
      end
    end
    
    if init.AlwaysRun then
      Addon:pcall(init.AlwaysRun, function(err)
        Addon:Errorf("AlwaysRun failed for %s db\n%s", tostring(configType), err)
      end)
    end
    
    db.version = currentVersion
  end
  
  function Addon:InitDB(dbInitFuncs)
    for _, dbSection in ipairs(dbTypes) do
      InitDB(dbInitFuncs, dbSection[1])
    end
  end
end






--  ██████╗ ██╗      █████╗ ██╗   ██╗███████╗██████╗     ██████╗  █████╗ ████████╗ █████╗ 
--  ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
--  ██████╔╝██║     ███████║ ╚████╔╝ █████╗  ██████╔╝    ██║  ██║███████║   ██║   ███████║
--  ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗    ██║  ██║██╔══██║   ██║   ██╔══██║
--  ██║     ███████╗██║  ██║   ██║   ███████╗██║  ██║    ██████╔╝██║  ██║   ██║   ██║  ██║
--  ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

do
  local playerLocation = PlayerLocation:CreateFromUnit"player"
  
  
  Addon.MY_GUID = UnitGUID"player"
  
  
  Addon.MY_NAME = UnitNameUnmodified"player"
  
  
  Addon.MY_CLASS_LOCALNAME, MY_CLASS_FILENAME, Addon.MY_CLASS = UnitClass"player"
  
  
  Addon.MY_RACE_LOCALNAME, Addon.MY_RACE_FILENAME, Addon.MY_RACE = UnitRace"player"
  
  
  Addon.MY_FACTION = UnitFactionGroup"player"
  
  
  Addon.MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE and MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] or GetMaxLevelForPlayerExpansion()
  Addon.MY_LEVEL = UnitLevel"player"
  Addon:RegisterEventCallback("PLAYER_LEVEL_UP", function(self, event, level) self.MY_LEVEL = UnitLevel"player" end)
  
  
  Addon.MY_SEX = UnitSex"player" - 2
  Addon:RegisterAddonEventCallback("ENABLE", function(self)
    self.MY_SEX = C_PlayerInfo.GetSex(PlayerLocation:CreateFromUnit"player")
    do
      for name, id in pairs(Enum.UnitSex) do
        if id == self.MY_SEX then
          self.MY_SEX_LOCALNAME = name
          break
        end
      end
    end
  end)
  
  
  
  Addon.MAX_ITEM_LEVEL = Addon:Switch(Addon.expansionLevel, {
    [Addon.expansions.era]   = 100,
    [Addon.expansions.tbc]   = 159,
    [Addon.expansions.wrath] = 284,
    [Addon.expansions.cata]  = 416,
  }, 1000)
end




--   ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--   ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  do
    Addon.GUI = {}
    local GUI = Addon.GUI
    
    local defaultInc   = 1000
    local defaultOrder = 1000
    local order        = defaultOrder
    
    local dbType = ""
    local GetFunction      = function(keys) local funcName = format("Get%sOption",   dbType) return function(info)          Addon:HideConfirmPopup() return Addon[funcName](Addon, unpack(keys))                                                          end end
    local SetFunction      = function(keys) local funcName = format("Set%sOption",   dbType) return function(info, val)                                     Addon[funcName](Addon, val, unpack(keys))                                                     end end
    local ResetFunction    = function(keys) local funcName = format("Reset%sOption", dbType) return function(info, val)                                     Addon[funcName](Addon, unpack(keys))                                                          end end
    local GetColorFunction = function(keys) local funcName = format("Get%sOption",   dbType) return function(info)          Addon:HideConfirmPopup() return Addon:ConvertColorToBlizzard(Addon[funcName](Addon, unpack(keys)))                            end end
    local SetColorFunction = function(keys) local funcName = format("Set%sOption",   dbType) return function(info, r, g, b)                                 Addon[funcName](Addon, Addon:ConvertColorFromBlizzard(r, g, b), unpack(keys)):RefreshConfig() end end
    
    
    local MultiGetFunction = function(keys)
      local funcName = format("Get%sOption", dbType)
      return function(info, key)
        local path = Addon:Copy(keys)
        path[#path+1] = key
        return Addon[funcName](Addon, unpack(path))
      end
    end
    
    local MultiSetFunction = function(keys)
      local funcName = format("Set%sOption", dbType)
      return function(info, key, val)
        local path = Addon:Copy(keys)
        path[#path+1] = key
        Addon[funcName](Addon, val, unpack(path))
      end
    end
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
      local key = widgetType .. "_" .. (Addon:TableConcat(keys, ".") or "") .. "_" .. order
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
      return self:CreateDescription(opts, "", fontSize or "small")
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
      option.values = values
      option.get = MultiGetFunction(keys)
      option.set = MultiSetFunction(keys)
      return option
    end
    function GUI:CreateMultiDropdown(...)
      local option = self:CreateMultiSelect(...)
      option.dialogControl = "Dropdown"
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
  end
  
  
  
  
  function Addon:HideConfirmPopup()
    if not self:IsConfigOpen() then return end
    self:xpcall(function()
      if self.AceConfigDialog then
        local frame = self.AceConfigDialog.popup
        if frame then
          frame:Hide()
        end
      end
    end)
  end
  
  do
    local refreshingAllowed = true
    
    function Addon:RefreshConfig(appName)
      if not refreshingAllowed then return end
      appName = appName or ADDON_NAME
      
      if not self:IsConfigOpen() then return end
      self:HideConfirmPopup()
      self:xpcall(function()
        if self.AceConfigRegistry then
          self.AceConfigRegistry:NotifyChange(appName)
        end
      end)
      return self
    end
    
    function Addon:SuspendConfigRefreshingWhile(func, ...)
      refreshingAllowed = false
      self:xpcall(func, nil, ...)
      refreshingAllowed = true
    end
  end
  
  
  
  local blizzardCategory
  function Addon:OpenBlizzardConfig()
    Settings.OpenToCategory(blizzardCategory)
  end
  function Addon:CloseBlizzardConfig()
    SettingsPanel:Close(true)
  end
  function Addon:ToggleBlizzardConfig(...)
    if SettingsPanel:IsShown() then
      self:CloseBlizzardConfig(...)
    else
      self:OpenBlizzardConfig(...)
    end
  end
  
  local function HookCloseConfig()
    local hookedKey = ADDON_NAME .. "_OPEN"
    
    local frame = Addon:GetConfigWindow()
    Addon:ThrowAssert(frame, "Can't find frame to hook options menu close")
    
    local alreadyHooked = frame[hookedKey] ~= nil
    frame[hookedKey] = true
    
    if alreadyHooked then return end
    
    frame:HookScript('OnHide', function(self)
      local currentFrame = Addon:GetConfigWindow()
      if not currentFrame or self ~= currentFrame then
        if self[hookedKey] then
          Addon:FireAddonEvent"OPTIONS_CLOSED_POST"
          self[hookedKey] = false
        end
      end
    end)
    
  end
  
  function Addon:GetConfigWindow()
    return self:CheckTable(self, "AceConfigDialog", "OpenFrames", ADDON_NAME, "frame")
  end
  
  function Addon:IsConfigOpen(...)
    if not self:GetConfigWindow() then return false end
    
    local path = {...}
    local nPath = select("#", ...)
    while nPath > 0 do
      local lastGroup = tblRemove(path, nPath)
      nPath = nPath - 1
      
      if self:CheckTable(self.AceConfigDialog:GetStatusTable(ADDON_NAME, path), "groups", "selected") ~= lastGroup then
        return false
      end
    end
    
    return true
  end
  
  function Addon:OpenConfig(...)
    self:FireAddonEvent"OPTIONS_OPENED_PRE"
    
    local args = {...}
    local nArgs = select("#", ...)
    while nArgs > 0 do
      local arg = tblRemove(args)
      nArgs = nArgs - 1
      self:StoreInTable(self.AceConfigDialog:GetStatusTable(ADDON_NAME, args), "groups", "selected", arg)
    end
    self.AceConfigDialog:Open(ADDON_NAME)
    
    HookCloseConfig()
    self:FireAddonEvent"OPTIONS_OPENED_POST"
  end
  
  function Addon:CloseConfig()
    self.AceConfigDialog:Close(ADDON_NAME)
  end
  
  function Addon:ToggleConfig(...)
    if self:IsConfigOpen(...) then
      self:CloseConfig()
    else
      self:OpenConfig(...)
    end
  end
  
  function Addon:RefreshDebugOptions()
    if Addon:IsConfigOpen"Debug" then
      self:RefreshConfig()
    end
  end
  
  function Addon:ResetProfile(category)
    self:GetDB():ResetProfile()
    self:RefreshConfig(category)
  end
  
  function Addon:CreateBlizzardOptionsCategory(options)
    local blizzardOptions = ADDON_NAME .. ".Blizzard"
    self.AceConfig:RegisterOptionsTable(blizzardOptions, options)
    local Panel, id = self.AceConfigDialog:AddToBlizOptions(blizzardOptions, ADDON_NAME)
    blizzardCategory = id
    Panel.default = function() self:ResetProfile(blizzardOptions) end
    return Panel
  end
  
  
  do
    local staticPopups = {}
    Addon.staticPopups = staticPopups
    
    local function MakeName(name)
      return ADDON_NAME .. "_" .. tostring(name)
    end
    
    
    local function SetPopupText(name, text)
      Addon:Assertf(Addon.staticPopups[name], "StaticPopup with name '%s' doesn't exist", name)
      
      Addon.staticPopups[name].text = text
    end
    
    local function GetDialogFrames(name)
      local key = MakeName(name)
      Addon:Assertf(StaticPopupDialogs[key], "StaticPopup with name '%s' doesn't exist", key)
      Addon:Assertf(staticPopups[name], "StaticPopup with name '%s' isn't owned by %s", key, ADDON_NAME)
      
      local frameName, data = StaticPopup_Visible(key)
      if not frameName then return end
      local textFrameName = frameName .. "Text"
      local frame     = _G[frameName]
      local textFrame = _G[textFrameName]
      Addon:Assertf(frame and textFrameName, "Couldn't get StaticPopup frames '%s' and '%s'", frameName, textFrameName)
      
      return frame, textFrame
    end
    
    function Addon:GetPopupData(name)
      local key = MakeName(name)
      self:Assertf(StaticPopupDialogs[key], "StaticPopup with name '%s' doesn't exist", key)
      self:Assertf(staticPopups[name], "StaticPopup with name '%s' isn't owned by %s", key, ADDON_NAME)
      
      local frameName, data = StaticPopup_Visible(key)
      if not data then return end
      
      return data.data
    end
    
    function Addon:InitPopup(name, popupConfig)
      local key = MakeName(name)
      self:Assertf(not StaticPopupDialogs[key], "StaticPopup with name '%s' already exists", key)
      
      StaticPopupDialogs[key] = popupConfig
      self.staticPopups[name] = popupConfig
      
      popupConfig.patternText = popupConfig.text
      SetPopupText(name, "")
    end
    
    function Addon:ShowPopup(name, data, ...)
      local key = MakeName(name)
      self:Assertf(StaticPopupDialogs[key], "StaticPopup with name '%s' doesn't exist", key)
      self:Assertf(staticPopups[name], "StaticPopup with name '%s' isn't owned by %s", key, ADDON_NAME)
      
      SetPopupText(name, "")
      
      StaticPopup_Show(key, nil, nil, data)
      self:EditPopupText(name, ...)
    end
    
    function Addon:HidePopup(name)
      local key = MakeName(name)
      self:Assertf(StaticPopupDialogs[key], "StaticPopup with name '%s' doesn't exist", key)
      self:Assertf(staticPopups[name], "StaticPopup with name '%s' isn't owned by %s", key, ADDON_NAME)
      
      StaticPopup_Hide(key)
    end
    
    function Addon:IsPopupShown(name)
      return self:GetPopupData(name) and true or false
    end
    
    function Addon:EditPopupText(name, ...)
      local key = MakeName(name)
      self:Assertf(StaticPopupDialogs[key], "StaticPopup with name '%s' doesn't exist", key)
      self:Assertf(staticPopups[name], "StaticPopup with name '%s' isn't owned by %s", key, ADDON_NAME)
      
      local frame, textFrame = GetDialogFrames(name)
      self:Assertf(textFrame, "StaticPopup text frame with name '%s' doesn't exist", textFrameName)
      
      textFrame:SetFormattedText(staticPopups[name].patternText, ...)
      SetPopupText(name, textFrame:GetText())
      StaticPopup_Resize(frame, key)
    end
  end
end




--  ████████╗██╗  ██╗██████╗ ███████╗ █████╗ ██████╗ ██╗███╗   ██╗ ██████╗ 
--  ╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ 
--     ██║   ███████║██████╔╝█████╗  ███████║██║  ██║██║██╔██╗ ██║██║  ███╗
--     ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══██║██║  ██║██║██║╚██╗██║██║   ██║
--     ██║   ██║  ██║██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║╚██████╔╝
--     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
do
  do
    local threads = {}
    Addon.threads = threads
    
    local meta = {
      __index = {
        Start = function(self) self.frame:Show() end,
        Stop  = function(self) self.frame:Hide() end,
        Run   = function(self) self.runner(self) end,
      },
    }
    
    local function MakeNewThread(name)
      local thread = setmetatable({}, meta)
      
      local data = {}
      local runner = function(self)
        if coroutine.status(thread.co) ~= "dead" then
          thread.laps = thread.laps + 1
          thread.startTime = GetTimePreciseSec()
          local success, err = coroutine.resume(thread.co, Addon, data)
          thread.time = thread.time + (GetTimePreciseSec() - thread.startTime)
          thread.startTime = nil
          if not success then
            -- thread.error = true
            Addon:Throw(err)
          end
        end
        if coroutine.status(thread.co) == "dead" then
          thread:Stop()
        end
      end
      local frame = CreateFrame"Frame"
      frame:SetScript("OnUpdate", runner)
      
      
      thread.data   = data
      thread.runner = runner
      thread.frame  = frame
      
      threads[name] = thread
      return thread
    end
    
    
    function Addon:StartNewThread(name, func, nextFrame)
      self:Assertf(name,                     "Thread needs a name")
      self:Assertf(type(func) == "function", "Thread needs a function")
      
      local thread
      if threads[name] then
        thread = self:StopThread(name)
      else
        thread = MakeNewThread(name)
      end
      
      -- thread.error = nil
      thread.co = coroutine.create(func)
      thread:Start()
      
      thread.realTime = GetTimePreciseSec()
      thread.time     = 0
      thread.laps     = 0
      
      if not nextFrame then
        thread:Run()
      end
    end
    
    function Addon:DoesThreadExist(name)
      return threads[name] and true or false
    end
    
    function Addon:StartThread(name)
      local thread = threads[name]
      if thread and not self:IsThreadDead(name) then
        thread:Start()
      end
      return thread
    end
    
    function Addon:StopThread(name)
      local thread = threads[name]
      if thread then
        thread:Stop()
      end
      return thread
    end
    
    function Addon:KillThread(name)
      local thread = threads[name]
      if thread then
        thread:Stop()
      end
      threads[name] = nil
    end
    
    function Addon:RunThread(name)
      local thread = threads[name]
      if thread then
        thread:Run()
      end
      return thread
    end
    
    function Addon:IsThreadDead(name)
      local thread = threads[name]
      return not thread or coroutine.status(thread.co) == "dead"
    end
    
    function Addon:GetThreadData(name)
      local thread = threads[name]
      return thread and thread.data or nil
    end
    
    function Addon:GetThreadRunTime(name)
      local thread = threads[name]
      if thread then
        local totalTime = thread.time
        if thread.startTime then
          totalTime = totalTime + GetTimePreciseSec() - thread.startTime
        end
        return totalTime
      end
    end
    
    function Addon:GetThreadRealTime(name)
      local thread = threads[name]
      return thread and (GetTimePreciseSec() - thread.realTime) or nil
    end
    
    function Addon:GetThreadLaps(name)
      local thread = threads[name]
      return thread and thread.laps or nil
    end
  end
  
  do
    local function Rollover(self)
      self[3] = self[3] + self[1]
      self[1] = 0
      self[4] = self[4] + 1
    end
    
    local meta = {
      __index = {
        Tick = function(self, n, callback, ...)
          self[1] = self[1] + (n or 1)
          if self[1] >= self[2] then
            Rollover(self)
            
            callback = callback or self[5]
            if callback then
              Addon:xpcall(callback)
            end
            return true, coroutine.yield(...)
          end
        end,
        Trigger = function(self, ...)
          Rollover(self)
          return coroutine.yield(...)
        end,
        GetSpeed = function(self)
          return self[2]
        end,
        SetSpeed = function(self, v)
          self[2] = v
          return self
        end,
        GetSteps = function(self)
          return self[1] + self[3]
        end,
        GetLaps = function(self)
          return self[4]
        end,
        SetCallback = function(self, callback)
          self[5] = callback
        end,
      },
    }
  
    function Addon:MakeThreadTicker(speed)
      return setmetatable({0, speed, 0, 1}, meta)
    end
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
      self:ToggleConfig()
    end
  end
  
  function Addon:InitChatCommands(...)
    for i, chatCommand in ipairs{...} do
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
  
  function Addon:ToFormattedNumber(text, numDecimalPlaces, decimalChar, thousandsChar, fourDigitException, separateDecimals)
    local decimal   = decimalChar   or self.L["."]
    local separator = thousandsChar or self.L[","]
    
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
        result[mathFloor(i/3)+1] = strSub(left, mathMax(0, i-2), i)
      end
      if result[1] == "" then
        tblRemove(result, 1)
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
      num = mathMax(min, num)
    end
    if max then
      num = mathMin(num, max)
    end
    return num
  end
end






--  ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
--  ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
--  ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║╚════██║
--  ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝


do
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
  
  do
    local chainGsubPattern = {
      {"%%%d%$", "%%"},               -- koKR ITEM_RESIST_SINGLE: "%3$s 저항력 %1$c%2$d" -> "%s 저항력 %c%d"
      {"|3%-%d+%((.+)%)", "%1"},      -- ruRU ITEM_RESIST_SINGLE: "%c%d к сопротивлению |3-7(%s)" -> %c%d к сопротивлению %s
      {"[%[%]().+-]", "%%%0"},        -- cover special characters with escape codes
      {"%%c", "([+-])"},              -- "%c" -> "([+-])"
      {"%%d", "(%%d+)"},              -- "%d" -> "(%d+)"
      {"%%s", "(.*)"},                -- "%s" -> "(.*)"
      {"|4[^:]-:[^:]-:[^:]-;", ".-"}, -- removes |4singular:plural;
      {"|4[^:]-:[^:]-;", ".-"},       -- removes ruRU |4singular:plural1:plural2;
    }
    local reversedPatternsCache = {}
    function Addon:ReversePattern(text, noStart, noEnd)
      reversedPatternsCache[text] = reversedPatternsCache[text] or ((noStart and "" or "^") .. self:ChainGsub(text, unpack(chainGsubPattern)) .. (noEnd and "" or "$"))
      return reversedPatternsCache[text]
    end
  end
  
  
  function Addon:MakeAtlas(atlas, height, width, hex)
    height = tostring(height or "0")
    local tex = "|A:" .. atlas .. ":" .. height .. ":" .. tostring(width or height)
    if hex then
      tex = tex .. format(":::%d:%d:%d", self:ConvertHexToRGB(hex))
    end
    return tex .. "|a"
  end
  function Addon:MakeIcon(texture, height, width, hex)
    local tex = "|T" .. texture .. ":" .. tostring(height or "0") .. ":"
    if width then
      tex = tex .. width
    end
    if hex then
      tex = tex .. format(":::1:1:0:1:0:1:%d:%d:%d", self:ConvertHexToRGB(hex))
    end
    return tex .. "|t"
  end
  function Addon:UnmakeIcon(texture)
    return strMatch(texture, "|T([^:]+):")
  end
end


