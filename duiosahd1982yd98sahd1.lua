getgenv().Speed = true
getgenv().FakeMacro = true
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://413861777"
	sound.Parent = game:GetService("SoundService")
	sound:Play()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zvxvaz/PiterNaGitHub/refs/heads/main/gui.lua"))()
local Window = Library:CreateWindow("swindle.cc (beta)", Vector2.new(492, 598), Enum.KeyCode.RightControl)
local AimingTab = Window:CreateTab("Aimbot")
local MovementTab = Window:CreateTab("Movement")  -- Nowa zakładka "Movement"
local Visuals = Window:CreateTab("Visuals")
local Misc = Window:CreateTab("Misc")


local AimbotSection = AimingTab:CreateSector("Camlock", "left")  -- Sekcja w "Movement"
local SilentAimSection = AimingTab:CreateSector("Silent Aim", "right")  -- Sekcja Silent Aim
local TargetStrafeSection = AimingTab:CreateSector("TargetStrafe", "right")
local FlightSection = MovementTab:CreateSector("Flight", "right")
local CFrameSection = MovementTab:CreateSector("CFrame", "Left")
local MacroSection = MovementTab:CreateSector("Macro", "Left")
local BunnyHopSection = MovementTab:CreateSector("BunnyHop", "Right")
local AntilockSection = AimingTab:CreateSector("Antilock", "left")  -- Sekcja Silent Aim
local VisualsSection = Visuals:CreateSector("ESP", "Left")
local TexturesSection = Visuals:CreateSector("Texture Changer", "Right")
local TrailSection = Visuals:CreateSector("Self Visuals", "left")
local FogSection = Visuals:CreateSector("Fog Settings", "right")
local WatermarkSection = Misc:CreateSector("Watermark", "Right")
local TrashTalkSection = Misc:CreateSector("Trash Talk", "Left")
local PlayerSection = Misc:CreateSector("Player", "Right")
local CrosshairSection = Misc:CreateSector("Crosshair", "Left")
local WorldSection = Visuals:CreateSector("World", "Right")
local SkyboxesSection = Visuals:CreateSector("Skyboxes", "Right")
local AvatarSection = Misc:CreateSector("Avatar Stuff", "Right")
local StrechScreenSection = Misc:CreateSector("Strech Screen", "Right")
local ForceHitSection = AimingTab:CreateSector("Force Hit", "Right")

-- Load services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")



-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local targetPlayer = nil

-- Ustawienia aimbota
getgenv().Aimbot = {
    Enabled = false,
    Keybind = "C",
    Hitpart = "HumanoidRootPart",
    Smoothness = 1,
    Prediction = 0,
    MaxDistance = 5000,
    JumpOffset = 0,  -- Jump offset
    FallOffset = 0,  -- Fall offset
    WallCheck = false,  -- WallCheck
    KnockCheck = false  -- KnockCheck
}

-- Ustawienia ruchu
getgenv().Movement = {
    Speed = 7500,  -- Domyślna prędkość ruchu
    JumpPower = 5000  -- Domyślna moc skoku
}

-- Ustawienia Silent Aim
getgenv().Yuth = {
    Silent = {
        Enabled = false,
        Keybind = "C",
        Prediction = 0,
        AutoPrediction = false,
        Part = "HumanoidRootPart", -- Change this to the part you want to target
        WallCheck = false,  -- WallCheck
        KnockCheck = false  -- KnockCheck
    },

    resolver = true,
    
    FOV = {
        Radius = 200,     -- Adjust the radius of the FOV circle
        Visible = false,   -- Ustawienia widoczności FOV circle
    },
    
        Highlight = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255), -- Czerwony
        Transparency = 0.5
    }
}

getgenv().TargetStrafe = {
    Enabled = false, -- Jeśli false, strafe nie działa po injekcji
    speed = 20,
    radius = 10,
    heightOffset = 5,
    Key = "F",
}

-- Load services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables
local target = nil
local angle = 0
local originalPosition = nil
local humanoid = nil
local isStrafingEnabled = false

-- Function to find the closest target
local function GetClosestTarget()
    local closestDistance = 500
    local closestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distance < closestDistance then
                        closestPlayer = player
                        closestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Toggle TargetStrafe
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode.Name == getgenv().TargetStrafe.Key then  
        if getgenv().TargetStrafe.Enabled then  -- Sprawdzanie, czy funkcja jest włączona
            isStrafingEnabled = not isStrafingEnabled
            if isStrafingEnabled then
                target = GetClosestTarget()
                if target then
                    originalPosition = LocalPlayer.Character.HumanoidRootPart.Position
                    humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                else
                    isStrafingEnabled = false -- Jeśli nie ma celu, nie włączaj strafingu
                end
            else
                target = nil
                humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
        end
    end
end)

-- Spinning logic
RunService.RenderStepped:Connect(function()
    if isStrafingEnabled and getgenv().TargetStrafe.Enabled and target and target.Character then
        local targetPosition = target.Character.HumanoidRootPart.Position
        local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position

        angle = angle + getgenv().TargetStrafe.speed / 100
        
        local offsetX = math.cos(angle) * getgenv().TargetStrafe.radius
        local offsetZ = math.sin(angle) * getgenv().TargetStrafe.radius
        
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(offsetX, getgenv().TargetStrafe.heightOffset, offsetZ), targetPosition)
    end
end)

-- Allow falling if disabled
RunService.Heartbeat:Connect(function()
    if not isStrafingEnabled and humanoid then
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid.PlatformStand = false
        end
    end
end)

-- Pobranie usług Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Zmienna do przechowywania aktualnego celu Silent Aim
local SilentAimTarget = nil

-- Funkcja do sprawdzania, czy nie ma przeszkód między lokalnym graczem a celem (WallCheck)
local function isTargetVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * (target.Position - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target.Parent})
    
    return hit == nil or hit:IsDescendantOf(target.Parent)
end

-- Funkcja do sprawdzania, czy cel nie jest powalony (KnockCheck)
local function isTargetKnocked(target)
    local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Funkcja wyszukująca najbliższego przeciwnika
local function GetClosestTarget()
    local ClosestDistance = getgenv().Aimbot.MaxDistance
    local ClosestPlayer = nil
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local HitPart = Player.Character:FindFirstChild(getgenv().Aimbot.Hitpart)
            
            if HitPart then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HitPart.Position)
                if OnScreen and (not getgenv().Aimbot.WallCheck or isTargetVisible(HitPart)) and (not getgenv().Aimbot.KnockCheck or isTargetKnocked(HitPart)) then
                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                    if Distance < ClosestDistance then
                        ClosestPlayer = Player
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

-- Obsługa włączania aimbota przyciskiem
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[getgenv().Aimbot.Keybind] then
        Target = not Target and GetClosestTarget() or nil
    end
end)

-- Główna pętla aimbota
RunService.RenderStepped:Connect(function()
    if getgenv().Aimbot.Enabled and Target and Target.Character then
        local HitPart = Target.Character:FindFirstChild(getgenv().Aimbot.Hitpart)
        if HitPart then
            local PredictedPos = HitPart.Position + HitPart.Velocity * getgenv().Aimbot.Prediction
            
            -- Track jump/fall offset based on vertical speed (Y axis velocity)
            local humanoid = Target.Character:FindFirstChild("Humanoid")
            if humanoid then
                -- Get humanoid state for jump/fall detection
                local isJumping = humanoid:GetState() == Enum.HumanoidStateType.Jumping
                local isFalling = humanoid:GetState() == Enum.HumanoidStateType.Freefall

                -- Apply jump offset if the player is jumping
                if isJumping then
                    PredictedPos = PredictedPos + Vector3.new(0, getgenv().Aimbot.JumpOffset, 0)
                -- Apply fall offset if the player is falling
                elseif isFalling then
                    PredictedPos = PredictedPos + Vector3.new(0, getgenv().Aimbot.FallOffset, 0)
                end
            end
            
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, PredictedPos)
            -- Apply smoothness with Lerp
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, math.clamp(getgenv().Aimbot.Smoothness, 0, 1))
        end
    end
end)

