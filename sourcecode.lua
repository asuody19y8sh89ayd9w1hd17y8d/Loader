if not getgenv().Loaded then
    getgenv().Loaded = true
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Invasion",
        Text = "Executed successfully",
        Duration = 3,
    })
else
    if Invasion and Invasion.Options and Invasion.Options.UpdateNotification == true then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Invasion",
            Text = "Settings Updated",
            Duration = 3,
        })
    end
end

local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()
local DrawingLib = Drawing
local isSpeeding = false

local mousePositionArgument = { Argument = "UpdateMousePos", Remote = "MainEvent" }

local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local mainEvent = replicatedStorage:FindFirstChild(mousePositionArgument.Remote)

local isA = game.IsA
local findFirstChild = game.FindFirstChild

local findPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
local getChildren = workspace.GetChildren
local getPlayers = players.GetPlayers

local getMouseLocation = inputService.GetMouseLocation
local worldToViewportPoint = camera.WorldToViewportPoint

local fireServer = mainEvent and mainEvent.FireServer or function() end

local twait = task.wait
local tspawn = task.spawn

local tinsert = table.insert
local tfind = table.find

local newVector3 = Vector3.new
local newVector2 = Vector2.new
local newCFrame = CFrame.new

local newRay = Ray.new
local fromHSV = Color3.fromHSV

local min = math.min
local random = math.random
local abs = math.abs
local rad = math.rad
local sin = math.sin
local cos = math.cos
local inf = math.huge
local pi = math.pi

local upper = string.upper
local sub = string.sub

local freeFall = Enum.HumanoidStateType.Freefall
local jumping = Enum.HumanoidStateType.Jumping
local enumKeyCode = Enum.KeyCode

local isLocking, targetPlayer = false, nil
local aimbotCircle = Drawing.new("Circle")

local updateFieldOfViewDrawings = function()
    local fieldOfView = Invasion.FieldOfView
    aimbotCircle.Visible = fieldOfView.Enabled
    aimbotCircle.Color = fieldOfView.Color
    aimbotCircle.Radius = fieldOfView.Size
    aimbotCircle.Transparency = fieldOfView.Transparency
    aimbotCircle.Filled = fieldOfView.Filled
    aimbotCircle.Position = getMouseLocation(inputService)
end

local isPlayerAlive = function(player: Player)
    return player.Character and findFirstChild(player.Character, "Humanoid") and player.Character.Humanoid.Health > 0
end

local wallCheck = function(character: Model)
    if not Invasion.Misc.Checks.WallCheck then
        return true
    end

    local targetPosition = character.HumanoidRootPart.Position
    local cameraPosition = camera.CFrame.Position
    local distance = (targetPosition - cameraPosition).Magnitude

    local hitPart, hitPosition = findPartOnRayWithIgnoreList(
        workspace,
        newRay(cameraPosition, (targetPosition - cameraPosition).Unit * distance),
        { localPlayer.Character, character }
    )

    return hitPart == nil or (hitPosition - cameraPosition).Magnitude >= distance
end

local getClosestPlayerToCursor = function(radius: number)
    local shortestDistance = radius
    local closestPlayer = nil
    local mousePosition = getMouseLocation(inputService)
    local part = Invasion.Aimbot.Part

    for _, player in next, getPlayers(players) do
        local character = player.Character
        if player ~= localPlayer and isPlayerAlive(player) and wallCheck(character) and character:FindFirstChild(part) then
            local onScreenPosition, isOnScreen = worldToViewportPoint(camera, character[part].Position)
            local distance = (newVector2(onScreenPosition.X, onScreenPosition.Y) - mousePosition).Magnitude

            if distance < shortestDistance and isOnScreen then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

local getRandomVector3 = function(aimbot: table)
    local positiveShakeAmount = aimbot.Shake.Amount
    local negativeShakeAmount = -positiveShakeAmount
    local factor = 0.01

    return newVector3(
        random(negativeShakeAmount, positiveShakeAmount) * factor,
        random(negativeShakeAmount, positiveShakeAmount) * factor,
        random(negativeShakeAmount, positiveShakeAmount) * factor
    )
end

local SpeedGlitch = false

inputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local macroKey = Enum.KeyCode[Invasion.Macro.Keybind]
    
    if macroKey and input.KeyCode == macroKey then
        SpeedGlitch = not SpeedGlitch
        if SpeedGlitch then
            coroutine.wrap(function()
                local macro = Invasion.Macro
                while SpeedGlitch and macro["Enabled"] do
                    local speed = macro["Speed"]
                    if macro["Type"] == "Electron" then
                        runService.Heartbeat:Wait()
                        keypress(0x49) -- I
                        runService.Heartbeat:Wait()
                        keypress(0x4F) -- O
                        runService.Heartbeat:Wait()
                        keyrelease(0x49)
                        runService.Heartbeat:Wait()
                        keyrelease(0x4F)
                    elseif macro["Type"] == "Third" then
                        task.wait(speed)
                        VirtualInputManager:SendKeyEvent(true, "I", false, game)
                        task.wait(speed)
                        VirtualInputManager:SendKeyEvent(true, "O", false, game)
                        task.wait(speed)
                        VirtualInputManager:SendKeyEvent(true, "I", false, game)
                        task.wait(speed)
                        VirtualInputManager:SendKeyEvent(true, "O", false, game)
                    elseif macro["Type"] == "First" then
                        task.wait(speed)
                        VirtualInputManager:SendMouseWheelEvent(0, 0, true, game)
                        task.wait(speed)
                        VirtualInputManager:SendMouseWheelEvent(0, 0, false, game)
                        task.wait(speed)
                        VirtualInputManager:SendMouseWheelEvent(0, 0, true, game)
                        task.wait(speed)
                        VirtualInputManager:SendMouseWheelEvent(0, 0, false, game)
                    end
                end
            end)()
        end
    end
end)

local MinecraftTextures = {
    wood = "http://www.roblox.com/asset/?id=10324380233",
    woodplanks = "http://www.roblox.com/asset/?id=9359126646",
    grass = "http://www.roblox.com/asset/?id=9267183930",
    slate = "http://www.roblox.com/asset/?id=136966049937099",
    brick = "http://www.roblox.com/asset/?id=9888913739",
    concrete = "http://www.roblox.com/asset/?id=16772273988",
    glass = "http://www.roblox.com/asset/?id=5132413910",
    TileSize = 5
}

local originalTextures = {}

local function saveOriginalState(part)
    if originalTextures[part] then return end
    local textures = {}
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("Texture") then
            table.insert(textures, {
                Face = child.Face,
                Texture = child.Texture,
                StudsPerTileU = child.StudsPerTileU,
                StudsPerTileV = child.StudsPerTileV,
                Transparency = child.Transparency,
                Name = child.Name
            })
        end
    end
    originalTextures[part] = {
        Material = part.Material,
        Color = part.Color,
        Textures = textures
    }
end

local function restoreOriginalState(part)
    local data = originalTextures[part]
    if not data then return end

    part.Material = data.Material
    part.Color = data.Color

    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("Texture") then
            child:Destroy()
        end
    end

    for _, texData in ipairs(data.Textures) do
        local tex = Instance.new("Texture")
        tex.Face = texData.Face
        tex.Texture = texData.Texture
        tex.StudsPerTileU = texData.StudsPerTileU
        tex.StudsPerTileV = texData.StudsPerTileV
        tex.Transparency = texData.Transparency
        tex.Name = texData.Name
        tex.Parent = part
    end
end

