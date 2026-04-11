-- [[ KAMIAPA - NO RESPAWN VERSION ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- [[ KONFIGURASI ]]
getgenv().MAX_BUY_PER_ITEM = 5 
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2.5 

-- [[ FITUR AUTO-MOVE & LIMIT ]]
local function getCleanUnitName(model)
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    if textLabel and textLabel.Text ~= "" then return string.lower(textLabel.Text) end
    return string.lower(tostring(model:GetAttribute("Index") or model.Name))
end

task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Purchase" then
                    local model = prompt:FindFirstAncestorOfClass("Model")
                    if model then
                        local unitName = getCleanUnitName(model)
                        local isTarget = false
                        for _, t in ipairs(getgenv().TARGET_LIST or {}) do
                            if string.find(unitName, string.lower(t)) then
                                local count = getgenv().PURCHASED_LOG[string.lower(t)] or 0
                                if count < getgenv().MAX_BUY_PER_ITEM then
                                    root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0)
                                    if (tick() - LAST_PURCHASE_TIME) > COOLDOWN_TIME then
                                        LAST_PURCHASE_TIME = tick()
                                        task.wait(0.2)
                                        fireproximityprompt(prompt)
                                        getgenv().PURCHASED_LOG[string.lower(t)] = count + 1
                                        warn("KAMIAPA: Beli " .. t .. " (" .. count + 1 .. "/5)")
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [[ FITUR ANTI-AFK (DIPERTAHANKAN) ]]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(300)
    end
end)

-- [[ FITUR AUTO SPEED COIL (DIPERTAHANKAN) ]]
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and not char:FindFirstChildOfClass("Tool") then
                for _, t in ipairs(backpack:GetChildren()) do
                    if string.find(string.lower(t.Name), "coil") or string.find(string.lower(t.Name), "speed") then
                        hum:EquipTool(t) break
                    end
                end
            end
        end
        task.wait(5)
    end
end)

print("KAMIAPA: Skrip Tanpa Auto-Reset Berhasil Dimuat!")
