getgenv().Flight = {
    Enabled = false, -- Flight nie działa po injekcji, dopóki nie zostanie aktywowany w GUI
    Speed = 500,
    Keybind = Enum.KeyCode.F -- Domyślny klawisz przełączania (Enum.KeyCode.F)
}

local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

local runServiceConnection

-- Funkcja aktualizująca prędkość postaci podczas lotu
local function onUpdate()
    if not getgenv().Flight.Enabled then return end
    
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
    
    hrp.Velocity = moveDirection
end

-- Funkcja uruchamiająca lot po załadowaniu postaci
local function setupCharacter(character)
    if runServiceConnection then
        runServiceConnection:Disconnect()
        runServiceConnection = nil
    end
    
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    if getgenv().Flight.Enabled then
        runServiceConnection = runService.Heartbeat:Connect(onUpdate)
    end
end

-- Funkcja zmieniająca stan lotu
local function toggleFlight()
    if not getgenv().Flight.Enabled then return end -- Flight działa tylko, jeśli Enabled = true

    if runServiceConnection then
        runServiceConnection:Disconnect()
        runServiceConnection = nil

        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    else
        runServiceConnection = runService.Heartbeat:Connect(onUpdate)
    end
end

-- Funkcja włączająca Flight przez GUI
getgenv().Flight.Enable = function()
    if not getgenv().Flight.Enabled then
        getgenv().Flight.Enabled = true
        if not runServiceConnection then
            runServiceConnection = runService.Heartbeat:Connect(onUpdate)
        end
    end
end

-- Funkcja wyłączająca Flight przez GUI
getgenv().Flight.Disable = function()
    if getgenv().Flight.Enabled then
        getgenv().Flight.Enabled = false
        if runServiceConnection then
            runServiceConnection:Disconnect()
            runServiceConnection = nil
        end

        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- Funkcja reagująca na naciśnięcie klawisza
local function onToggleKeyPressed(input, gameProcessedEvent)
    if not gameProcessedEvent and getgenv().Flight.Enabled then
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == getgenv().Flight.Keybind then
            toggleFlight()
        end
    end
end

-- Połączenia dla naciśnięcia klawisza i załadowania postaci
userInputService.InputBegan:Connect(onToggleKeyPressed)
player.CharacterAdded:Connect(setupCharacter)

-- Inicjalizujemy, jeśli postać jest już załadowana
if player.Character then
    setupCharacter(player.Character)
end

-- Ustawienia dla prędkości i klawisza
getgenv().Flight.SetSpeed = function(speed)
    getgenv().Flight.Speed = speed
end

getgenv().Flight.SetKeybind = function(key)
    if typeof(key) == "EnumItem" then
        getgenv().Flight.Keybind = key
    end
end
