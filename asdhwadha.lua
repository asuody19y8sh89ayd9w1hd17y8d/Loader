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
