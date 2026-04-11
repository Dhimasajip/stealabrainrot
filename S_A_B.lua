-- [[ KAMIAPA MAIN SCRIPT - NO TELEPORT + MAX BUY ACTIVE ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS ]]
getgenv().MAX_BUY_PER_ITEM = 15 -- Batas maksimal beli per jenis item
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2 

-- [[ FUNGSI DETEKSI TARGET ]]
local function isTarget(model)
    if not getgenv().TARGET_LIST then return false end
    local name = model:GetAttribute("Index") or model.Name
    
    -- Cek apakah sudah mencapai batas beli
    local currentCount = getgenv().PURCHASED_LOG[name] or 0
    if currentCount >= getgenv().MAX_BUY_PER_ITEM then
        return false
    end

    for _, targetName in ipairs(getgenv().TARGET_LIST) do
        if string.find(string.lower(name), string.lower(targetName)) then
            return true
        end
    end
    return false
end

-- [[ AUTO PURCHASE (ANTI-SPAM) ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Jeda waktu agar tidak spam klik berlebihan
    if (tick() - LAST_PURCHASE_TIME) < COOLDOWN_TIME then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        local name = model:GetAttribute("Index") or model.Name
        
        LAST_PURCHASE_TIME = tick()
        task.wait(0.2)
        
        pcall(function()
            fireproximityprompt(prompt)
            -- Catat pembelian ke log
            getgenv().PURCHASED_LOG[name] = (getgenv().PURCHASED_LOG[name] or 0) + 1
            print("KAMIAPA: Beli " .. name .. " (" .. getgenv().PURCHASED_LOG[name] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
        end)
    end
end)

-- [[ AUTO SPEED COIL ]]
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local holding = char:FindFirstChildOfClass("Tool")
            if not holding then
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

print("KAMIAPA: Script Berhasil Dimuat (Max Buy Aktif & No Teleport)!")
