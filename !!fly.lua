local on = false
local plr = game.Players.LocalPlayer

local mouse = plr:GetMouse()

local RunService = game:GetService("RunService")

mouse.KeyDown:Connect(function(key)
    if key == "e" or key == "E" then
       if on == false then
           on = true
           else
           on = false
        end
    end
end)

RunService.Stepped:Connect(function()
    if on == true then
        plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + (workspace.CurrentCamera.CoordinateFrame.lookVector * 2) + Vector3.new(0,1,0)
    end
end)