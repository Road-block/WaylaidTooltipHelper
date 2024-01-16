local addonName, addon = ...
local L = addon.L

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN") -- faction's not going to change during a play session, no reason to call it every tooltip show
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_FACTION") -- rep standing on the other hand can, but let's update only on relevant events
f:RegisterEvent("PLAYER_LEVEL_UP") -- xp to money conversion
f:RegisterEvent("ZONE_CHANGED_NEW_AREA") -- turnin alert
f:RegisterEvent("PLAYER_CONTROL_LOST") -- turnin alert
f:RegisterEvent("PLAYER_ALIVE") -- turnin alert
f:RegisterEvent("PLAYER_UNGHOST") -- turnin alert
f:RegisterEvent("ADDON_LOADED")
f.OnEvent = function(_,event,...)
  return addon[event] and addon[event](addon,...)
end
f:SetScript("OnEvent", f.OnEvent)

local COLOR_STRONG_CYAN = CreateColor(0,198/255,209/255)
addon.label = COLOR_STRONG_CYAN:WrapTextInColorCode(addonName)
addon.short = COLOR_STRONG_CYAN:WrapTextInColorCode("WttH")
local FACTION_NEUTRAL, FACTION_FRIENDLY, FACTION_HONORED, FACTION_REVERED, FACTION_EXALTED = 4,5,6,7,8
local FACTION_AZEROTH_COMMERCE, FACTION_DUROTAR_SUPPLY = 2586, 2587

local sodSeasonID = Enum.SeasonID.SeasonOfDiscovery or Enum.SeasonID.Placeholder
local sod_phases = {[25]=1, [40]=2, [50]=3, [60]=4} --
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isSoD = isClassic and C_Seasons and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason() == sodSeasonID
local SoD_Phase = isSoD and sod_phases[(GetEffectivePlayerMaxLevel())]

