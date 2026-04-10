-- [[ KAMIAPA MAIN SCRIPT - FINAL STABLE ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS & POSISI ]]
getgenv().MAX_BUY_PER_ITEM = 15 --
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 1.5 

-- GANTI KOORDINAT DI BAWAH INI SESUAI TEMPAT BERDIRI KAMU
local HOME_POS = Vector3.new(-410.13562, -6.50197, 208.25595) --

-- [[ STAY AT HOME (ANTI-TELEPORT SPAM) ]]
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            -- Hanya teleport jika jarak karakter terlalu jauh dari titik aman
            if (root.Position - HOME_POS).Magnitude > 3 then 
                root.CFrame = CFrame.new(HOME_POS)
            end
        end
        task.wait(1)
    end
end)

-- [[ SISTEM PEMBELIAN DENGAN LOCK KETAT ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    if (tick() - LAST_PURCHASE_TIME) < COOLDOWN_TIME then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then
        local id = model:GetAttribute("Index") or model.Name
        
        -- Cek Target List
        local isTargetItem = false
        for _, v in ipairs(getgenv().TARGET_LIST or {}) do
            if id == v then isTargetItem = true break end
        end

        -- Cek Limit
        local currentCount = getgenv().PURCHASED_LOG[id] or 0
        if isTargetItem and currentCount < getgenv().MAX_BUY_PER_ITEM then
            LAST_PURCHASE_TIME = tick()
            task.wait(0.1)
            pcall(function()
                fireproximityprompt(prompt)
                getgenv().PURCHASED_LOG[id] = currentCount + 1
                print("KAMIAPA: Beli " .. id .. " (" .. getgenv().PURCHASED_LOG[id] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
            end)
        end
    end
end)

-- [[ AUTO SPEED COIL ]]
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not char:FindFirstChildOfClass("Tool") then
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