getgenv().Flight = {
    Enabled = false, -- Flight nie działa po injekcji, dopóki nie zostanie aktywowany w GUI
    Speed = 500,
    Keybind = "F"
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
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[getgenv().Flight.Keybind] then
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
    getgenv().Flight.Keybind = key
end


getgenv().Settings = {
	Antilock = false,
	xAxis = 1000,
	yAxis = 1000,
    zAxis = 1000,

	Keybind = Enum.KeyCode.B,

	DesyncMode = false,
	DesyncAngles = 100,

	VelocityVisual = false,
	
	RandomMode = false
}


local veldot = Drawing.new("Circle")

spawn(function()
	veldot.Filled = true
	veldot.Thickness = 1
	veldot.Transparency = 1
	veldot.Radius = 5
	veldot.Color = Color3.fromRGB(0, 0, 189)
end)

-- Velocity Visualizer

game:GetService("RunService").Heartbeat:Connect(function()
	local pos, onscreen = workspace.CurrentCamera:WorldToViewportPoint(
		game:GetService("Players").LocalPlayer.Character["HumanoidRootPart"].CFrame.Position +
			(game:GetService("Players").LocalPlayer.Character["HumanoidRootPart"].AssemblyLinearVelocity *
				0.15))

	if Settings.VelocityVisual and onscreen then
		veldot.Visible = true
		veldot.Position = Vector2.new(pos.X, pos.Y)
	else
		veldot.Visible = false
	end
end)

-- Anti-Aim Functions

game:GetService("RunService").Heartbeat:Connect(function()
	local hrp, hum = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, game:GetService("Players").LocalPlayer.Character.Humanoid
	local velocity, cframe = hrp.AssemblyLinearVelocity, hrp.CFrame

	if Settings.Antilock then
		if Settings.RandomMode then
			hrp.AssemblyLinearVelocity = Vector3.new(
				math.random(-10000, 10000),
				math.random(-10000, 10000),
				math.random(-10000, 10000))
		else
			hrp.AssemblyLinearVelocity = Vector3.new(
				Settings.xAxis,
				Settings.yAxis,
				Settings.zAxis)
		end

		if Settings.DesyncMode then
			hrp.CFrame = cframe *
				CFrame.Angles(0, math.rad(Settings.DesyncAngles), 0)
		end

		game:GetService("RunService").RenderStepped:Wait()
		hrp.AssemblyLinearVelocity = velocity
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function(Key)
	if Key.KeyCode == Settings.Keybind and not game:GetService("UserInputService"):GetFocusedTextBox() then
		Settings.Antilock = not Settings.Antilock
	end
end)

getgenv().Esp = {
    Enabled           = false,
    Box               = false,
    BoxColor          = Color3.fromRGB(255,255,255),
    BoxOutlineColor   = Color3.fromRGB(0,0,0),
    HealthBar         = false,
    HealthBarSide     = "Right",
    Names             = false,
    NamesColor        = Color3.fromRGB(255,255,255),
    NamesFont         = 2,
    NamesSize         = 13,
    Tracers           = false,
    TracersColor      = Color3.fromRGB(255,255,255),
    TracersOutlineColor = Color3.fromRGB(0,0,0),
    TracersFollowMouse = false
}

VisualsSection:AddToggle("Enable ESP", getgenv().Esp.Enabled, function(value)
    getgenv().Esp.Enabled = value
end)

VisualsSection:AddToggle("Box", getgenv().Esp.Box, function(value)
    getgenv().Esp.Box = value
end)

VisualsSection:AddToggle("Names", getgenv().Esp.Names, function(value)
    getgenv().Esp.Names = value
end)

VisualsSection:AddToggle("Tracers", getgenv().Esp.Tracers, function(value)
    getgenv().Esp.Tracers = value
end)

VisualsSection:AddToggle("Tracers Follow Mouse", getgenv().Esp.TracersFollowMouse, function(value)
    getgenv().Esp.TracersFollowMouse = value
end)

VisualsSection:AddColorpicker("ESP Box Color", Color3.fromRGB(255, 255, 255), function(color)
    getgenv().Esp.BoxColor = color
end)

VisualsSection:AddColorpicker("ESP Names Color", Color3.fromRGB(255, 255, 255), function(color)
    getgenv().Esp.NamesColor = color
end)

VisualsSection:AddColorpicker("ESP Tracers Color", Color3.fromRGB(255, 255, 255), function(color)
    getgenv().Esp.TracersColor = color
end)

function CreateEsp(Player)
    local Box,BoxOutline,Name,HealthBar,HealthBarOutline,Tracer,TracerOutline = Drawing.new("Square"),Drawing.new("Square"),Drawing.new("Text"),Drawing.new("Square"),Drawing.new("Square"),Drawing.new("Line"),Drawing.new("Line")
    local Updater = game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().Esp.Enabled and Player.Character ~= nil and Player.Character:FindFirstChild("Humanoid") ~= nil and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil and Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("Head") ~= nil then
            local Target2dPosition,IsVisible = workspace.CurrentCamera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            local scale_factor = 1 / (Target2dPosition.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)
            if getgenv().Esp.Box then
                Box.Visible = IsVisible
                Box.Color = getgenv().Esp.BoxColor
                Box.Size = Vector2.new(width,height)
                Box.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                Box.Thickness = 1
                Box.ZIndex = 69

                BoxOutline.Visible = IsVisible
                BoxOutline.Color = getgenv().Esp.BoxOutlineColor
                BoxOutline.Size = Vector2.new(width,height)
                BoxOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                BoxOutline.Thickness = 3
                BoxOutline.ZIndex = 1
            else
                Box.Visible = false
                BoxOutline.Visible = false
            end
            if getgenv().Esp.Names then
                Name.Visible = IsVisible
                Name.Color = getgenv().Esp.NamesColor
                Name.Text = Player.Name.." "..math.floor((workspace.CurrentCamera.CFrame.p - Player.Character.HumanoidRootPart.Position).magnitude).."m"
                Name.Center = true
                Name.Outline = true
                Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                Name.Position = Vector2.new(Target2dPosition.X,Target2dPosition.Y - height * 0.5 + -15)
                Name.Font = getgenv().Esp.NamesFont
                Name.Size = getgenv().Esp.NamesSize
            else
                Name.Visible = false
            end
            if getgenv().Esp.HealthBar then
                HealthBarOutline.Visible = IsVisible
                HealthBarOutline.Color = Color3.fromRGB(0,0,0)
                HealthBarOutline.Filled = true
                HealthBarOutline.ZIndex = 1
    
                HealthBar.Visible = IsVisible
                HealthBar.Color = Color3.fromRGB(0,255,0):lerp(Color3.fromRGB(0,255,0), Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth)
                HealthBar.Thickness = 1
                HealthBar.Filled = false
                HealthBar.ZIndex = 69
                if getgenv().Esp.HealthBarSide == "Left" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(-3,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * (Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth))
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif getgenv().Esp.HealthBarSide == "Bottom" then
                    HealthBarOutline.Size = Vector2.new(width,3)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(0,height + 2)

                    HealthBar.Size = Vector2.new((HealthBarOutline.Size.X - 2) * (Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth),1)
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif getgenv().Esp.HealthBarSide == "Right" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(width + 1,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * (Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth))
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                end
            else
                HealthBar.Visible = true
                HealthBarOutline.Visible = false
            end
            if getgenv().Esp.Tracers then
                Tracer.Visible = IsVisible
                Tracer.Color = getgenv().Esp.TracersColor
                Tracer.To = Vector2.new(Target2dPosition.X, Target2dPosition.Y)
                Tracer.Thickness = 1
                Tracer.ZIndex = 69

                TracerOutline.Visible = IsVisible
                TracerOutline.Color = getgenv().Esp.TracersOutlineColor
                TracerOutline.To = Vector2.new(Target2dPosition.X, Target2dPosition.Y)
                TracerOutline.Thickness = 3
                TracerOutline.ZIndex = 1

                if getgenv().Esp.TracersFollowMouse then
                    local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
                    Tracer.From = Vector2.new(mouseLocation.X, mouseLocation.Y)
                    TracerOutline.From = Vector2.new(mouseLocation.X, mouseLocation.Y)
                else
                    Tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    TracerOutline.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                end
            else
                Tracer.Visible = false
                TracerOutline.Visible = false
            end
        else
            Box.Visible = false
            BoxOutline.Visible = false
            Name.Visible = false
            HealthBar.Visible = false
            HealthBarOutline.Visible = false
            Tracer.Visible = false
            TracerOutline.Visible = false
            if not Player then
                Box:Remove()
                BoxOutline:Remove()
                Name:Remove()
                HealthBar:Remove()
                HealthBarOutline:Remove()
                Tracer:Remove()
                TracerOutline:Remove()
                Updater:Disconnect()
            end
        end
    end)
end

for _,v in pairs(game:GetService("Players"):GetPlayers()) do
   if v ~= game:GetService("Players").LocalPlayer then
      CreateEsp(v)
   end
end

game:GetService("Players").PlayerAdded:Connect(function(v)
   if v ~= game:GetService("Players").LocalPlayer then
      CreateEsp(v)
   end
end)

getgenv().Txt = {
    ['Textures'] = {
        ['Enabled'] = false,
        ['Material'] = "Rock",
        ['Color'] = Color3.fromRGB(255, 255, 255),
        ['Types'] = {"Asphalt", "Basalt", "Brick", "Cobblestone", "Concrete", "CrackedLava", "Glacier", "Grass", "Ground",
                     "Ice", "Limestone", "LeafyGrassMud", "Pavement", "Rock", "Salt", "Sand", "Slate", "Snow", "Water"}
    }
}

local function applyTextures(enable)
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            if enable then
                v.Material = getgenv().Txt.Textures.Material
                v.Color = getgenv().Txt.Textures.Color
                if v:IsA("Texture") then
                    v:Destroy()
                end
            end
        end
    end
end

applyTextures(getgenv().Txt.Textures.Enabled)

TexturesSection:AddToggle("Enable Texture Changer", getgenv().Txt.Textures.Enabled, function(value)
    getgenv().Txt.Textures.Enabled = value
    applyTextures(value)
end)

TexturesSection:AddDropdown("Textures Material", {"Rock", "Brick", "Grass", "Sand", "CrackedLava", "Asphalt", "Ice", "Pavement"}, getgenv().Txt.Textures.Material, false, function(value)
    getgenv().Txt.Textures.Material = value
end)

TexturesSection:AddColorpicker("Textures Color", Color3.fromRGB(255, 255, 255), function(color)
    getgenv().Txt.Textures.Color = color
end)

getgenv().Fog = {
    Enabled = false, -- Włącz lub wyłącz mgłę
    NoFog = false, -- Całkowite usunięcie mgły
    Color = Color3.fromRGB(135, 206, 235), -- Domyślny kolor mgły (błękitny)
    FogStart = 200, -- Odległość rozpoczęcia mgły
    FogEnd = 200, -- Odległość zakończenia mgły
    RainBow = false, -- Tryb tęczy
    PreviousColor = Color3.fromRGB(135, 206, 235),
    OriginalFogStart = nil,
    OriginalFogEnd = nil,
    OriginalFogColor = nil
}

local Lighting = game:GetService("Lighting")
local runService = game:GetService("RunService")

-- Zapisz oryginalne wartości mgły
if getgenv().Fog.OriginalFogStart == nil then
    getgenv().Fog.OriginalFogStart = Lighting.FogStart
    getgenv().Fog.OriginalFogEnd = Lighting.FogEnd
    getgenv().Fog.OriginalFogColor = Lighting.FogColor
end

-- Aktualizacja mgły
local function UpdateFog()
    if getgenv().Fog.NoFog then
        Lighting.FogEnd = 1e6 -- Całkowicie usuwa mgłę
        Lighting.FogStart = 1e6
    elseif getgenv().Fog.Enabled then
        Lighting.FogColor = getgenv().Fog.Color
        Lighting.FogStart = getgenv().Fog.FogStart
        Lighting.FogEnd = getgenv().Fog.FogEnd
    else
        -- Przywróć oryginalne wartości mgły
        Lighting.FogColor = getgenv().Fog.OriginalFogColor
        Lighting.FogStart = getgenv().Fog.OriginalFogStart
        Lighting.FogEnd = getgenv().Fog.OriginalFogEnd
    end
end

-- Dynamiczny tryb tęczy
local function StartRainbowMode()
    while getgenv().Fog.RainBow do
        for hue = 0, 360, 2 do -- Przechodzi przez kolory tęczy
            if not getgenv().Fog.RainBow then
                getgenv().Fog.Color = getgenv().Fog.PreviousColor -- Przywróć poprzedni kolor
                UpdateFog()
                return
            end
            getgenv().Fog.Color = Color3.fromHSV(hue / 360, 1, 1)
            UpdateFog()
            task.wait(0.1) -- Prędkość zmiany koloru
        end
    end
end

-- Monitoruj zmianę Rainbow Mode
runService.Heartbeat:Connect(function()
    if getgenv().Fog.RainBow then
        StartRainbowMode()
    end
end)

-- Wywołaj aktualizację na starcie
UpdateFog()


FogSection:AddToggle("Enable Fog", getgenv().Fog.Enabled, function(value)
    getgenv().Fog.Enabled = value
    UpdateFog() -- Aktualizacja mgły po zmianie wartości
end)

FogSection:AddColorpicker("Fog Color", Color3.fromRGB(255, 255, 255), function(color)
    getgenv().Fog.Color = color
    UpdateFog() -- Aktualizacja mgły po zmianie koloru
end)

FogSection:AddSlider("Fog Start", 0, 10000, getgenv().Fog.FogStart, 100, function(value)
    getgenv().Fog.FogStart = value
    UpdateFog() -- Aktualizacja mgły po zmianie wartości
end)

FogSection:AddSlider("Fog End", 0, 10000, getgenv().Fog.FogEnd, 100, function(value)
    getgenv().Fog.FogEnd = value
    UpdateFog() -- Aktualizacja mgły po zmianie wartości
end)