-- filled, unfilled, copper reward filled, copper unfilled, {numreq, itemrequired}, itemphase
-- itemrequired might need to be an array, guessing they'll do combo fills for higher tiers
local Supplies = {
  -- Phase 1 maxlevel:25
  [211331] = { 300, 100, 600, 100, { 20, 6290} }, --"Waylaid Supplies: Brilliant Smallfish"
  [210771] = { 300, 100, 600, 100, { 20, 2840} }, --"Waylaid Supplies: Copper Bars"
  [211315] = { 300, 100, 600, 100, { 14, 2318} }, --"Waylaid Supplies: Light Leather"
  [211316] = { 300, 100, 600, 100, { 20, 2447} }, --"Waylaid Supplies: Peacebloom"
  [211933] = { 300, 100, 600, 100, { 10, 2835} }, --"Waylaid Supplies: Rough Stone"
  [211317] = { 300, 100, 600, 100, { 20, 765} }, --"Waylaid Supplies: Silverleaf"
  [211332] = { 300, 100, 1500, 100, { 10, 2581} }, --"Waylaid Supplies: Heavy Linen Bandages"
  [211329] = { 300, 100, 1500, 100, { 20, 6888} }, --"Waylaid Supplies: Herb Baked Eggs"
  [211330] = { 300, 100, 1500, 100, { 20, 2680} }, --"Waylaid Supplies: Spiced Wolf Meat"
  [211320] = { 450, 100, 1500, 100, { 3, 3473} }, --"Waylaid Supplies: Runed Copper Pants"
  [211327] = { 450, 100, 1500, 100, { 6, 4343} }, --"Waylaid Supplies: Brown Linen Pants"
  [211328] = { 450, 100, 1500, 100, { 4, 6238} }, --"Waylaid Supplies: Brown Linen Robes"
  [211319] = { 450, 100, 1500, 100, { 6, 2847} }, --"Waylaid Supplies: Copper Shortswords"
  [211326] = { 450, 100, 1500, 100, { 3, 2300} }, --"Waylaid Supplies: Embossed Leather Vests"
  [211325] = { 450, 100, 1500, 100, { 5, 4237} }, --"Waylaid Supplies: Handstitched Leather Belts"
  [211934] = { 450, 100, 1500, 100, { 10, 929} }, --"Waylaid Supplies: Healing Potions"
  [211321] = { 450, 100, 1500, 100, { 2, 11287} }, --"Waylaid Supplies: Lesser Magic Wands"
  [211318] = { 450, 100, 1500, 100, { 20, 118} }, --"Waylaid Supplies: Minor Healing Potions"
  [211322] = { 450, 100, 1500, 100, { 2, 20744}, 5 }, --"Waylaid Supplies: Minor Wizard Oil"
  [211324] = { 450, 100, 1500, 100, { 3, 4362} }, --"Waylaid Supplies: Rough Boomsticks"
  [211323] = { 450, 100, 1500, 100, { 12, 4360} }, --"Waylaid Supplies: Rough Copper Bombs"
  [211819] = { 500, 200, 2000, 500, { 12, 2841} }, --"Waylaid Supplies: Bronze Bars"
  [211822] = { 500, 200, 2000, 500, { 20, 2453} }, --"Waylaid Supplies: Bruiseweed"
  [211837] = { 500, 200, 2000, 500, { 8, 5527} }, --"Waylaid Supplies: Goblin Deviled Clams"
  [211838] = { 500, 200, 2000, 500, { 15, 3531} }, --"Waylaid Supplies: Heavy Wool Bandages"
  [211821] = { 500, 200, 2000, 500, { 12, 2319} }, --"Waylaid Supplies: Medium Leather"
  [211820] = { 500, 200, 2000, 500, { 6, 2842} }, --"Waylaid Supplies: Silver Bars"
  [211836] = { 500, 200, 2000, 500, { 20, 8607} }, --"Waylaid Supplies: Smoked Bear Meat"
  [211835] = { 500, 200, 2000, 500, { 15, 21072} }, --"Waylaid Supplies: Smoked Sagefish"
  [211823] = { 500, 200, 2000, 500, { 20, 2452} }, --"Waylaid Supplies: Swiftthistle"
  [211831] = { 650, 200, 2000, 500, { 2, 2316} }, --"Waylaid Supplies: Dark Leather Cloaks"
  [211833] = { 650, 200, 2000, 500, { 4, 2587} }, --"Waylaid Supplies: Gray Woolen Shirts"
  [211824] = { 650, 200, 2000, 500, { 20, 3385} }, --"Waylaid Supplies: Lesser Mana Potions"
  [211828] = { 650, 200, 2000, 500, { 2, 20745}, 5 }, --"Waylaid Supplies: Minor Mana Oil"
  [211825] = { 650, 200, 2000, 500, { 3, 6350} }, --"Waylaid Supplies: Rough Bronze Boots"
  [211829] = { 650, 200, 2000, 500, { 12, 4374} }, --"Waylaid Supplies: Small Bronze Bombs"
  [211935] = { 800, 200, 3000, 500, { 15, 6373} }, --"Waylaid Supplies: Elixir of Firepower"
  [211832] = { 800, 200, 3000, 500, { 2, 4251} }, --"Waylaid Supplies: Hillman's Shoulders"
  [211830] = { 800, 200, 3000, 500, { 2, 5507} }, --"Waylaid Supplies: Ornate Spyglasses"
  [211834] = { 800, 200, 3000, 500, { 3, 5542} }, --"Waylaid Supplies: Pearl-clasped Cloaks"
  [211827] = { 800, 200, 3000, 500, { 1, 6339} }, --"Waylaid Supplies: Runed Silver Rods"
  [211826] = { 800, 200, 3000, 500, { 14, 15869} }, --"Waylaid Supplies: Silver Skeleton Keys"
  -- Future phases
}
-- questlevel, rep, money, exp
local Filled = {
  -- Phase 1
  --[2589] = {5, 200, 400, 80}, -- debug
  [211365] = { 9, 300, 600, 105 },
  [211367] = { 12, 450, 1500, 120 },
  [211839] = { 18, 500, 1500, 195 },
  [211840] = { 22, 650, 2000, 240 },
  [211841] = { 25, 800, 3000, 270 },
}
-- name, npcid, mapx, mapy
local factionNPCS = {
  [FACTION_AZEROTH_COMMERCE] = {
    [1453] = {L["Elaine Compton <Supply Officer>"], 213077, 54.8, 61.2}, -- Stormwind
    [1455] = {L["Tamelyn Aldridge <Supply Officer>"], 214099, 24.6, 67.6}, -- Ironforge
    [1457] = {L["Marcy Baker <Supply Officer>"], 214101, 59.8, 56.6}, -- Darnassus
  },
  [FACTION_DUROTAR_SUPPLY] = {
    [1456] = {L["Dokimi <Supply Officer>"], 214096, 39.6, 53.6}, -- Thunder Bluff
    [1454] = {L["Jornah <Supply Officer>"], 214070, 51.6, 63.8}, -- Orgrimmar
    [1458] = {L["Gishah <Supply Officer>"], 214098, 65.6, 38.2}, -- Undercity
  },
}

