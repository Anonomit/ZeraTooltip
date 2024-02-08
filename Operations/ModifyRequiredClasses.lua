
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




local stat = "RequiredClasses"
function Addon:ModifyRequiredClasses(text)
  local reword  = self:GetOption("allow", "reword")
  local recolor = self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat)
  if not reword and not recolor then
    return text
  end
  
  local trim  = reword and self:GetOption("trimPunctuation", stat)
  local names = not reword or not self:GetOption("doReword", stat)
  local icons = reword and self:GetOption("doIcon", stat)
  if not (icons or names and (recolor or trim)) then
    return text
  end
  
  local subs = {}
  for matcher, className in pairs(self.classNames) do
    local sub = ""
    
    if names then
      if recolor then
        if self.isEra and self:GetOption("doRecolor", "RequiredClasses_shaman") then
          sub = Addon.classNamesColoredEra[matcher]
        else
          sub = Addon.classNamesColored[matcher]
        end
      else
        sub = className
      end
    end
    
    if icons then
      sub = self:InsertAtlas(sub, stat, Addon.classIconAtlases[matcher])
    end
    
    sub = " " .. sub
    table.insert(subs, {matcher, sub})
  end
  text = self:ChainGsub(text, unpack(subs))
  
  if trim then
    text = self:ChainGsub(text, {",", ""})
  end
  
  return text
end