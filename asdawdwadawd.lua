getgenv().Jump = {
    Enabled = false -- Możesz zmieniać na false, jeśli chcesz wyłączyć
}

if not game:IsLoaded() then 
    game.Loaded:Wait()
end

-- Zmienne
local IsA = game.IsA
local newindex = nil 

-- Główne hookowanie
newindex = hookmetamethod(game, "__newindex", function(self, Index, Value)
    if getgenv().Jump.Enabled and not checkcaller() and IsA(self, "Humanoid") and Index == "JumpPower" then 
        return
    end
    
    return newindex(self, Index, Value)
end)

getgenv().AutoStomp = {
    Enabled = false  -- Zmieniaj na 'true', aby włączyć AutoStomp
}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RATE_PER_SECOND = 10

-- Główna funkcjonalność AutoStomp
RunService.Stepped:Connect(function(time, step)
    if getgenv().AutoStomp.Enabled then
        ReplicatedStorage.MainEvent:FireServer("Stomp")
    end
end)

getgenv().NoSlow = {
    Enabled = false  -- Możesz zmienić na 'true' w GUI, aby włączyć
}

-- Funkcja hookująca
local mt = getrawmetatable(game)
local backup

backup = hookfunction(mt.__newindex, newcclosure(function(self, key, value)
    if getgenv().NoSlow.Enabled then
        if key == "WalkSpeed" and value < 20 then
            value = 20
        end
    end
    return backup(self, key, value)
end))
