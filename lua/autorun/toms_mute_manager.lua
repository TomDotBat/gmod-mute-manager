
--[[-------------------------------------------------------------------------
Tom's Mute Manager - A very simple script that helps users mute another player locally.

Created by Tom.bat (STEAM_0:0:127595314)
Website: https://tomdotbat.dev
Email: tom@tomdotbat.dev
Discord: Tom.bat#0001
---------------------------------------------------------------------------]]

if SERVER then AddCSLuaFile() return end

local config = {}

config.cantBeMutedRanks = { --Which ranks should not be able to be muted other players (usually staff)
	["superadmin"] = true
}

config.cantMuteOthersRanks = { --Which ranks should not be able to mute other players (usually staff)
	["superadmin"] = true
}

local function mutePlayer(ply)
    local group = ply:GetUserGroup()
	if config.cantMuteOthersRanks[group] then
		chat.AddText("You can't mute players that are in the group: " .. group .. ".")
    	return
	end

	ply:SetMuted(true)
	chat.AddText("Muted " .. ply:Name() .. " locally.")
end

local function unmutePlayer(ply)
    local group = ply:GetUserGroup()
	if config.cantMuteOthersRanks[group] then
		chat.AddText("You can't mute players that are in the group: " .. group .. ".")
    	return
	end

	ply:SetMuted(true)
	chat.AddText("Unmuted " .. ply:Name() .. " locally.")
end

local function openMenu()
    local group = LocalPlayer():GetUserGroup()
	if config.cantMuteOthersRanks[group] then
		chat.AddText("You can't mute other players as a: " .. group .. ".")
    	return
    end

	chat.AddText("Opening Tom's Mute Manager Menu...")

	local Menu = vgui.Create("DFrame")
	Menu:SetSize(ScrW()*.2, ScrH()*.9)
	Menu:Center()
	Menu:SetTitle("Tom's Mute Manager")
	Menu:MakePopup()
	Menu.btnMinim:SetVisible(false)
	Menu.btnMaxim:SetVisible(false)

	Menu.PlayerList = vgui.Create("DListView", Menu)
	Menu.PlayerList:Dock(FILL)
	Menu.PlayerList:SetMultiSelect(false)
	Menu.PlayerList:AddColumn("Player")
	Menu.PlayerList:AddColumn("Is Muted?")
	Menu.PlayerList.Players = player.GetAll()

	for k,v in ipairs(Menu.PlayerList.Players) do
		Menu.PlayerList:AddLine(v:Name(), v:IsMuted() and "Yes" or "No")
	end

	function Menu.PlayerList:OnRowSelected(index, row)
		if !IsValid(self.Players[index]) then
			self:RemoveLine(index)
			Menu.ToggleButton:SetDisabled(true)
			return
		end

		Menu.ToggleButton:SetDisabled(false)
	end

	Menu.ToggleButton = vgui.Create("DButton", Menu)
	Menu.ToggleButton:Dock(BOTTOM)
	Menu.ToggleButton:SetText("Toggle Mute")
	Menu.ToggleButton:SetTall(ScrH()*.1)
	Menu.ToggleButton:SetDisabled(true)
	function Menu.ToggleButton:DoClick()
		local index, row = Menu.PlayerList:GetSelectedLine()
		local ply = Menu.PlayerList.Players[index]

		if !IsValid(ply) then
			Menu.PlayerList:RemoveLine(index)
			self:SetDisabled(true)
			return
		end

		local isMuted = ply:IsMuted()
		if isMuted then
			unmutePlayer(ply)
		else
			mutePlayer(ply)
		end

		row:SetColumnText(2, isMuted and "No" or "Yes")
	end
end

concommand.Add("mute_manager", openMenu)
concommand.Add("toms_mute_manager", openMenu)

local function findPlyFromString(findString)
	local tar = false
	for k,v in ipairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), findString) then
			tar = v
			break
		end
	end

	return tar
end

local function canMute(ply)
	local group = ply:GetUserGroup()
    if config.cantMuteOthersRanks[group] then
		chat.AddText("You can't mute other players as a: " .. group .. ".")
    	return false
    end
end

hook.Add("OnPlayerChat", "TomsMuteManager", function(ply, text) 
    if (ply != LocalPlayer()) then return end

	text = string.Trim(string.lower(text))

	if string.Left(text, 12) == "/mutemanager" then
		if !canMute(ply) then return true end
		openMenu()
	end

	if string.Left(text, 5) == "/mute" then
		if !canMute(ply) then return true end
		if #text <= 5 then openMenu() return true end

		local tar = findPlyFromString(string.Right(text, #text-6))
		if !tar then
			chat.AddText("Couldn't find player with the name: " .. findString .. ".")
			return true
		end

		mutePlayer(tar)
		return true
	end

	if string.Left(text, 7) == "/unmute" then
		if !canMute(ply) then return true end
		if #text <= 7 then openMenu() return true end

		local tar = findPlyFromString(string.Right(text, #text-8))
		if !tar then
			chat.AddText("Couldn't find player with the name: " .. findString .. ".")
			return true
		end
		
		unmutePlayer(tar)
		return true
	end
end)

timer.Create("TomsMuteManager", 30, 0, function()
	if config.cantMuteOthersRanks[LocalPlayer():GetUserGroup()] then
		for k,v in ipairs(player.GetAll()) do
			v:SetMuted(false)
		end
		return
    end

    for k,v in ipairs(player.GetAll()) do
    	if config.cantBeMutedRanks[v:GetUserGroup()] then v:SetMuted(false) end
    end
end)

print("[TOM'S MUTE MANAGER] Loaded.")
