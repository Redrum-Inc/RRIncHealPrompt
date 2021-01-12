local addonTitle = ""
local addonVersion = ""
local messagePrefix = ""

local addonChannel = "RRIncAfraPower"

-- Not implemented yet.
function ShowHealOrder(number)
    StaticPopupDialogs["RRIncHealOrder"] = {
		text = "You are healer #"..number..", wait for popup telling you it's your turn to heal!",
		timeout = 3,
		whileDead = true,
		hideOnEscape = false,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    }
        
    StaticPopup_Show("RRIncHealOrder")    
end

local function ShowHealPrompt()
        StaticPopupDialogs["RRIncHealPrompt"] = {
		text = "\nYOUR TURN TO HEAL!",
		timeout = 0,
		whileDead = true,
		hideOnEscape = false,
		preferredIndex = 3,
    }    

    StaticPopup_Show("RRIncHealPrompt")   
end

local function HideHealPrompt()
    StaticPopup_Hide("RRIncHealPrompt")
end

local function SendAddonMessageHandler(msg)
    if IsInRaid() then
        C_ChatInfo.SendAddonMessage(addonChannel, msg, "RAID");
    else
        C_ChatInfo.SendAddonMessage(addonChannel, msg, "SAY");
    end
end

function IncomingMessage(...)
    local arg1, arg2, arg3, arg4, arg5, arg6 = ...

    local prefix=arg3;	
    local messageText = arg4;
    local sender = arg6;    

    if prefix == addonChannel then         
        if messageText == "VERSIONCHECK"  then
            local playerName = select(6, GetPlayerInfoByGUID(UnitGUID("player")))
            SendAddonMessageHandler("VERSION_"..playerName.."_"..addonTitle.."_"..addonVersion)
            return
        end  
        if messageText == "RESET"  then
            HideHealPrompt() 
            monitorActive = false
            return
        end
        if messageText == "START"  then
            monitorActive = true
            return
        end

        local playerName = select(6, GetPlayerInfoByGUID(UnitGUID("player")))
        local action, targetPlayer = strsplit("_", messageText)

        if action == "NEXT" and targetPlayer == playerName then
            ShowHealPrompt()
        end

        if action == "DONE" and targetPlayer == playerName then
            HideHealPrompt()
        end

        if action == "SKIP" and targetPlayer == playerName then
            HideHealPrompt()
        end
        
    end
end

local function EventEnterWorld(self, event, isLogin, isReload)
    addonTitle = GetAddOnMetadata("RRIncHealPrompt", "Title")
    addonVersion = GetAddOnMetadata("RRIncHealPrompt", "Version")
    messagePrefix = addonTitle..": "

    local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(addonChannel)
    if isLogin then      
        print(addonTitle.." v"..addonVersion.." loaded.")
    end
end

local RRIncHealPrompt_FrameEnterWorld = CreateFrame("Frame")
RRIncHealPrompt_FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
RRIncHealPrompt_FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)

local RRIncHealPrompt_IncomingMessage = CreateFrame("Frame")
RRIncHealPrompt_IncomingMessage:RegisterEvent("CHAT_MSG_ADDON")
RRIncHealPrompt_IncomingMessage:SetScript("OnEvent", IncomingMessage)