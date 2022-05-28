local f = CreateFrame("Frame");
local markTextures = {};
local raid = {};
local usedMarks = {};
f:RegisterEvent("RAID_TARGET_UPDATE");
f:RegisterEvent("GROUP_ROSTER_UPDATE");
f:RegisterEvent("PLAYER_LOGIN");

for i = 1, NUM_RAID_ICONS do
	local texture = f:CreateTexture("AS_markFrame_markTexture"..i, "BACKGROUND");
	texture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\TheNine.tga");
	texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i);
	texture:SetPoint("TOPLEFT", f, "TOPRIGHT", 1, 1);
	texture:SetSize(8, 8);
	texture:Hide();
	table.insert(markTextures, texture);
end

local function updateRaid()
	raid = {};
	for group = 1, 8 do
		for member = 1, 5 do
			if (_G["CompactRaidGroup"..group.."Member"..member] and _G["CompactRaidGroup"..group.."Member"..member]:GetAttribute("unit")) then
				local unit = _G["CompactRaidGroup"..group.."Member"..member]:GetAttribute("unit");
				raid[unit] = {["group"] = group, ["member"] = member};
			end
		end
	end
end

local function updateIcons()
	for i = 1, GetNumGroupMembers() do
		local mark = GetRaidTargetIndex("raid" .. i);
		if (usedMarks["raid"..i]) then
			local mark = usedMarks["raid"..i];
			markTextures[mark]:Hide();
			markTextures[mark]:ClearAllPoints();
			usedMarks["raid"..i] = nil;
		end
		if (mark) then
			local group = raid["raid"..i].group;
			local member = raid["raid"..i].member;
			markTextures[mark]:SetPoint("CENTER", _G["CompactRaidGroup"..group.."Member"..member], "CENTER", 0, 0);
			markTextures[mark]:Show();
			local prevUser = IRT_Contains(usedMarks, mark);
			if (prevUser) then
				usedMarks[prevUser] = nil;
			end
			usedMarks["raid"..i] = mark;
		end
	end
end
--[[
C_Timer.After(5, function()
	CompactRaidFrameContainer:HookScript("OnShow", function(self)
		C_Timer.After(2, function()
			updateRaid();
			updateIcons();
		end)
	end);
end);
]]
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IsInRaid() or IsInGroup()) then
			updateRaid();
			updateIcons();
		end
	elseif (event == "RAID_TARGET_UPDATE") then
		updateIcons();
	elseif (event == "GROUP_ROSTER_UPDATE") then
		C_Timer.After(0.01, function()
			updateRaid();
			updateIcons();
		end);
	end
end);