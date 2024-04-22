
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strLower = string.lower
local strFind  = string.find


local noChargesPattern = Addon:ReversePattern(strLower(ITEM_SPELL_CHARGES_NONE))
local sides

local function Recolor(side, stat)
  if Addon:GetOption("doRecolor", stat) then
    sides[side] = Addon:GetOption("color", stat)
  end
end


function Addon:RecolorLine(tooltip, line, tooltipData)
  sides = {
    left  = line.colorLeft,
    right = line.colorRight,
  }
  
  if Addon:GetOption("allow", "recolor") then
    if line.type == "Quality" then
      Recolor("left", line.type)
    elseif line.type == "Binding" then
      Recolor("left", line.bindType)
    elseif line.type == "RedType" then
      if self.expansionLevel < self.expansions.cata then
        if IsEquippableItem(tooltipData.id) and self:IsItemUsable(tooltipData.id) then
          if line.colorLeft == self.COLORS.RED then
            Recolor("left", "Trainable")
          end
          if line.colorRight == self.COLORS.RED then
            Recolor("right", "Trainable")
          end
        end
      end
    elseif line.type == "Damage" then
      Recolor("left", "Damage")
      Recolor("right", "Speed")
    elseif line.type == "DamageBonus" then
      Recolor("left", "Damage")
    elseif line.type == "DamagePerSecond" then
      Recolor("left", "DamagePerSecond")
      -- Speed bar colored through rewording
    elseif line.stat and (line.type == "BaseStat" or line.type == "SecondaryStat") then
      Recolor("left", line.stat)
    -- elseif line.type == "Socket" then
    --   if line.colorLeft == self.COLORS.WHITE then
    --     local socketType = line.socketType
    --     if socketType then
    --       Recolor("left", socketType)
    --     end
    --   end
    elseif line.prefix and not line.stat then
      local stat = self.prefixStats[line.prefix]
      if stat then
        Recolor("left", stat)
      end
    elseif line.type == "RequiredClasses" then
      -- Handled as a reword instead
    elseif line.type == "Charges" then
      Recolor("left", strFind(line.textLeftTextStripped, noChargesPattern) and "NoCharges" or "Charges")
    elseif self.statsInfo[line.type].color then
      Recolor("left", line.type)
    end
  elseif line.type == "DamagePerSecond" and line.rewordRight then
    line.recolorRight = self.COLORS.WHITE -- the speedbar default tooltip color is yellow but let's pretend it's white
  end
  
  if sides.left ~= line.realColor then
    line.recolorLeft = sides.left
  end
  if sides.right ~= line.colorRight then
    line.recolorRight = sides.right
  end
end