getgenv().Watermark = {
    
    Enabled = false
    
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name
local GameName = "Unknown Game"

-- Pobieranie nazwy gry (obsługa błędów)
pcall(function()
    GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

-- Tworzenie UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "SwindleWatermark"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 20) -- Początkowa szerokość
Frame.Position = UDim2.new(0, 10, 0, 10) -- Lewy górny róg
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Czarne tło
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.2
Frame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke") -- Obrys
UIStroke.Parent = Frame
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 0, 189) -- Niebieski obrys

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, -10, 1, 0)
TextLabel.Position = UDim2.new(0, 5, 0, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Biały tekst
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextSize = 12 -- Mniejsza czcionka
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Text = "Loading..."
TextLabel.Parent = Frame

-- Zmienna do liczenia FPS
local frameCount = 0
local lastTime = tick()
local fps = 0
local ping = "0ms" -- Domyślny ping

-- Funkcja do aktualizacji watermarka
local function UpdateWatermark()
    local lastUpdateTime = tick() -- Czas ostatniej aktualizacji
    local fpsUpdateInterval = 1 -- Aktualizacja co 1 sekundę

    -- Obliczanie FPS i Ping w czasie rzeczywistym
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()

        -- Obliczanie FPS co sekundę
        if currentTime - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = currentTime

            -- Pobranie pingu co sekundę
            local success, result = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+")
            end)
            if success and result then
                ping = result .. "ms"
            else
                ping = "N/A"
            end
        end

        -- Zaktualizowanie tekstu watermarka
        if getgenv().Watermark.Enabled then
            TextLabel.Text = string.format("Swindle.cc | Game: %s | Name: %s | Ping: %s | FPS: %d", GameName, PlayerName, ping, fps)

            -- Dynamiczne dopasowanie szerokości Frame do długości tekstu
            local textWidth = TextLabel.TextBounds.X + 10  -- +10 na margines
            Frame.Size = UDim2.new(0, textWidth, 0, 20)  -- Zmieniamy szerokość Frame na dynamiczną

            ScreenGui.Enabled = true
        else
            ScreenGui.Enabled = false
        end
    end)
end

-- Uruchomienie funkcji aktualizacji watermarka
task.spawn(UpdateWatermark)

WatermarkSection:AddToggle("Enable Watermark", getgenv().Watermark.Enabled, function(value)
    getgenv().Watermark.Enabled = value
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

getgenv().TrashTalk = {
    Enabled = false,
    Keybind = "T",
}

local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local trashTalkMessages = {
    "when azure modded pulled up...",
    "up sets ng",
    "its bad",
    "get better config",
    "gg = get good",
    "funny sets ngl",
    "up it ong",
    "u cant handle me im on different level",
    "azure modded final boss",
    "skid alert!!!",
    "Swindle.cc on top",
    "no one compares when it comes to Swindle.cc",
}

local function sendTrashTalk()
    if getgenv().TrashTalk.Enabled and TextChatService then
        local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
        
        -- Pobierz domyślny kanał gracza i wyślij wiadomość
        local chatChannel = TextChatService.TextChannels.RBXGeneral
        if chatChannel then
            chatChannel:SendAsync(message)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[getgenv().TrashTalk.Keybind] then
        sendTrashTalk()
    end
end)

TrashTalkSection:AddToggle("Enable TrashTalk", getgenv().TrashTalk.Enabled, function(value)
    getgenv().TrashTalk.Enabled = value
end)

TrashTalkSection:AddTextbox("TrashTalk Keybind", getgenv().TrashTalk.Keybind, function(value)
    if Enum.KeyCode[value] then
        getgenv().TrashTalk.Keybind = value
    end
end)

getgenv().Macro = {
    Enabled = false,
    Keybind = "X",  -- Teraz przechowujemy keybind jako zwykły tekst
}

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local SpeedGlitch = false

-- Obsługa klawisza
Mouse.KeyDown:Connect(function(Key)
    if Key:upper() == getgenv().Macro.Keybind then  -- Porównanie z uwzględnieniem wielkości liter
        SpeedGlitch = not SpeedGlitch
        if SpeedGlitch == true then
            repeat
                game:GetService("RunService").Heartbeat:wait()
                if not getgenv().Macro.Enabled then
                    SpeedGlitch = false
                    break
                end
                game:GetService("VirtualInputManager"):SendMouseWheelEvent(0, 0, true, game)
                game:GetService("RunService").Heartbeat:wait()
                game:GetService("VirtualInputManager"):SendMouseWheelEvent(0, 0, false, game)
                game:GetService("RunService").Heartbeat:wait()
            until SpeedGlitch == false
        end
    end
end)

-- Dodanie toggle do GUI
MacroSection:AddToggle("Enable Macro", getgenv().Macro.Enabled, function(value)
    getgenv().Macro.Enabled = value
end)

-- Dodanie textboxa do zmiany Keybind w GUI
MacroSection:AddTextbox("Macro Keybind", getgenv().Macro.Keybind, function(value)
    getgenv().Macro.Keybind = value:upper()  -- Upewniamy się, że keybind jest przechowywany w wersji z wielkimi literami
end)

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

PlayerSection:AddToggle("No jump cooldown", getgenv().Jump.Enabled, function(value)
    getgenv().Jump.Enabled = value
end)

-- Inicjalizacja zmiennej NoSlow
-- Inicjalizacja zmiennej NoSlow
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

PlayerSection:AddToggle("Auto stomp", getgenv().AutoStomp.Enabled, function(value)
    -- Aktualizowanie stanu zmiennej globalnej
    getgenv().AutoStomp.Enabled = value
end)

-- Dodanie toggle w GUI
PlayerSection:AddToggle("No slow", getgenv().NoSlow.Enabled, function(value)
    -- Aktualizowanie stanu zmiennej globalnej
    getgenv().NoSlow.Enabled = value
end)

-- Zmienna do kontrolowania włączenia/wyłączenia tańca
getgenv().Floss = {
    Enabled = false  -- Zmieniaj na 'false' aby wyłączyć
}

-- Ustawienia animacji
local danceAnimationId = "http://www.roblox.com/asset/?id=10714340543"  -- ID animacji Floss

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animationTrack

-- Funkcja do uruchamiania animacji
local function playDanceAnimation()
    if getgenv().Floss.Enabled then
        -- Tworzymy instancję animacji
        local danceAnimation = Instance.new("Animation")
        danceAnimation.AnimationId = danceAnimationId

        -- Odtwarzamy animację na humanoidzie
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            animationTrack = animator:LoadAnimation(danceAnimation)
        else
            animationTrack = humanoid:LoadAnimation(danceAnimation)
        end

        -- Uruchamiamy animację w pętli
        animationTrack:Play()
        animationTrack.Looped = true
    end
end

-- Funkcja do zatrzymywania animacji
local function stopDanceAnimation()
    if animationTrack and animationTrack.IsPlaying then
        animationTrack:Stop()
    end
end

-- Uruchomienie tańca (jeśli Floss jest włączony)
if getgenv().Floss.Enabled then
    playDanceAnimation()
end

-- Jeśli postać się zmieni, zacznij ponownie tańczyć
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")

    -- Jeśli Floss jest włączony, zacznij tańczyć
    if getgenv().Floss.Enabled then
        playDanceAnimation()
    end
end)

-- Nasłuchuj zmiany wartości Floss.Enabled
game:GetService("RunService").Heartbeat:Connect(function()
    if getgenv().Floss.Enabled then
        -- Jeśli Floss jest włączony, uruchom animację
        if not animationTrack or not animationTrack.IsPlaying then
            playDanceAnimation()
        end
    else
        -- Jeśli Floss jest wyłączony, zatrzymaj animację
        stopDanceAnimation()
    end
end)

PlayerSection:AddToggle("Floss dance", getgenv().Floss.Enabled, function(value)
    -- Aktualizowanie stanu zmiennej globalnej
    getgenv().Floss.Enabled = value
end)

-- Globalne przechowywanie ustawień
getgenv().NoRecoil = {
    Enabled = false
}

-- Funkcja sprawdzająca, czy skrypt to "Framework"
function isframework(scriptInstance)
    return tostring(scriptInstance) == "Framework"
end

-- Funkcja sprawdzająca argumenty
function checkArgs(instance, index)
    return tostring(instance):lower():find("camera") and tostring(index) == "CFrame"
end

-- Hookowanie funkcji __newindex
local newindex
newindex = hookmetamethod(game, "__newindex", function(self, index, value)
    if not getgenv().NoRecoil.Enabled then  -- Jeśli NoRecoil jest wyłączone, nie rób nic
        return newindex(self, index, value)
    end

    local callingScr = getcallingscript()
    if isframework(callingScr) and checkArgs(self, index) then
        return  -- Blokuje zmianę CFrame kamery, jeśli NoRecoil jest włączone
    end

    return newindex(self, index, value)
end)

-- Dodanie przełącznika do GUI w sekcji "PlayerSection"
PlayerSection:AddToggle("No Recoil", getgenv().NoRecoil.Enabled, function(value)
    getgenv().NoRecoil.Enabled = value
end)

getgenv().Light = {
    Enabled = false,  -- Włącz lub wyłącz ciemność
}

-- Skrypt robiący ciemno w Roblox bez użycia Ambient, z manipulowaniem innymi ustawieniami
local lighting = game:GetService("Lighting")

-- Funkcja aktualizująca świat
local function updateWorldLighting()
    if getgenv().Light.Enabled then
        lighting.Brightness = 0  -- Zmniejszenie ogólnej jasności
        lighting.ExposureCompensation = -2  -- Zmniejsza ekspozycję (ciemniejsze)
        lighting.GlobalShadows = true
    else
        lighting.Brightness = 2  -- Standardowa jasność
        lighting.ExposureCompensation = 0  -- Domyślna ekspozycja
        lighting.GlobalShadows = true  -- Włączanie globalnych cieni
    end
end

-- Ustawienia początkowe
updateWorldLighting()

WorldSection:AddToggle("World Overlay", getgenv().Light.Enabled, function(value)
    getgenv().Light.Enabled = value
    updateWorldLighting()  -- Zaktualizowanie światła po zmianie w GUI
end)

-- Zmienna globalna, która trzyma ustawienia
-- Zmienna globalna, która trzyma ustawienia

getgenv().Resolution = {
    [".gg/scripters"] = 1
}

getgenv().Enabled = false -- Możesz ustawić na false, aby wyłączyć działanie skryptu

local Camera = workspace.CurrentCamera
local DefaultCFrame = Camera.CFrame -- Zapisanie domyślnej wartości CFrame
local RunService = game:GetService("RunService")

-- Funkcja do aktualizacji kamery
local function updateCamera()
    if getgenv().Enabled then
        Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
    end
end

