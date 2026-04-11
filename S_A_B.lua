-- [[ KAMIAPA MAIN SCRIPT - AUTO MOVE + EDITABLE LIMIT ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN LIMIT - BISA KAMU UBAH ]]
getgenv().MAX_BUY_PER_ITEM = 5 -- Ganti angka ini untuk mengatur max pembelian
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 

local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 2.5 

-- [[ FUNGSI IDENTIFIKASI NAMA UNIT ]]
local function getUnitName(model)
    -- Mencari nama dari BillboardGui (tulisan di atas unit)
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    
    if textLabel and textLabel.Text ~= "" then
        return string.lower(textLabel.Text)
    end
    
    -- Cadangan jika tidak ada Billboard
    return string.lower(model:GetAttribute("Index") or model.Name)
end

-- [[ SISTEM CEK TARGET & LIMIT ]]
local function isValidTarget(prompt)
    if prompt.ActionText ~= "Purchase" then return nil end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    
    local unitName = getUnitName(model)
    
    -- Cek apakah unit masuk dalam daftar TARGET_LIST
    for _, target in ipairs(getgenv().TARGET_LIST or {}) do
        local targetLower = string.lower(target)
        if string.find(unitName, targetLower) then
            -- CEK LIMIT PEMBELIAN
            local currentCount = getgenv().PURCHASED_LOG[targetLower] or 0
            if currentCount < getgenv().MAX_BUY_PER_ITEM then
                return targetLower
            end
        end
    end
    return nil
end

-- [[ LOOPING PERGERAKAN (DARI SKRIP LAMA) ]]
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Cari item valid di workspace
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local targetKey = isValidTarget(prompt)
                    
                    if targetKey then
                        -- Teleport langsung ke unit (seperti skrip lama kamu)
                        root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0)
                        
                        -- Eksekusi Beli
                        if (tick() - LAST_PURCHASE_TIME) > COOLDOWN_TIME then
                            LAST_PURCHASE_TIME = tick()
                            task.wait(0.2)
                            fireproximityprompt(prompt)
                            
                            -- Update hitungan ke log
                            getgenv().PURCHASED_LOG[targetKey] = (getgenv().PURCHASED_LOG[targetKey] or 0) + 1
                            warn("KAMIAPA: Berhasil beli " .. targetKey .. " (" .. getgenv().PURCHASED_LOG[targetKey] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
                        end
                        break -- Fokus beli satu ini dulu
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [[ AUTO SPEED COIL (DARI KAMIAPA-EVENT.TXT) ]]
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not char:FindFirstChildOfClass("Tool") then
                for _, t in ipairs(backpack:GetChildren()) do
                    if string.find(string.lower(t.Name), "coil") or string.find(string.lower(t.Name), "speed") then
                        hum:EquipTool(t)
                        break
                    end
                end
            end
        end
        task.wait(5)
    end
end)

print("KAMIAPA: Skrip Auto-Move + Limit Berhasil Dimuat!")
