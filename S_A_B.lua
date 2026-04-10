-- [[ KAMIAPA MAIN SCRIPT - FULL VERSION ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ KONFIGURASI POSISI ]]
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) -- 
local RETURN_DISTANCE = 2 

-- [[ INISIALISASI DATA ]]
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
getgenv().TARGET_SPAWN_TIME = {}

-- [[ FUNGSI UTILITY ]]
local function getUnitID(m)
    return m:GetAttribute("Index") or m.Name
end

local function canProcessUnit(m)
    if getgenv().SEEN_UNIT_INSTANCES[m] then
        return not getgenv().FORGOTTEN_UNITS[getUnitID(m)]
    end
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
    for _,v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return canProcessUnit(m) end
    end
    return false
end

-- [[ LOGIKA STAY DI HOME & RETURN ON HIT ]]
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            local currentPos = root.Position
            local targetPos = Vector3.new(HOME_POS.X, currentPos.Y, HOME_POS.Z)
            
            -- Jika terkena hit (darah berkurang), teleport balik ke home 
            if hum.Health < lastHealth then
                getgenv().currentTarget = nil
                root.CFrame = CFrame.new(targetPos)
            end

            -- Jika menjauh dari titik home
            if (currentPos - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- [[ SISTEM SCAN & AUTO PURCHASE ]]
workspace.DescendantAdded:Connect(function(o)
    if o:IsA("Model") and isTarget(o) then
        table.insert(getgenv().TARGET_QUEUE, o)
    end
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        task.wait(0.05)
        pcall(function() fireproximityprompt(prompt) end)
    end
end)

-- [[ ANTI-AFK ]]
task.spawn(function()
    while true do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            for _=1,2 do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.O, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.O, false, game)
            end
        end
        task.wait(360) -- 
    end
end)

-- [[ AUTO SPEED COIL ]]
task.spawn(function()
    while true do
        local backpack = player:FindFirstChildOfClass("Backpack")
        local char = player.Character
        if backpack and char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "speed") then
                    hum:EquipTool(tool) [cite: 5]
                    break
                end
            end
        end
        task.wait(1)
    end
end)