-- Odłączamy pętlę RenderStepped, jeśli Enabled jest false
local connection
connection = RunService.RenderStepped:Connect(
    function()
        -- Jeśli Enabled jest false, skrypt w ogóle nie zmienia kamery
        if getgenv().Enabled then
            updateCamera() -- Tylko wtedy, gdy Enabled jest true, zmieniamy kamerę
        else
            -- Kamera nie jest zmieniana, nic się nie dzieje
            -- To zapewnia, że skrypt nie zmienia stanu kamery, gdy Enabled jest false
        end
    end
)

getgenv().gg_scripters = "Aori0001"

-- GUI kontrolki
StrechScreenSection:AddToggle("Enable", getgenv().Enabled, function(value)
    getgenv().Enabled = value -- Aktualizowanie stanu włączania/wyłączania
    -- Odświeżenie kamery po zmianie, ale tylko wtedy, gdy Enabled jest true
    if getgenv().Enabled then
        updateCamera() 
    end
end)

StrechScreenSection:AddTextbox("Strech Screen value", getgenv().Resolution[".gg/scripters"], function(value)
    getgenv().Resolution[".gg/scripters"] = value
end)

local Lighting = game:GetService("Lighting")

local Lighting = game:GetService("Lighting")

local Lighting = game:GetService("Lighting")

getgenv().Configurations = {
    Visuals = {
        World = {
            ClockTime = {
                Enabled = false,
                Value = 12, -- Możesz zmieniać wartość od 1 do 24
                PreviousValue = Lighting.ClockTime -- Przechowuje poprzedni czas
            }
        }
    }
}

-- Logika aktualizująca czas w grze
local function ApplyClockTime()
    local config = getgenv().Configurations.Visuals.World.ClockTime
    if config.Enabled then
        Lighting.ClockTime = config.Value
    end
end

-- Aktualizacja czasu w pętli
local function MonitorClockTime()
    while task.wait(0) do
        ApplyClockTime()
    end
end

task.spawn(MonitorClockTime)

WorldSection:AddToggle("Time Changer", getgenv().Configurations.Visuals.World.ClockTime.Enabled, function(value)
    local config = getgenv().Configurations.Visuals.World.ClockTime
    if value then
        config.PreviousValue = Lighting.ClockTime -- Zapisuje poprzedni czas tylko raz, gdy Enabled przechodzi na true
    else
        Lighting.ClockTime = config.PreviousValue -- Przywraca poprzedni czas
    end
    config.Enabled = value
end)

WorldSection:AddTextbox("Time", getgenv().Configurations.Visuals.World.ClockTime.Value, function(value)
    getgenv().Configurations.Visuals.World.ClockTime.Value = tonumber(value) or 12
end)

-- Sprawdzenie, czy obiekt `SkyboxSettings` jest poprawnie zainicjowany
if not getgenv().SkyboxSettings then
    getgenv().SkyboxSettings = {}
end

-- Sprawdzenie, czy obiekt `SkyboxSettings` jest poprawnie zainicjowany
if not getgenv().SkyboxSettings then
    getgenv().SkyboxSettings = {}
end

getgenv().SkyboxSettings = {
    Minecraft = {Enabled = false, Assets = {SkyboxBk = "rbxassetid://1876545003", SkyboxDn = "rbxassetid://1876544331", SkyboxFt = "rbxassetid://1876542941", SkyboxLf = "rbxassetid://1876543392", SkyboxRt = "rbxassetid://1876543764", SkyboxUp = "rbxassetid://1876544642"}},
    Purple = {Enabled = false, Assets = {SkyboxBk = "http://www.roblox.com/asset/?id=14543264135", SkyboxDn = "http://www.roblox.com/asset/?id=14543358958", SkyboxFt = "http://www.roblox.com/asset/?id=14543257810", SkyboxLf = "http://www.roblox.com/asset/?id=14543275895", SkyboxRt = "http://www.roblox.com/asset/?id=14543280890", SkyboxUp = "http://www.roblox.com/asset/?id=14543371676"}},
    DarkBlue = {Enabled = false, Assets = {SkyboxBk = "rbxassetid://393845394", SkyboxDn = "rbxassetid://393845204", SkyboxFt = "rbxassetid://393845629", SkyboxLf = "rbxassetid://393845750", SkyboxRt = "rbxassetid://393845533", SkyboxUp = "rbxassetid://393845287"}},
    Red = {Enabled = false, Assets = {SkyboxBk = "rbxassetid://15832429892", SkyboxDn = "rbxassetid://15832430998", SkyboxFt = "rbxassetid://15832430210", SkyboxLf = "rbxassetid://15832430671", SkyboxRt = "rbxassetid://15832431198", SkyboxUp = "rbxassetid://15832429401"}},
    Pink = {Enabled = false, Assets = {SkyboxBk = "rbxassetid://12635309703", SkyboxDn = "rbxassetid://12635311686", SkyboxFt = "rbxassetid://12635312870", SkyboxLf = "rbxassetid://12635313718", SkyboxRt = "rbxassetid://12635315817", SkyboxUp = "rbxassetid://12635316856"}},
    DarkGreen = {Enabled = false, Assets = {SkyboxBk = "rbxassetid://566611187", SkyboxDn = "rbxassetid://566613198", SkyboxFt = "rbxassetid://566611142", SkyboxLf = "rbxassetid://566611266", SkyboxRt = "rbxassetid://566611300", SkyboxUp = "rbxassetid://566611218"}},
    Green = {Enabled = false, Assets = {SkyboxBk = "rbxassetid://11941775243", SkyboxDn = "rbxassetid://11941774975", SkyboxFt = "rbxassetid://11941774655", SkyboxLf = "rbxassetid://11941774369", SkyboxRt = "rbxassetid://11941774042", SkyboxUp = "rbxassetid://11941773718"}},
    Yellow = {Enabled = false, Assets = {SkyboxBk = "http://www.roblox.com/asset/?id=15670828196", SkyboxDn = "http://www.roblox.com/asset/?id=15670829373", SkyboxFt = "http://www.roblox.com/asset/?id=15670830476", SkyboxLf = "http://www.roblox.com/asset/?id=15670831662", SkyboxRt = "http://www.roblox.com/asset/?id=15670833256", SkyboxUp = "http://www.roblox.com/asset/?id=15670834206"}},
    Orange = {Enabled = false, Assets = {SkyboxBk = "http://www.roblox.com/asset/?id=150939022", SkyboxDn = "http://www.roblox.com/asset/?id=150939038", SkyboxFt = "http://www.roblox.com/asset/?id=150939047", SkyboxLf = "http://www.roblox.com/asset/?id=150939056", SkyboxRt = "http://www.roblox.com/asset/?id=150939063", SkyboxUp = "http://www.roblox.com/asset/?id=150939082"}},
}

-- Pobranie serwisu Lighting i zapisanie oryginalnego skyboxa
local lighting = game:GetService("Lighting")
local originalSkybox = nil
for _, child in pairs(lighting:GetChildren()) do
    if child:IsA("Sky") then
        originalSkybox = child:Clone()
        break
    end
end

