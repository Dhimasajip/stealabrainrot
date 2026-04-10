-- [[ KAMIAPA MAIN SCRIPT - FULL VERSION FIXED ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS & POSISI ]]
getgenv().MAX_BUY_PER_ITEM = 5 -- Maksimal beli per jenis item (bisa Anda ubah)
getgenv().PURCHASED_LOG = {}    -- Mencatat jumlah yang sudah dibeli
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 
local RETURN_DISTANCE = 2 

-- [[ INISIALISASI DATA ]]
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().UNIT_SPAWN_COUNT = {}
getgenv().SEEN_UNIT_INSTANCES = {}
getgenv().MAX_SPAWN_BEFORE_FORGET = 5

-- [[ FUNGSI UTILITY ]]
local function getUnitID(m)
    return m:GetAttribute("Index") or m.Name
end

local function canProcessUnit(m)
    local id = getUnitID(m)
    if getgenv().SEEN_UNIT_INSTANCES[m] then
        return not getgenv().FORGOTTEN_UNITS[id]
    end
    getgenv().SEEN_UNIT_INSTANCES[m] = true
    getgenv().UNIT_SPAWN_COUNT[id] = (getgenv().UNIT_SPAWN_COUNT[id] or 0) + 1
    if getgenv().UNIT_SPAWN_COUNT[id] >= getgenv().MAX_SPAWN_BEFORE_FORGET then
        getgenv().FORGOTTEN_UNITS[id] = true
        return false
    end
    return true
end

local function isTarget(m)
    local id = getUnitID(m)
    
    -- CEK 1: Apakah sudah mencapai batas maksimal beli?
    if (getgenv().PURCHASED_LOG[id] or 0) >= getgenv().MAX_BUY_PER_ITEM then
        return false
    end
    
    -- CEK 2: Apakah item ini sudah masuk daftar lupakan?
    if getgenv().FORGOTTEN_UNITS[id] then return false end
    
    -- CEK 3: Apakah ada di dalam TARGET_LIST?
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then 
            return canProcessUnit(m) 
        end
    end
    return false
end

-- [[ STAY AT HOME & RETURN ON HIT ]]
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then
            local targetPos = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
            if hum.Health < lastHealth then root.CFrame = CFrame.new(targetPos) end
            if (root.Position - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- [[ SISTEM PEMBELIAN (DENGAN PEMBATAS) ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        local id = getUnitID(model)
        
        task.wait(0.3) -- Jeda agar server tidak mengira spam
        pcall(function()
            fireproximityprompt(prompt)
            -- Tambah hitungan log setelah berhasil menekan tombol beli
            getgenv().PURCHASED_LOG[id] = (getgenv().PURCHASED_LOG[id] or 0) + 1
            print("KAMIAPA: Membeli " .. id .. " (" .. getgenv().PURCHASED_LOG[id] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
        end)
    end
end)

-- [[ AUTO SPEED COIL (ANTI-SPAM) ]]
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local holding = false
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and (string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil")) then
                    holding = true; break
                end
            end
            if not holding then
                for _, t in ipairs(backpack:GetChildren()) do
                    if t:IsA("Tool") and (string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil")) then
                        hum:EquipTool(t); break
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

print("KAMIAPA: Skrip Utama Berhasil Dimuat!")
