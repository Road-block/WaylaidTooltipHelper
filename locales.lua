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
  L["Too low for "] = "Too low for "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["Lvl %d %s (x%d)"] = "Lvl %d %s (x%d)"
  L[" (P%d)"] = " (P%d)"
  return
elseif LOCALE == "frFR" then
  L["Too low for "] = "Too low for "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["Lvl %d %s (x%d)"] = "Lvl %d %s (x%d)"
  L[" (P%d)"] = " (P%d)"
  return
elseif LOCALE == "deDE" then
  L["Too low for "] = "Too low for "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["Lvl %d %s (x%d)"] = "Lvl %d %s (x%d)"
  L[" (P%d)"] = " (P%d)"
  return
end