-- Funkcja do zmiany skyboxa
local function changeSkybox()
    -- Usuń obecny skybox
    for _, child in pairs(lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end

    for skybox, settings in pairs(getgenv().SkyboxSettings) do
        if settings.Enabled then
            local newSky = Instance.new("Sky")
            newSky.Name = "CustomSkybox"
            newSky.SkyboxBk = settings.Assets.SkyboxBk
            newSky.SkyboxDn = settings.Assets.SkyboxDn
            newSky.SkyboxFt = settings.Assets.SkyboxFt
            newSky.SkyboxLf = settings.Assets.SkyboxLf
            newSky.SkyboxRt = settings.Assets.SkyboxRt
            newSky.SkyboxUp = settings.Assets.SkyboxUp
            newSky.Parent = lighting
            break
        end
    end
end

-- Monitorowanie zmian w Enabled i aktualizacja skyboxa
task.spawn(function()
    local lastState = {}
    for skybox, settings in pairs(getgenv().SkyboxSettings) do
        lastState[skybox] = settings.Enabled
    end

    while task.wait(1) do -- Sprawdza co sekundę
        for skybox, settings in pairs(getgenv().SkyboxSettings) do
            if settings.Enabled ~= lastState[skybox] then
                lastState[skybox] = settings.Enabled
                changeSkybox()
            end
        end
    end
end)

-- GUI - Przycisk do zmiany skyboxa
for skybox, settings in pairs(getgenv().SkyboxSettings) do
    SkyboxesSection:AddToggle(skybox, settings.Enabled, function(value)
        settings.Enabled = value -- Poprawiona nazwa zmiennej
        changeSkybox() -- Natychmiastowa aktualizacja skyboxa po zmianie
    end)
end

getgenv().Zoom = {
    Enabled = false -- Set this to true or false to enable/disable the zoom
}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local defaultMaxZoom = 100
local currentMaxZoom = defaultMaxZoom  -- Store the initial max zoom

-- Initially set the camera's max zoom distance to the default value
player.CameraMaxZoomDistance = defaultMaxZoom

local isEnabled = getgenv().Zoom.Enabled

local function onMouseWheel(input, gameProcessed)
    if not isEnabled or gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local currentZoom = (camera.CFrame.Position - camera.Focus.Position).Magnitude
        
        if input.Position.Z < 0 then
            if currentZoom >= currentMaxZoom * 0.9 then
                currentMaxZoom = currentMaxZoom * 1.5
                player.CameraMaxZoomDistance = currentMaxZoom
            end
        end
    end
end

-- Function to toggle the zoom functionality on or off
local function toggleZoom(state)
    getgenv().Zoom.Enabled = state
    isEnabled = state

    if not isEnabled then
        -- When disabled, set CameraMaxZoomDistance back to the default value
        player.CameraMaxZoomDistance = defaultMaxZoom
    end
end

UserInputService.InputChanged:Connect(onMouseWheel)

-- Example usage: toggle zoom on or off
-- toggleZoom(true) -- Enable
-- toggleZoom(false) -- Disable and reset to default zoom

-- Update the toggle in the GUI and ensure it's reflected properly
PlayerSection:AddToggle("Infinite Zoom", getgenv().Zoom.Enabled, function(value)
    toggleZoom(value) -- Call toggleZoom function to change the zoom state
end)

-- GUI ustawienia aimbota
AimbotSection:AddToggle("Enable Camlock", getgenv().Aimbot.Enabled, function(value)
    getgenv().Aimbot.Enabled = value
end)

AimbotSection:AddTextbox("Camlock Keybind", getgenv().Aimbot.Keybind, function(value)
    getgenv().Aimbot.Keybind = value
end)

AimbotSection:AddTextbox("Prediction", tostring(getgenv().Aimbot.Prediction), function(value)
    getgenv().Aimbot.Prediction = tonumber(value) or 0.12
end)

AimbotSection:AddDropdown("Hitpart", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, getgenv().Aimbot.Hitpart, false, function(value)
    getgenv().Aimbot.Hitpart = value
end)

AimbotSection:AddTextbox("Smoothness", tostring(getgenv().Aimbot.Smoothness), function(value)
    getgenv().Aimbot.Smoothness = math.clamp(tonumber(value) or 1, 0, 1)
end)

AimbotSection:AddSlider("Max Distance", 50, 10000, getgenv().Aimbot.MaxDistance, 100, function(value)
    getgenv().Aimbot.MaxDistance = value
end)

AimbotSection:AddTextbox("MouseTp", tostring(getgenv().Aimbot.FallOffset), function(value)
    getgenv().Aimbot.FallOffset = tonumber(value) or 0  -- Default to 0 if input is invalid
end)

-- GUI ustawienia Silent Aim
SilentAimSection:AddToggle("Enable Silent aim", getgenv().Yuth.Silent.Enabled, function(value)
    getgenv().Yuth.Silent.Enabled = value
    if not value then
        SilentAimTarget = nil
        RemoveHighlight()
    end
end)

SilentAimSection:AddTextbox("Silent Aim Keybind", getgenv().Yuth.Silent.Keybind, function(value)
    getgenv().Yuth.Silent.Keybind = value
end)

SilentAimSection:AddTextbox("Silent Aim Prediction", tostring(getgenv().Yuth.Silent.Prediction), function(value)
    getgenv().Yuth.Silent.Prediction = tonumber(value) or 0.036572562
end)

SilentAimSection:AddDropdown("Hitpart", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, getgenv().Yuth.Silent.Part, false, function(value)
    getgenv().Yuth.Silent.Part = value
end)

SilentAimSection:AddToggle("Highlight Target", getgenv().Yuth.Highlight.Enabled, function(value)
    getgenv().Yuth.Highlight.Enabled = value
    if not value then
        RemoveHighlight()
    elseif SilentAimTarget then
        CreateHighlight(SilentAimTarget)
    end
end)

SilentAimSection:AddColorpicker("Highlight Color", getgenv().Yuth.Highlight.Color, function(value)
    getgenv().Yuth.Highlight.Color = value
    if HighlightObject then
        HighlightObject.FillColor = value
    end
end)

TargetStrafeSection:AddToggle("Toggle Taregt Strafe", getgenv().TargetStrafe.Enabled, function(value)
    getgenv().TargetStrafe.Enabled = value
        if not value then
    end
end)

TargetStrafeSection:AddSlider("Speed", 0, 100, getgenv().TargetStrafe.speed, 1, function(value)
    getgenv().TargetStrafe.speed = value
end)

TargetStrafeSection:AddSlider("Radius", 0, 50, getgenv().TargetStrafe.radius, 1, function(value)
    getgenv().TargetStrafe.radius = value
end)

TargetStrafeSection:AddSlider("Height", 0, 10, getgenv().TargetStrafe.heightOffset, 1, function(value)
    getgenv().TargetStrafe.heightOffset = value
end)

TargetStrafeSection:AddTextbox("Toggle Key", getgenv().TargetStrafe.Key, function(value)
    getgenv().TargetStrafe.Key = value
end)

AntilockSection:AddToggle("Enable Antilock", getgenv().Settings.Antilock, function(value)
    getgenv().Settings.Antilock = value
    ViewTarget.Enabled = value
end)

AntilockSection:AddToggle("Velocity Visual", getgenv().Settings.VelocityVisual, function(value)
    getgenv().Settings.VelocityVisual = value
end)

AntilockSection:AddToggle("Random mode", getgenv().Settings.RandomMode, function(value)
    getgenv().Settings.RandomMode = value
end)

AntilockSection:AddSlider("X", -1000, 0, getgenv().Settings.xAxis, 1, function(value)
    getgenv().Settings.xAxis = value
end)

AntilockSection:AddSlider("Y", -1000, 0, getgenv().Settings.yAxis, 1, function(value)
    getgenv().Settings.yAxis = value
end)

AntilockSection:AddSlider("Z", -1000, 0, getgenv().Settings.zAxis, 1, function(value)
    getgenv().Settings.zAxis = value
end)

AntilockSection:AddToggle("Spinbot Desync", getgenv().Settings.DesyncMode, function(value)
    getgenv().Settings.DesyncMode = value
end)

AntilockSection:AddSlider("Spinbot speed", 0, 0, getgenv().Settings.DesyncAngles, 1, function(value)
    getgenv().Settings.DesyncAngles = value
end)

-- Obsługa włączania/wyłączania Silent Aim przyciskiem
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[getgenv().Yuth.Silent.Keybind] then
        if getgenv().Yuth.Silent.Enabled then
            if SilentAimTarget then
                SilentAimTarget = nil
            else
                SilentAimTarget = GetClosestTarget()
            end
        end
    end
end)

FlightSection:AddToggle("Enable Flight", getgenv().Flight.Enabled, function(value)
    getgenv().Flight.Enabled = value
end)

FlightSection:AddSlider("Flight Speed", 0, 1000, getgenv().Flight.Speed, 1000, function(value)
    getgenv().Flight.Speed = value
end)

FlightSection:AddTextbox("Flight Keybind", getgenv().Flight.Keybind, function(value)
    getgenv().Flight.Keybind = value
end)

-- Ustawienie globalnej zmiennej cframe
getgenv().cframe = {
    Enabled = false,  -- Domyślnie wyłączona
    Speed = 1000,  -- Domyślna prędkość
    Keybind = "V"  -- Domyślny klawisz przełączania
}

local runServiceConnection

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    local function onUpdate(deltaTime)
        if not getgenv().cframe.Enabled then return end  -- Jeśli prędkość jest wyłączona, nic nie rób

        -- Jeśli prędkość jest ustawiona, zmieniamy CFrame na nową pozycję
        local direction = humanoid.MoveDirection
        if direction.magnitude > 0 then
            local newCFrame = hrp.CFrame + direction * getgenv().cframe.Speed * deltaTime
            hrp.CFrame = newCFrame
        end
    end

    -- Odłącz poprzednie połączenie, jeśli istnieje
    if runServiceConnection then
        runServiceConnection:Disconnect()
    end

    -- Podłącz funkcję do zdarzenia Heartbeat
    runServiceConnection = RunService.Heartbeat:Connect(onUpdate)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Funkcja do obsługi przełączania klawisza
local function onToggleKeyPressed(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[getgenv().cframe.Keybind] then
        getgenv().cframe.Enabled = not getgenv().cframe.Enabled  -- Przełącz flagę
        if not getgenv().cframe.Enabled then
            -- Resetujemy CFrame do aktualnej pozycji
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame
            end
        end
    end
end

-- Ustawienie prędkości chodu na odpowiednią wartość
UserInputService.InputBegan:Connect(onToggleKeyPressed)

-- Dodanie suwaczka w GUI do sekcji CFrame
CFrameSection:AddToggle("Enable CFrame", getgenv().cframe.Enabled, function(value)
    getgenv().cframe.Enabled = value
    if not value and runServiceConnection then
        runServiceConnection:Disconnect()
        runServiceConnection = nil
    elseif value and LocalPlayer.Character then
        setupCharacter(LocalPlayer.Character)
    end
end)

CFrameSection:AddSlider("CFrame Speed", 0, 0, getgenv().cframe.Speed, 1, function(value)
    getgenv().cframe.Speed = value
end)

CFrameSection:AddTextbox("Toggle Keybind", getgenv().cframe.Keybind, function(value)
    getgenv().cframe.Keybind = value
end)

getgenv().Visuals = {
    ForceFieldEnabled = false,
    ForceFieldGunEnabled = false,
    TrailEnabled = false,
    ForceFieldColor = Color3.fromRGB(255, 255, 255),
    ForceFieldGunColor = Color3.fromRGB(255, 255, 255),
    TrailColor = Color3.fromRGB(255, 255, 255),
    TrailLifetime = 1.5,
    TrailWidth = 0.6,
    TrailInstance = nil,
    OriginalColors = {} -- Przechowywanie oryginalnych kolorów części postaci
}

local function updateForceField()
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Accessory") then
                local part = obj:IsA("Accessory") and obj:FindFirstChild("Handle") or obj
                
                if part and part:IsA("BasePart") then
                    if getgenv().Visuals.ForceFieldEnabled then
                        -- Zapisz oryginalny kolor przed zmianą
                        if not getgenv().Visuals.OriginalColors[part] then
                            getgenv().Visuals.OriginalColors[part] = part.Color
                        end
                        part.Material = Enum.Material.ForceField
                        part.Color = getgenv().Visuals.ForceFieldColor
                    else
                        part.Material = Enum.Material.Plastic
                        -- Przywróć oryginalny kolor
                        if getgenv().Visuals.OriginalColors[part] then
                            part.Color = getgenv().Visuals.OriginalColors[part]
                        end
                    end
                end
            end
        end
    end
end

local function updateForceFieldGun()
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                if getgenv().Visuals.ForceFieldGunEnabled then
                    -- Zapisz oryginalny kolor przed zmianą
                    if not getgenv().Visuals.OriginalColors[handle] then
                        getgenv().Visuals.OriginalColors[handle] = handle.Color
                    end
                    handle.Material = Enum.Material.ForceField
                    handle.Color = getgenv().Visuals.ForceFieldGunColor
                else
                    handle.Material = Enum.Material.Plastic
                    -- Przywróć oryginalny kolor
                    if getgenv().Visuals.OriginalColors[handle] then
                        handle.Color = getgenv().Visuals.OriginalColors[handle]
                    end
                end
            end
        end
    end
end

local function createTrail()
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local trail = Instance.new("Trail")
        trail.Color = ColorSequence.new(getgenv().Visuals.TrailColor)
        trail.Lifetime = getgenv().Visuals.TrailLifetime
        trail.WidthScale = NumberSequence.new(getgenv().Visuals.TrailWidth)
        trail.Enabled = true

        local attachment0 = Instance.new("Attachment", humanoidRootPart)
        local attachment1 = Instance.new("Attachment", humanoidRootPart)
        attachment0.Position = Vector3.new(0, -0.5, 0)
        attachment1.Position = Vector3.new(0, -0.5, -1)

        trail.Attachment0 = attachment0
        trail.Attachment1 = attachment1
        trail.Parent = humanoidRootPart

        getgenv().Visuals.TrailInstance = trail
    end
end

local function updateTrail()
    if getgenv().Visuals.TrailEnabled then
        if not getgenv().Visuals.TrailInstance or not getgenv().Visuals.TrailInstance.Parent then
            createTrail()
        else
            getgenv().Visuals.TrailInstance.Enabled = true
            getgenv().Visuals.TrailInstance.Color = ColorSequence.new(getgenv().Visuals.TrailColor)
        end
    elseif getgenv().Visuals.TrailInstance then
        getgenv().Visuals.TrailInstance:Destroy()
        getgenv().Visuals.TrailInstance = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if getgenv().Visuals.TrailEnabled then
        createTrail() -- Tworzenie nowego traila po respawnie
    end
    updateForceField()
end)

RunService.Heartbeat:Connect(function()
    updateForceField()
    updateForceFieldGun()
    updateTrail()
end)

TrailSection:AddToggle("Enable ForceField", getgenv().Visuals.ForceFieldEnabled, function(value)
    getgenv().Visuals.ForceFieldEnabled = value
end)

