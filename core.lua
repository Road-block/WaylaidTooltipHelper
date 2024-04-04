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
local AMOUNT_NEUTRAL, AMOUNT_FRIENDLY, AMOUNT_HONORED, AMOUNT_REVERED = 3000,6000,12000,21000
local FACTION_AZEROTH_COMMERCE, FACTION_DUROTAR_SUPPLY = 2586, 2587
local P1_LEVEL_CAP, P2_LEVEL_CAP, P3_LEVEL_CAP, P4_LEVEL_CAP = 25,40,50,60
local sodSeasonID = Enum.SeasonID.SeasonOfDiscovery or Enum.SeasonID.Placeholder
local sod_phases = {[P1_LEVEL_CAP]=1, [P2_LEVEL_CAP]=2, [P3_LEVEL_CAP]=3, [P4_LEVEL_CAP]=4} -- we know there's more phases after 60, will have to find another way
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isSoD = isClassic and C_Seasons and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason() == sodSeasonID
local SoD_Phase = isSoD and sod_phases[(GetEffectivePlayerMaxLevel())] or false

-- filled, unfilled, copper reward filled, copper unfilled, {numreq, itemrequired}, itemphase
-- itemrequired might need to be an array, guessing they'll do combo fills for higher tiers
local Supplies = {
  -- Phase 1 maxlevel:25
  [211331] = { 300, 0, 600, 100, { 20, 6290} }, --"Waylaid Supplies: Brilliant Smallfish"
  [210771] = { 300, 0, 600, 100, { 20, 2840} }, --"Waylaid Supplies: Copper Bars"
  [211315] = { 300, 0, 600, 100, { 14, 2318} }, --"Waylaid Supplies: Light Leather"
  [211316] = { 300, 0, 600, 100, { 20, 2447} }, --"Waylaid Supplies: Peacebloom"
  [211933] = { 300, 0, 600, 100, { 10, 2835} }, --"Waylaid Supplies: Rough Stone"
  [211317] = { 300, 0, 600, 100, { 20, 765} }, --"Waylaid Supplies: Silverleaf"
  [211332] = { 300, 0, 1500, 100, { 10, 2581} }, --"Waylaid Supplies: Heavy Linen Bandages"
  [211329] = { 300, 0, 1500, 100, { 20, 6888} }, --"Waylaid Supplies: Herb Baked Eggs"
  [211330] = { 300, 0, 1500, 100, { 20, 2680} }, --"Waylaid Supplies: Spiced Wolf Meat"
  [211320] = { 450, 0, 1500, 100, { 3, 3473} }, --"Waylaid Supplies: Runed Copper Pants"
  [211327] = { 450, 0, 1500, 100, { 6, 4343} }, --"Waylaid Supplies: Brown Linen Pants"
  [211328] = { 450, 0, 1500, 100, { 4, 6238} }, --"Waylaid Supplies: Brown Linen Robes"
  [211319] = { 450, 0, 1500, 100, { 6, 2847} }, --"Waylaid Supplies: Copper Shortswords"
  [211326] = { 450, 0, 1500, 100, { 3, 2300} }, --"Waylaid Supplies: Embossed Leather Vests"
  [211325] = { 450, 0, 1500, 100, { 5, 4237} }, --"Waylaid Supplies: Handstitched Leather Belts"
  [211934] = { 450, 0, 1500, 100, { 10, 929} }, --"Waylaid Supplies: Healing Potions"
  [211321] = { 450, 0, 1500, 100, { 2, 11287} }, --"Waylaid Supplies: Lesser Magic Wands"
  [211318] = { 450, 0, 1500, 100, { 20, 118} }, --"Waylaid Supplies: Minor Healing Potions"
  [211322] = { 450, 0, 1500, 100, { 2, 20744}, 5 }, --"Waylaid Supplies: Minor Wizard Oil"
  [211324] = { 450, 0, 1500, 100, { 3, 4362} }, --"Waylaid Supplies: Rough Boomsticks"
  [211323] = { 450, 0, 1500, 100, { 12, 4360} }, --"Waylaid Supplies: Rough Copper Bombs"
  [211819] = { 500, 0, 2000, 500, { 12, 2841} }, --"Waylaid Supplies: Bronze Bars"
  [211822] = { 500, 0, 2000, 500, { 20, 2453} }, --"Waylaid Supplies: Bruiseweed"
  [211837] = { 500, 0, 2000, 500, { 8, 5527} }, --"Waylaid Supplies: Goblin Deviled Clams"
  [211838] = { 500, 0, 2000, 500, { 15, 3531} }, --"Waylaid Supplies: Heavy Wool Bandages"
  [211821] = { 500, 0, 2000, 500, { 12, 2319} }, --"Waylaid Supplies: Medium Leather"
  [211820] = { 500, 0, 2000, 500, { 6, 2842} }, --"Waylaid Supplies: Silver Bars"
  [211836] = { 500, 0, 2000, 500, { 20, 6890} }, --"Waylaid Supplies: Smoked Bear Meat"
  [211835] = { 500, 0, 2000, 500, { 15, 21072} }, --"Waylaid Supplies: Smoked Sagefish"
  [211823] = { 500, 0, 2000, 500, { 20, 2452} }, --"Waylaid Supplies: Swiftthistle"
  [211831] = { 650, 0, 2000, 500, { 2, 2316} }, --"Waylaid Supplies: Dark Leather Cloaks"
  [211833] = { 650, 0, 2000, 500, { 4, 2587} }, --"Waylaid Supplies: Gray Woolen Shirts"
  [211824] = { 650, 0, 2000, 500, { 20, 3385} }, --"Waylaid Supplies: Lesser Mana Potions"
  [211828] = { 650, 0, 2000, 500, { 2, 20745}, 5 }, --"Waylaid Supplies: Minor Mana Oil"
  [211825] = { 650, 0, 2000, 500, { 3, 6350} }, --"Waylaid Supplies: Rough Bronze Boots"
  [211829] = { 650, 0, 2000, 500, { 12, 4374} }, --"Waylaid Supplies: Small Bronze Bombs"
  [211935] = { 800, 0, 3000, 500, { 15, 6373} }, --"Waylaid Supplies: Elixir of Firepower"
  [211832] = { 800, 0, 3000, 500, { 2, 4251} }, --"Waylaid Supplies: Hillman's Shoulders"
  [211830] = { 800, 0, 3000, 500, { 2, 5507} }, --"Waylaid Supplies: Ornate Spyglasses"
  [211834] = { 800, 0, 3000, 500, { 3, 5542} }, --"Waylaid Supplies: Pearl-clasped Cloaks"
  [211827] = { 800, 0, 3000, 500, { 1, 6339} }, --"Waylaid Supplies: Runed Silver Rods"
  [211826] = { 800, 0, 3000, 500, { 14, 15869} }, --"Waylaid Supplies: Silver Skeleton Keys"
  -- Phase 2 maxlevel: 40 -- incomplete data
  -- 30
  [215386] = {700, 0, 20000, 2000, { 6,3860} }, -- waylaid-supplies-mithril-bars
  [215387] = {700, 0, 20000, 2000, { 5,4235} }, -- waylaid-supplies-heavy-hide
  [215388] = {700, 0, 20000, 2000, { 10,4304} }, -- waylaid-supplies-thick-leather
  [215389] = {700, 0, 20000, 2000, { 16,3818} }, -- waylaid-supplies-fadeleaf
  [215390] = {700, 0, 20000, 2000, { 10,3358} }, -- waylaid-supplies-khadgars-whisker
  [215391] = {700, 0, 20000, 2000, { 8,3819} }, -- waylaid-supplies-wintersbite
  [215392] = {700, 0, 20000, 2000, { 8,8831} }, -- waylaid-supplies-purple-lotus
  [215400] = {700, 0, 20000, 2000, { 5,7966} }, -- waylaid-supplies-solid-grinding-stones
  [215413] = {700, 0, 20000, 2000, { 3,4334} }, -- waylaid-supplies-formal-white-shirts
  [215417] = {700, 0, 20000, 2000, { 10,3729} }, -- waylaid-supplies-soothing-turtle-bisque
  [215418] = {700, 0, 20000, 2000, { 5,17222} }, -- waylaid-supplies-spider-sausages
  [215419] = {700, 0, 20000, 2000, { 10,6451} }, -- waylaid-supplies-heavy-silk-bandages
  [215420] = {700, 0, 20000, 2000, { 40,4594} }, -- waylaid-supplies-rockscale-cod
  [215421] = {700, 0, 20000, 2000, { 7,6371} }, -- waylaid-supplies-fire-oil
  -- 35
  [215385] = {850, 0, 55000, 2000, { 4,3577} }, -- waylaid-supplies-gold-bars
  [215393] = {850, 0, 55000, 2000, { 16,1710} }, -- waylaid-supplies-greater-healing-potions
  [215395] = {850, 0, 55000, 2000, { 6,8949} }, -- waylaid-supplies-elixirs-of-agility
  [215398] = {850, 0, 55000, 2000, { 5,3835} }, -- waylaid-supplies-green-iron-bracers
  [215399] = {850, 0, 55000, 2000, { 3,7919} }, -- waylaid-supplies-heavy-mithril-gauntlets
  [215401] = {850, 0, 55000, 2000, { 2,4391} }, -- waylaid-supplies-compact-harvest-reaper-kits
  [215402] = {850, 0, 55000, 2000, { 8,4394} }, -- waylaid-supplies-big-iron-bombs
  [215403] = {850, 0, 55000, 2000, { 2,10546} }, -- waylaid-supplies-deadly-scopes
  [215407] = {850, 0, 55000, 2000, { 4,5964} }, -- waylaid-supplies-barbaric-shoulders
  [215408] = {850, 0, 55000, 2000, { 5,5966} }, -- waylaid-supplies-guardian-gloves
  [215411] = {850, 0, 55000, 2000, { 2,7377} }, -- waylaid-supplies-frost-leather-cloaks
  [215414] = {850, 0, 55000, 2000, { 4,7062} }, -- waylaid-supplies-crimson-silk-pantaloons
  [215415] = {850, 0, 55000, 2000, { 5,4335} }, -- waylaid-supplies-rich-purple-silk-shirts
  -- 40
  [215394] = {1000, 0, 120000, 2000, { 10,4942} }, -- waylaid-supplies-lesser-stoneshield-potions
  [215396] = {1000, 0, 120000, 2000, { 14,8951} }, -- waylaid-supplies-elixirs-of-greater-defense
  [215397] = {1000, 0, 120000, 2000, { 2,3855} }, -- waylaid-supplies-massive-iron-axes
  [215404] = {1000, 0, 120000, 2000, { 2,10508} }, -- waylaid-supplies-mithril-blunderbuss
  [215409] = {1000, 0, 120000, 2000, { 2,8198} }, -- waylaid-supplies-turtle-scale-bracers
  [215410] = {1000, 0, 120000, 2000, { 3,7387} }, -- waylaid-supplies-dusky-belts
  [215416] = {1000, 0, 120000, 2000, { 3,10008} }, -- waylaid-supplies-white-bandit-masks
  -- unknown
  [215405] = {1000, 0, 120000, 2000, { 1,17024} }, -- waylaid-supplies-gnomish-rocket-boots
  [215406] = {1000, 0, 120000, 2000, { 1,10577} }, -- waylaid-supplies-goblin-mortars
  [215412] = {1000, 0, 120000, 2000, { 1,18238} }, -- waylaid-supplies-shadowskin-gloves
  -- Phase 3 maxlevel: 50
  --45
  [220918] = {950, 0, 38500, 5000, { 16, 16766} }, -- Waylaid Supplies: Undermine Clam Chowder:
  [220919] = {950, 0, 38500, 5000, { 8, 13931} }, -- Waylaid Supplies: Nightfin Soup:
  [220920] = {950, 0, 38500, 5000, { 12, 18045} }, -- Waylaid Supplies: Tender Wolf Steaks:
  [220921] = {950, 0, 38500, 5000, { 14, 8545} }, -- Waylaid Supplies: Heavy Mageweave Bandages:
  [220922] = {950, 0, 38500, 5000, { 15, 8838} }, -- Waylaid Supplies: Sungrass:
  [220923] = {950, 0, 38500, 5000, { 6, 13463} }, -- Waylaid Supplies: Dreamfoil:
  [220924] = {950, 0, 38500, 5000, { 12, 6037} }, -- Waylaid Supplies: Truesilver Bars:
  [220925] = {950, 0, 38500, 5000, { 16, 12359} }, -- Waylaid Supplies: Thorium Bars:
  [220926] = {950, 0, 38500, 5000, { 14, 8170} }, -- Waylaid Supplies: Rugged Leather:
  [220927] = {950, 0, 38500, 5000, { 8, 8169} }, -- Waylaid Supplies: Thick Hide:
  --mid
  [220928] = {1300, 0, 84500, 5000, { 4, 12655} }, -- Waylaid Supplies: Enchanted Thorium Bars:
  [220929] = {1300, 0, 84500, 5000, { 6, 13443} }, -- Waylaid Supplies: Superior Mana Potions:
  [220930] = {1300, 0, 84500, 5000, { 8, 13446} }, -- Waylaid Supplies: Major Healing Potions:
  [220931] = {1300, 0, 84500, 5000, { 16, 10562} }, -- Waylaid Supplies: Hi-Explosive Bombs:
  [220932] = {1300, 0, 84500, 5000, { 3, 15993} }, -- Waylaid Supplies: Thorium Grenades:
  [220934] = {1300, 0, 84500, 5000, { 3, 7931} }, -- Waylaid Supplies: Mithril Coifs:
  [220935] = {1300, 0, 84500, 5000, { 5, 12406} }, -- Waylaid Supplies: Thorium Belts:
  [220937] = {1300, 0, 84500, 5000, { 12, 15564} }, -- Waylaid Supplies: Rugged Armor Kits:
  [220938] = {1300, 0, 84500, 5000, { 6, 15084} }, -- Waylaid Supplies: Wicked Leather Bracers:
  [220940] = {1300, 0, 84500, 5000, { 5, 10024} }, -- Waylaid Supplies: Black Mageweave Headbands:
  [220942] = {1300, 0, 84500, 5000, { 4, 10034} }, -- Waylaid Supplies: Tuxedo Shirts:
  --top (speculative)
  [220933] = {1650, 0, 160000, 5000, { 2, 15995} }, -- Waylaid Supplies: Thorium Rifles:
  [220936] = {1650, 0, 160000, 5000, { 2, 7938} }, -- Waylaid Supplies: Truesilver Gauntlets:
  [220939] = {1650, 0, 160000, 5000, { 5, 15092} }, -- Waylaid Supplies: Runic Leather Bracers:
  [220941] = {1650, 0, 160000, 5000, { 6, 13856} }, -- Waylaid Supplies: Runecloth Belts:
}
-- questlevel, rep, money, exp
local Filled = {
  -- Phase 1
  --[2589] = {5, 200, 400, 80}, -- debug
  [211365] = { 9, 300, 600, 105 },
  [211368] = { 9, 300, 600, 105 },
  [211367] = { 12, 450, 1500, 120 },
  [211839] = { 18, 500, 1500, 195 },
  [211840] = { 22, 650, 2000, 240 },
  [211841] = { 25, 800, 3000, 270 },
  -- Phase 2 : possibly incomplete
  [217337] = { 28, 700, 20000, 850 }, -- values will need discovery when quests are available
  [217338] = { 35, 850, 55000, 1550 }, -- values will need discovery when quests are available
  [217339] = { 40, 1000, 120000, 3000 }, -- values will need discovery when quests are available
  -- Phase 3 : only have some info for lowest tier
  [221008] = { 42, 950, 38500, 1},
  [221009] = { 45, 1300, 84500, 1},
  [221010] = { 50, 1650, 160000, 1}, -- speculative
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
local levelToStanding = {
  [10] = _G["FACTION_STANDING_LABEL"..FACTION_NEUTRAL]..KEY_PLUS,
  [25] = _G["FACTION_STANDING_LABEL"..FACTION_FRIENDLY]..KEY_PLUS,
  [30] = _G["FACTION_STANDING_LABEL"..FACTION_HONORED]..KEY_PLUS, -- speculated, might be partial
  [35] = _G["FACTION_STANDING_LABEL"..FACTION_HONORED]..KEY_PLUS, -- speculated, might be partial
  [40] = _G["FACTION_STANDING_LABEL"..FACTION_HONORED]..KEY_PLUS,
  [45] = _G["FACTION_STANDING_LABEL"..FACTION_REVERED]..KEY_PLUS,
  [50] = _G["FACTION_STANDING_LABEL"..FACTION_REVERED]..KEY_PLUS,
  [60] = _G["FACTION_STANDING_LABEL"..FACTION_EXALTED]..KEY_PLUS, -- ??
}
local levelToStandingID = {
  [10] = FACTION_NEUTRAL,
  [25] = FACTION_FRIENDLY,
  [30] = FACTION_HONORED, -- speculated, might be partial
  [35] = FACTION_HONORED, -- speculated, might be partial
  [40] = FACTION_HONORED,
  [45] = FACTION_REVERED,
  [50] = FACTION_REVERED,
  [60] = FACTION_EXALTED,
}
local levelToStandingEarned = {
  [10] = AMOUNT_NEUTRAL,
  [25] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY,
  [30] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED,
  [35] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED,
  [40] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED,
  [45] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED+AMOUNT_REVERED,
  [50] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED+AMOUNT_REVERED,
  [60] = AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED+AMOUNT_REVERED,
}
local standingToPhase = {
  [FACTION_FRIENDLY] = 1, -- capped at start honored
  [FACTION_HONORED] = 2, -- capped at start revered
  [FACTION_REVERED] = 3, -- capped at start exalted ??
  [FACTION_EXALTED] = 4, -- ??
}
local phaseToStanding = {
  [1] = FACTION_FRIENDLY,
  [2] = FACTION_HONORED,
  [3] = FACTION_REVERED,
  [4] = FACTION_EXALTED,
}

local tomtomOpt = {
  desc = L["A Full Shipment"],
  title = L["Supply Officer"],
  from = addonName,
  persistent = false,
  silent = true,
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
  if not mapID and SoD_Phase then return end
  if not self.db.alert then return end
  local repCapped = self._standing and standingToPhase[self._standing] and (standingToPhase[self._standing] > SoD_Phase)
  -- if repCapped then return end
  local alertOption = self.db.alert
  local tomtomOption = self.db.tomtom
  if UnitOnTaxi("player") then return end
  if mapID then
    local turninInfo = factionNPCS[self._supplyFaction][mapID]
    if turninInfo then
      local supplyOfficer,npcid,map_x,map_y = unpack(turninInfo,1,4)
      local filledSupply = self:HaveFilledSupply()
      local emptySupply = self:HaveEmptySupply()
      if filledSupply or emptySupply then
        local now = GetTime()
        if not self._lastAlert or (now-self._lastAlert) > 30 then
          self._lastAlert = now
          if repCapped then
            addon:Print(format(L["You carry %s items but your P%d rep is maxed."],self._factionName, SoD_Phase))
          else
            PlaySound(SOUNDKIT.UI_STORE_UNWRAP)
            if emptySupply and (alertOption==true or alertOption=="empty") then
              RaidNotice_AddMessage(RaidBossEmoteFrame, format(L["You have %s"],emptySupply),ChatTypeInfo["RAID_WARNING"], 10)
              addon:Print(format(L["You have %s"],emptySupply))
            end
            if filledSupply and (alertOption==true or alertOption=="filled") then
              RaidNotice_AddMessage(RaidBossEmoteFrame, format(L["You can turn-in %s to %s"],filledSupply,supplyOfficer),ChatTypeInfo["RAID_WARNING"], 10)
              addon:Print(format(L["You can turn-in %s to %s"],filledSupply,supplyOfficer))
              if self.AddWaypoint then
                if self._alertWaypoint then
                  self.RemoveWaypoint(TomTom,self._alertWaypoint) -- cleanup old waypoint
                end
                if tomtomOption then
                  tomtomOpt.title = supplyOfficer
                  self._alertWaypoint = self.AddWaypoint(TomTom,mapID,map_x/100,map_y/100,tomtomOpt)
                end
              end
            end
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

function addon:factionMath(earned, bracketmin, bracketmax, isID)
  local standing, placement -- placement values: -1 lower than bracketmin, 0 between brackets, 1 higher
  if earned > AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED+AMOUNT_REVERED then
    standing = FACTION_EXALTED
  elseif earned > AMOUNT_NEUTRAL+AMOUNT_FRIENDLY+AMOUNT_HONORED then
    standing = FACTION_REVERED
  elseif earned > AMOUNT_NEUTRAL+AMOUNT_FRIENDLY then
    standing = FACTION_HONORED
  elseif earned > AMOUNT_NEUTRAL then
    standing = FACTION_FRIENDLY
  elseif earned >= 0 then
    standing = FACTION_NEUTRAL
  end
  if bracketmin and bracketmax then
    if earned < bracketmin then
      placement = -1
    elseif earned > bracketmax then
      placement = 1
    elseif bracketmin <= earned and earned <= bracketmax then
      placement = 0
    end
  end
  return standing, placement
end

function addon:CacheItems()
  self.supplyCache = self.supplyCache or {}
  self.needCache = self.needCache or {}
  self.filledCache = self.filledCache or {}
  for k, v in pairs(Supplies) do
    local id = GetItemInfoInstant(k)
    if id then -- valid item for this version of the game
      local neededItem = v[5]
      local moneyFilled = v[3]
      local neededNum, neededItemID = unpack(neededItem,1,2)
      self.needCache[neededItemID]=id -- item needed for filling, supply
      local itemAsync = Item:CreateFromItemID(id)
      itemAsync:ContinueOnItemLoad(function()
        local itemLevel = itemAsync:GetCurrentItemLevel()
        local itemName = itemAsync:GetItemName()
        local itemID = itemAsync:GetItemID()
        addon.supplyCache[itemID] = {itemName,itemLevel,neededNum,moneyFilled}
      end)
    end
  end
  for k,v in pairs(Filled) do
    local id = GetItemInfoInstant(k)
    if id then
      local itemAsync = Item:CreateFromItemID(k)
      itemAsync:ContinueOnItemLoad(function()
        local itemLevel = itemAsync:GetCurrentItemLevel()
        local itemName = itemAsync:GetItemName()
        local itemID = itemAsync:GetItemID()
        addon.filledCache[itemID] = {itemName,itemLevel}
      end)
    end
  end
end

function addon:HaveFilledSupply(withRep)
  for item,info in pairs(Filled) do
    local count = GetItemCount(item, true) -- include bank, we'll only trigger in town anyway
    if count > 0 then
      local itemName, itemLevel = unpack(addon.filledCache[item])
      if not withRep then
        return itemName
      else
        local itemFactionLevel = levelToStandingID[itemLevel]
        if not (self._standing > itemFactionLevel) then
          return itemName
        end
      end
    end
  end
  return false
end

function addon:HaveEmptySupply(withRep)
  for item,info in pairs(Supplies) do
    local count = GetItemCount(item, true)
    if count > 0 then
      local itemName, itemLevel = unpack(addon.supplyCache[item])
      if not withRep then
        return itemName
      else
        local itemFactionLevel = levelToStandingID[itemLevel]
        if not (self._standing > itemFactionLevel) then
          return itemName
        end
      end
    end
  end
  return false
end

function addon:CalculateRewards(questlevel, xp)
  local greenlevel = self._playerLevel - GetQuestGreenRange()
  local atlevelcap = self._playerLevel == self._playerMaxLevel
  --[[local hoardprotection
  if self._playerLevel >= P1_LEVEL_CAP and questlevel <= P1_LEVEL_CAP then
    hoardprotection = true
  elseif self._playerLevel >= P2_LEVEL_CAP and questlevel <= P2_LEVEL_CAP then
    hoardprotection = true
  elseif self._playerLevel >= P3_LEVEL_CAP and questlevel <= P3_LEVEL_CAP then
    hoardprotection = true
  end
  if hoardprotection then xp = 0 end]]
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
  -- remove extraMoney addition for now these quests seem to be exempt from levellocked xp>gold
  extraMoney = 0
  return questRep*(self._repMultiplier or 1), questMoney+extraMoney, realExp, itemLevel, itemName
end

function addon:AddTipInfo()
  local tooltip = self
  local self = addon
  local itemName, itemLink = tooltip:GetItem()
  local itemID = itemLink and itemLink:match("item:(%d+):")
  itemID = tonumber(itemID)
  if not (itemID and SoD_Phase) then return end
  local repFilled, repUnfilled, moneyFilled, moneyUnfilled, itemLevel, supplyName, supplyLevel
  local numNeeded, needItemPhase
  local noRep, givesRep, filledReward, unfilledReward, usedFor
  local questRep, questMoney, questExp, questItem
  local repCapped = self._standing and standingToPhase[self._standing] and (standingToPhase[self._standing] > SoD_Phase)
  local supply = Supplies[itemID]
  local needed = addon.needCache[itemID]
  local filled = Filled[itemID]
  if supply then
    repFilled, repUnfilled, moneyFilled, moneyUnfilled, itemLevel, needItemPhase = addon:SupplyDetails(itemID)
    if itemLevel then
      local itemRepDesc = levelToStanding[itemLevel]
      local itemFactionLevel = levelToStandingID[itemLevel]
      if self._standing > itemFactionLevel then -- too low for player standing, or gain capped
        noRep = RED_FONT_COLOR:WrapTextInColorCode(L["Too low for "]..addon._factionName)
      else
        givesRep = GREEN_FONT_COLOR:WrapTextInColorCode(addon._factionName)
        if needItemPhase and SoD_Phase < needItemPhase then
          filledReward = RED_FONT_COLOR:WrapTextInColorCode(L["Filled: +"]..repFilled..L[" Rep, "]..GetMoneyString(moneyFilled)..format(L[" (P%d)"],needItemPhase))
        else
          filledReward = L["Filled: +"]..repFilled..L[" Rep, "]..GetMoneyString(moneyFilled)
        end
        if repUnfilled > 0 or moneyUnfilled > 0 then
          unfilledReward = L["Unfilled: +"]..(repUnfilled>0 and repUnfilled or "")..(moneyUnfilled>0 and GetMoneyString(moneyUnfilled) or "")
        else
          unfilledReward = ""
        end
      end
      if givesRep then
        tooltip:AddDoubleLine(givesRep,itemRepDesc)
        if repCapped then
          tooltip:AddLine(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(format(L["P%d Rep Maxed"],SoD_Phase)))
        else
          tooltip:AddDoubleLine(filledReward,unfilledReward)
        end
      elseif noRep then
        tooltip:AddDoubleLine(noRep,itemRepDesc)
      end
    end
    return
  end
  if filled then
    questRep, questMoney, questExp, itemLevel, questItem = addon:FilledDetails(itemID)
    if itemLevel then
      local itemRepDesc = levelToStanding[itemLevel]
      local itemFactionLevel = levelToStandingID[itemLevel]
      if self._standing > itemFactionLevel then
        tooltip:AddLine(RED_FONT_COLOR:WrapTextInColorCode(L["No Rep, "])..format(L["+%d XP, "],questExp)..GetMoneyString(questMoney))
      else
        tooltip:AddDoubleLine(GREEN_FONT_COLOR:WrapTextInColorCode(addon._factionName),itemRepDesc)
        if repCapped then
          tooltip:AddLine(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(format(L["P%d Rep Maxed"],SoD_Phase)))
        else
          tooltip:AddLine(format(L["+%d Rep, "],questRep)..format(L["+%d XP, "],questExp)..GetMoneyString(questMoney))
        end
      end
    end
    return
  end
  if needed then
    supplyName, supplyLevel, numNeeded, moneyFilled = addon.supplyCache[needed][1], addon.supplyCache[needed][2], addon.supplyCache[needed][3], addon.supplyCache[needed][4]
    if supplyName then
      local itemRepDesc = levelToStanding[supplyLevel]
      tooltip:AddDoubleLine(GREEN_FONT_COLOR:WrapTextInColorCode(addon._factionName),format(L["Lvl %d (%s) %s"],supplyLevel,GetMoneyString(moneyFilled),itemRepDesc))
      tooltip:AddLine(YELLOW_FONT_COLOR:WrapTextInColorCode(format(L["x%d per [%s]"],numNeeded,supplyName)))
    end
    return
  end

end

function addon:SetupFaction()
  local _
  local factionEN, faction = UnitFactionGroup("player")
  if not self._supplyFaction then
    self._supplyFaction = (factionEN == "Horde") and FACTION_DUROTAR_SUPPLY or FACTION_AZEROTH_COMMERCE
  end
  if not (self._factionName and self._standing) then
    self._factionName, _, self._standing, _, _, self._earnedFaction = GetFactionInfoByID(self._supplyFaction)
  end
  if not self._repMultiplier then
    local race, raceEN, racedID = UnitRace("player")
    self._repMultiplier = (racedID and racedID == 1) and 1.1 or 1.0
  end
  self._playerLevel = UnitLevel("player")
  self._playerMaxLevel = GetEffectivePlayerMaxLevel()
  SoD_Phase = isSoD and sod_phases[self._playerMaxLevel] or false -- update, seems to return 60 on a cold login
  if not self._standing and SoD_Phase then
    return false
  end
  self:CacheItems()
  return true
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
    if WaylaidTooltipHelperSVPC.tomtom == nil then
      WaylaidTooltipHelperSVPC.tomtom = true
    end
    addon.db = WaylaidTooltipHelperSVPC
  end
end

function addon:PLAYER_LOGIN()
  local sod_check = self:SetupFaction()
  if not sod_check then return end
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
    local sod_check = self:SetupFaction()
    if not sod_check then return end
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
    _,_, self._standing, _,_, self._earnedFaction = GetFactionInfoByID(self._supplyFaction)
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
  local cmd, arg1, arg2 = option[1], option[2], option[3]
  if cmd=="alert" then
    if arg1 and #arg1>0 then
      if arg1 == "filled" or arg1 == "empty" then
        WaylaidTooltipHelperSVPC[cmd] = arg1
        addon:Print("Shipment Delivery Alerts: "..GREEN_FONT_COLOR:WrapTextInColorCode("ON")..format(" (%s)",WaylaidTooltipHelperSVPC.alert))
      end
    else
      WaylaidTooltipHelperSVPC[cmd] = not WaylaidTooltipHelperSVPC[cmd]
      addon:Print("Shipment Delivery Alerts: "..(WaylaidTooltipHelperSVPC.alert and GREEN_FONT_COLOR:WrapTextInColorCode("ON") or RED_FONT_COLOR:WrapTextInColorCode("OFF")))
    end
    if WaylaidTooltipHelperSVPC.alert then
      addon:ZONE_CHANGED_NEW_AREA()
    else
      if addon._alertWaypoint then
        addon.RemoveWaypoint(TomTom,addon._alertWaypoint)
      end
    end
  elseif cmd=="tomtom" then
    WaylaidTooltipHelperSVPC[cmd] = not WaylaidTooltipHelperSVPC[cmd]
    addon:Print("TomTom arrow:"..(WaylaidTooltipHelperSVPC.tomtom and GREEN_FONT_COLOR:WrapTextInColorCode("ON") or RED_FONT_COLOR:WrapTextInColorCode("OFF")))
    if not WaylaidTooltipHelperSVPC.tomtom and addon._alertWaypoint then
      addon.RemoveWaypoint(TomTom,addon._alertWaypoint)
    end
  end
  if not msg or msg == "" then
    addon:Print("/wtth alert [filled||empty]")
    addon:Print("  to toggle town shipment delivery alerts")
    addon:Print("/wtth tomtom")
    addon:Print("  to toggle TomTom arrow")
    addon:Print("alert: "..(WaylaidTooltipHelperSVPC.alert and GREEN_FONT_COLOR:WrapTextInColorCode("ON") or RED_FONT_COLOR:WrapTextInColorCode("OFF"))..(type(WaylaidTooltipHelperSVPC.alert)=="string" and format(" (%s)",WaylaidTooltipHelperSVPC.alert) or "")..",tomtom: "..(WaylaidTooltipHelperSVPC.tomtom and GREEN_FONT_COLOR:WrapTextInColorCode("ON") or RED_FONT_COLOR:WrapTextInColorCode("OFF")))
  end
end
_G["SLASH_"..addon_upper.."1"] = "/"..addon_lower
_G["SLASH_"..addon_upper.."2"] = "/wtth"
_G[addonName] = addon
