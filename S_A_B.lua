-- KAMIAPA BYPASS VERSION (HUMANIZED & UPDATED)
task.spawn(function() 
    repeat task.wait(math.random(1, 3)) until game:IsLoaded()
    local p = game:GetService("Players").LocalPlayer
    local pps = game:GetService("ProximityPromptService")
    
    local HP = Vector3.new(-411.6094055175781, -6.403680801391602, 230.6124725341797) 
    
    -- ANTI-AFK
    task.spawn(function()
        while task.wait(math.random(120, 240)) do 
            pcall(function() 
                local cam = game.Workspace.CurrentCamera
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            end)
        end
    end)

    -- AUTO RESPAWN
    task.spawn(function()
        while task.wait(150) do 
            pcall(function()
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                    p.Character:FindFirstChildOfClass("Humanoid").Health = 0
                end
            end)
        end
    end)

    -- AUTO PURCHASE (NEW LOGIC: Scan all prompts)
    task.spawn(function()
        while task.wait(2) do -- Scan setiap 2 detik
            pcall(function()
                local targets = getgenv().TARGET_LIST or {}
                for _, obj in pairs(game.Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local parentName = string.lower(obj.Parent.Name)
                        local isT = false
                        for _, t in ipairs(targets) do 
                            if string.find(parentName, string.lower(t)) then isT = true break end 
                        end
                        
                        if isT then
                            -- Cek jarak agar tidak trigger prompt yang terlalu jauh
                            local char = p.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local dist = (char.HumanoidRootPart.Position - obj.Parent:GetPivot().Position).Magnitude
                                if dist <= obj.MaxActivationDistance then
                                    fireproximityprompt(obj) -- Menggunakan fungsi internal untuk memicu prompt
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- STAY AT HOME & AUTO RETURN
    task.spawn(function() 
        while task.wait(math.random(1, 2)) do 
            pcall(function() 
                local c = p.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then 
                    if (r.Position - HP).Magnitude > 5 then h:MoveTo(HP) end
                end 
            end) 
        end 
    end)

    -- AUTO SPEED COIL
    task.spawn(function() 
        while task.wait(math.random(10, 20)) do 
            pcall(function() 
                local c = p.Character
                local b = p:FindFirstChildOfClass("Backpack")
                if c and b then 
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if not (c:FindFirstChild("Speed Coil") or c:FindFirstChild("Coil")) and h then 
                        for _, t in ipairs(b:GetChildren()) do 
                            if t:IsA("Tool") and (string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil")) then 
                                h:EquipTool(t) break 
                            end 
                        end 
                    end 
                end 
            end) 
        end 
    end)

    print("KAMIAPA: Loaded with Proximity Logic")
end)
