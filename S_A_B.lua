-- Mengubah nama global variable agar tidak terdeteksi blacklist 
if getgenv().__MY_APP_SECURE_RUNNING then return end
getgenv().__MY_APP_SECURE_RUNNING = true

task.wait(5)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
-- VirtualInputManager dihapus karena pemicu utama deteksi
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().UNIT_SPAWN_COUNT = {}
getgenv().SEEN_UNIT_INSTANCES = {}

getgenv().MAX_SPAWN_BEFORE_FORGET = 15
getgenv().GRAB_RADIUS = 30
getgenv().TARGET_TIMEOUT = 20
getgenv().CHASE_DELAY = 1.0 -- Ditingkatkan agar lebih manusiawi 

getgenv().TARGET_QUEUE = {}
getgenv().currentTarget = nil
getgenv().targetStartTime = 0
getgenv().TARGET_SPAWN_TIME = {}

local RETRY_INTERVAL = 1.5 -- Ditingkatkan agar tidak spamming 

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

local function getTargetPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _,d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then return d end
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

-- Sistem Cash Watcher
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
			if tgt then getgenv().FORGOTTEN_UNITS[getUnitID(tgt)] = true end
			getgenv().currentTarget = nil
		end
		lastCash = cashValue.Value
	end)
end

task.spawn(function()
	repeat task.wait(1) until player:FindFirstChild("leaderstats")
	setupCashWatcher()
end)

-- Perbaikan Interaksi: Ditambah Jeda Acak 
ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.ActionText ~= "Purchase" then return end
	local model = prompt:FindFirstAncestorOfClass("Model")
	if not model or model ~= getgenv().currentTarget then return end

	task.wait(math.random(0.5, 1.2)) -- Jeda agar tidak terdeteksi bot 

	pcall(function()
		fireproximityprompt(prompt)
	end)
end)

-- Perbaikan Loop Pergerakan Utama
task.spawn(function()
	while true do
		if not getgenv().currentTarget then
			repeat
				getgenv().currentTarget = table.remove(getgenv().TARGET_QUEUE,1)
			until not getgenv().currentTarget or getgenv().currentTarget.Parent
			getgenv().targetStartTime = tick()
		end

		local tgt = getgenv().currentTarget
		if tgt and tgt.Parent then
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local part = getTargetPart(tgt)

			if hum and hrp and part then
				local spawnTime = getgenv().TARGET_SPAWN_TIME[tgt]
				if not spawnTime or tick() - spawnTime >= getgenv().CHASE_DELAY then
					local dist = (hrp.Position - part.Position).Magnitude
					if dist > 2 then
						-- Tambah variasi posisi agar tidak kaku 
						local var = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
						hum:MoveTo(part.Position + var)
					end
					if dist <= getgenv().GRAB_RADIUS then
						if not hasPurchasePrompt(tgt) then
							local id = getUnitID(tgt)
							getgenv().FORGOTTEN_UNITS[id] = true
							getgenv().TARGET_SPAWN_TIME[tgt] = nil
							getgenv().currentTarget = nil
						end
					end
				end
			end
			if tick() - getgenv().targetStartTime >= getgenv().TARGET_TIMEOUT then
				getgenv().currentTarget = nil
			end
		else
			getgenv().currentTarget = nil
		end
		task.wait(RETRY_INTERVAL)
	end
end)

-- Waypoints Statis
local TARGETS = {
	Vector3.new(-348.08, -7.0, 200.22),
	Vector3.new(-317.96, -7.0, 173.27),
	Vector3.new(-351.60, -7.0, 140.55),
	Vector3.new(-473.55, -7.0, 190.71),
	Vector3.new(-508.02, -7.0, 172.87),
	Vector3.new(-468.29, -7.0, 143.89),
	Vector3.new(-467.09, -7.0, 81.65),
	Vector3.new(-509.83, -7.0, 60.71),
	Vector3.new(-472.07, -7.0, 36.39),
	Vector3.new(-469.87, -7.0, -15.74),
	Vector3.new(-344.73, -7.0, -17.09),
	Vector3.new(-348.09, -7.0, 38.18),
	Vector3.new(-303.98, -7.0, 66.93),
	Vector3.new(-350.02, -7.0, 80.84),
	Vector3.new(-351.59, -7.0, -22.45),
	Vector3.new(-313.39, -7.0, -41.65),
	Vector3.new(-348.01, -7.0, -75.82),
	Vector3.new(-478.14, -7.0, -26.70),
	Vector3.new(-518.76, -7.0, -46.07),
	Vector3.new(-471.65, -7.0, -69.66),
	Vector3.new(-465.01, -7.0, -129.68),
	Vector3.new(-346.22, -7.0, -123.08),
	Vector3.new(-434.94, -6.6, 62.77),
}

local ARRIVE_DISTANCE = 4
local MOVE_TIMEOUT = 6

task.spawn(function()
	while true do
		local char = player.Character or player.CharacterAdded:Wait()
		local humanoid = char:WaitForChild("Humanoid")
		local root = char:WaitForChild("HumanoidRootPart")

		for i, target in ipairs(TARGETS) do
			if humanoid.Health <= 0 then break end
			
			-- Tambah variasi koordinat agar tidak terdeteksi pola tetap 
			local goal = Vector3.new(target.X + math.random(-2,2), root.Position.Y, target.Z + math.random(-2,2))
			humanoid:MoveTo(goal)

			local start = tick()
			while tick() - start < MOVE_TIMEOUT do
				if (root.Position - goal).Magnitude <= ARRIVE_DISTANCE then break end
				task.wait(0.2)
			end
			task.wait(math.random(0.5, 1.5))
		end
		task.wait(20)
	end
end)

-- Anti-AFK Baru (Aman dari BAC-9511) 
task.spawn(function()
	while true do
		local char = player.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new(0,0))
		end
		task.wait(240)
	end
end)

-- Auto Speed Coil (Diperbaiki agar tidak spam) 
if not getgenv().__MY_APP_AUTO_SPEED_COIL then
	getgenv().__MY_APP_AUTO_SPEED_COIL = true
	local function equipSpeedCoil()
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local backpack = player:FindFirstChildOfClass("Backpack")
		if hum and backpack then
			for _,tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and string.find(string.lower(tool.Name),"speed") then
					hum:EquipTool(tool)
					break
				end
			end
		end
	end
	task.spawn(function()
		while true do
			equipSpeedCoil()
			task.wait(5) -- Jangan 0 detik agar tidak terdeteksi spam 
		end
	end)
end
