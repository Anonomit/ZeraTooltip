
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
        
        order = (function()
          local order={}
          for i = 1, self.expansionLevel do
            order[i] = tblConcat(self.statList[i], ",")
          end
          return order
        end)(),
        hide = {
          ["*"]                           = false,
          uselessRaces                    = true,
          nonEquipment                    = true,
          StackSize_single                = true,
          StackSize_equipment             = true,
          Reputation_waylaidSuppliesItems = true,
        },
        doReword = {
          ["*"]              = true,
          ItemLevel          = false,
          TransmogHeader     = false,
          Armor              = false,
          BonusArmor         = false,
          Block              = false,
          Enchant            = false,
          WeaponEnchant      = false,
          Rune               = false,
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
          ["*"]           = "",
          DamagePerSecond = Addon.L["DPS"],
        },
        separateThousands = {
          ["*"] = true,
        },
        mod = {
          ["*"] = 1,
        },
        precision = {
          ["*"]           = 0,
          DamagePerSecond = 1,
          Speed           = 1,
        },
        doRecolor = {
          ["*"]                  = true,
          Title                  = false,
          Armor                  = false,
          BonusArmor             = false,
          Block                  = false,
          Enchant                = false,
          EnchantOnUse           = false, -- no GUI option, should not be enabled. inherits from Use
          RequiredClasses_shaman = true,
          RequiredRaces          = false,
          Socket_red             = false,
          Socket_blue            = false,
          Socket_yellow          = false,
          Socket_purple          = false,
          Socket_green           = false,
          Socket_orange          = false,
          Socket_prismatic       = false,
          Socket_meta            = false,
          Socket_cogwheel        = false,
          Socket_hydraulic       = false,
          Equip                  = false, -- just to match Use
          ChanceOnHit            = false, -- just to match Use
          Use                    = false, -- because of EnchantOnUse
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
        
        overwriteSeparator = {
          ["."] = false,
          [","] = false,
        },
        separator = {
          ["."]              = ".",
          [","]              = " ",
          fourDigitException = false,
          separateDecimals   = false,
        },
        
        itemLevel = {
          ["*"]               = true,
          useShortName        = true,
          showWaylaidSupplies = true,
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
          Transmog        = true,
          Enchant         = true,
          EnchantOnUse    = false,
          WeaponEnchant   = true,
          Rune            = true,
          RequiredClasses = true,
        },
        icon = {
          ["*"]          = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\Samwise",
          Title          = "Interface\\ICONS\\INV_Misc_Wrench_01", -- should only show up when an item doesn't exist
          ItemLevel      = "Interface\\Transmogrify\\transmog-tooltip-arrow",
          TransmogHeader = "Interface\\MINIMAP\\TRACKING\\Transmogrifier",
          Transmog       = "Interface\\MINIMAP\\TRACKING\\Transmogrifier",
          AlreadyBound   = "Interface\\PetBattles\\PetBattle-LockIcon",
          CharacterBound = "Interface\\PetBattles\\PetBattle-LockIcon",
          AccountBound   = "Interface\\PetBattles\\PetBattle-LockIcon",
          Tradeable      = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
          Armor          = Addon.retailTexturesPath .. "ICONS\\Garrison_BlueArmor",
          BonusArmor     = Addon.retailTexturesPath .. "ICONS\\Garrison_GreenArmorUpgrade",
          Block          = "Interface\\ICONS\\INV_Shield_09",
          Enchant        = "Interface\\Buttons\\UI-GroupLoot-DE-Up",
          WeaponEnchant  = "Interface\\CURSOR\\Attack",
          Rune           = "Interface\\ICONS\\INV_Misc_Rune_06",
          EnchantOnUse   = "Interface\\Buttons\\UI-GroupLoot-DE-Up",
          Durability     = "Interface\\MINIMAP\\TRACKING\\Repair",
          Equip          = "Interface\\Tooltips\\ReforgeGreenArrow",
          ChanceOnHit    = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
          Use            = "Interface\\CURSOR\\Cast",
          Reputation     = "Interface\\COMMON\\friendship-heart",
          
        },
        iconSizeManual = {
          ["*"] = false,
          Title = true,
          Rune  = true,
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
            ["*"]         = false,
            BaseStat      = false,
            SecondaryStat = true,
            Enchant       = true,
            WeaponEnchant = true,
            Socket        = true,
            SetBonus      = true,
            BonusEffect   = true,
          },
          after = {
            ["*"]         = false,
            BaseStat      = false,
            SecondaryStat = true,
            Enchant       = true,
            WeaponEnchant = true,
            SocketBonus   = true,
            SetBonus      = true,
          },
        },
        padLastLine  = true,
        combineStats = true,
      },
      
      global = {
        -- Debug options
        debug = false,
        
        debugShowLuaErrors   = true,
        debugShowLuaWarnings = true,
        
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
          enabled = true,
          
          -- constructor = false,
          -- text        = false,
          -- stat        = false,
          
          constructorWipeDelay    = 5,   -- time in seconds without constructor being accessed before it's cleared
          constructorMinSeenCount = 3,   -- minimum number of times item must be seen (within wipe delay) before it can be cached
          constructorMinSeenTime  = 0.5, -- minimum time in seconds since item was first seen (within wipe delay) before it can be cached
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
