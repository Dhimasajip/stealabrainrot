-- KAMIAPA BYPASS VERSION (HUMANIZED)
task.spawn(function() 
    repeat task.wait(math.random(1, 3)) until game:IsLoaded()
    local p = game:GetService("Players").LocalPlayer
    local pps = game:GetService("ProximityPromptService")
    local HP = Vector3.new(-410.287, -6.403, -68.402) 
    
    -- ANTI-AFK HUMANIZED (Gerak kamera sedikit)
    task.spawn(function()
        while task.wait(math.random(120, 240)) do -- Gerak tiap 2-4 menit
            pcall(function()
                local cam = game.Workspace.CurrentCamera
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            end)
        end
    end)

    -- STAY AT HOME & AUTO RETURN (Humanized MoveTo)
    task.spawn(function() 
        while task.wait(math.random(1, 2)) do 
            pcall(function() 
                local c = p.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local r = c and c:FindFirstChild("HumanoidRootPart")
                
                if h and r and h.Health > 0 then 
                    local distance = (r.Position - HP).Magnitude
                    
                    -- Bergerak perlahan ke posisi jika jauh
                    if distance > 5 then 
                        h:MoveTo(HP)
                    end
                end 
            end) 
        end 
    end)

    -- AUTO PURCHASE (Humanized Delay)
    pps.PromptShown:Connect(function(pr) 
        pcall(function() 
            local m = pr:FindFirstAncestorOfClass("Model")
            local targets = getgenv().TARGET_LIST or {}
            if m then
                local n = string.lower(m:GetAttribute("Index") or m.Name)
                local isT = false
                for _, t in ipairs(targets) do 
                    if string.find(n, string.lower(t)) then isT = true break end 
                end
                
                if isT then 
                    task.wait(math.random(0.5, 1.2)) -- Jeda acak sebelum interaksi
                    pr:InputHoldBegin() 
                    task.wait(pr.HoldDuration + math.random(0.1, 0.3)) 
                    pr:InputHoldEnd() 
                end 
            end 
        end) 
    end)

    -- AUTO SPEED COIL
    task.spawn(function() 
        while task.wait(math.random(10, 20)) do 
            pcall(function() 
                local c = p.Character
                local b = p:FindFirstChildOfClass("Backpack")
                if c and b then 
                    local h = c:FindFirstChildOfClass("Humanoid")
                    local coil = c:FindFirstChild("Speed Coil") or c:FindFirstChild("Coil")
                    if not coil and h then 
                        for _, t in ipairs(b:GetChildren()) do 
                            if t:IsA("Tool") and (string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil")) then 
                                task.wait(math.random(0.5, 1))
                                h:EquipTool(t) 
                                break 
                            end 
                        end 
                    end 
                end 
            end) 
        end 
    end)

    print("KAMIAPA: Humanized Script Loaded - Good Luck")
end)