TrailSection:AddToggle("Enable ForceField Gun", getgenv().Visuals.ForceFieldGunEnabled, function(value)
    getgenv().Visuals.ForceFieldGunEnabled = value
end)

TrailSection:AddColorpicker("ForceField Color", getgenv().Visuals.ForceFieldColor, function(color)
    getgenv().Visuals.ForceFieldColor = color
end)

TrailSection:AddColorpicker("ForceField Gun Color", getgenv().Visuals.ForceFieldGunColor, function(color)
    getgenv().Visuals.ForceFieldGunColor = color
end)

TrailSection:AddToggle("Enable Trail", getgenv().Visuals.TrailEnabled, function(value)
    getgenv().Visuals.TrailEnabled = value
end)

TrailSection:AddColorpicker("Trail Color", getgenv().Visuals.TrailColor, function(color)
    getgenv().Visuals.TrailColor = color
end)

-- Define available hit sounds
local sfx = {
    ["Bameware"] = "16910460773",
    ["Skeet"] = "4753603610",
    ["Bonk"] = "3765689841",
    ["Lazer Beam"] = "130791043",
    ["Windows XP Error"] = "160715357",
    ["TF2 Hitsound"] = "3455144981",
    ["TF2 Critical"] = "296102734",
    ["TF2 Bat"] = "3333907347",
    ["Bow Hit"] = "1053296915",
    ["Bow"] = "3442683707",
    ["OSU"] = "7147454322",
    ["Minecraft Hit"] = "4018616850",
    ["Steve"] = "5869422451",
    ["1nn"] = "7349055654",
    ["Rust"] = "3744371091",
    ["TF2 Pan"] = "3431749479",
    ["Neverlose"] = "8679627751",
    ["Mario"] = "5709456554",
}

-- Convert sound names to dropdown options
local sfx_names = {}
for name, _ in pairs(sfx) do
    table.insert(sfx_names, name)
end

-- Store default hit sound before modifying
local hitSound = game.ReplicatedStorage:FindFirstChild("HitSound")
local defaultSoundId = hitSound and hitSound:IsA("Sound") and hitSound.SoundId or ""

-- Global settings
getgenv().Yuth.HitSounds = {
    Enabled = false,
    SelectedSound = "Skeet",
    Volume = "3" -- Default volume (string for text input)
}

-- Add Hit Sound settings to the Silent Aim section
SilentAimSection:AddToggle("Hit Sounds", getgenv().Yuth.HitSounds.Enabled, function(value)
    getgenv().Yuth.HitSounds.Enabled = value
    updateHitSound()
end)

SilentAimSection:AddDropdown("Select Hit Sound", sfx_names, getgenv().Yuth.HitSounds.SelectedSound, false, function(value)
    getgenv().Yuth.HitSounds.SelectedSound = value
    updateHitSound()
end)

SilentAimSection:AddTextbox("Hit Sound Volume", getgenv().Yuth.HitSounds.Volume, function(value)
    local num = tonumber(value) -- Convert input to number
    if num then
        getgenv().Yuth.HitSounds.Volume = num
        updateHitSound()
    end
end)

-- Function to update hit sound settings
function updateHitSound()
    local hitSound = game.ReplicatedStorage:FindFirstChild("HitSound")
    if hitSound and hitSound:IsA("Sound") then
        if getgenv().Yuth.HitSounds.Enabled then
            -- Apply selected sound
            hitSound.SoundId = "rbxassetid://" .. sfx[getgenv().Yuth.HitSounds.SelectedSound]
            hitSound.Volume = getgenv().Yuth.HitSounds.Volume
            print("[Hit Sounds] Set to:", getgenv().Yuth.HitSounds.SelectedSound, "Volume:", getgenv().Yuth.HitSounds.Volume)
        else
            -- Reset to default sound
            hitSound.SoundId = defaultSoundId
            hitSound.Volume = 1
            print("[Hit Sounds] Disabled - Reset to default sound.")
        end
    else
        warn("[Hit Sounds] Could not find HitSound in ReplicatedStorage.")
    end
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local SilentAimTarget = nil
local HighlightObject = nil

-- Globalna zmienna do zarządzania BunnyHop
getgenv().BunnyHop = {
    Enabled = false,
    Power = 50,  -- Domyślna moc skoku
    SpeedBoost = 1.5  -- Mnożnik prędkości ruchu podczas skoku
}

-- Funkcja obsługująca BunnyHop
local function ToggleBunnyHop(state)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    if state then
        -- Aktywacja BunnyHop
        getgenv().BunnyHop.Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local rootPart = character.HumanoidRootPart
                
                if humanoid.FloorMaterial == Enum.Material.Air then
                    -- Przyspieszenie ruchu w powietrzu
                    local moveDirection = humanoid.MoveDirection
                    rootPart.Velocity = Vector3.new(moveDirection.X * getgenv().BunnyHop.SpeedBoost * 30, rootPart.Velocity.Y, moveDirection.Z * getgenv().BunnyHop.SpeedBoost * 30)
                else
                    -- Wykonanie skoku
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    humanoid.JumpPower = getgenv().BunnyHop.Power
                end
            end
        end)
    else
        -- Dezaktywacja BunnyHop
        if getgenv().BunnyHop.Connection then
            getgenv().BunnyHop.Connection:Disconnect()
            getgenv().BunnyHop.Connection = nil
        end
    end
end

-- Dodaje opcję Toggle do sektora BunnyHop
BunnyHopSection:AddToggle("Enable BunnyHop", getgenv().BunnyHop.Enabled, function(value)
    getgenv().BunnyHop.Enabled = value
    ToggleBunnyHop(value)
end)

-- Dodaje Slider do regulacji mocy skoku
BunnyHopSection:AddSlider("BunnyHop Power", 10, 100, getgenv().BunnyHop.Power, 5, function(value)
    getgenv().BunnyHop.Power = value
end)

-- Dodaje Textbox do wpisania mnożnika prędkości w powietrzu
BunnyHopSection:AddTextbox("BunnyHop Speed Boost", getgenv().BunnyHop.SpeedBoost, function(value)
    local newSpeedBoost = tonumber(value)
    if newSpeedBoost then
        getgenv().BunnyHop.SpeedBoost = math.clamp(newSpeedBoost, 1, 5) -- Ograniczenie wartości (1-3)
    end
end)

getgenv().rapidfire = false

local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local isActive = false  

local function continuouslyActivateHeldItem()
    while true do  
        if getgenv().rapidfire and isActive then
            local character = player.Character or player.CharacterAdded:Wait()
            local gunTool = character:FindFirstChildOfClass("Tool")

            if gunTool then
                gunTool:Activate()
            end
        end
        task.wait(0.01) -- Mniejsze obciążenie niż `wait(0.0001)`
    end
end

local function onMouseClick(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isActive = true
    end
end

local function onMouseRelease(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isActive = false
    end
end

userInputService.InputBegan:Connect(onMouseClick)
userInputService.InputEnded:Connect(onMouseRelease)

spawn(continuouslyActivateHeldItem)

PlayerSection:AddToggle("Faster shooting", getgenv().rapidfire, function(value)
    getgenv().rapidfire = value
end)

getgenv().Headless = getgenv().Headless or false
getgenv().Korblox = getgenv().Korblox or false
getgenv().KorbloxData = getgenv().KorbloxData or {OriginalMeshes = {}, OriginalTextures = {}}
getgenv().ShirtChanger = getgenv().ShirtChanger or {Enabled = false, AssetId = "", OriginalId = nil}
getgenv().PantsChanger = getgenv().PantsChanger or {Enabled = false, AssetId = "", OriginalId = nil}

local player = game.Players.LocalPlayer

-- Function to toggle head transparency (Headless)
local function toggleHeadless(state)
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            head.Transparency = state and 1 or 0
            for _, v in pairs(head:GetChildren()) do
                if v:IsA("Decal") then
                    v.Transparency = state and 1 or 0
                end
            end
        end
    end
end

-- Function to apply or remove Korblox leg
local function toggleKorblox(state)
    local character = player.Character
    if character then
        local rightFoot = character:FindFirstChild("RightFoot")
        local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
        local rightUpperLeg = character:FindFirstChild("RightUpperLeg")

        if rightFoot and rightLowerLeg and rightUpperLeg then
            if state then
                -- Save original meshes/textures before changing
                if not getgenv().KorbloxData.OriginalMeshes["RightFoot"] then
                    getgenv().KorbloxData.OriginalMeshes["RightFoot"] = rightFoot.MeshId
                    getgenv().KorbloxData.OriginalTextures["RightFoot"] = rightFoot.TextureID
                    getgenv().KorbloxData.OriginalMeshes["RightLowerLeg"] = rightLowerLeg.MeshId
                    getgenv().KorbloxData.OriginalTextures["RightLowerLeg"] = rightLowerLeg.TextureID
                    getgenv().KorbloxData.OriginalMeshes["RightUpperLeg"] = rightUpperLeg.MeshId
                    getgenv().KorbloxData.OriginalTextures["RightUpperLeg"] = rightUpperLeg.TextureID
                end

                -- Apply Korblox leg
                rightFoot.MeshId = "http://www.roblox.com/asset/?id=902942089"
                rightFoot.Transparency = 1
                rightLowerLeg.MeshId = "http://www.roblox.com/asset/?id=902942093"
                rightLowerLeg.Transparency = 1
                rightUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096"
                rightUpperLeg.TextureID = "http://roblox.com/asset/?id=902843398"
            else
                -- Restore original leg
                if getgenv().KorbloxData.OriginalMeshes["RightFoot"] then
                    rightFoot.MeshId = getgenv().KorbloxData.OriginalMeshes["RightFoot"]
                    rightFoot.TextureID = getgenv().KorbloxData.OriginalTextures["RightFoot"]
                    rightFoot.Transparency = 0
                    rightLowerLeg.MeshId = getgenv().KorbloxData.OriginalMeshes["RightLowerLeg"]
                    rightLowerLeg.TextureID = getgenv().KorbloxData.OriginalTextures["RightLowerLeg"]
                    rightLowerLeg.Transparency = 0
                    rightUpperLeg.MeshId = getgenv().KorbloxData.OriginalMeshes["RightUpperLeg"]
                    rightUpperLeg.TextureID = getgenv().KorbloxData.OriginalTextures["RightUpperLeg"]
                end
            end
        end
    end
end

-- Function to apply the shirt to the character
local function applyShirtToCharacter(character)
    local shirt = character:FindFirstChildOfClass("Shirt")
    if getgenv().ShirtChanger.Enabled then
        if shirt then
            if not getgenv().ShirtChanger.OriginalId then
                getgenv().ShirtChanger.OriginalId = shirt.ShirtTemplate
            end
            shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=" .. getgenv().ShirtChanger.AssetId
        else
            shirt = Instance.new("Shirt")
            shirt.Parent = character
            shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=" .. getgenv().ShirtChanger.AssetId
        end
    elseif getgenv().ShirtChanger.OriginalId then
        if shirt then
            shirt.ShirtTemplate = getgenv().ShirtChanger.OriginalId
        end
    end
end

-- Function to apply pants to the character
local function applyPantsToCharacter(character)
    local pants = character:FindFirstChildOfClass("Pants")
    if getgenv().PantsChanger.Enabled then
        if pants then
            if not getgenv().PantsChanger.OriginalId then
                getgenv().PantsChanger.OriginalId = pants.PantsTemplate
            end
            pants.PantsTemplate = "rbxassetid://" .. getgenv().PantsChanger.AssetId
        else
            pants = Instance.new("Pants")
            pants.Parent = character
            pants.PantsTemplate = "rbxassetid://" .. getgenv().PantsChanger.AssetId
        end
    elseif getgenv().PantsChanger.OriginalId then
        if pants then
            pants.PantsTemplate = getgenv().PantsChanger.OriginalId
        end
    end
end

-- Listen for character respawn
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Head", math.huge)
    toggleHeadless(getgenv().Headless) -- Apply headless state on respawn
    toggleKorblox(getgenv().Korblox) -- Apply Korblox if enabled
    applyShirtToCharacter(character) -- Apply shirt on respawn
    applyPantsToCharacter(character) -- Apply pants on respawn
end)

-- GUI Integration

-- Headless toggle
AvatarSection:AddToggle("Headless Head", getgenv().Headless, function(value)
    getgenv().Headless = value
    toggleHeadless(value)
end)

-- Korblox toggle (Moved directly under Headless)
AvatarSection:AddToggle("Korblox", getgenv().Korblox, function(value)
    getgenv().Korblox = value
    toggleKorblox(value)
end)

-- Shirt changer
AvatarSection:AddToggle("Shirt Changer", getgenv().ShirtChanger.Enabled, function(value)
    getgenv().ShirtChanger.Enabled = value
    if player.Character then applyShirtToCharacter(player.Character) end
end)

AvatarSection:AddTextbox("Shirt Asset ID", getgenv().ShirtChanger.AssetId, function(value)
    getgenv().ShirtChanger.AssetId = value
    if getgenv().ShirtChanger.Enabled and player.Character then applyShirtToCharacter(player.Character) end
end)

-- Pants changer
AvatarSection:AddToggle("Pants Changer", getgenv().PantsChanger.Enabled, function(value)
    getgenv().PantsChanger.Enabled = value
    if player.Character then applyPantsToCharacter(player.Character) end
end)

AvatarSection:AddTextbox("Pants Asset ID", getgenv().PantsChanger.AssetId, function(value)
    getgenv().PantsChanger.AssetId = value
    if getgenv().PantsChanger.Enabled and player.Character then applyPantsToCharacter(player.Character) end
end)

getgenv().Crosshair = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Rotation = false,
    Gap = 4,
    Length = 100,
    Thickness = 2.5,
    RotationSpeed = 50,
    Position = "Mouse",
    ShowText = false,
    TextColor = Color3.fromRGB(255, 255, 255)
}


