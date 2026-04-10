-- [[ KAMIAPA MAIN SCRIPT - FULL VERSION ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ KOORDINAT HOME ]]
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 
local RETURN_DISTANCE = 2 

-- [[ LOGIKA STAY & RETURN ON HIT ]]
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            local currentPos = root.Position
            local targetPos = Vector3.new(HOME_POS.X, currentPos.Y, HOME_POS.Z)
            
            -- Jika darah berkurang (kena hit), teleport balik
            if hum.Health < lastHealth then
                root.CFrame = CFrame.new(targetPos)
            end

            -- Jika menjauh dari titik home
            if (currentPos - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- [[ SISTEM PURCHASE ]]
workspace.DescendantAdded:Connect(function(o)
    if o:IsA("Model") and getgenv().TARGET_LIST then
        local idx = o:GetAttribute("Index") or o.Name
        for _,v in ipairs(getgenv().TARGET_LIST) do
            if idx == v then
                table.insert(getgenv().TARGET_QUEUE or {}, o)
            end
        end
    end
end)

-- [[ ANTI-AFK ]]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(360)
    end
end)
