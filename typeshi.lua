if getgenv().loadedl == true then
    return
end
getgenv().loadedl = true

local Players, Client, Mouse, RS, Camera, UserInputService =
    game:GetService("Players"),
    game:GetService("Players").LocalPlayer,
    game:GetService("Players").LocalPlayer:GetMouse(),
    game:GetService("RunService"),
    game.Workspace.CurrentCamera,
    game:GetService("UserInputService")

local Circle = Drawing.new("Circle")
Circle.Color = Color3.new(1, 1, 1)
Circle.Thickness = 1

local function UpdateFOV()
    if not Circle then
        return Circle
    end
    Circle.Visible = getgenv().n3ez.Silent.Setting.FOV["Visible"]
    Circle.Radius = getgenv().n3ez.Silent.Setting.FOV["Radius"] * 3
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + (game:GetService("GuiService"):GetGuiInset().Y))
    return Circle
end

RS.Heartbeat:Connect(UpdateFOV)

local function GetClosestPlayer()
    local MaxDist = math.huge
    local Target = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("Humanoid") and 
        v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild(n3ez.Camlock.HitPart) then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character[n3ez.Camlock.HitPart].Position)
            local Distance = (Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            
            if Distance < MaxDist and OnScreen then
                MaxDist = Distance
                Target = v
            end
        end
    end
    
    return Target
end

local Target
local Enabled = false
local Holding = false

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode[n3ez.Camlock.Key] then
        if n3ez.Camlock.Toggle then
            Enabled = not Enabled
            if Enabled then
                Target = GetClosestPlayer()
                getgenv().n3ez.Silent.Setting.Enabled = true
            else
                Target = nil
                getgenv().n3ez.Silent.Setting.Enabled = false
            end
        else
            Holding = true
            Target = GetClosestPlayer()
            getgenv().n3ez.Silent.Setting.Enabled = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode[n3ez.Camlock.Key] and not n3ez.Camlock.Toggle then
        Holding = false
        Target = nil
        getgenv().n3ez.Silent.Setting.Enabled = false
    end
end)

RS.RenderStepped:Connect(function()
    if (Enabled or Holding) and Target and Target.Character and Target.Character:FindFirstChild(n3ez.Camlock.HitPart) then
        local TargetPos = Target.Character[n3ez.Camlock.HitPart].Position
        
        if n3ez.Camlock.Prediction.Enabled then
            local Velocity = Target.Character[n3ez.Camlock.HitPart].Velocity
            TargetPos = TargetPos + (Velocity * n3ez.Camlock.Prediction.Amount)
        end
        
        if n3ez.Camlock.Shake.Enabled then
            TargetPos = TargetPos + Vector3.new(
                math.random(-n3ez.Camlock.Shake.X, n3ez.Camlock.Shake.X) / 100,
                math.random(-n3ez.Camlock.Shake.Y, n3ez.Camlock.Shake.Y) / 100,
                math.random(-n3ez.Camlock.Shake.Z, n3ez.Camlock.Shake.Z) / 100
            )
        end

        local CameraPosition = Camera.CFrame.Position
        local TargetCFrame = CFrame.lookAt(CameraPosition, TargetPos)
        
        if n3ez.Camlock.Smoothness.Enabled then
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, n3ez.Camlock.Smoothness.Amount)
        else
            Camera.CFrame = TargetCFrame
        end
    end
end)

-- Silent Aim
local Inset, Vector2New = game:GetService("GuiService"):GetGuiInset().Y, Vector2.new

local FOV = Drawing.new("Circle")
FOV.Transparency = 0.5
FOV.Thickness = 1.6
FOV.Color = Color3.fromRGB(230, 230, 250)
FOV.Filled = false

local function UpdateSilentFOV(Radius)
    if not FOV then
        return
    end
    FOV.Position = Vector2New(Mouse.X, Mouse.Y + Inset)
    FOV.Visible = getgenv().n3ez.Silent.Setting.FOV["Visible"]
    FOV.Radius = (Radius) * 3.067
    return FOV
end

RS.RenderStepped:Connect(function()
    UpdateSilentFOV(getgenv().n3ez.Silent.Setting.FOV["Radius"])
end)

local function WallCheck(destination, ignore)
    if getgenv().n3ez.Silent.Setting.WallCheck then
        local Origin = Camera.CFrame.p
        local CheckRay = Ray.new(Origin, destination - Origin)
        local Hit = game.workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
        return Hit == nil
    else
        return true
    end