CrosshairSection:AddToggle("Enable Crosshair", getgenv().Crosshair.Enabled, function(value)
    getgenv().Crosshair.Enabled = value
end)

CrosshairSection:AddToggle("Rotation", getgenv().Crosshair.Rotation, function(value)
    getgenv().Crosshair.Rotation = value
end)

CrosshairSection:AddToggle("Show Text", getgenv().Crosshair.ShowText, function(value)
    getgenv().Crosshair.ShowText = value
end)

CrosshairSection:AddColorpicker("Crosshair Color", getgenv().Crosshair.Color, function(color)
    getgenv().Crosshair.Color = color
end)

CrosshairSection:AddColorpicker("Text Color", getgenv().Crosshair.TextColor, function(color)
    getgenv().Crosshair.TextColor = color
end)

CrosshairSection:AddSlider("Gap", 0, 20, getgenv().Crosshair.Gap, 1, function(value)
    getgenv().Crosshair.Gap = value
end)

CrosshairSection:AddSlider("Length", 0, 150, getgenv().Crosshair.Length, 1, function(value)
    getgenv().Crosshair.Length = value
end)

CrosshairSection:AddSlider("Thickness", 0, 10, getgenv().Crosshair.Thickness, 1, function(value)
    getgenv().Crosshair.Thickness = value
end)

CrosshairSection:AddSlider("Rotation Speed", 0, 1000, getgenv().Crosshair.RotationSpeed, 1, function(value)
    getgenv().Crosshair.RotationSpeed = value
end)

CrosshairSection:AddDropdown("Position", {"Mouse", "Center"}, getgenv().Crosshair.Position, false, function(value)
    getgenv().Crosshair.Position = value
end)

-- Logika rysowania celownika
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game.Workspace.CurrentCamera

local Crosshair = {}
Crosshair.Lines = {}
Crosshair.Angle = 0

-- Funkcja tworząca linię
local function CreateLine()
    local Line = Drawing.new("Line")
    Line.Thickness = getgenv().Crosshair.Thickness
    Line.Color = getgenv().Crosshair.Color
    Line.Visible = getgenv().Crosshair.Enabled
    return Line
end

-- Tworzenie 4 linii celownika
for i = 1, 4 do
    Crosshair.Lines[i] = CreateLine()
end

-- Tworzenie napisu pod celownikiem
local TextLabel = Drawing.new("Text")
TextLabel.Size = 20
TextLabel.Visible = getgenv().Crosshair.ShowText
TextLabel.Text = "swindle.cc"
TextLabel.Outline = true
TextLabel.Color = getgenv().Crosshair.TextColor

-- Aktualizacja celownika
RunService.RenderStepped:Connect(function()
    if not getgenv().Crosshair.Enabled then
        for _, line in pairs(Crosshair.Lines) do
            line.Visible = false
        end
        TextLabel.Visible = false
        return
    end

    local Center
    if getgenv().Crosshair.Position == "Mouse" then
        Center = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    else
        Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    local Gap = math.clamp(getgenv().Crosshair.Gap, 0, 20)
    local Length = math.clamp(getgenv().Crosshair.Length, 0, 150)
    local Thickness = math.clamp(getgenv().Crosshair.Thickness, 0, 10)
    local RotationSpeed = math.clamp(getgenv().Crosshair.RotationSpeed, 0, 1000)

    if getgenv().Crosshair.Rotation then
        Crosshair.Angle = Crosshair.Angle + (RotationSpeed / 1000)
    end

    local Directions = {
        Vector2.new(1, 0),
        Vector2.new(-1, 0),
        Vector2.new(0, 1),
        Vector2.new(0, -1)
    }

    for i, Dir in ipairs(Directions) do
        local RotatedDir = Vector2.new(
            Dir.X * math.cos(Crosshair.Angle) - Dir.Y * math.sin(Crosshair.Angle),
            Dir.X * math.sin(Crosshair.Angle) + Dir.Y * math.cos(Crosshair.Angle)
        )

        local StartPos = Center + RotatedDir * Gap
        local EndPos = Center + RotatedDir * (Gap + Length)

        local Line = Crosshair.Lines[i]
        Line.From = StartPos
        Line.To = EndPos
        Line.Thickness = Thickness
        Line.Color = getgenv().Crosshair.Color
        Line.Visible = true
    end

    -- Ustawienie tekstu pod celownikiem
    if getgenv().Crosshair.ShowText then
        TextLabel.Position = Vector2.new(Center.X - (TextLabel.TextBounds.X / 2), Center.Y + Gap + Length + 10)
        TextLabel.Color = getgenv().Crosshair.TextColor
        TextLabel.Visible = true
    else
        TextLabel.Visible = false
    end
end)

-- 🔹 Funkcja do tworzenia podświetlenia
local function CreateHighlight(target)
    if getgenv().Yuth.Highlight.Enabled and target and target.Character then
        if HighlightObject then HighlightObject:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = target.Character
        highlight.Parent = game.CoreGui
        highlight.FillColor = getgenv().Yuth.Highlight.Color
        highlight.FillTransparency = getgenv().Yuth.Highlight.Transparency
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Biały obrys
        highlight.OutlineTransparency = 0

        HighlightObject = highlight
    end
end

-- 🔹 Funkcja do usuwania podświetlenia
local function RemoveHighlight()
    if HighlightObject then
        HighlightObject:Destroy()
        HighlightObject = nil
    end
end

getgenv().CloneChams = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    RespawnTime = 0.5
}

getgenv().ChinaHat = {
    Enabled = false,
    Rainbow = false,
    Radius = 1,
    Sides = 25,
    Color = Color3.fromRGB(255, 255, 255)
}

-- Clone Chams Logic
spawn(function()
    while true do
        if getgenv().CloneChams.Enabled then
            local player = game.Players.LocalPlayer
            if player.Character then
                player.Character.Archivable = true
                local Clone = player.Character:Clone()
                Clone.Name = "CloneChams" -- Remove username visibility
                
                for _, Obj in pairs(Clone:GetDescendants()) do
                    if Obj:IsA("BasePart") or Obj:IsA("MeshPart") or Obj:IsA("Part") then
                        Obj.CanCollide = false
                        Obj.Anchored = true
                        Obj.Material = Enum.Material.ForceField
                        Obj.Color = getgenv().CloneChams.Color
                        Obj.Transparency = 0
                        Obj.Size = Obj.Size + Vector3.new(0.03, 0.03, 0.03)
                    elseif Obj:IsA("Humanoid") or Obj:IsA("LocalScript") or Obj:IsA("Script") or Obj:IsA("Decal") then
                        Obj:Destroy()
                    end
                end
                
                Clone.Parent = game.Workspace
                wait(getgenv().CloneChams.RespawnTime)
                Clone:Destroy()
            end
        end
        wait(0.1)
    end
end)

-- China Hat Logic
local RunService = game:GetService("RunService")
local tau = math.pi * 2
local drawings = {}

for i = 1, getgenv().ChinaHat.Sides do
    drawings[i] = {Drawing.new('Line'), Drawing.new('Triangle')}
    drawings[i][1].ZIndex = 2
    drawings[i][1].Thickness = 2
    drawings[i][2].ZIndex = 1
    drawings[i][2].Filled = true
end

RunService.RenderStepped:Connect(function()
    if not getgenv().ChinaHat.Enabled then
        for _, v in ipairs(drawings) do
            v[1].Visible = false
            v[2].Visible = false
        end
        return
    end

    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild('Head') then return end
    
    local pos = player.Character.Head.Position + Vector3.new(0, 1, 0)
    local topWorld = pos + Vector3.new(0, 0.75, 0)

    for i = 1, getgenv().ChinaHat.Sides do
        local line, triangle = drawings[i][1], drawings[i][2]
        local color = getgenv().ChinaHat.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or getgenv().ChinaHat.Color

        local last = (i / getgenv().ChinaHat.Sides) * tau
        local next = ((i + 1) / getgenv().ChinaHat.Sides) * tau
        local lastWorld = pos + (Vector3.new(math.cos(last), 0, math.sin(last)) * getgenv().ChinaHat.Radius)
        local nextWorld = pos + (Vector3.new(math.cos(next), 0, math.sin(next)) * getgenv().ChinaHat.Radius)

        local lastScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(lastWorld)
        local nextScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(nextWorld)
        local topScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(topWorld)

        line.From = Vector2.new(lastScreen.X, lastScreen.Y)
        line.To = Vector2.new(nextScreen.X, nextScreen.Y)
        line.Color = color
        line.Visible = true

        triangle.PointA = Vector2.new(topScreen.X, topScreen.Y)
        triangle.PointB = line.From
        triangle.PointC = line.To
        triangle.Color = color
        triangle.Visible = true
    end
end)

