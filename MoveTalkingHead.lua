-- Author: Ketho (EU-Boulderfist)
-- License: Public Domain

local NAME, S = ...
local L = S.L
local f = CreateFrame("Frame")
local db, THF, model

local function round(num, q)
	return floor(num*q + .5) / q
end

local function RemoveAnchor()
	for i, alertSubSystem in pairs(AlertFrame.alertFrameSubSystems) do
		if alertSubSystem.anchorFrame == THF then
			tremove(AlertFrame.alertFrameSubSystems, i)
			return 
		end
	end
end

function f:OnEvent(event, addon)
	if addon == NAME then
		MoveTalkingHeadDB = MoveTalkingHeadDB or {}
		db = MoveTalkingHeadDB
		
		THF = TalkingHeadFrame
		model = THF.MainFrame.Model

		THF:SetMovable(true)
		THF:SetClampedToScreen(true)
		THF.ignoreFramePositionManager = true -- important
		
		THF:RegisterForDrag("LeftButton")
		THF:SetScript("OnDragStart", function(self)
			if IsModifierKeyDown() then -- allow ctrl/shift/alt
				self:StartMoving() -- calls :SetUserPlaced() but we dont use that
			end
		end)
		THF:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			local point, _, relPoint, dx, dy = self:GetPoint()
			db.point = point
			db.relPoint = relPoint
			db.dx = dx
			db.dy = dy
			RemoveAnchor()
		end)

		THF:SetScript("OnMouseWheel", function(self, delta)
			if IsModifierKeyDown() then
				-- prefer it rounded if that helps anything
				local scale = round(self:GetScale(), 10^2) + (.05 * delta)
				scale = max(min(scale, 2), .5)
				if db.scale ~= scale then
					db.scale = scale
					self:SetScale(scale)
					Model_ApplyUICamera(model, model.uiCameraID)
				end
			end
		end)

		if db.point then
			THF:ClearAllPoints()
			THF:SetPoint(db.point, nil, db.relPoint, db.dx, db.dy)
			RemoveAnchor()
		end
		if db.scale then
			THF:SetScale(db.scale)
		end
		
		self:UnregisterEvent(event)
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

for i, v in ipairs({"mth", "movetalking", "movetalkinghead"}) do
	_G["SLASH_MOVETALKINGHEAD"..i] = "/"..v
end

function SlashCmdList.MOVETALKINGHEAD(msg)
	local scale = tonumber(msg)
	
	if msg == "reset" then
		wipe(db)
		print(L.RESET)
		if THF then
			THF:ClearAllPoints()
			THF:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 96)
			THF:SetScale(1)
			Model_ApplyUICamera(model, model.uiCameraID)
		end
	elseif scale and scale <= 2 and scale >= .5 then
		db.scale = scale
		print(L.SET:format(scale))
		if THF then
			THF:SetScale(db.scale)
			-- update model camera for new scale
			Model_ApplyUICamera(model, model.uiCameraID)
		end
	else
		print(L.USAGE:format(msg, "[0.50 - 2.00]"))
	end
end