local function applyTextures()
    local settings = getgenv().Invasion or getgenv().Txt
    if not settings or not settings.Textures then
        return
    end

    local textures = settings.Textures

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then

            if textures.Enabled and not textures.Minecraft then
                saveOriginalState(v)
                v.Material = Enum.Material[textures.Material] or Enum.Material.Rock
                for _, child in ipairs(v:GetChildren()) do
                    if child:IsA("Texture") then
                        child:Destroy()
                    end
                end

            elseif textures.Minecraft and textures.Enabled then
                saveOriginalState(v)
                for _, child in ipairs(v:GetChildren()) do
                    if child:IsA("Texture") then child:Destroy() end
                end
                local selectedTexture
                if v.Material == Enum.Material.Wood then
                    selectedTexture = MinecraftTextures.wood
                elseif v.Material == Enum.Material.WoodPlanks then
                    selectedTexture = MinecraftTextures.woodplanks
                elseif v.Material == Enum.Material.Slate then
                    selectedTexture = MinecraftTextures.slate
                elseif v.Material == Enum.Material.Brick then
                    selectedTexture = MinecraftTextures.brick
                elseif v.Material == Enum.Material.Concrete then
                    selectedTexture = MinecraftTextures.concrete
                elseif v.Material == Enum.Material.Glass then
                    selectedTexture = MinecraftTextures.glass
                elseif v.Material == Enum.Material.Grass or v.Name:match("Grass") then
                    selectedTexture = MinecraftTextures.grass
                end
                if selectedTexture then
                    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                        local newTexture = Instance.new("Texture")
                        newTexture.Texture = selectedTexture
                        newTexture.Face = face
                        newTexture.StudsPerTileU = MinecraftTextures.TileSize
                        newTexture.StudsPerTileV = MinecraftTextures.TileSize
                        newTexture.Parent = v
                    end
                end
            else
                restoreOriginalState(v)
            end
        end
    end
end

applyTextures()

local RunService = game:GetService("RunService")
local lastClassic = nil
local lastMinecraft = nil

RunService.RenderStepped:Connect(function()
    local settings = getgenv().Invasion or getgenv().Txt
    if not settings or not settings.Textures then return end

    local currentClassic = settings.Textures.Enabled
    local currentMinecraft = settings.Textures.Minecraft

    if currentClassic ~= lastClassic or currentMinecraft ~= lastMinecraft then
        applyTextures()
        lastClassic = currentClassic
        lastMinecraft = currentMinecraft
    end
end)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RATE_PER_SECOND = 10

-- Główna funkcjonalność AutoStomp
RunService.Stepped:Connect(function(time, step)
    if getgenv().Invasion.AutoStomp then
        ReplicatedStorage.MainEvent:FireServer("Stomp")
    end
end)

local Lighting = game:GetService("Lighting")

local lastClockTime = -1
local lastTrunLightsOn = nil

local function updateLights(state)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			obj.Enabled = state
		end
	end
end

task.spawn(function()
	while true do
		local config = getgenv().Invasion.World

		if config.Enabled then
			-- Aktualizacja ClockTime
			if config.Clocktime ~= lastClockTime then
				Lighting.ClockTime = config.Clocktime
				lastClockTime = config.Clocktime
			end

			-- Aktualizacja świateł
			if config.TrunLightsOn ~= lastTrunLightsOn then
				updateLights(config.TrunLightsOn)
				lastTrunLightsOn = config.TrunLightsOn
			end
		end

		task.wait(0.5)
	end
end)

if getgenv().Invasion["Misc"].NoJumpCooldown then
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local IsA = game.IsA
    local newindex = nil

    newindex = hookmetamethod(game, "__newindex", function(self, Index, Value)
        if not checkcaller() and IsA(self, "Humanoid") and Index == "JumpPower" then
            return
        end
        return newindex(self, Index, Value)
    end)
end

local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local isActive = false  

local function continuouslyActivateHeldItem()
    while true do  
        if getgenv().Invasion.Misc.HoldShooting and isActive then
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

local isSpeeding = false
local walkSpeedConnection = nil

Mouse.KeyDown:Connect(function(key)
    local wsConf = getgenv().Invasion["WalkSpeed"]
    if wsConf.Enabled and key:lower() == wsConf.Keybind:lower() then
        isSpeeding = not isSpeeding

        local character = Client.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = isSpeeding and wsConf.Speed or 20

                if walkSpeedConnection then
                    walkSpeedConnection:Disconnect()
                end

                walkSpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if isSpeeding then
                        humanoid.WalkSpeed = wsConf.Speed
                    end
                end)
            end
        end
    end
end)

local debounce = false
local TotalRotation = 0
local LastRenderTime = tick()
local Spinning = false

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent or debounce then return end

    local spinConfig = getgenv().Invasion["Spin"]
    if not spinConfig.Enabled then return end

    if input.KeyCode == Enum.KeyCode[spinConfig.Keybind] then
        debounce = true
        Spinning = not Spinning
        if Spinning then
            TotalRotation = 0
            LastRenderTime = tick()
        end
        task.wait(0.1)
        debounce = false
    end
