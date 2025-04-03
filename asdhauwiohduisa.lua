getgenv().Flight = {
    Enabled = false,  -- Domyślnie wyłączony
    Speed = 500,  -- Domyślna prędkość
    Keybind = Enum.KeyCode.F  -- Domyślny klawisz przełączania (Enum.KeyCode.F)
}

local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local runServiceConnection

-- Funkcja aktualizująca prędkość postaci podczas lotu
local function onUpdate(deltaTime)
    if not getgenv().Flight.Enabled then return end  -- Jeśli lot jest wyłączony, nic nie rób
    
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    if not hrp then return end

    local moveDirection = Vector3.new()

    if userInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + (camera.CFrame.LookVector * getgenv().Flight.Speed)
    end
    if userInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - (camera.CFrame.LookVector * getgenv().Flight.Speed)
    end
    if userInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - (camera.CFrame.RightVector * getgenv().Flight.Speed)
    end
    if userInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + (camera.CFrame.RightVector * getgenv().Flight.Speed)
    end

    -- Ustawienie nowej prędkości
    hrp.Velocity = moveDirection
end

-- Funkcja uruchamiająca lot po załadowaniu postaci
local function setupCharacter(character)
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Resetujemy prędkość
    hrp.Velocity = Vector3.new(0, 0, 0) 
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    -- Połączymy funkcję onUpdate z Heartbeat, jeśli lot jest włączony
    if getgenv().Flight.Enabled then
        if runServiceConnection then
            runServiceConnection:Disconnect()
        end
        runServiceConnection = runService.Heartbeat:Connect(onUpdate)
    end
end

-- Funkcja zmieniająca stan lotu
local function setFlightState(enable)
    if getgenv().Flight.Enabled == enable then return end  -- Jeśli stan się nie zmienia, nie rób nic

    getgenv().Flight.Enabled = enable
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")

    if enable then
        -- Włącz lot
        if not runServiceConnection then
            runServiceConnection = runService.Heartbeat:Connect(onUpdate)
        end
    else
        -- Wyłącz lot
        if runServiceConnection then
            runServiceConnection:Disconnect()
            runServiceConnection = nil
        end
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Funkcja do przełączania lotu
local function toggleFlight()
    setFlightState(not getgenv().Flight.Enabled)
end

-- Funkcja reagująca na naciśnięcie klawisza
local function onToggleKeyPressed(input, gameProcessed)
    -- Sprawdź, czy klawisz został wciśnięty i nie jest zablokowany przez grę
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == getgenv().Flight.Keybind then
        toggleFlight()
    end
end

-- Funkcja do ustawienia prędkości lotu
getgenv().Flight.SetSpeed = function(speed)
    if type(speed) == "number" and speed > 0 then
        getgenv().Flight.Speed = speed
    end
end

-- Funkcja do ustawienia keybindu
getgenv().Flight.SetKeybind = function(newKey)
    if typeof(newKey) == "EnumItem" then
        getgenv().Flight.Keybind = newKey
    end
end

-- Funkcja do ustawiania stanu lotu na true/false
getgenv().Flight.SetEnabled = function(enable)
    if type(enable) == "boolean" then
        setFlightState(enable)
    end
end

-- Połączenie z wydarzeniem naciśnięcia klawisza
userInputService.InputBegan:Connect(onToggleKeyPressed)
player.CharacterAdded:Connect(setupCharacter)

-- Inicjalizowanie, jeśli postać jest już załadowana
if player.Character then
    setupCharacter(player.Character)
end
