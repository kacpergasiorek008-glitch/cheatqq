-- Roblox Silent Aim + Aimbot + ESP (Inject Version)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Ustawienia
local FOV = 25 -- Pole widzenia (niewidoczne dla innych)
local AimSpeed = 0.8 -- Szybkość korekcji
local SilentAim = true

function GetNearestTarget()
    local nearestPlayer = nil
    local closestDist = math.huge
    local localPos = HumanoidRootPart.Position

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local dist = (head.Position - localPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    nearestPlayer = target
                end
            end
        end
    end
    return nearestPlayer, closestDist
end

function SilentAimLogic(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if head then
        local headPos = head.Position
        local lookVector = Camera.CFrame.LookVector
        local targetVector = (headPos - LocalPlayer.Character.PrimaryPart.Position).Unit
        
        -- Obliczanie kąta odchylenia
        local angle = math.deg(math.acos(lookVector:Dot(targetVector)))
        
        if angle < FOV then
            -- Cicha korekcja celowania (zmiana wektora strzału w pamięci)
            -- W zaawansowanych cheatach modyfikuje się tu zmienną RemoteEvent lub Raycast
            localPlayer.Character.PrimaryPart.CFrame = CFrame.lookAt(LocalPlayer.Character.PrimaryPart.Position, headPos)
        end
    end
end

function DrawESP(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local worldPos = rootPart.CFrame.Position
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos + Vector3.new(0, 1.5, 0))
    
    if onScreen then
        -- Rysowanie boxa (uproszczone dla Lua)
        -- W pełnej wersji użyj Direct3D do rysowania w pamięci karty graficznej
        print("ESP aktywny dla: " .. player.Name)
    end
end

local function Loop()
    local target, dist = GetNearestTarget()
    
    if target then
        DrawESP(target)
        if SilentAim then
            SilentAimLogic(target)
        end
    end
end

RunService.RenderStepped:Connect(Loop)

-- Automatyczny strzał (Aimbot) gdy cel jest w FOV
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        local target, dist = GetNearestTarget()
        if target then
            -- Symulacja strzału w głowę (modyfikacja RemoteEvent)
            local head = target.Character:FindFirstChild("Head")
            if head then
                game:GetService("ReplicatedStorage"):WaitForChild("Shoot"):FireServer(head.Position)
            end
        end
    end
end)

print("Silent Aim + Aimbot + ESP włączone.")
