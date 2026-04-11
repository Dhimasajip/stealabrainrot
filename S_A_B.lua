-- [[ KAMIAPA IMPROVED - AUTO MOVE + NAME-BASED LIMIT ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- [[ KONFIGURASI ]]
getgenv().MAX_BUY_PER_ITEM = 5 -- Kamu bisa ubah batas ini
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 
getgenv().FORGOTTEN_UNITS = {} -- Untuk mematikan unit yang sudah limit

local LAST_PURCHASE_TIME = 0
local COOLDOWN_TIME = 1.5 
local GRAB_RADIUS = 20

-- [[ FUNGSI MENDAPATKAN NAMA UNIT (ANTI-RANDOM ID) ]]
local function getCleanUnitName(model)
    -- Prioritas 1: Baca teks dari BillboardGui (tulisan di atas kepala unit)
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    if textLabel and textLabel.Text ~= "" then
        return string.lower(textLabel.Text)
    end
    
    -- Prioritas 2: Gunakan Atribut Index atau Nama Model
    local rawName = model:GetAttribute("Index") or model.Name
    return string.lower(tostring(rawName))
end

-- [[ CEK APAKAH UNIT VALID ]]
local function isValidTarget(model)
    local unitName = getCleanUnitName(model)
    
    -- Cek apakah unit masuk daftar TARGET_LIST
    for _, target in ipairs(getgenv().TARGET_LIST or {}) do
        local targetLower = string.lower(target)
        if string.find(unitName, targetLower) then
            -- CEK LIMIT: Gunakan nama target sebagai kunci log agar ID acak tidak berpengaruh
            local count = getgenv().PURCHASED_LOG[targetLower] or 0
            if count < getgenv().MAX_BUY_PER_ITEM then
                return targetLower
            end
        end
    end
    return nil
end

-- [[ LOOPING PERGERAKAN & BELI OTOMATIS ]]
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Scan area untuk mencari ProximityPrompt
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Purchase" then
                    local model = prompt:FindFirstAncestorOfClass("Model")
                    if model then
                        local targetKey = isValidTarget(model)
                        
                        if targetKey then
                            -- TELEPORT KE TARGET (Fitur dari skrip lama kamu)
                            root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0)
                            
                            -- EKSEKUSI BELI DENGAN COOLDOWN
                            if (tick() - LAST_PURCHASE_TIME) > COOLDOWN_TIME then
                                LAST_PURCHASE_TIME = tick()
                                task.wait(0.2)
                                fireproximityprompt(prompt)
                                
                                -- Update hitungan log
                                getgenv().PURCHASED_LOG[targetKey] = (getgenv().PURCHASED_LOG[targetKey] or 0) + 1
                                warn("KAMIAPA: Berhasil beli " .. targetKey .. " (" .. getgenv().PURCHASED_LOG[targetKey] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
                            end
                            break -- Fokus satu target
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [[ FITUR TAMBAHAN DARI KAMIAPA-EVENT.TXT ]]
-- Anti-AFK [cite: 6]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(300)
    end
end)

-- Auto Speed Coil [cite: 10]
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

print("KAMIAPA: Skrip Improved Berhasil Dimuat!")
