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
  L["No Rep, "] = "No Rep, "
  L["+%d XP, "] = "+%d XP, "
  L["+%d Rep, "] = "+%d Rep, "
  L["P%d Rep Maxed"] = "P%d Rep Maxed"
  L["Lvl %d (%s) %s"] = "Lvl %d (%s) %s"
  L["You have %s"] = "You have %s"
  L["x%d per [%s]"] = "x%d per [%s]"
  L["You carry %s items but your P%d rep is maxed."] = "You carry %s items but your P%d rep is maxed."
  L["You can turn-in %s to %s"] = "You can turn-in %s to %s"
  L["Elaine Compton <Supply Officer>"] = "Илана Комптон <Интендант>"
  L["Tamelyn Aldridge <Supply Officer>"] = "Тамелин Альдридж <Интендант>"
  L["Marcy Baker <Supply Officer>"] = "Марси Бейкер <Интендант>"
  L["Dokimi <Supply Officer>"] = "Докими <Интендант>"
  L["Jornah <Supply Officer>"] = "Джорна <Интендант>"
  L["Gishah <Supply Officer>"] = "Гиша <Интендант>"
  return
elseif LOCALE == "frFR" then
  L["Too low for "] = "Too low for "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["Lvl %d %s (x%d)"] = "Lvl %d %s (x%d)"
  L[" (P%d)"] = " (P%d)"
  L["No Rep, "] = "No Rep, "
  L["+%d XP, "] = "+%d XP, "
  L["+%d Rep, "] = "+%d Rep, "
  L["You have %s"] = "You have %s"
  L["P%d Rep Maxed"] = "P%d Rep Maxed"
  L["Lvl %d (%s) %s"] = "Lvl %d (%s) %s"
  L["x%d per [%s]"] = "x%d per [%s]"
  L["You carry %s items but your P%d rep is maxed."] = "You carry %s items but your P%d rep is maxed."
  L["You can turn-in %s to %s"] = "You can turn-in %s to %s"
  L["Elaine Compton <Supply Officer>"] = "Elaine Compton <Officier de ravitaillement>"
  L["Tamelyn Aldridge <Supply Officer>"] = "Tamelyn Aldridge <Officière de ravitaillement>"
  L["Marcy Baker <Supply Officer>"] = "Marcy Fournier <Officière de ravitaillement>"
  L["Dokimi <Supply Officer>"] = "Dokimi <Officière de ravitaillement>"
  L["Jornah <Supply Officer>"] = "Jornah <Officière de ravitaillement>"
  L["Gishah <Supply Officer>"] = "Gishah <Officière de ravitaillement>"
  return
elseif LOCALE == "deDE" then
  L["Too low for "] = "Too low for "
  L["Unfilled: +"] = "Unfilled: +"
  L["Filled: +"] = "Filled: +"
  L[" Rep, "] = " Rep, "
  L["Lvl %d %s (x%d)"] = "Lvl %d %s (x%d)"
  L[" (P%d)"] = " (P%d)"
  L["No Rep, "] = "No Rep, "
  L["+%d XP, "] = "+%d XP, "
  L["+%d Rep, "] = "+%d Rep, "
  L["P%d Rep Maxed"] = "P%d Rep Maxed"
  L["Lvl %d (%s) %s"] = "Lvl %d (%s) %s"
  L["x%d per [%s]"] = "x%d per [%s]"
  L["You have %s"] = "You have %s"
  L["You carry %s items but your P%d rep is maxed."] = "You carry %s items but your P%d rep is maxed."
  L["You can turn-in %s to %s"] = "You can turn-in %s to %s"
  L["Elaine Compton <Supply Officer>"] = "Elaine Compton <Versorgungsoffizierin>"
  L["Tamelyn Aldridge <Supply Officer>"] = "Tamelyn Aldridge <Versorgungsoffizierin>"
  L["Marcy Baker <Supply Officer>"] = "Marcy Bäcker <Versorgungsoffizierin>"
  L["Dokimi <Supply Officer>"] = "Dokimi <Versorgungsoffizierin>"
  L["Jornah <Supply Officer>"] = "Jornah <Versorgungsoffizierin>"
  L["Gishah <Supply Officer>"] = "Gishah <Versorgungsoffizierin>"
  return
end
