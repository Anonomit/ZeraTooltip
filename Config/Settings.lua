
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
          ["*"]               = false,
          uselessRaces        = true,
          nonEquipment        = true,
          StackSize_single    = true,
          StackSize_equipment = true,
        },
        doReword = {
          ["*"]              = true,
          ItemLevel          = false,
          Armor              = false,
          BonusArmor         = false,
          Block              = false,
          Enchant            = false,
          WeaponEnchant      = false,
          EnchantOnUse       = false,
          Durability         = false,
          RequiredClasses    = false,
          Equip              = false,
          ChanceOnHit        = false,
          Use                = false,
          Refundable         = false,
          SoulboundTradeable = false,
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
          ["*"]            = true,
          Title            = false,
          Armor            = false,
          BonusArmor       = false,
          Block            = false,
          Enchant          = false,
          EnchantOnUse     = false, -- no GUI option, should not be enabled. inherits from Use
          Socket_red       = false,
          Socket_blue      = false,
          Socket_yellow    = false,
          Socket_purple    = false,
          Socket_green     = false,
          Socket_orange    = false,
          Socket_prismatic = false,
          Socket_meta      = false,
          Equip            = false, -- just to match Use
          ChanceOnHit      = false, -- just to match Use
          Use              = false, -- because of EnchantOnUse
        },
        color = (function() local colors = {["*"] = "00ff00"} for stat, StatInfo in pairs(self.statsInfo) do colors[stat] = StatInfo.color end return colors end)(),
        
        doReorder = {
          ["*"]              = true,
          ItemLevel          = false, -- whether it shows up in the original wrath location
          RequiredRaces      = true, -- whether it shows up after title
          RequiredClasses    = true, -- whether it shows up after title
          RequiredLevel      = false, -- whether it shows up after title
          Refundable         = true, -- whether it shows up after binding
          SoulboundTradeable = true, -- whether it shows up after binding
          ProposedEnchant    = true, -- no GUI option
          EnchantHint        = true, -- no GUI option
          EnchantOnUse       = false, -- whether it shows up after on use effects
          SocketHint         = false, -- whether it shows up after socket bonus
          StackSize          = false, -- whether it shows up after title
        },
        
        itemLevel = {
          ["*"]        = true,
          useShortName = true,
        },
        damage = {
          ["*"]           = true,
          showVariance    = false,
          variancePercent = true,
          variancePrefix  = "+-",
        },
        dps = {
          ["*"] = true,
        },
        speedBar = {
          min         = 1.2,
          max         = 4,
          size        = 20,
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
        trimPunctuation = {
          ["*"] = false,
        },
        doIcon = {
          ["*"]           = false,
          Title           = true,
          Enchant         = true,
          EnchantOnUse    = false,
          WeaponEnchant   = true,
          RequiredClasses = true,
        },
        icon = {
          ["*"]          = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\Samwise",
          ItemLevel      = "Interface\\Transmogrify\\transmog-tooltip-arrow",
          AlreadyBound   = "Interface\\PetBattles\\PetBattle-LockIcon",
          CharacterBound = "Interface\\PetBattles\\PetBattle-LockIcon",
          AccountBound   = "Interface\\PetBattles\\PetBattle-LockIcon",
          Tradeable      = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
          Armor          = Addon.retailTexturesPath .. "ICONS\\Garrison_BlueArmor",
          BonusArmor     = Addon.retailTexturesPath .. "ICONS\\Garrison_GreenArmorUpgrade",
          Block          = "Interface\\ICONS\\INV_Shield_09",
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
          ["*"]           = true,
          RequiredClasses = false,
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
        
        debugShowLuaErrors = true,
          
        debugView = {
          ["*"] = false,
        },
          
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
