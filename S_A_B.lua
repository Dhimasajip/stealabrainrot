-- [[ KAMIAPA MAIN SCRIPT - STRICT LIMIT VERSION ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ PENGATURAN PEMBATAS ]]
getgenv().MAX_BUY_PER_ITEM = 5 -- Batas maksimal Anda
getgenv().PURCHASED_LOG = getgenv().PURCHASED_LOG or {} 

local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 
local RETURN_DISTANCE = 2 

-- [[ FUNGSI CEK LIMIT KETAT ]]
local function isUnderLimit(model)
    local id = model:GetAttribute("Index") or model.Name
    local currentCount = getgenv().PURCHASED_LOG[id] or 0
    
    if currentCount >= getgenv().MAX_BUY_PER_ITEM then
        return false
    end
    return true
end

-- [[ STAY AT HOME ]]
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local targetPos = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
            if (root.Position - targetPos).Magnitude >= RETURN_DISTANCE then
                root.CFrame = CFrame.new(targetPos)
            end
        end
        task.wait(0.1)
    end
end)

-- [[ SISTEM PEMBELIAN DENGAN LOCK ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then
        local id = model:GetAttribute("Index") or model.Name
        
        -- CEK APAKAH ITEM ADA DI TARGET_LIST DAN MASIH DI BAWAH LIMIT
        local isTargetItem = false
        for _, v in ipairs(getgenv().TARGET_LIST or {}) do
            if id == v then isTargetItem = true break end
        end

        if isTargetItem and isUnderLimit(model) then
            task.wait(0.5) -- Jeda aman agar tidak dianggap spamming
            
            -- Lakukan pembelian
            fireproximityprompt(prompt)
            
            -- Update Log Pembelian
            getgenv().PURCHASED_LOG[id] = (getgenv().PURCHASED_LOG[id] or 0) + 1
            print("KAMIAPA: " .. id .. " dibeli (" .. getgenv().PURCHASED_LOG[id] .. "/" .. getgenv().MAX_BUY_PER_ITEM .. ")")
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
            local hasTool = char:FindFirstChildOfClass("Tool")
            if not hasTool then
                for _, t in ipairs(backpack:GetChildren()) do
                    if string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil") then
                        hum:EquipTool(t) break
                    end
                end
            end
        end
        task.wait(5)
    end
end)

print("KAMIAPA: Skrip Limit Berhasil Dimuat!")
