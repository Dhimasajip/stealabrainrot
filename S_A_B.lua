-- [[ KAMIAPA MAIN SCRIPT - FINAL NAME-BASED LOCK ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS ]]
getgenv().MAX_BUY_PER_ITEM = 20 --
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2.5 

-- [[ FUNGSI MENDAPATKAN NAMA ASLI UNIT ]]
local function getRealUnitName(model)
    -- Mencari BillboardGui yang berisi nama unit di atas kepalanya
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    
    if textLabel and textLabel.Text ~= "" then
        return string.lower(textLabel.Text) -- Mengambil nama yang kamu lihat di game
    end
    
    -- Jika tidak ada Billboard, gunakan atribut atau nama model sebagai cadangan
    local fallback = model:GetAttribute("Index") or model.Name
    return string.lower(tostring(fallback))
end

-- [[ SISTEM PEMBELIAN DENGAN FILTER NAMA ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    if (tick() - LAST_PURCHASE_TIME) < COOLDOWN_TIME then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then
        local unitName = getRealUnitName(model)
        
        -- Cek apakah unit ini ada dalam TARGET_LIST kamu
        local isTarget = false
        local targetKey = ""
        for _, t in ipairs(getgenv().TARGET_LIST or {}) do
            if string.find(unitName, string.lower(t)) then
                isTarget = true
                targetKey = string.lower(t) -- Simpan nama target sebagai kunci log
                break
            end
        end

        if isTarget then
            -- CEK LIMIT BERDASARKAN NAMA TARGET (Bukan ID Acak)
            local currentCount = getgenv().PURCHASED_LOG[targetKey] or 0
            
            if currentCount < getgenv().MAX_BUY_PER_ITEM then
                LAST_PURCHASE_TIME = tick()
                task.wait(0.2)
                
                pcall(function()
                    fireproximityprompt(prompt)
                    getgenv().PURCHASED_LOG[targetKey] = currentCount + 1
                    warn("KAMIAPA: Berhasil beli " .. targetKey .. " (" .. getgenv().PURCHASED_LOG[targetKey] .. "/5)")
                end)
            else
                -- Jika sudah 5, hapus tombolnya agar tidak bisa diklik lagi
                prompt.Enabled = false
                prompt:Destroy()
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

print("KAMIAPA: Skrip Name-Based Lock Berhasil Dimuat!")
