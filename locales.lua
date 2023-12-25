local addonName, addon = ...

local L = setmetatable({}, { __index = function(t, k)
  local v = tostring(k)
  rawset(t, k, v)
  return v
end })

addon.L = L

local LOCALE = GetLocale()

-- replace the parts after = if you want to help with localization
if LOCALE == "ruRU" then
  L["No Reputation with "] = "No Reputation with "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["%s (Lvl %d)"] = "%s (Lvl %d)"
  L[" (P%d)"] = " (P%d)"
  return
elseif LOCALE == "frFR" then
  L["No Reputation with "] = "No Reputation with "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["%s (Lvl %d)"] = "%s (Lvl %d)"
  L[" (P%d)"] = " (P%d)"
  return
elseif LOCALE == "deDE" then
  L["No Reputation with "] = "No Reputation with "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["%s (Lvl %d)"] = "%s (Lvl %d)"
  L[" (P%d)"] = " (P%d)"
  return
end
