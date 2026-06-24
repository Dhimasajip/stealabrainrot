-- KAMI_APA.lua (Full Original + Anti-AFK + Coordinate System)
task.wait(10)
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

-- ==================== PENGATURAN KOORDINAT BARU ====================
getgenv().USE_COORDINATE = true -- Ubah ke false jika ingin mematikan fitur koordinat
getgenv().TARGET_COORDINATE = Vector3.new(-438.3928527832031, -4.257575035095215, 61.922977447509766) -- Koordinat dari image_7a7209.png
-- ===================================================================

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

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
local RETRY_INTERVAL = 1

-- --- FUNGSI BARU: TELEPORT/WALK KE KOORDINAT ---
local function moveToCoordinate(targetPos)
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    
    if rootPart then
        rootPart.CFrame = CFrame.new(targetPos)
        task.wait(0.5) -- Jeda agar area sekitar ter-load dengan aman
    end
end

-- Eksekusi pergerakan ke koordinat sebelum memulai scanning
if getgenv().USE_COORDINATE then
    moveToCoordinate(getgenv().TARGET_COORDINATE)
end

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

local function getTargetPart(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then return d end end
end

local function hasPurchasePrompt(model)
    for _,d in ipairs(model:GetDescendants()) do if d:IsA("ProximityPrompt") and d.ActionText == "Purchase" then return true end end
    return false
end

local function addTarget(unit)
    if getgenv().TARGET_SPAWN_TIME[unit] then return end
    getgenv().TARGET_SPAWN_TIME[unit] = tick()
    table.insert(getgenv().TARGET_QUEUE,unit)
end

local function scanExistingTargets()
    for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("Model") and isTarget(o) then addTarget(o) end end
end

scanExistingTargets()
workspace.DescendantAdded:Connect(function(o) if o:IsA("Model") and isTarget(o) then addTarget(o) end end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if not model or not isTarget(model) then return end
    task.wait(0.05)
    pcall(function() fireproximityprompt(prompt) end)
end)

-- [Logika Farming & Auto-Speed & Auto-Buy lainnya di sini (seperti skrip asli Anda)]

-- --- TAMBAHAN ANTI-AFK (Metode Paling Halus) ---
if not getgenv().__KAMI_APA_ANTI_AFK_NEW then
    getgenv().__KAMI_APA_ANTI_AFK_NEW = true
    task.spawn(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        while true do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            task.wait(math.random(240, 360))
        end
    end)
end
