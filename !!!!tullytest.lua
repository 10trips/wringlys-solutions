--> VARIABLES <--
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()
local RunService = game:GetService("RunService")
local camera = game:GetService("Workspace").CurrentCamera
local Players = game:GetService("Players")
local GetPlayers = Players.GetPlayers
local LocalPlayer = Players.LocalPlayer


local resume = coroutine.resume 
local create = coroutine.create

local Camera = workspace.CurrentCamera

local WorldToViewportPoint = Camera.WorldToViewportPoint
local RenderStepped = RunService.RenderStepped
local UserInputService = game:GetService("UserInputService")
local GetMouseLocation = UserInputService.GetMouseLocation
local FindFirstChild = game.FindFirstChild
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local WorldToScreen = Camera.WorldToScreenPoint
local FindFirstChild = game.FindFirstChild

local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean", "boolean"
        }
    },
    FindPartOnRayWithWhitelist = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean"
        }
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = {
            "Instance", "Ray", "Instance", "boolean", "boolean"
        }
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
        }
    }
}

local config = {
    --Aimbot settings
    SilentAim = false,
    SilentAimHoldToToggle = true,
    SilentAimDisplayFOVCircle = true,
    SilentAimMethod = nil, --not used
    SilentAimRadius = 200,
    SilentAimBodyPart = "Head",
    SilentAimIsVisible = true,
    SilentAimTeamCheck = false,
    SilentAimShowTargetedPlr = true,
    SilentAimTargetedPlrColor = Color3.fromRGB(255,255,255),

    Fov = 100,
    --ESP
    Esp = false,
    EspTeamCeck = false,
    EspDefaultColor = Color3.fromRGB(255,70,70),
    EspTeamColor = Color3.fromRGB(50,50,255),
    EspEnemyColor = Color3.fromRGB(255,50,50),
    EspType = "Shader",
    --tracer
    Tracer = true,
    --misc
    Notifications = true,
    NotificationsTime = 1,

}
 

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 200
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = Color3.fromRGB(54, 57, 241)
fov_circle.Visible = true



--> FUNCTIONS <--



local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getMousePosition()
    return GetMouseLocation(UserInputService)
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter or LocalPlayerCharacter) then return end 
    local PlayerRoot = FindFirstChild(PlayerCharacter, config.SilentAimBodyPart) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return end 
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

