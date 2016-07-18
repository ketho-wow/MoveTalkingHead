local NAME = ...
local f = CreateFrame("Frame")
local db, THF, model

-- update model camera for the new scale
local function ApplyUICamera()
	Model_ApplyUICamera(model, model.uiCameraID)
end

 -- distance fix, the face would clip out of the model with smaller scales
local function ValidateDistance()
	if db.scale <= .7 then
		local newScale = db.scale == .5 and 1.06 or 1.03 -- bit crude
		model:SetCameraDistance(model:GetCameraDistance() * newScale)
	end
end

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
				C_Timer.After(.1, ValidateDistance) -- camera is not yet set up
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
		print(format("%s: Settings have been reset", NAME))
		if THF then
			THF:ClearAllPoints()
			THF:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 96)
			THF:SetScale(1)
			ApplyUICamera()
		end
	elseif scale and scale <= 2 and scale >= 0.5 then -- sanitize
		db.scale = scale
		print(format("%s: Scale is now |cffFFFF00%.2f|r", NAME, scale))
		if THF then
			THF:SetScale(db.scale) -- set scale
			ApplyUICamera()
			ValidateDistance()
		end
	else
		print(format("|cffFF0000%s|r is not in the valid range of [0.50 - 2.00]. Current scale is |cffFFFF00%.2f|r", msg, db.scale))
	end
end