end

local function GetClosestChar()
    local Target, Closest = nil, 1 / 0
    for _, v in pairs(game.Players:GetPlayers()) do
        if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
            local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2New(Position.X, Position.Y) - Vector2New(Mouse.X, Mouse.Y)).Magnitude

            if
                (FOV.Radius > Distance and Distance < Closest and OnScreen and
                    WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}))
             then
                Closest = Distance
                Target = v
            end
        end
    end
    return Target
end

local Old
Old = hookmetamethod(game, "__index", function(self, key)
    if self:IsA("Mouse") and key == "Hit" then
        if getgenv().n3ez.Silent.Setting.Enabled then
            local target = GetClosestChar()
            if target then
                local targetPart = target.Character[getgenv().n3ez.Silent.Setting.TargetPart]
                local predictedPosition = targetPart.Position + (targetPart.Velocity * getgenv().n3ez.Silent.Setting.Prediction)
                return CFrame.new(predictedPosition)
            end
        end
    end
    return Old(self, key)
end)

-- WalkSpeed
local defaultSpeed = 16
local speedEnabled = false

local function updateSpeed()
    if Client.Character and Client.Character:FindFirstChild("Humanoid") then
        if speedEnabled and n3ez.WalkSpeed.Options.Enabled then
            Client.Character.Humanoid.WalkSpeed = n3ez.WalkSpeed.Options.Speed
        else
            Client.Character.Humanoid.WalkSpeed = Client.Character.Humanoid.WalkSpeed
        end
    end
end

local speedConnection = RS.RenderStepped:Connect(updateSpeed)

Client.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateSpeed()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode[n3ez.WalkSpeed.Options.Keybind] then
        speedEnabled = not speedEnabled
        updateSpeed()
    end
end)

-- Text Display
if n3ez["Main"]["Visible Text"] == true then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "n3ez"
    Title.Size = UDim2.new(0, 100, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextStrokeTransparency = 0
    Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Title.Parent = ScreenGui

    local FPS = Instance.new("TextLabel")
    FPS.Name = "FPS"
    FPS.Size = UDim2.new(0, 200, 0, 30)
    FPS.Position = UDim2.new(0, 10, 0, 40)
    FPS.BackgroundTransparency = 1
    FPS.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPS.TextStrokeTransparency = 0
    FPS.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    FPS.Parent = ScreenGui

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(0, 200, 0, 30)
    Status.Position = UDim2.new(0, 10, 0, 70)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextStrokeTransparency = 0
    Status.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Status.Parent = ScreenGui

    local BulletRedirection = Instance.new("TextLabel")
    BulletRedirection.Name = "BulletRedirection"
    BulletRedirection.Size = UDim2.new(0, 200, 0, 30)
    BulletRedirection.Position = UDim2.new(0, 10, 0, 100)
    BulletRedirection.BackgroundTransparency = 1
    BulletRedirection.TextColor3 = Color3.fromRGB(255, 255, 255)
    BulletRedirection.TextStrokeTransparency = 0
    BulletRedirection.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    BulletRedirection.Parent = ScreenGui

    local WalkspeedStatus = Instance.new("TextLabel")
    WalkspeedStatus.Name = "WalkspeedStatus"
    WalkspeedStatus.Size = UDim2.new(0, 200, 0, 30)
    WalkspeedStatus.Position = UDim2.new(0, 10, 0, 130)
    WalkspeedStatus.BackgroundTransparency = 1
    WalkspeedStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    WalkspeedStatus.TextStrokeTransparency = 0
    WalkspeedStatus.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    WalkspeedStatus.Parent = ScreenGui

    local function UpdateStatus()
        if Enabled and Target then
            Status.Text = "Aiming: Enabled"
        else
            Status.Text = "Aiming: Disabled"
        end

        if getgenv().n3ez.Silent.Setting.Enabled then
            BulletRedirection.Text = "BulletRedirection: Enabled"
        else
            BulletRedirection.Text = "BulletRedirection: Disabled"
        end

        if speedEnabled then
            WalkspeedStatus.Text = "Walkspeed: Enabled"
        else
            WalkspeedStatus.Text = "Walkspeed: Disabled"
        end
    end

    local function UpdateFPS()
        local currentFPS = math.floor(1 / RS.RenderStepped:Wait())
        FPS.Text = "FPS: " .. tostring(currentFPS)
    end

    RS.RenderStepped:Connect(function()
        UpdateStatus()
        UpdateFPS()
    end)
end