local tomtomOpt = {
  desc = L["A Full Shipment"],
  title = L["Supply Officer"],
  from = addonName,
  persistent = false,
  minimap = true,
  world = false,
  crazy = true,
  cleardistance = 10,
  arrivaldistance = 5,
}

function addon:Print(msg)
  local chatFrame = (SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME)
  chatFrame:AddMessage(format("%s: %s",self.short,msg))
end

function addon:Alert(mapID)
  if not self.db.alert then return end
  if UnitOnTaxi("player") then return end
  if mapID then
    local turninInfo = factionNPCS[self._supplyFaction][mapID]
    if turninInfo then
      local supplyOfficer,npcid,map_x,map_y = unpack(turninInfo,1,4)
      local filledSupply = self:HaveFilledSupply()
      if filledSupply then
        local now = GetTime()
        if not self._lastAlert or (now-self._lastAlert) > 30 then
          self._lastAlert = now
          PlaySound(SOUNDKIT.UI_STORE_UNWRAP)
          RaidNotice_AddMessage(RaidBossEmoteFrame, format(L["You can turn-in %s to %s"],filledSupply,supplyOfficer),ChatTypeInfo["RAID_WARNING"], 10)
          addon:Print(format(L["You can turn-in %s to %s"],filledSupply,supplyOfficer))
          if self.AddWaypoint then
            if self._alertWaypoint then
              self.RemoveWaypoint(TomTom,self._alertWaypoint) -- cleanup old waypoint
            end
            tomtomOpt.title = supplyOfficer
            self._alertWaypoint = self.AddWaypoint(TomTom,mapID,map_x/100,map_y/100,tomtomOpt)
          end
        end
      end
    else
      if self._alertWaypoint then
        self.RemoveWaypoint(TomTom,self._alertWaypoint) -- cleanup if we left town
      end
    end
  end
end

function addon:CacheItems()
  self.supplyCache = self.supplyCache or {}
  self.needCache = self.needCache or {}
  self.filledCache = self.filledCache or {}
  for k, v in pairs(Supplies) do
    local neededItem = v[5]
    local neededNum, neededItemID = unpack(neededItem,1,2)
    self.needCache[neededItemID]=k -- item needed for filling, supply
    local itemAsync = Item:CreateFromItemID(k)
    itemAsync:ContinueOnItemLoad(function()
      local itemLevel = itemAsync:GetCurrentItemLevel()
      local itemName = itemAsync:GetItemName()
      local itemID = itemAsync:GetItemID()
      addon.supplyCache[itemID] = {itemName,itemLevel,neededNum}
    end)
  end
  for k,v in pairs(Filled) do
    local itemAsync = Item:CreateFromItemID(k)
    itemAsync:ContinueOnItemLoad(function()
      local itemLevel = itemAsync:GetCurrentItemLevel()
      local itemName = itemAsync:GetItemName()
      local itemID = itemAsync:GetItemID()
      addon.filledCache[itemID] = {itemName,itemLevel}
    end)
  end
end

function addon:HaveFilledSupply()
  for item,info in pairs(Filled) do
    local count = GetItemCount(item, true) -- include bank, we'll only trigger in town anyway
    if count > 0 then
      return addon.filledCache[item][1]
    end
  end
  return false
end

function addon:CalculateRewards(questlevel, xp)
  local greenlevel = self._playerLevel - GetQuestGreenRange()
  local atlevelcap = self._playerLevel == self._playerMaxLevel
  local extraMoney, realXP = 0, xp
  if questlevel >= greenlevel then -- green or higher quest
    if atlevelcap then
      extraMoney = xp * 6
      return 0, extraMoney
    else
      return xp, 0
    end
  else -- gray
    local diff = greenlevel - questlevel
    if diff > 5 then
      realXP = 0
    elseif diff > 4 then
      realXP = Round(xp*0.1)
    elseif diff > 3 then
      realXP = Round(xp*0.2)
    elseif diff > 2 then
      realXP = Round(xp*0.4)
    elseif diff > 1 then
      realXP = Round(xp*0.6)
    else
      realXP = Round(xp*0.8)
    end
    if atlevelcap then
      extraMoney = realXP * 6
      return 0, extraMoney
    else
      return realXP, 0
    end
  end
  return realXP, extraMoney
end

function addon:SupplyDetails(supplyID)
  local staticInfo = Supplies[supplyID]
  if not staticInfo then return end -- not a waylaid supply package we know
  local dynamicInfo = self.supplyCache[supplyID]
  if not dynamicInfo then return end
  local repFilled, repUnfilled, moneyFilled, moneyUnfilled, neededItem, needItemPhase = unpack(staticInfo,1,6)
  local itemLevel = dynamicInfo[2]
  return repFilled*(self._repMultiplier or 1), repUnfilled*(self._repMultiplier or 1), moneyFilled, moneyUnfilled, itemLevel, needItemPhase
