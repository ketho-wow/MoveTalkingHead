local _, S = ...

local L = {
	enUS = {
		RESET = "Settings have been reset",
		SET = "Current scale is now %.2f",
		USAGE = "%s is not in the valid range of %s",
	},
	deDE = {
		RESET = "Einstellungen wurden zurückgesetzt",
		SET = "Die momentane Skalierung beträgt %.2f",
		USAGE = "%s ist nicht im gültigen Bereich von %s",
	},
	esES = {
	},
	esMX = {
	},
	frFR = {
	},
	itIT = {
	},
	koKR = {
	},
	ptBR = {
	},
	ruRU = {
	},
	zhCN = {
	},
	zhTW = {
	},
}

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
