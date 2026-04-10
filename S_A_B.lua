if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")

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
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) [cite: 4]
local RETURN_DISTANCE = 2

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
	if getgenv().FORGOTTEN_UNITS[getUnitID(m)] then
		return false
	end
	local idx = m:GetAttribute("Index")
	if not idx then return false end
	for _,v in ipairs(getgenv().TARGET_LIST) do
		if idx == v then
			return canProcessUnit(m)
		end
	end
	return false
end

local function getTargetPart(model)
	if model.PrimaryPart then
		return model.PrimaryPart
	end
	for _,d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			return d
		end
	end
end

local function hasPurchasePrompt(model)
	for _,d in ipairs(model:GetDescendants()) do
		if d:IsA("ProximityPrompt") and d.ActionText == "Purchase" then
			return true
		end
	end
	return false
end

local function addTarget(unit)
	if getgenv().TARGET_SPAWN_TIME[unit] then return end
	getgenv().TARGET_SPAWN_TIME[unit] = tick()
	table.insert(getgenv().TARGET_QUEUE,unit)
end

local function scanExistingTargets()
	for _,o in ipairs(workspace:GetDescendants()) do
		if o:IsA("Model") and isTarget(o) then
			addTarget(o)
		end
	end
end

scanExistingTargets()

workspace.DescendantAdded:Connect(function(o)
	if o:IsA("Model") and isTarget(o) then
		addTarget(o)
	end
end)

local lastCash
local cashValue

local function setupCashWatcher()
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end
	cashValue = stats:FindFirstChild("Cash") or stats:FindFirstChild("Money") or stats:FindFirstChild("Coins")
	if not cashValue then return end
	lastCash = cashValue.Value
	cashValue:GetPropertyChangedSignal("Value"):Connect(function()
		if not getgenv().currentTarget then
			lastCash = cashValue.Value
			return
		end
		if cashValue.Value < lastCash then
			local tgt = getgenv().currentTarget
			if tgt then
				getgenv().FORGOTTEN_UNITS[getUnitID(tgt)] = true
			end
			getgenv().currentTarget = nil
		end
		lastCash = cashValue.Value
	end)
end

task.spawn(function()
	repeat task.wait(1) until player:FindFirstChild("leaderstats")
	setupCashWatcher()
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.ActionText ~= "Purchase" then return end
	local model = prompt:FindFirstAncestorOfClass("Model")
	if not model then return end
	if not isTarget(model) then return end
	task.wait(0.05)
	pcall(function()
		fireproximityprompt(prompt)
	end)
end)

-- Logika Stay di Home & Balik saat di-hit
task.spawn(function()
    local lastHealth = 100
    
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            local currentPos = root.Position
            local targetPos = Vector3.new(HOME_POS.X, currentPos.Y, HOME_POS.Z)
            local distance = (currentPos - targetPos).Magnitude

            -- Jika darah berkurang (kena hit)
            if hum.Health < lastHealth then
                getgenv().currentTarget = nil -- Batalkan target
                root.CFrame = CFrame.new(targetPos) -- Instan balik ke home
            end

            -- Jika terdorong atau menjauh dari titik stay
            if distance >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- Anti-AFK
task.spawn(function()
	while true do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			for _=1,2 do
				VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.I,false,game)
				VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.I,false,game)
			end
			for _=1,2 do
				VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.O,false,game)
				VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.O,false,game)
			end
		end
		task.wait(360)
	end
end)

-- Auto Speed Coil
if not getgenv().__KAMI_APA_AUTO_SPEED_COIL then
	getgenv().__KAMI_APA_AUTO_SPEED_COIL = true
	local function equipSpeedCoil()
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		local backpack = player:FindFirstChildOfClass("Backpack")
		if not backpack then return end
		for _,tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and string.find(string.lower(tool.Name),"speed") then
				hum:EquipTool(tool)
				break
			end
		end
	end
	player.CharacterAdded:Connect(function()
		task.wait(1)
		equipSpeedCoil()
	end)
	task.spawn(function()
		while true do
			equipSpeedCoil()
			task.wait(1)
		end
	end)
end