end

function addon:FilledDetails(supplyID)
  local staticInfo = Filled[supplyID]
  if not staticInfo then return end
  local dynamicInfo = self.filledCache[supplyID]
  if not dynamicInfo then return end
  local questLevel, questRep, questMoney, questExp = unpack(staticInfo,1,4)
  local itemName, itemLevel = dynamicInfo[1], dynamicInfo[2]
  local realExp, extraMoney = self:CalculateRewards(questLevel,questExp)
  return questRep*(self._repMultiplier or 1), questMoney+extraMoney, realExp, itemLevel, itemName
end

function addon:AddTipInfo()
  local tooltip = self
  local self = addon
  local itemName, itemLink = tooltip:GetItem()
  local itemID = itemLink and itemLink:match("item:(%d+):")
  itemID = tonumber(itemID)
  local repFilled, repUnfilled, moneyFilled, moneyUnfilled, itemLevel, supplyName, supplyLevel
  local numNeeded, needItemPhase
  local noRep, givesRep, filledReward, unfilledReward, usedFor
  local questRep, questMoney, questExp, questItem
  if itemID then
    local supply = Supplies[itemID]
    local needed = addon.needCache[itemID]
    local filled = Filled[itemID]
    if supply then
      repFilled, repUnfilled, moneyFilled, moneyUnfilled, itemLevel, needItemPhase = addon:SupplyDetails(itemID)
      if itemLevel then
        if itemLevel < addon._threshold then
          noRep = RED_FONT_COLOR:WrapTextInColorCode(L["Too low for "]..addon._factionName)
        else
          givesRep = GREEN_FONT_COLOR:WrapTextInColorCode(addon._factionName..": ")
          if needItemPhase and SoD_Phase < needItemPhase then
            filledReward = RED_FONT_COLOR:WrapTextInColorCode(L["Filled: +"]..repFilled..L[" Rep, "]..GetMoneyString(moneyFilled)..format(L[" (P%d)"],needItemPhase))
          else
            filledReward = L["Filled: +"]..repFilled..L[" Rep, "]..GetMoneyString(moneyFilled)
          end
          unfilledReward = L["Unfilled: +"]..repUnfilled..L[" Rep, "]..GetMoneyString(moneyUnfilled)
        end
        if givesRep then
          tooltip:AddDoubleLine(givesRep..filledReward,unfilledReward)
        elseif noRep then
          tooltip:AddLine(noRep)
        end
      end
      return
    end
    if filled then
      questRep, questMoney, questExp, itemLevel, questItem = addon:FilledDetails(itemID)
      if itemLevel then
        if itemLevel < addon._threshold then
          tooltip:AddDoubleLine(GREEN_FONT_COLOR:WrapTextInColorCode(addon._factionName),RED_FONT_COLOR:WrapTextInColorCode(L[" No Rep, "])..format(L["XP: %d, "],questExp)..GetMoneyString(questMoney))
        else
          tooltip:AddDoubleLine(GREEN_FONT_COLOR:WrapTextInColorCode(addon._factionName),format(L["+%d Rep, "],questRep)..format(L["XP: %d, "],questExp)..GetMoneyString(questMoney))
        end
      end
      return
    end
    if needed then
      supplyName, supplyLevel, numNeeded = addon.supplyCache[needed][1], addon.supplyCache[needed][2], addon.supplyCache[needed][3]
      if supplyName then
        usedFor = YELLOW_FONT_COLOR:WrapTextInColorCode(format(L["Lvl %d %s (x%d)"],supplyLevel,supplyName,numNeeded))
      end
      if usedFor then
        tooltip:AddDoubleLine(addon._factionName,usedFor)
      end
      return
    end
  end
end

function addon:SetupFaction()
  local _
  local factionEN, faction = UnitFactionGroup("player")
  if not self._supplyFaction then
    self._supplyFaction = (factionEN == "Horde") and FACTION_DUROTAR_SUPPLY or FACTION_AZEROTH_COMMERCE
  end
  if not (self._factionName and self._standing) then
    self._factionName, _, self._standing = GetFactionInfoByID(self._supplyFaction)
    self._threshold = (self._standing < FACTION_FRIENDLY) and 10 or (self._standing < FACTION_HONORED) and 25 or (self._standing < FACTION_REVERED) and 40 or (self._standing < FACTION_EXALTED) and 50 or 60
  end
  if not self._repMultiplier then
    local race, raceEN, racedID = UnitRace("player")
    self._repMultiplier = (racedID and racedID == 1) and 1.1 or 1.0
  end
  self._playerLevel = UnitLevel("player")
  self._playerMaxLevel = GetEffectivePlayerMaxLevel()
  self:CacheItems()
