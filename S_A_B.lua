-- Reset Global Variable untuk menghindari konflik
getgenv().__KAMI_APA_MAIN_RUNNING = nil
task.wait(0.1)
getgenv().__KAMI_APA_MAIN_RUNNING = true

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) [cite: 4]
local RETURN_DISTANCE = 5 [cite: 4]

-- Inisialisasi Tabel
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().UNIT_SPAWN_COUNT = {}
getgenv().SEEN_UNIT_INSTANCES = {}
getgenv().TARGET_QUEUE = {}
getgenv().currentTarget = nil

-- Fungsi Deteksi Target [cite: 1, 2]
local function getUnitID(m)
    return m:GetAttribute("Index") or m.Name
end

local function isTarget(m)
    if getgenv().FORGOTTEN_UNITS[getUnitID(m)] then return false end
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end
    end
    return false
end

-- LOGIKA RETURN SAAT TERKENA HIT (DARAH BERKURANG)
local lastHealth = 100
local function setupReturnLogic(char)
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    lastHealth = hum.Health

    hum.HealthChanged:Connect(function(newHealth)
        if newHealth < lastHealth then
            -- Langsung balik ke HOME_POS jika kena hit
            hum:MoveTo(Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z))
        end
        lastHealth = newHealth
    end)
end

player.CharacterAdded:Connect(setupReturnLogic)
if player.Character then setupReturnLogic(player.Character) end

-- LOOP RETURN JARAK RUTIN
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            local target = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
            if (root.Position - target).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(target)
            end
        end
        task.wait(1)
    end
end)

-- PERBAIKAN TOTAL: KLIK PROMPT TANPA fireproximityprompt (Mencegah Nil Error) 
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if not model or not isTarget(model) then return end

    task.wait(0.1)

    -- Gunakan pcall agar jika executor error, script tidak berhenti total
    pcall(function()
        -- Simulasi tekan tombol E (atau HoldDuration)
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()
    end)
end)

-- ANTI AFK [cite: 5]
task.spawn(function()
    while true do
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.O, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.O, false, game)
        end)
        task.wait(300)
    end
end)

-- AUTO EQUIP SPEED COIL [cite: 5]
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local backpack = player:FindFirstChildOfClass("Backpack")
        
        if hum and backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if string.find(string.lower(tool.Name), "speed") then
                    hum:EquipTool(tool)
                end
            end
        end
        task.wait(2)
    end
end)
