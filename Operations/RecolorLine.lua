
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


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
    if line.type == "RedType" then
      if IsEquippableItem(tooltipData.id) and self:IsItemUsable(tooltipData.id) then
        if line.colorLeft == self.COLORS.RED then
          Recolor("left", "Trainable")
        end
        if line.colorRight == self.COLORS.RED then
          Recolor("right", "Trainable")
        end
      end
    elseif line.type == "Damage" then
      Recolor("left", "Damage")
      Recolor("right", "Speed")
    elseif line.type == "DamagePerSecond" then
      Recolor("left", "DamagePerSecond")
      Recolor("right", "Speedbar")
    elseif line.stat and (line.type == "BaseStat" or line.type == "SecondaryStat") then
      Recolor("left", line.stat)
    elseif line.prefix and not line.stat then
      local stat = self.prefixStats[line.prefix]
      if stat then
        Recolor("left", stat)
      end
    elseif self.statsInfo[line.type].color then
      Recolor("left", line.type)
    end
  elseif line.type == "DamagePerSecond" and line.rewordRight then
    line.recolorRight = self.COLORS.WHITE -- the speedbar default tooltip color is yellow but let's pretend it's white
  elseif line.type == "RequiredClasses" then
    -- Handled as a reword instead
  end
  
  if sides.left ~= line.realColor then
    line.recolorLeft = sides.left
  end
  if sides.right ~= line.colorRight then
    line.recolorRight = sides.right
  end
end