end

function addon:ADDON_LOADED(...)
  if ... == "TomTom" then
    if not self.AddWaypoint and TomTom.AddWaypoint then
      self.AddWaypoint = TomTom.AddWaypoint
    end
    if not self.RemoveWaypoint and TomTom.RemoveWaypoint then
      self.RemoveWaypoint = TomTom.RemoveWaypoint
    end
  end
  if ... == addonName then
    WaylaidTooltipHelperSVPC = WaylaidTooltipHelperSVPC or {alert=true}
    addon.db = WaylaidTooltipHelperSVPC
  end
end

function addon:PLAYER_LOGIN()
  self:SetupFaction()
  -- install our hook
  GameTooltip:HookScript("OnTooltipSetItem", self.AddTipInfo)
  ItemRefTooltip:HookScript("OnTooltipSetItem", self.AddTipInfo)
  -- optional TomTom use
  if TomTom then
    if TomTom.AddWaypoint then
      self.AddWaypoint = TomTom.AddWaypoint
    end
    if TomTom.RemoveWaypoint then
      self.RemoveWaypoint = TomTom.RemoveWaypoint
    end
  end
end

function addon:PLAYER_ENTERING_WORLD(...)
  local isLogin, isReload = ...
  if isLogin or isReload then
    self:SetupFaction()
  end
  local mapID = C_Map.GetBestMapForUnit("player")
  self:Alert(mapID)
  if UnitOnTaxi("player") then
    f:RegisterEvent("PLAYER_CONTROL_GAINED")
  end
end

function addon:UPDATE_FACTION()
  local _
  if self._supplyFaction then
    _,_, self._standing = GetFactionInfoByID(self._supplyFaction)
    self._threshold = (self._standing < FACTION_FRIENDLY) and 10 or (self._standing < FACTION_HONORED) and 25 or (self._standing < FACTION_REVERED) and 40 or (self._standing < FACTION_EXALTED) and 50 or 60
  end
end

function addon:PLAYER_LEVEL_UP()
  self._playerLevel = UnitLevel("player")
  self._playerMaxLevel = GetEffectivePlayerMaxLevel()
end

function addon:ZONE_CHANGED_NEW_AREA()
  local mapID = C_Map.GetBestMapForUnit("player")
  self:Alert(mapID)
end
addon.PLAYER_UNGHOST = addon.ZONE_CHANGED_NEW_AREA
addon.PLAYER_ALIVE = addon.ZONE_CHANGED_NEW_AREA

function addon:PLAYER_CONTROL_LOST()
  C_Timer.After(1,function()
    if UnitOnTaxi("player") then
      f:RegisterEvent("PLAYER_CONTROL_GAINED")
    end
  end)
end
function addon:PLAYER_CONTROL_GAINED()
  f:UnregisterEvent("PLAYER_CONTROL_GAINED")
  C_Timer.After(1,function()
    addon:ZONE_CHANGED_NEW_AREA()
  end)
end

local addon_upper, addon_lower = addonName:upper(), addonName:lower()
SlashCmdList[addon_upper] = function(msg)
  local option = {}
  msg = (msg or ""):trim()
  msg = msg:lower()
  for token in msg:gmatch("(%S+)") do
    tinsert(option,token)
  end
  if option[1]=="alert" then
    WaylaidTooltipHelperSVPC[option[1]] = not WaylaidTooltipHelperSVPC[option[1]]
    addon:Print("Shipment Delivery Alerts: "..(WaylaidTooltipHelperSVPC.alert and GREEN_FONT_COLOR:WrapTextInColorCode"ON" or RED_FONT_COLOR:WrapTextInColorCode("OFF")))
    if WaylaidTooltipHelperSVPC.alert then
      addon:ZONE_CHANGED_NEW_AREA()
    else
      if addon._alertWaypoint then
        addon.RemoveWaypoint(TomTom,addon._alertWaypoint)
      end
    end
  end
  if not msg or msg == "" then
    addon:Print("/wtth alert")
    addon:Print("  to toggle town shipment delivery alerts")
  end
end
_G["SLASH_"..addon_upper.."1"] = "/"..addon_lower
_G["SLASH_"..addon_upper.."2"] = "/wtth"
--_G[addonName] = addon
