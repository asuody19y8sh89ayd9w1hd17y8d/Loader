getgenv().Reduction = 100

local OldCFrameAngles; OldCFrameAngles = hookfunction(CFrame.Angles, function(...)
    local X, Y, Z = ...

    if select(4, ...) == "webhate is daddy" then
        return OldCFrameAngles(X, Y, Z)
    end

    local Caller = getcallingscript()

    if Caller and Caller.Name == "LocalScript" and X ~= 0 and Y == 0 and Z == 0 then
        local SpreadReduction = 1 - (Reduction / 100)
        return OldCFrameAngles(X * SpreadReduction, Y, Z)
    end

    return OldCFrameAngles(X, Y, Z)
end)

local Players, Workspace = game:GetService("Players"), game:GetService("Workspace")
local Player = Players.LocalPlayer

local SpreadPatterns = {
    -1.35,
    -0.9,
    0.25,
    0.55,
    1
}

local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Arguments, Method = { ... }, getnamecallmethod()

    if Method == "FireServer" and Arguments[1] == "Shoot" then
        local RemoteOrigin, MousePosition = Arguments[2][3], Arguments[2][4]
        local ServerTimeNow = Workspace.GetServerTimeNow(Workspace)
        local RandomGenerator = Random.new(ServerTimeNow)

        Arguments[2][5] = ServerTimeNow

        local Character = Player.Character
        local Tool = Character.FindFirstChildOfClass(Character, "Tool")
        local Module = Tool.FindFirstChild(Tool, "GunData")

        if Module and require(Module).is_shotgun then
            local SpreadResults = Arguments[2][1]

            local RandomAngleZ = RandomGenerator.NextNumber(RandomGenerator, -90, 90)
            local ZAxisRotation = CFrame.Angles(0, 0, math.rad(RandomAngleZ), "webhate is daddy")
            local SpreadIntensity = RandomGenerator.NextNumber(RandomGenerator, 0, 5.75) * (RandomGenerator.NextInteger(RandomGenerator, 0, 1) == 1 and 1 or -1)

            if SpreadIntensity > -0.35 and SpreadIntensity < 0.35 then
                SpreadIntensity = 0.35;
            end;

            for Index, SpreadEntry in next, SpreadResults do
                local DirectionToPosition = (MousePosition - RemoteOrigin).Unit

                local Unit = (CFrame.new(RemoteOrigin, RemoteOrigin + DirectionToPosition) * ZAxisRotation * CFrame.Angles(math.rad(SpreadPatterns[Index] * SpreadIntensity), 0, 0, "webhate is daddy")).LookVector

                SpreadEntry.Position = RemoteOrigin + (Unit * (MousePosition - RemoteOrigin).Magnitude)
            end
        end
    end

    return OldNamecall(Self, ...)
end)