end)

RunService.RenderStepped:Connect(function()
    local spinConfig = getgenv().Invasion["Spin"]
    if not Spinning or not spinConfig.Enabled then return end

    local currentTime = tick()
    local timeDelta = math.min(currentTime - LastRenderTime, 0.01)
    LastRenderTime = currentTime

    local rotationAngle = spinConfig.SpinSpeed * timeDelta
    local rotation = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(rotationAngle))
    Camera.CFrame = Camera.CFrame * rotation

    TotalRotation = TotalRotation + rotationAngle
    if TotalRotation >= spinConfig.Degrees then
        Spinning = false
        TotalRotation = 0
    end
end)

runService.Heartbeat:Connect(function(deltaTime: number)
    updateFieldOfViewDrawings()

    if targetPlayer and isLocking and targetPlayer.Character and targetPlayer.Character.Parent and Invasion.Aimbot.Enabled then
        local character = targetPlayer.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            targetPlayer = nil
            isLocking = false
            return
        end

        local isFalling = humanoid:GetState() == freeFall
        local targetData = (isFalling and Invasion.Aimbot.Air.Enabled) and Invasion.Aimbot.Air or Invasion.Aimbot
        local targetPartName = targetData.Part

        local targetPart = character:FindFirstChild(targetPartName)
        if not targetPart then
            targetPlayer = nil
            isLocking = false
            return
        end

        local alpha = targetData.Smoothness
        local velocity = targetPart.Velocity
        local predictedVelocity = Vector3.new(
            velocity.X * targetData.Prediction.X,
            velocity.Y * targetData.Prediction.Y,
            velocity.Z * (targetData.Prediction.X + targetData.Prediction.Y) / 2
        )
        local goalPosition = targetPart.Position + predictedVelocity

        if Invasion.Aimbot.Shake.Enabled then
            goalPosition = goalPosition + getRandomVector3(Invasion.Aimbot)
        end

        local goal = newCFrame(camera.CFrame.Position, goalPosition)
        camera.CFrame = camera.CFrame:Lerp(goal, alpha)

        local checks = Invasion.Misc.Checks

        if checks.KnockedChecks then
            local bodyEffects = character:FindFirstChild("BodyEffects")
            local isKO = bodyEffects and bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value
            local isGrabbed = character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if humanoid.Health <= 0 or isKO or isGrabbed then
                targetPlayer = nil
                isLocking = false
            end
        end
    end
end)

-- Funkcja hookująca
local mt = getrawmetatable(game)
local backup

backup = hookfunction(mt.__newindex, newcclosure(function(self, key, value)
    if getgenv().Invasion.Misc.NoSlow then
        if key == "WalkSpeed" and value < 20 then
            value = 20
        end
    end
    return backup(self, key, value)
end))

local MetaTable = getrawmetatable(game)
local OldIndex = MetaTable.__index
setreadonly(MetaTable, false)

MetaTable.__index = function(self, key)
    if not checkcaller() and self == localPlayer:GetMouse() and Invasion.Silent and Invasion.Silent.Enabled then
        if key == "Hit" or key == "Target" then
            local targetPlayer = getClosestPlayerToCursor(inf)
            if targetPlayer and targetPlayer.Character then
                local targetPart = targetPlayer.Character:FindFirstChild(Invasion.Silent.Part)
                if targetPart then
                    local velocity = targetPart.Velocity or Vector3.zero
                    local predictedPosition = targetPart.Position + (velocity * Invasion.Silent.Prediction)
                    return key == "Hit" and CFrame.new(predictedPosition) or targetPart
                end
            end
        end
    end
    return OldIndex(self, key)
end
setreadonly(MetaTable, true)

inputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
    if gameProcessedEvent then
        return
    end

    local inputKeyCode = input.KeyCode
    local keyBind = Invasion.Aimbot.Keybind 

    if inputKeyCode == enumKeyCode[sub(upper(keyBind), 1, 1)] then
        isLocking = not isLocking
        targetPlayer = isLocking and getClosestPlayerToCursor(inf) or nil
    end
end)

getgenv().Loaded = true
