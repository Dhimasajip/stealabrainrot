-- [[ KAMIAPA MAIN SCRIPT - STRICT MAX BUY LOCK ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS ]]
getgenv().MAX_BUY_PER_ITEM = 5 -- Sesuai permintaan kamu (5 kali)
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2.5 -- Jeda sedikit lebih lama agar sinkronisasi server stabil

-- [[ FUNGSI DETEKSI TARGET ]]
local function isTarget(model)
    if not getgenv().TARGET_LIST then return false end
    
    -- Ambil ID unik (Index atau Name)
    local rawId = model:GetAttribute("Index") or model.Name
    local id = string.lower(tostring(rawId)) -- Gunakan lowercase agar konsisten
    
    -- CEK LIMIT PEMBELIAN
    local currentCount = getgenv().PURCHASED_LOG[id] or 0
    if currentCount >= getgenv().MAX_BUY_PER_ITEM then
        return false
    end

    -- Cek apakah ID ada di Target List
    for _, targetName in ipairs(getgenv().TARGET_LIST) do
        if string.find(id, string.lower(targetName)) then
            return true
        end
    end
    return false
end

-- [[ AUTO PURCHASE (LOCK VERSION) ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Anti-Spam Waktu
    if (tick() - LAST_PURCHASE_TIME) < COOLDOWN_TIME then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        local rawId = model:GetAttribute("Index") or model.Name
        local id = string.lower(tostring(rawId))
        
        -- Double Check Limit Sebelum Eksekusi
        if (getgenv().PURCHASED_LOG[id] or 0) < getgenv().MAX_BUY_PER_ITEM then
            LAST_PURCHASE_TIME = tick()
            
            pcall(function()
                fireproximityprompt(prompt)
                
                -- Update Hitungan
                getgenv().PURCHASED_LOG[id] = (getgenv().PURCHASED_LOG[id] or 0) + 1
                
                print("------------------------------------------")
                print("KAMIAPA: Berhasil Membeli!")
                print("Unit: " .. id)
                print("Status: " .. getgenv().PURCHASED_LOG[id] .. " / " .. getgenv().MAX_BUY_PER_ITEM)
                print("------------------------------------------")
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

-- [[ ANTI-AFK ]]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(300)
    end
end)

print("KAMIAPA: Skrip Ter-Update! Limit 5x Aktif.")
