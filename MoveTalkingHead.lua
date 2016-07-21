-- Author: Ketho (EU-Boulderfist)
-- License: Public Domain

local NAME, S = ...
local L = S.L -- localization
local f = CreateFrame("Frame")
local db, THF, model

function f:OnEvent(event, addon)
	if event == "ADDON_LOADED" then
		if addon == NAME then
			MoveTalkingHeadDB = MoveTalkingHeadDB or {}
			db = MoveTalkingHeadDB -- init savedvars
		
		elseif addon == "Blizzard_TalkingHeadUI" then
			THF = TalkingHeadFrame
			model = THF.MainFrame.Model
			
			THF:SetMovable(true)
			THF:SetClampedToScreen(true)
			THF.ignoreFramePositionManager = true -- important
			--THF:SetUserPlaced(true) -- doesnt seem to help since its loadondemand
			
			THF:RegisterForDrag("LeftButton")
			
			THF:SetScript("OnDragStart", function(self)
				if IsModifierKeyDown() then -- ctrl/shift/alt
					self:StartMoving()
				end
			end)
			
			THF:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				local point, _, relPoint, dx, dy = self:GetPoint()
				db.point = point -- save point
				db.relPoint = relPoint
				db.dx = dx
				db.dy = dy
			end)
			
			if db.point then -- set point
				THF:ClearAllPoints()
				THF:SetPoint(db.point, nil, db.relPoint, db.dx, db.dy)
			end
			
			if db.scale then -- set scale
				THF:SetScale(db.scale)
			end
		end
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

-- couldnt make this addon loadondemand because of the slash command
for i, v in ipairs({"mth", "movetalking", "movetalkinghead"}) do
	_G["SLASH_MOVETALKINGHEAD"..i] = "/"..v
end

SlashCmdList.MOVETALKINGHEAD = function(msg)
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
	elseif scale and scale <= 2 and scale >= 0.5 then -- sanitize
		db.scale = scale
		print(L.SET:format(scale))
		if THF then
			THF:SetScale(db.scale) -- set scale
			Model_ApplyUICamera(model, model.uiCameraID) -- update camera for new scale
		end
	else
		print(L.USAGE:format(msg, "[0.50 - 2.00]"))
	end
end
