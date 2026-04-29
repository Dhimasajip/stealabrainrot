-- KAMI_APA_MAIN_MERGED
task.wait(10)
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- --- KONFIGURASI ---
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().UNIT_SPAWN_COUNT = {}
getgenv().SEEN_UNIT_INSTANCES = {}
getgenv().MAX_SPAWN_BEFORE_FORGET = 12
getgenv().GRAB_RADIUS = 25
getgenv().TARGET_TIMEOUT = 50
getgenv().CHASE_DELAY = 0.5
getgenv().TARGET_QUEUE = {}
getgenv().currentTarget = nil
getgenv().targetStartTime = 0
getgenv().TARGET_SPAWN_TIME = {}

-- --- FUNGSI UTAMA ---
local function getUnitID(m) return m:GetAttribute("Index") or m.Name end

local function canProcessUnit(m)
    if getgenv().SEEN_UNIT_INSTANCES[m] then return not getgenv().FORGOTTEN_UNITS[getUnitID(m)] end
    getgenv().SEEN_UNIT_INSTANCES[m] = true
    local id = getUnitID(m)
    getgenv().UNIT_SPAWN_COUNT[id] = (getgenv().UNIT_SPAWN_COUNT[id] or 0) + 1
    if getgenv().UNIT_SPAWN_COUNT[id] >= getgenv().MAX_SPAWN_BEFORE_FORGET then
        getgenv().FORGOTTEN_UNITS[id] = true
        return false
    end
    return true
end

local function isTarget(m)
    if getgenv().FORGOTTEN_UNITS[getUnitID(m)] then return false end
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _,v in ipairs(getgenv().TARGET_LIST) do if idx == v then return canProcessUnit(m) end end
    return false
end

-- --- FITUR ANTI-AFK (SIMULASI INPUT) ---
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        task.wait(math.random(280, 320)) -- Lompat interval 5 menit agar aman
    end
end)

-- --- FITUR AUTO FARM & BUY ---
workspace.DescendantAdded:Connect(function(o) if o:IsA("Model") and isTarget(o) then table.insert(getgenv().TARGET_QUEUE, o) end end)

task.spawn(function()
    while true do
        if not getgenv().currentTarget then
            getgenv().currentTarget = table.remove(getgenv().TARGET_QUEUE, 1)
            getgenv().targetStartTime = tick()
        end
        task.wait(1)
    end
end)

-- --- FITUR AUTO SPEED ---
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp = player:FindFirstChildOfClass("Backpack")
        if hum and bp then
            for _,t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), "speed") then
                    hum:EquipTool(t)
                end
            end
        end
        task.wait(2)
    end
end)

-- --- FITUR AUTO BUY & OPEN ---
task.spawn(function()
    while true do
        local tgt = getgenv().currentTarget
        if tgt and tgt.Parent then
            for _,v in ipairs(tgt:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled and (v.ActionText == "Purchase" or v.ActionText == "Open") then
                    pcall(function() fireproximityprompt(v) end)
                end
            end
        end
        task.wait(0.3)
    end
end)

print("KAMI_APA_MERGED ACTIVE")