-- GUI Integration
TrailSection:AddToggle("Clone Chams", getgenv().CloneChams.Enabled, function(value)
    getgenv().CloneChams.Enabled = value
end)

TrailSection:AddTextbox("Clone Chams Respawn Time", tostring(getgenv().CloneChams.RespawnTime), function(value)
    local num = tonumber(value)
    if num then
        getgenv().CloneChams.RespawnTime = num
    end
end)

TrailSection:AddColorpicker("Clone Chams Color", getgenv().CloneChams.Color, function(color)
    getgenv().CloneChams.Color = color
end)

TrailSection:AddToggle("China Hat", getgenv().ChinaHat.Enabled, function(value)
    getgenv().ChinaHat.Enabled = value
end)

TrailSection:AddToggle("China Hat Rainbow", getgenv().ChinaHat.Rainbow, function(value)
    getgenv().ChinaHat.Rainbow = value
end)

TrailSection:AddColorpicker("China Hat Color", getgenv().ChinaHat.Color, function(color)
    getgenv().ChinaHat.Color = color
end)

TrailSection:AddTextbox("China Hat Radius", tostring(getgenv().ChinaHat.Radius), function(value)
    local num = tonumber(value)
    if num then
        getgenv().ChinaHat.Radius = num
    end
end)

TrailSection:AddTextbox("China Hat Sides", tostring(getgenv().ChinaHat.Sides), function(value)
    local num = tonumber(value)
    if num then
        getgenv().ChinaHat.Sides = num
    end
end)

getgenv().ForceHit = {
    Enabled = false,       -- Włącz/Wyłącz
    Highlight = false,     -- Włącz/Wyłącz Podświetlenie
    Tracer = false,        -- Włącz/Wyłącz Tracer
    Notifications = false, -- Włącz/Wyłącz Powiadomienia
    Keybind = "C"         -- Domyślny klawisz (można zmienić w ustawieniach)
}

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Target = nil
local Tracer = Drawing.new("Line")
local Highlight = Instance.new("Highlight")
Highlight.Parent = game.CoreGui
Highlight.Enabled = false
Highlight.FillColor = Color3.fromRGB(255, 255, 255)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

getgenv().ForceHit = {
    Enabled = false,       -- Włącz/Wyłącz
    Highlight = false,     -- Włącz/Wyłącz Podświetlenie
    Tracer = false,        -- Włącz/Wyłącz Tracer
    Notifications = false, -- Włącz/Wyłącz Powiadomienia
    Keybind = "C"         -- Domyślny klawisz (można zmienić w ustawieniach)
}

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Target = nil
local Tracer = Drawing.new("Line")
local Highlight = Instance.new("Highlight")
Highlight.Parent = game.CoreGui
Highlight.Enabled = false
Highlight.FillColor = Color3.fromRGB(255, 255, 255)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

-- 📌 Ustawienia Tracera
Tracer.Thickness = 2
Tracer.Color = Color3.fromRGB(255, 255, 255)
Tracer.Transparency = 1
Tracer.Visible = false

-- 📌 Powiadomienie Swindle.CC
local isNotified = false -- Flaga kontrolująca, czy powiadomienie zostało wysłane

function SwindleNotification(targetName, status)
    if ForceHit.Notifications and not isNotified then
        isNotified = true
        StarterGui:SetCore("SendNotification", {
            Title = "Swindle.CC",
            Text = status .. " " .. targetName,
            Icon = "",
            Duration = 2.5
        })
    end
end

-- 📌 Znalezienie najbliższego gracza do celownika
function GetClosestToMouse()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local Head = player.Character.Head
            local HeadScreenPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Head.Position)
            if OnScreen then
                local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(HeadScreenPos.X, HeadScreenPos.Y)).Magnitude
                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestPlayer = player
                end
            end
        end
    end
    return ClosestPlayer
end

-- 📌 Aktualizacja Tracera
local function UpdateTracer()
    if ForceHit.Enabled and ForceHit.Tracer and Target and Target.Character and Target.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HeadPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Target.Character.Head.Position)
        local StartPos, StartOnScreen = workspace.CurrentCamera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
        if OnScreen and StartOnScreen then
            Tracer.From = Vector2.new(StartPos.X, StartPos.Y)
            Tracer.To = Vector2.new(HeadPos.X, HeadPos.Y)
            Tracer.Visible = true
        else
            Tracer.Visible = false
        end
    else
        Tracer.Visible = false
    end
end

RunService.RenderStepped:Connect(UpdateTracer)

-- 📌 Funkcja strzelania w HEAD
local function ShootBullet()
    if not ForceHit.Enabled or not Target or not Target.Character then return end
    
    local Head = Target.Character:FindFirstChild("Head")
    if not Head then return end

    local HitPosition = Head.Position
    local Offset = CFrame.new(0, 0, 0)

    local args = {
        [1] = "Shoot",
        [2] = {
            [1] = {
                [1] = {
                    ["Instance"] = Head,
                    ["Normal"] = Vector3.new(0, 1, 0),
                    ["Position"] = HitPosition
                }
            },
            [2] = {
                [1] = {
                    ["thePart"] = Head,
                    ["theOffset"] = Offset
                }
            },
            [3] = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0),
            [4] = HitPosition,
            [5] = tick()
        }
    }

    ReplicatedStorage.MainEvent:FireServer(unpack(args))
end

-- 📌 Obsługa klawisza do wybierania celu (z keybindem)
UserInputService.InputBegan:Connect(function(Input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if Input.KeyCode.Name == ForceHit.Keybind then
        if ForceHit.Enabled then
            if not Target then
                Target = GetClosestToMouse()
                if Target then
                    SwindleNotification(Target.Name, "Locked Onto")
                    if ForceHit.Highlight and Target.Character then
                        Highlight.Adornee = Target.Character
                        Highlight.Enabled = true
                    end
                    Target.CharacterAdded:Connect(function(newCharacter)
                        if Target == Players:GetPlayerFromCharacter(newCharacter) then
                            Highlight.Adornee = newCharacter
                        end
                    end)
                    isNotified = false
                else
                    SwindleNotification("No Target", "No enemies nearby!")
                end
            else
                SwindleNotification(Target.Name, "Unlocked")
                Target = nil
                Tracer.Visible = false
                Highlight.Enabled = false
                Highlight.Adornee = nil
                isNotified = false
            end
        else
            SwindleNotification("ForceHit Disabled", "Can't lock target when ForceHit is disabled!")
        end
    end
end)

-- 📌 Funkcja do obsługi resetu postaci
local function OnCharacterAdded(character)
    character.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            tool.Activated:Connect(ShootBullet)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

ForceHitSection:AddToggle("Force Hit", getgenv().ForceHit.Enabled, function(value)
    getgenv().ForceHit.Enabled = value
end)

ForceHitSection:AddTextbox("Force Hit Keybind", getgenv().ForceHit.Keybind, function(value)
    getgenv().ForceHit.Keybind = value
end)

ForceHitSection:AddToggle("Highlight Target", getgenv().ForceHit.Highlight, function(value)
    getgenv().ForceHit.Highlight = value
end)

ForceHitSection:AddToggle("Tracers", getgenv().ForceHit.Tracer, function(value)
    getgenv().ForceHit.Tracer = value
end)

ForceHitSection:AddToggle("Notifications", getgenv().ForceHit.Notifications, function(value)
    getgenv().ForceHit.Notifications = value
end)

getgenv().AntiSit = {
    Enabled = false -- Włącz/Wyłącz Anti-Sit
}

local function AntiSit()
    if not getgenv().AntiSit.Enabled then return end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid.Sit then
            Humanoid.Sit = false
        end
    end
end

RunService.Stepped:Connect(AntiSit)

PlayerSection:AddToggle("Anti Sit", getgenv().AntiSit.Enabled, function(value)
    getgenv().AntiSit.Enabled = value
end)

-- 🔹 Funkcja do obliczania prędkości (resolver)
local LastPositions = {}

local function CalculateVelocity(Character)
    if not LastPositions[Character] then
        LastPositions[Character] = {
            Position = Character.HumanoidRootPart.Position,
            Tick = tick()
        }
        return Vector3.new(0, 0, 0)
    end

    local LastData = LastPositions[Character]
    local DeltaTime = tick() - LastData.Tick
    local DeltaPosition = Character.HumanoidRootPart.Position - LastData.Position

    LastPositions[Character] = {
        Position = Character.HumanoidRootPart.Position,
        Tick = tick()
    }

    return DeltaPosition / DeltaTime
end

-- 🔹 Funkcja do obliczania najbliższego celu
local function GetClosestTarget()
    local Target, Closest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player ~= LocalPlayer then
            local HitPart = player.Character:FindFirstChild(getgenv().Yuth.Silent.Part)
            if HitPart then
                local Position, OnScreen = Camera:WorldToScreenPoint(HitPart.Position)
                local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                if Distance < Closest and OnScreen then
                    Closest = Distance
                    Target = player
                end
            end
        end
    end
    return Target
end

-- 🔹 Przełącznik Silent Aim
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[getgenv().Yuth.Silent.Keybind] then
        if getgenv().Yuth.Silent.Enabled then
            getgenv().Yuth.Silent.Enabled = false
            SilentAimTarget = nil
            RemoveHighlight()
        else
            getgenv().Yuth.Silent.Enabled = true
            SilentAimTarget = GetClosestTarget()
            CreateHighlight(SilentAimTarget)
        end
    end
end)

-- 🔹 Aktualizacja celu Silent Aim i podświetlenia
RunService.RenderStepped:Connect(function()
    if getgenv().Yuth.Silent.Enabled then
        if not SilentAimTarget or not SilentAimTarget.Character then
            SilentAimTarget = GetClosestTarget()
            CreateHighlight(SilentAimTarget)
        end
    else
        SilentAimTarget = nil
        RemoveHighlight()
    end
end)

-- 🔹 Hookowanie __index
local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index = newcclosure(function(self, v)
    if getgenv().Yuth.Silent.Enabled and SilentAimTarget and tostring(v) == "Hit" then
        local hitPart = getgenv().Yuth.Silent.Part
        if SilentAimTarget.Character and SilentAimTarget.Character:FindFirstChild(hitPart) then
            local targetPart = SilentAimTarget.Character[hitPart]
            local Velocity = CalculateVelocity(SilentAimTarget.Character)
            local predictedPosition = targetPart.Position + (Velocity * getgenv().Yuth.Silent.Prediction)
            return CFrame.new(predictedPosition)
        end
    end
    return backupindex(self, v)
end)
