
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tblConcat = table.concat


function Addon:MakeDefaultOptions()
  local fakeAddon = {
    db = {
      profile = {
        
        enabled    = true,
        invertMode = "none",
        modKeys = {
          ["*"] = true,
        },
        
        allow = { -- only applies to stats
          reorder = true,
          reword  = true,
          recolor = true,
        },
        
        order = {
          [self.expansions.wrath]   = tblConcat(self.statList[self.expansions.wrath]  , ","),
          [self.expansions.tbc]     = tblConcat(self.statList[self.expansions.tbc]    , ","),
          [self.expansions.classic] = tblConcat(self.statList[self.expansions.classic], ","),
        },
        hide = {
          ["*"]        = false,
          uselessRaces = true,
        },
        doReword = {
          ["*"]              = true,
          ItemLevel          = false,
          Refundable         = false,
          SoulboundTradeable = false,
          Enchant            = false,
          WeaponEnchant      = false,
          EnchantOnUse       = false,
          Durability         = false,
          Equip              = false,
          ChanceOnHit        = false,
          Use                = false,
        },
        reword = {
          ["*"] = "",
        },
        mod = {
          ["*"] = 1,
        },
        precision = {
          ["*"] = 0,
          Speed = 1,
        },
        doRecolor = {
          ["*"]        = true,
          Title        = false,
          Enchant      = false,
          EnchantOnUse = false, -- no GUI option, should not be enabled. inherits from Use
          Equip        = false, -- just to match Use
          ChanceOnHit  = false, -- just to match Use
          Use          = false, -- because of EnchantOnUse
        },
        color = (function() local colors = {["*"] = "00ff00"} for stat, StatInfo in pairs(self.statsInfo) do colors[stat] = StatInfo.color end return colors end)(),
        
        doReorder = {
          ["*"]              = true,
          RequiredRaces      = true, -- whether it shows up after title
          RequiredClasses    = true, -- whether it shows up after title
          RequiredLevel      = false, -- whether it shows up after title
          Refundable         = true, -- whether it shows up after binding
          SoulboundTradeable = true, -- whether it shows up after binding
          ProposedEnchant    = true, -- no GUI option
          EnchantHint        = true, -- no GUI option
          EnchantOnUse       = false, -- whether it shows up after on use effects
          SocketHint         = false, -- whether it shows up after socket bonus
        },
        
        damage = {
          ["*"]              = true,
          showVariance       = false,
          variancePercent    = true,
          ["variancePrefix"] = "+-",
        },
        dps = {
          ["*"] = true,
        },
        speedBar = {
          min         = 1.2,
          max         = 4,
          size        = 15,
          fillChar    = "I",
          blankChar   = " ",
          speedPrefix = false,
        },
        durability = {
          showCur     = true,
          showMax     = true,
          showPercent = true,
        },
        trimSpace = {
          ["*"] = true,
        },
        doIcon = {
          ["*"]         = false,
          Title         = true,
          Enchant       = true,
          EnchantOnUse  = false,
          WeaponEnchant = true,
        },
        icon = {
          ["*"]          = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\Samwise",
          ItemLevel      = "Interface\\Transmogrify\\transmog-tooltip-arrow",
          AlreadyBound   = "Interface\\PetBattles\\PetBattle-LockIcon",
          CharacterBound = "Interface\\PetBattles\\PetBattle-LockIcon",
          AccountBound   = "Interface\\PetBattles\\PetBattle-LockIcon",
          Tradeable      = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
          Enchant        = "Interface\\Buttons\\UI-GroupLoot-DE-Up",
          WeaponEnchant  = "Interface\\CURSOR\\Attack",
          EnchantOnUse   = "Interface\\Buttons\\UI-GroupLoot-DE-Up",
          Durability     = "Interface\\MINIMAP\\TRACKING\\Repair",
          Equip          = "Interface\\Tooltips\\ReforgeGreenArrow",
          ChanceOnHit    = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
          Use            = "Interface\\CURSOR\\Cast",
        },
        iconSizeManual = {
          ["*"] = false,
          Title = true,
        },
        iconSize = {
          ["*"] = 16,
          Title = 24,
        },
        iconSpace = {
          ["*"] = true,
        },
        
        pad = {
          before = {
            ["*"]    = true,
            BaseStat = false,
          },
          after = {
            ["*"] = true,
          },
        },
        padLastLine  = true,
        combineStats = true,
        
        
        -- Debug options
        debug = false,
          
        debugOutput = {
          ["*"] = false,
        },
        
        constructor = {
          doValidation = true,
          
          alwaysDestruct = false,
        },
        
        cache = {
          ["*"]   = true,
          enabled = false,
          
          -- constructor = false,
          -- text        = false,
          -- stat        = false,
          
          constructorWipeDelay    = 3, -- time in seconds without constructor being requested before it's cleared
          constructorMinSeenCount = 6, -- minimum number of times constructor must be requested before it can be cached
          constructorMinSeenTime  = 1, -- minimum time in seconds since constructor was first requested before it can be cached
        },
        
        throttle = {
          ["*"] = true,
          -- AuctionFrame    = false,
          -- InspectFrame    = false,
          -- MailFrame       = false,
          -- TradeSkillFrame = false,
        },
        
        fix = {
          InterfaceOptionsFrameForMe  = true,
          InterfaceOptionsFrameForAll = false,
        },
      },
    },
  }
  Addon.OverrideAllLocaleDefaults(fakeAddon)
  return fakeAddon.db
end
