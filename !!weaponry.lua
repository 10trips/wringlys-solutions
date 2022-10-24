local mouse = game.Players.LocalPlayer:GetMouse()
local partfolder = Instance.new("Folder")
partfolder.Parent = workspace
local walkfolder = Instance.new("Folder")
walkfolder.Parent = workspace
local platform = false
mouse.KeyUp:Connect(function(key)
    if key == "z" or key == "Z" then
        for i = 1,20 do
            local part = Instance.new("Part")
            part.Parent = partfolder
            part.Anchored = true
            part.Size = Vector3.new(4,.1,2)
            part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3+i*1.5, -1.5)
            part.Transparency = 1
        end
        wait(10)
        for i,v in pairs(partfolder:GetChildren()) do
            v:Destroy()
        end
    elseif key == "x" or key == "X" then
        if platform == false then
            platform = true
        else
            platform = false
            for i,v in pairs(walkfolder:GetChildren()) do
                v:Destroy()
            end
        end
    end
end)

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Herrtt/AimHot-v8/master/Main.lua", true))()
end)

while true do
   workspace.CurrentCamera.FieldOfView = 120
   wait()
   if platform == false then
       
    else
        local newpart = Instance.new("Part")
        newpart.Parent = walkfolder
        newpart.Anchored = true
        newpart.Size = Vector3.new(1,.2,1)
        newpart.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0,3.1,0)
        newpart.Transparency = 1
   end

end
