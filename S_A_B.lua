-- KAMIAPA BYPASS FULL VERSION - UPDATED PURCHASE LOGIC
task.spawn(function() 
    repeat task.wait(math.random(1, 3)) until game:IsLoaded()
    local p = game:GetService("Players").LocalPlayer
    local HP = Vector3.new(-411.6094055175781, -6.403680801391602, 230.6124725341797) 

    -- 1. ANTI-AFK HUMANIZED
    task.spawn(function()
        while task.wait(math.random(120, 240)) do 
            pcall(function() 
                local cam = game.Workspace.CurrentCamera
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            end)
        end
    end)

    -- 2. AUTO RESPAWN SETIAP 2.5 MENIT
    task.spawn(function()
        while task.wait(150) do 
            pcall(function()
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                    p.Character:FindFirstChildOfClass("Humanoid").Health = 0
                end
            end)
        end
    end)

    -- 3. AUTO PURCHASE (FIXED LOGIC)
    if not getgenv().__KAMI_APA_AUTO_BUY_FIX then
        getgenv().__KAMI_APA_AUTO_BUY_FIX = true
        task.spawn(function()
            while true do
                local tgt = getgenv().currentTarget
                if tgt and tgt.Parent then
                    for _, v in ipairs(tgt:GetDescendants()) do
                        if v:IsA("ProximityPrompt") 
                        and v.Enabled 
                        and v.ActionText == "Purchase" then
                            pcall(function()
                                fireproximityprompt(v, 0)
                            end)
                            task.wait(0.2)
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end

    -- 4. STAY AT HOME & AUTO RETURN
    task.spawn(function() 
        while task.wait(math.random(1, 2)) do 
            pcall(function() 
                local c = p.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then 
                    if (r.Position - HP).Magnitude > 10 then 
                        h:MoveTo(HP) 
                    end
                end 
            end) 
        end 
    end)

    -- 5. AUTO SPEED COIL
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

    print("KAMIAPA: FULL SCRIPT LOADED WITH FIX")
end)
