-- [[ KAMIAPA MAIN SCRIPT - ULTIMATE LIMIT LOCK ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS ]]
getgenv().MAX_BUY_PER_ITEM = 5 --
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2 

-- [[ FUNGSI PENYARINGAN KETAT ]]
local function getCategory(model)
    local name = tostring(model:GetAttribute("Index") or model.Name):lower()
    
    -- Cari apakah nama unit mengandung kata dari TARGET_LIST
    if getgenv().TARGET_LIST then
        for _, target in ipairs(getgenv().TARGET_LIST) do
            if string.find(name, target:lower()) then
                return target:lower() -- Mengunci ke nama di TARGET_LIST
            end
        end
    end
    return nil
end

-- [[ SISTEM PEMBELIAN DENGAN DOUBLE CHECK ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    if (tick() - LAST_PURCHASE_TIME) < COOLDOWN_TIME then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then
        local category = getCategory(model)
        
        -- Hanya proses jika item ada di TARGET_LIST
        if category then
            -- CEK LIMIT: Jika sudah 5 atau lebih, matikan tombolnya
            local currentCount = getgenv().PURCHASED_LOG[category] or 0
            if currentCount >= getgenv().MAX_BUY_PER_ITEM then
                prompt.Enabled = false
                prompt:Destroy() -- Hapus prompt agar tidak bisa ditekan manual
                return 
            end

            -- EKSEKUSI BELI
            LAST_PURCHASE_TIME = tick()
            task.wait(0.2)
            
            pcall(function()
                fireproximityprompt(prompt)
                getgenv().PURCHASED_LOG[category] = currentCount + 1
                warn("KAMIAPA: " .. category .. " dibeli (" .. getgenv().PURCHASED_LOG[category] .. "/5)")
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
