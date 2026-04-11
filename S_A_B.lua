if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) [cite: 4]
local RETURN_DISTANCE = 5

-- Konfigurasi Global
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

-- Fungsi Pendukung (Targeting & Cash)
local function getTargetPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _,d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then return d end
	end
end

local function hasPurchasePrompt(model)
	for _,d in ipairs(model:GetDescendants()) do
		if d:IsA("ProximityPrompt") and d.ActionText == "Purchase" then return true end
	end
	return false
end

local function addTarget(unit)
	if getgenv().TARGET_SPAWN_TIME[unit] then return end
	getgenv().TARGET_SPAWN_TIME[unit] = tick()
	table.insert(getgenv().TARGET_QUEUE,unit)
end

workspace.DescendantAdded:Connect(function(o)
	if o:IsA("Model") and isTarget(o) then addTarget(o) end
end)

-- Logika Kembali ke Titik Awal & Deteksi Hit
local lastHealth = 100
local function setupReturnLogic(char)
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	lastHealth = hum.Health

	hum.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			-- Jika terkena hit, paksa kembali ke HOME_POS [cite: 4]
			local target = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
			hum:MoveTo(target)
		end
		lastHealth = newHealth
	end)
end

player.CharacterAdded:Connect(setupReturnLogic)
if player.Character then setupReturnLogic(player.Character) end

-- Loop Utama Kembali ke Home (Setiap 1 detik)
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

-- Anti AFK & Purchase Logic (Sesuai File Asli) [cite: 3, 5]
ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.ActionText ~= "Purchase" then return end
	local model = prompt:FindFirstAncestorOfClass("Model")
	if not model or not isTarget(model) then return end
	task.wait(0.05)
	pcall(function() fireproximityprompt(prompt) end)
end)

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