local function getPlayerClosestToMouse()
    local Closest
    local DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end
        if config.SilentAimTeamCheck and Player.Team == LocalPlayer.Team then continue end
        local Character = Player.Character
        if not Character then continue end
        if config.SilentAimIsVisible and not IsPlayerVisible(Player) then continue end
        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end
        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end
        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or config.SilentAimRadius or 2000) then
            Closest = ((config.SilentAimBodyPart == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[config.SilentAimBodyPart])
            DistanceToMouse = Distance
        end
    end
    return Closest
end
 
local function draw()
    for i,v in next, GetPlayers(Players) do
        char = v.Character
        if char == nil then warn("its nil!") continue end

        if FindFirstChild(char, "Highlight") then
            if config.EspTeamCeck == true then
                if v.Team == LocalPlayer.Team then
                    FindFirstChild(char, "Highlight").OutlineColor = config.EspTeamColor
                else
                    FindFirstChild(char, "Highlight").OutlineColor = config.EspEnemyColor
                end
            else


                if config.SilentAimShowTargetedPlr == true and config.SilentAim == true then
                    local player = getPlayerClosestToMouse()
                    if player ~= nil then
                        if player.Parent == char then
                            character = player.Parent

                            if FindFirstChild(character, "Highlight") then
                                FindFirstChild(character, "Highlight").OutlineColor = config.SilentAimTargetedPlrColor
                            end
                        elseif player.Parent ~= char then
                            FindFirstChild(char, "Highlight").OutlineColor = config.EspDefaultColor
                        end
                    elseif player == nil or config.SilentAim == false then
                        FindFirstChild(char, "Highlight").OutlineColor = config.EspDefaultColor
                    end
                else

                    FindFirstChild(char, "Highlight").OutlineColor = config.EspDefaultColor
                end
            end
            FindFirstChild(char, "Highlight").Enabled = config.Esp 


        else
            local highlight = Instance.new("Highlight")
                highlight.Parent = char
                highlight.Adornee = char
                highlight.Enabled = false
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0
                
                highlight.OutlineColor = Color3.fromRGB(255,25,25)

        end
    end
end




--UI------------

local targettracer = Drawing.new("Line")
targettracer.ZIndex = 999
targettracer.Visible = true
targettracer.Transparency = 1
targettracer.Color = Color3.fromRGB(255, 50, 255)
targettracer.Thickness = 2
targettracer.From = Vector2.new(getMousePosition().X,getMousePosition().Y)
targettracer.To = Vector2.new()






















local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local MainWindow = OrionLib:MakeWindow({Name = "tullyhack dev", HidePremium = false, SaveConfig = true, ConfigFolder = "tully", IntroEnabled = true, IntroText = "tullyhack on top!", CloseCallBack = function()
    OrionLib:Destroy()
end})

local function makenoti(name,text,image,time)
    OrionLib:MakeNotification({
        Name = name,
        Content = text,
        Image = image,
        Time = time
    })
end



--Tab


--Aimbot
local AimbotTab = MainWindow:MakeTab({
	Name = "Aimbot",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = true
})
--Aimbot Sections


--Silent Aim Section
local SilentAimSection = AimbotTab:AddSection({
	Name = "SilentAim"
})

local silentaimtoggle = SilentAimSection:AddToggle({ --Enable Silent Aim
	Name = "Silent Aim",
	Default = false,
	Callback = function(Value)
		config.SilentAim = Value
        if config.Notifications == true then
            makenoti("Silent Aim", "Silent Aim was toggled: "..tostring(Value), "rbxassetid://4483345998", config.NotificationsTime)
        end
	end    
})
SilentAimSection:AddToggle({ --Enable Hold to Use
	Name = "Hold To Use Silent Aim",
	Default = true,
	Callback = function(Value)
		config.SilentAimHoldToToggle = Value
	end    
})
SilentAimSection:AddToggle({ --Enable Silent Aim FOV Circle
	Name = "Display FOV",
	Default = false,
	Callback = function(Value)
		fov_circle.Visible = Value
	end    
})
SilentAimSection:AddToggle({ --Enable Silent Aim FOV Circle
	Name = "Team Check",
	Default = false,
	Callback = function(Value)
		config.SilentAimTeamCheck = Value
	end    
})
SilentAimSection:AddSlider({
	Name = "FOV Radius",
	Min = 1,
	Max = 1000,
	Default = 100,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Radius",
	Callback = function(Value)
		fov_circle.Radius = Value
        config.SilentAimRadius = Value
	end    
})
local silentaimkeybind = SilentAimSection:AddBind({ --Silent Aim KeyBind
	Name = "Silent Aim KeyBind",
	Default = Enum.KeyCode.F,
	Hold = true,
	Callback = function(Value)

        if config.SilentAimHoldToToggle == true then
            
            config.SilentAim = Value
            silentaimtoggle:Set(Value)
        elseif config.SilentAimHoldToToggle == false then

            if Value == true then
                if config.SilentAim == true then
                    config.SilentAim = false
                    silentaimtoggle:Set(false)
                elseif config.SilentAim == false then
                    config.SilentAim = true
                    silentaimtoggle:Set(true)
                end
            end
            
        end

	end    
})
SilentAimSection:AddButton({
	Name = "Print Config",
	Callback = function()
        for i,v in pairs(config) do
            print(i,v)
        end
  	end    
})




--Visual
local VisualTab = MainWindow:MakeTab({
	Name = "Visual",
	Icon = "rbxassetid://4483362748",
	PremiumOnly = true
})



local SilentAimVisualSection = VisualTab:AddSection({
	Name = "SilentAim Visual"
})


SilentAimVisualSection:AddSlider({
	Name = "FOV Circle Thickness",
	Min = 1,
	Max = 10,
	Default = 1,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Thickness",
	Callback = function(Value)
		fov_circle.Thickness = Value
	end    
})

SilentAimVisualSection:AddSlider({
	Name = "FOV Circle Transparency",
	Min = 0,
	Max = 1,
	Default = 1,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.05,
	ValueName = "Transparency",
	Callback = function(Value)
		fov_circle.Transparency = Value
	end    
})


SilentAimVisualSection:AddSlider({
	Name = "FOV Circle Sides",
	Min = 5,
	Max = 200,
	Default = 100,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Sides",
	Callback = function(Value)
		fov_circle.NumSides = Value
	end    
})


SilentAimVisualSection:AddColorpicker({
	Name = "FOV Circle Color",
	Default = Color3.fromRGB(255, 0, 0),
	Callback = function(Value)
		fov_circle.Color = Value
	end	  
})
SilentAimVisualSection:AddToggle({ --Enable Silent Aim FOV Circle
Name = "Show Targeted Player",
Default = true,
Callback = function(Value)
    config.SilentAimShowTargetedPlr = Value
end    
})
SilentAimVisualSection:AddColorpicker({
	Name = "Targeted Player Color",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(Value)
		config.SilentAimTargetedPlrColor = Value
	end	  
})


--ESP-----------

local espvisualsection = VisualTab:AddSection({
	Name = "ESP"
})

espvisualsection:AddToggle({ 
    Name = "ESP",
    Default = false,
    Callback = function(Value)
        config.Esp = Value
        if config.Notifications == true then
            makenoti("ESP", "Esp was toggled: "..tostring(Value), "rbxassetid://4483362748", config.NotificationsTime)
        end
    end    
})

espvisualsection:AddToggle({ 
    Name = "Team Check",
    Default = false,
    Callback = function(Value)
        config.EspTeamCeck = Value
    end    
})
espvisualsection:AddColorpicker({
	Name = "ESP Default Color",
	Default = Color3.fromRGB(255,70,70),
	Callback = function(Value)
		config.EspDefaultColor = Value
	end	  
})
espvisualsection:AddColorpicker({
	Name = "ESP Teammate Color",
	Default = Color3.fromRGB(50, 50, 255),
	Callback = function(Value)
		config.EspTeamColor = Value
	end	  
})
espvisualsection:AddColorpicker({
	Name = "ESP Enemy Color",
	Default = Color3.fromRGB(255, 50, 50),
	Callback = function(Value)
		config.EspEnemyColor = Value
	end	  
})

espvisualsection:AddDropdown({
	Name = "ESP Type",
	Default = "Shader",
	Options = {"Shader", "Box", "Both"},
	Callback = function(Value)
		config.EspType = Value
	end    
})

local miscvisualsection = VisualTab:AddSection({
	Name = "Misc"
})

miscvisualsection:AddToggle({ 
    Name = "Tracers",
    Default = true,
    Callback = function(Value)
        config.Tracer = Value
    end    
})

miscvisualsection:AddSlider({
	Name = "Tracer Thickness",
	Min = 0,
	Max = 10,
	Default = 1,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Thickness",
	Callback = function(Value)
		targettracer.Thickness = Value
	end    
})

miscvisualsection:AddColorpicker({
	Name = "Tracer Color",
	Default = Color3.fromRGB(255, 50, 255),
	Callback = function(Value)
		targettracer.Color = Value
	end	  
})



--FOV=----
miscvisualsection:AddSlider({
	Name = "FOV",
	Min = 0,
	Max = 120,
	Default = 100,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "FOV",
	Callback = function(Value)
		config.FOV = Value
	end    
})

--MISC-----------------

local misctab = MainWindow:MakeTab({
	Name = "Miscellaneous",
	Icon = "rbxassetid://4483364237",
	PremiumOnly = true
})

misctab:AddToggle({ 
    Name = "Notifications",
    Default = true,
    Callback = function(Value)
        config.Notifications = Value
    end    
})

misctab:AddSlider({
	Name = "Notification Time",
	Min = 1,
	Max = 5,
	Default = 1,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Seconds",
	Callback = function(Value)
		config.NotificationsTime = Value
	end    
})





--the real stuff starts here V




























--> Hooking to the remote <--
local oldNamecall
 
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    if config.SilentAim == true and self == workspace and not checkcaller() then

        if Method == "FindPartOnRayWithIgnoreList" then
             print("Hooked FindPartOnRayWithIgnoreList")
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                local A_Ray = Arguments[2]

                local HitPart = getPlayerClosestToMouse()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)

                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif Method == "FindPartOnRayWithWhitelist" then
            print("Hooked FindPartOnRayWithWhitelist")
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                local A_Ray = Arguments[2]

                local HitPart = getPlayerClosestToMouse()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)

                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") then
            print("Hooked FindPartOnRay")
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                local A_Ray = Arguments[2]

                local HitPart = getPlayerClosestToMouse()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)

                    return oldNamecall(unpack(Arguments))
                end
            end

        elseif Method == "Raycast" then
            print("Hooked Raycast")
            if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                local A_Origin = Arguments[2]

                local HitPart = getPlayerClosestToMouse()
                if HitPart then
                    Arguments[3] = getDirection(A_Origin, HitPart.Position)

                    return oldNamecall(unpack(Arguments))
                end
            end
        end




    end
    return oldNamecall(...)
end))

resume(create(function()
    RenderStepped:Connect(function()

        local playr = getPlayerClosestToMouse()
        if config.Tracer == true and config.SilentAim == true and playr ~= nil then
            local pos = WorldToViewportPoint(Camera, playr.Position)
            targettracer.Visible = true
            targettracer.To = Vector2.new(pos.X, pos.Y)
            targettracer.From = Vector2.new(getMousePosition().X,getMousePosition().Y)
        else
            targettracer.Visible = false
        end

        fov_circle.Position = getMousePosition()
        
        Camera.FieldOfView = config.FOV
    end)
end))

resume(create(function()
    while true do
        wait(.05)
        draw()
    end
end))


OrionLib:Init()