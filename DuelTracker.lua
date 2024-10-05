-- Create a frame to handle events
local DuelTrackerFrame = CreateFrame("Frame")

-- Register for events
DuelTrackerFrame:RegisterEvent("DUEL_REQUESTED")
DuelTrackerFrame:RegisterEvent("DUEL_FINISHED")
DuelTrackerFrame:RegisterEvent("CHAT_MSG_SYSTEM")

-- Initialize win/loss/request counters
local duelWins = 0
local duelLosses = 0
local duelRequests = 0
local duelInProgress = false
local opponentName = ""

-- Load saved stats (if any)
duelWins = DuelStats and DuelStats.wins or 0
duelLosses = DuelStats and DuelStats.losses or 0
duelRequests = DuelStats and DuelStats.requests or 0

-- Function to save stats
local function SaveDuelStats()
    DuelStats = {
        wins = duelWins,
        losses = duelLosses,
        requests = duelRequests
    }
end

-- Function to handle events
local function DuelTracker_OnEvent(self, event, ...)
    if event == "DUEL_REQUESTED" then
        opponentName = UnitName("target")  -- Get the name of the opponent you're dueling
        duelRequests = duelRequests + 1  -- Increment the duel request counter
        duelInProgress = true
        print("Duel requested by: " .. opponentName)
        print("Total Duels Requested: " .. duelRequests)

    elseif event == "DUEL_FINISHED" then
        duelInProgress = false

    elseif event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        if duelInProgress then
            if string.find(msg, "You have defeated") then
                duelWins = duelWins + 1
                print("You won the duel against " .. opponentName .. ". Total Wins: " .. duelWins)
            elseif string.find(msg, "has defeated you") then
                duelLosses = duelLosses + 1
                print("You lost the duel against " .. opponentName .. ". Total Losses: " .. duelLosses)
            end
        end
    end
end

-- Function to print win/loss/request stats
local function PrintDuelStats()
    print("Duel Wins: " .. duelWins .. " | Duel Losses: " .. duelLosses .. " | Duels Requested: " .. duelRequests)
end

-- Register slash command
SLASH_DUELTRACKER1 = "/dueltracker"
SlashCmdList["DUELTRACKER"] = PrintDuelStats

-- Save the stats when the player logs out
DuelTrackerFrame:RegisterEvent("PLAYER_LOGOUT")
DuelTrackerFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGOUT" then
        SaveDuelStats()
    else
        DuelTracker_OnEvent(self, event, ...)
    end
end)

-- Set the script to handle the registered events
DuelTrackerFrame:SetScript("OnEvent", DuelTracker_OnEvent)
