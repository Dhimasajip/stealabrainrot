-- [[ KAMIAPA MAIN SCRIPT - AUTO MOVE + STRICT LIMIT ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN ]]
getgenv().MAX_BUY_PER_ITEM = 5 -- Bisa kamu ubah sesuai kebutuhan
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2.5 

-- [[ FUNGSI PENYARINGAN & LIMIT ]]
local function checkTarget(prompt)
    if prompt.ActionText ~= "Purchase" then return nil end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    
    -- Ambil Nama dari Billboard (Nama Visual) atau Model
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    local rawName = textLabel and textLabel.Text or model.Name
    local cleanName = string.lower(tostring(rawName))
    
    -- Cari kecocokan di TARGET_LIST
    for _, t in ipairs(getgenv().TARGET_LIST or {}) do
        local targetLower = string.lower(t)
        if string.find(cleanName, targetLower) then
            -- CEK LIMIT: Jika sudah mencapai batas, jangan diproses
            local count = getgenv().PURCHASED_LOG[targetLower] or 0
            if count < getgenv().MAX_BUY_PER_ITEM then
                return targetLower
            end
        end
    end
    return nil
end

-- [[ LOOPING PERGERAKAN OTOMATIS ]]
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Cari ProximityPrompt terdekat yang valid (belum limit)
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local targetKey = checkTarget(prompt)
                    
                    if targetKey then
                        -- Teleport ke lokasi unit
                        root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0)
                        
                        -- Eksekusi Beli jika sudah dekat
                        if (tick() - LAST_PURCHASE_TIME) > COOLDOWN_TIME then
                            LAST_PURCHASE_TIME = tick()
                            task.wait(0.2)
                            fireproximityprompt(prompt)
                            
                            -- Update Log
                            getgenv().PURCHASED_LOG[targetKey] = (getgenv().PURCHASED_LOG[targetKey] or 0) + 1
                            warn("KAMIAPA: Beli " .. targetKey .. " (" .. getgenv().PURCHASED_LOG[targetKey] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
                        end
                        break -- Fokus ke satu target dulu
                    end
                end
            end
        end
        task.wait(0.5)
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

print("KAMIAPA: Skrip Auto-Move + Limit " .. getgenv().MAX_BUY_PER_ITEM .. "x Aktif!")
