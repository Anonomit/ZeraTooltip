
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub = string.gsub


local armorText   = ARMOR
local coveredText = Addon:CoverSpecialCharacters(armorText)
local emptyText   = armorText .. " *"

local stat = "Armor"
function Addon:RewordArmor(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, emptyText, alias)
      elseif alias ~= coveredText then
        text = strGsub(text, coveredText, alias)
      end
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end

local stat = "BonusArmor"
function Addon:RewordBonusArmor(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, emptyText, alias)
      elseif alias ~= coveredText then
        text = strGsub(text, coveredText, alias)
      end
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end