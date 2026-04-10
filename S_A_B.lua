-- [[ KAMIAPA MAIN SCRIPT - TIME-LOCK VERSION ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS ]]
getgenv().MAX_BUY_PER_ITEM = 5
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {}
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2 -- Jeda 2 detik antar pembelian (Atur sesuai keinginan)

local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 

-- [[ STAY AT HOME ]]
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
        end
        task.wait(0.5)
    end
end)

-- [[ SISTEM PEMBELIAN DENGAN TIME-LOCK ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- CEK 1: Apakah baru saja membeli? (Anti-Spam Waktu)
    if (tick() - LAST_PURCHASE_TIME) < COOLDOWN_TIME then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then
        local id = model:GetAttribute("Index") or model.Name
        
        -- CEK 2: Apakah ada di TARGET_LIST?
        local isTargetItem = false
        for _, v in ipairs(getgenv().TARGET_LIST or {}) do
            if id == v then isTargetItem = true break end
        end

        if isTargetItem then
            -- CEK 3: Apakah sudah mencapai limit?
            local currentCount = getgenv().PURCHASED_LOG[id] or 0
            if currentCount < getgenv().MAX_BUY_PER_ITEM then
                
                -- KUNCI WAKTU SEKARANG
                LAST_PURCHASE_TIME = tick()
                
                task.wait(0.1) -- Jeda sangat singkat untuk sinkronisasi
                
                pcall(function()
                    fireproximityprompt(prompt)
                    getgenv().PURCHASED_LOG[id] = currentCount + 1
                    print("KAMIAPA: Beli " .. id .. " (" .. getgenv().PURCHASED_LOG[id] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
                end)
            end
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

-- [[ ANTI-AFK ]]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(300)
    end
end)
