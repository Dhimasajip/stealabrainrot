-- [[ KAMIAPA MAIN SCRIPT ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- Koordinat Home [cite: 1]
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 
local RETURN_DISTANCE = 2 

-- Logika Stay & Return on Hit
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then
            local targetPos = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
            if hum.Health < lastHealth then -- Fitur Return on Hit
                root.CFrame = CFrame.new(targetPos)
            end
            if (root.Position - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- Sistem Purchase [cite: 1]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and getgenv().TARGET_LIST then
        for _, v in ipairs(getgenv().TARGET_LIST) do
            if (model:GetAttribute("Index") or model.Name) == v then
                task.wait(0.05)
                fireproximityprompt(prompt)
            end
        end
    end
end)

-- Anti-AFK [cite: 1]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(360)
    end
end)
