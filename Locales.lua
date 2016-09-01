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
	--zhCN = {},
	zhTW = {
		RESET = "設定已經重置",
		SET = "目前的縮放大小是 %.2f",
		USAGE = "%s 不在有效的數字範圍 %s 以內",
	},
}

L.zhCN = L.zhTW

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
