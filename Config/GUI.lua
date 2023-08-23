
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local tblConcat = table.concat


do
  Addon.GUI = {}
  local GUI = Addon.GUI
  
  local defaultInc   = 1000
  local defaultOrder = 1000
  local order        = defaultOrder
  
  local dbType = ""
  local GetFunction      = function(keys) local funcName = format("Get%sOption",   dbType) return function(info)      return Addon[funcName](Addon, unpack(keys))      end end
  local SetFunction      = function(keys) local funcName = format("Set%sOption",   dbType) return function(info, val)        Addon[funcName](Addon, val, unpack(keys)) end end
  local ResetFunction    = function(keys) local funcName = format("Reset%sOption", dbType) return function(info, val)        Addon[funcName](Addon, unpack(keys))      end end
  local GetColorFunction = function(keys) local funcName = format("Get%sOption",   dbType) return function(info)          return Addon:ConvertColorToBlizzard(Addon[funcName](Addon, unpack(keys)))            end end
  local SetColorFunction = function(keys) local funcName = format("Set%sOption",   dbType) return function(info, r, g, b)        Addon[funcName](Addon, Addon:ConvertColorFromBlizzard(r, g, b), unpack(keys)) end end
  
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
    if type(keys) ~= "table" then keys = {keys} end
    local key = widgetType .. "_" .. (tblConcat(keys, ".") or "")
    opts.args[key] = {name = name, desc = desc, type = widgetType, order = order or self:Order(), disabled = disabled}
    opts.args[key].set = SetFunction(keys)
    opts.args[key].get = GetFunction(keys)
    return opts.args[key]
  end
  
  function GUI:CreateHeader(opts, name)
    return self:CreateEntry(opts, self:Order(), name, nil, "header", nil, self:Order(0))
  end
  
  function GUI:CreateDescription(opts, desc, fontSize)
    local option = self:CreateEntry(opts, self:Order(), desc, nil, "description", nil, self:Order(0))
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
    option.style   = "dropdown"
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
    key = tostring(key)
    opts.args[key] = {name = name, desc = desc, type = "group", childGroups = groupType, args = {}, order = self:Order(), disabled = disabled}
    return opts.args[key]
  end
  function GUI:CreateGroupBox(opts, name)
    local key = self:Order(-1)
    local option = self:CreateGroup(opts, key, name)
    option.inline = true
    return option
  end
  
  function GUI:CreateOpts(name, groupType, disabled)
    return {name = name, type = "group", childGroups = groupType, args = {}, order = self:Order()}
  end
end





