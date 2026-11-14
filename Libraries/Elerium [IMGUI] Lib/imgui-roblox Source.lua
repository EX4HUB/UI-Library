--[[
    ui-engine-v2
    version 1.3a
    by Singularity (V3rm @ King Singularity) (Discord @ Singularity#5490)
    Refactored for readability, maintainability, and bug-fixing.
]]

-- 1. Services / Imports
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 2. Constants
local DEFAULT_UI_OPTIONS = {
    main_color = Color3.fromRGB(41, 74, 122),
    min_size = Vector2.new(400, 300),
    toggle_key = Enum.KeyCode.RightShift,
    can_resize = true,
    tween_time = 0.1,
}

local SHORTCUT_KEYS = {
    RightControl = "RightCtrl",
    LeftControl = "LeftCtrl",
    LeftShift = "LShift",
    RightShift = "RShift",
    MouseButton1 = "Mouse1",
    MouseButton2 = "Mouse2"
}

local LUA_KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", 
    "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", 
    "true", "until", "while"
}

local GLOBAL_ENV = {
    "getrawmetatable", "newcclosure", "islclosure", "setclipboard", "game", "workspace", 
    "script", "math", "string", "table", "print", "wait", "BrickColor", "Color3", 
    "next", "pairs", "ipairs", "select", "unpack", "Instance", "Vector2", "Vector3", 
    "CFrame", "Ray", "UDim2", "Enum", "assert", "error", "warn", "tick", "loadstring", 
    "_G", "shared", "getfenv", "setfenv", "newproxy", "setmetatable", "getmetatable", 
    "os", "debug", "pcall", "ypcall", "xpcall", "rawequal", "rawset", "rawget", 
    "tonumber", "tostring", "type", "typeof", "_VERSION", "coroutine", "delay", 
    "require", "spawn", "LoadLibrary", "settings", "stats", "time", "UserSettings", 
    "version", "Axes", "ColorSequence", "Faces", "ColorSequenceKeypoint", "NumberRange", 
    "NumberSequence", "NumberSequenceKeypoint", "gcinfo", "elapsedTime", "collectgarbage", 
    "PhysicalProperties", "Rect", "Region3", "Region3int16", "UDim", "Vector2int16", 
    "Vector3int16", "load", "fire", "Fire"
}

-- 3. Shared State
local State = {
    isBindingKey = false,
    isDropdownOpen = false,
    windowCount = 0,
}

-- 4. Cleanup
local existingImgui = CoreGui:FindFirstChild("imgui")
if existingImgui then
    existingImgui:Destroy()
end

-- 5. Utility Functions
local function hasProperty(object, property)
    local success, result = pcall(function()
        return object[tostring(property)]
    end)
    return success and result ~= nil
end

local function getTextWidth(textObject)
    return textObject.TextBounds.X + 15
end

local function getMousePosition()
    local mouseLoc = UserInputService:GetMouseLocation()
    return Vector2.new(mouseLoc.X + 1, mouseLoc.Y - 35)
end

local function rgbToHsv(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max

    local d = max - min
    s = (max == 0) and 0 or (d / max)

    if max ~= min then
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, v
end

local function tweenProperty(instance, properties, duration)
    duration = duration or 0.5
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createRipple(button, x, y)
    task.spawn(function()
        button.ClipsDescendants = true
        local circle = Prefabs.Circle:Clone()
        circle.Parent = button
        circle.ZIndex = 1000

        local relativeX = x - circle.AbsolutePosition.X
        local relativeY = y - circle.AbsolutePosition.Y
        circle.Position = UDim2.new(0, relativeX, 0, relativeY)

        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5

        circle:TweenSizeAndPosition(
            UDim2.new(0, maxSize, 0, maxSize),
            UDim2.new(0.5, -maxSize / 2, 0.5, -maxSize / 2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.5,
            false
        )
        tweenProperty(circle, {ImageTransparency = 1}, 0.5)

        task.wait(0.5)
        circle:Destroy()
    end)
end

local function create(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props) do 
        inst[k] = v 
    end
    if parent then 
        inst.Parent = parent 
    end
    return inst
end

-- 6. Core Systems & 8. Launcher Construction (Prefabs & GUI)
local imgui = Instance.new("ScreenGui")
imgui.Name = "imgui"
imgui.Parent = CoreGui

local Prefabs = create("Frame", {Name="Prefabs", BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(0,100,0,100), Visible=false}, imgui)
create("TextLabel", {Name="Label", BackgroundTransparency=1, Size=UDim2.new(0,200,0,20), Font=Enum.Font.GothamSemibold, Text="Hello, world 123", TextColor3=Color3.new(1,1,1), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Prefabs)

local Window = create("ImageLabel", {Name="Window", Active=true, BackgroundTransparency=1, ClipsDescendants=true, Position=UDim2.new(0,20,0,20), Selectable=true, Size=UDim2.new(0,200,0,200), Image="rbxassetid://2851926732", ImageColor3=Color3.fromRGB(21,22,23), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(12,12,12,12)}, Prefabs)
create("Frame", {Name="Resizer", Active=true, BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.new(1,-20,1,-20), Size=UDim2.new(0,20,0,20)}, Window)
local Bar = create("Frame", {Name="Bar", BackgroundColor3=Color3.fromRGB(41,74,122), BorderSizePixel=0, Position=UDim2.new(0,0,0,5), Size=UDim2.new(1,0,0,15)}, Window)
create("ImageButton", {Name="Toggle", BackgroundTransparency=1, Position=UDim2.new(0,5,0,-2), Rotation=90, Size=UDim2.new(0,20,0,20), ZIndex=2, Image="https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4731371541"}, Bar)
create("ImageLabel", {Name="Base", BackgroundColor3=Color3.fromRGB(41,74,122), BorderSizePixel=0, Position=UDim2.new(0,0,0.8,0), Size=UDim2.new(1,0,0,10), Image="rbxassetid://2851926732", ImageColor3=Color3.fromRGB(41,74,122), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(12,12,12,12)}, Bar)
create("ImageLabel", {Name="Top", BackgroundTransparency=1, Position=UDim2.new(0,0,0,-5), Size=UDim2.new(1,0,0,10), Image="rbxassetid://2851926732", ImageColor3=Color3.fromRGB(41,74,122), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(12,12,12,12)}, Bar)
create("Frame", {Name="Tabs", BackgroundTransparency=1, Position=UDim2.new(0,15,0,60), Size=UDim2.new(1,-30,1,-60)}, Window)
create("TextLabel", {Name="Title", BackgroundTransparency=1, Position=UDim2.new(0,30,0,3), Size=UDim2.new(0,200,0,20), Font=Enum.Font.GothamBold, Text="Gamer Time", TextColor3=Color3.new(1,1,1), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Window)
local TabSelection = create("ImageLabel", {Name="TabSelection", BackgroundTransparency=1, Position=UDim2.new(0,15,0,30), Size=UDim2.new(1,-30,0,25), Visible=false, Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(37,38,40), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Window)
local TabButtons = create("Frame", {Name="TabButtons", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, TabSelection)
create("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2)}, TabButtons)
create("Frame", {BackgroundColor3=Color3.fromRGB(32,58,95), BorderColor3=Color3.fromRGB(27,42,53), BorderSizePixel=0, Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,2)}, TabSelection)

create("Frame", {Name="Tab", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Visible=false}, Prefabs)
create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)}, Prefabs.Tab)

create("TextBox", {BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,0,20), ZIndex=2, Font=Enum.Font.GothamSemibold, PlaceholderColor3=Color3.fromRGB(178,178,178), PlaceholderText="Input Text", Text="", TextColor3=Color3.fromRGB(200,200,200), TextSize=14}, Prefabs)
create("ImageLabel", {Name="TextBox_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(52,53,56), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.TextBox)

create("ImageLabel", {Name="Slider", BackgroundTransparency=1, Position=UDim2.new(0,0,0.178571433,0), Size=UDim2.new(1,0,0,20), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(37,38,40), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs)
create("TextLabel", {Name="Title", BackgroundTransparency=1, Position=UDim2.new(0.5,0,0.5,-10), Size=UDim2.new(0,0,0,20), ZIndex=2, Font=Enum.Font.GothamBold, Text="Slider", TextColor3=Color3.fromRGB(200,200,200), TextSize=14}, Prefabs.Slider)
create("ImageLabel", {Name="Indicator", BackgroundTransparency=1, Size=UDim2.new(0,0,0,20), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(65,67,71), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.Slider)
create("TextLabel", {Name="Value", BackgroundTransparency=1, Position=UDim2.new(1,-55,0.5,-10), Size=UDim2.new(0,50,0,20), Font=Enum.Font.GothamBold, Text="0%", TextColor3=Color3.fromRGB(200,200,200), TextSize=14}, Prefabs.Slider)
create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(1,-20,-0.75,0), Size=UDim2.new(0,26,0,50), Font=Enum.Font.GothamBold, Text="]", TextColor3=Color3.fromRGB(160,160,160), TextSize=14}, Prefabs.Slider)
create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(1,-65,-0.75,0), Size=UDim2.new(0,26,0,50), Font=Enum.Font.GothamBold, Text="[", TextColor3=Color3.fromRGB(160,160,160), TextSize=14}, Prefabs.Slider)

create("ImageLabel", {Name="Circle", BackgroundTransparency=1, Image="rbxassetid://266543268", ImageTransparency=0.5}, Prefabs)
create("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,20)}, Prefabs)

create("TextButton", {Name="Dropdown", BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.new(-0.055555556,0,0.0833333284,0), Size=UDim2.new(0,200,0,20), ZIndex=2, Font=Enum.Font.GothamBold, Text="      Dropdown", TextColor3=Color3.fromRGB(200,200,200), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Prefabs)
create("ImageLabel", {Name="Indicator", BackgroundTransparency=1, Position=UDim2.new(0.9,-10,0.1,0), Rotation=-90, Size=UDim2.new(0,15,0,15), ZIndex=2, Image="https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4744658743"}, Prefabs.Dropdown)
local Box = create("ImageButton", {Name="Box", BackgroundTransparency=1, Position=UDim2.new(0,0,0,25), Size=UDim2.new(1,0,0,150), ZIndex=3, Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(33,34,36), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.Dropdown)
create("ScrollingFrame", {Name="Objects", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=3, CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=8}, Box)
create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder}, Box.Objects)
create("ImageLabel", {Name="TextButton_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(52,53,56), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.Dropdown)

create("TextButton", {Name="TabButton", BackgroundColor3=Color3.fromRGB(41,74,122), BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.new(0.185185179,0,0,0), Size=UDim2.new(0,71,0,20), ZIndex=2, Font=Enum.Font.GothamSemibold, Text="Test tab", TextColor3=Color3.fromRGB(200,200,200), TextSize=14}, Prefabs)
create("ImageLabel", {Name="TextButton_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(52,53,56), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.TabButton)

local Folder = create("ImageLabel", {Name="Folder", BackgroundTransparency=1, Position=UDim2.new(0,0,0,50), Size=UDim2.new(1,0,0,20), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(21,22,23), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs)
local Button = create("TextButton", {Name="Button", BackgroundColor3=Color3.fromRGB(41,74,122), BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,0,20), ZIndex=2, Font=Enum.Font.GothamSemibold, Text="      Folder", TextColor3=Color3.new(1,1,1), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Folder)
create("ImageLabel", {Name="TextButton_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(41,74,122), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Button)
create("ImageLabel", {Name="Toggle", BackgroundTransparency=1, Position=UDim2.new(0,5,0,0), Size=UDim2.new(0,20,0,20), Image="https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4731371541"}, Button)
create("Frame", {Name="Objects", BackgroundTransparency=1, Position=UDim2.new(0,10,0,25), Size=UDim2.new(1,-10,1,-25), Visible=false}, Folder)
create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)}, Folder.Objects)

create("Frame", {Name="HorizontalAlignment", BackgroundTransparency=1, Size=UDim2.new(1,0,0,20)}, Prefabs)
create("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)}, Prefabs.HorizontalAlignment)

local Console = create("ImageLabel", {Name="Console", BackgroundTransparency=1, Size=UDim2.new(1,0,0,200), Image="rbxassetid://2851928141", ImageColor3=Color3.fromRGB(33,34,36), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(8,8,8,8)}, Prefabs)
local ScrollingFrame = create("ScrollingFrame", {BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,1), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=4}, Console)
local Source = create("TextBox", {Name="Source", BackgroundTransparency=1, Position=UDim2.new(0,40,0,0), Size=UDim2.new(1,-40,0,10000), ZIndex=3, ClearTextOnFocus=false, Font=Enum.Font.Code, MultiLine=true, PlaceholderColor3=Color3.fromRGB(204,204,204), Text="", TextColor3=Color3.new(1,1,1), TextSize=15, TextStrokeColor3=Color3.new(1,1,1), TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, ScrollingFrame)

create("TextLabel", {Name="Comments", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(59,200,59), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Globals", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(132,214,247), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Keywords", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(248,109,124), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="RemoteHighlight", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(0,145,255), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Strings", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(173,241,149), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Tokens", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.new(1,1,1), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Numbers", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=4, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(255,198,0), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Info", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=5, Font=Enum.Font.Code, Text="", TextColor3=Color3.fromRGB(0,162,255), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, Source)
create("TextLabel", {Name="Lines", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(0,40,0,10000), ZIndex=4, Font=Enum.Font.Code, Text="1\n", TextColor3=Color3.new(1,1,1), TextSize=15, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top}, ScrollingFrame)

local ColorPicker = create("ImageLabel", {Name="ColorPicker", BackgroundTransparency=1, Size=UDim2.new(0,180,0,110), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(52,53,56), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs)
local Palette = create("ImageLabel", {Name="Palette", BackgroundTransparency=1, Position=UDim2.new(0.05,0,0.05,0), Size=UDim2.new(0,100,0,100), Image="rbxassetid://698052001", ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, ColorPicker)
create("ImageLabel", {Name="Indicator", BackgroundTransparency=1, Size=UDim2.new(0,5,0,5), ZIndex=2, Image="rbxassetid://2851926732", ImageColor3=Color3.new(0,0,0), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(12,12,12,12)}, Palette)
create("ImageLabel", {Name="Sample", BackgroundTransparency=1, Position=UDim2.new(0.8,0,0.05,0), Size=UDim2.new(0,25,0,25), Image="rbxassetid://2851929490", ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, ColorPicker)
local Saturation = create("ImageLabel", {Name="Saturation", Position=UDim2.new(0.65,0,0.05,0), Size=UDim2.new(0,15,0,100), Image="rbxassetid://3641079629"}, ColorPicker)
create("Frame", {Name="Indicator", BorderSizePixel=0, Size=UDim2.new(0,20,0,2), ZIndex=2}, Saturation)

create("TextButton", {Name="Switch", BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.new(0.229411766,0,0.20714286,0), Size=UDim2.new(0,20,0,20), ZIndex=2, Font=Enum.Font.SourceSans, Text="", TextColor3=Color3.new(1,1,1), TextSize=18}, Prefabs)
create("ImageLabel", {Name="TextButton_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(41,74,122), ImageTransparency=0.5, ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.Switch)
create("TextLabel", {Name="Title", BackgroundTransparency=1, Position=UDim2.new(1.2,0,0,0), Size=UDim2.new(0,20,0,20), Font=Enum.Font.GothamSemibold, Text="Switch", TextColor3=Color3.fromRGB(200,200,200), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Prefabs.Switch)

create("TextButton", {Name="Button", BackgroundColor3=Color3.fromRGB(41,74,122), BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(0,91,0,20), ZIndex=2, Font=Enum.Font.GothamSemibold, TextColor3=Color3.new(1,1,1), TextSize=14}, Prefabs)
create("ImageLabel", {Name="TextButton_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(41,74,122), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs.Button)

create("TextButton", {Name="DropdownButton", BackgroundColor3=Color3.fromRGB(33,34,36), BorderSizePixel=0, Size=UDim2.new(1,0,0,20), ZIndex=3, Font=Enum.Font.GothamBold, Text="      Button", TextColor3=Color3.fromRGB(200,200,200), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Prefabs)

local Keybind = create("ImageLabel", {Name="Keybind", BackgroundTransparency=1, Size=UDim2.new(0,200,0,20), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(52,53,56), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Prefabs)
create("TextLabel", {Name="Title", BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, Text="Keybind", TextColor3=Color3.fromRGB(200,200,200), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, Keybind)
local Input = create("TextButton", {Name="Input", BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.new(1,-85,0,2), Size=UDim2.new(0,80,1,-4), ZIndex=2, Font=Enum.Font.GothamSemibold, Text="RShift", TextColor3=Color3.fromRGB(200,200,200), TextSize=12, TextWrapped=true}, Keybind)
create("ImageLabel", {Name="Input_Roundify_4px", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Image="rbxassetid://2851929490", ImageColor3=Color3.fromRGB(74,75,80), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(4,4,4,4)}, Input)

local Windows = create("Frame", {Name="Windows", BackgroundTransparency=1, Position=UDim2.new(0,20,0,20), Size=UDim2.new(1,20,1,-20)}, imgui)

-- 9. Main Game Loop / Runtime Connections
local function formatWindows()
    local layout = Prefabs.UIListLayout:Clone()
    layout.Parent = Windows

    local windowPositions = {}
    for _, window in ipairs(Windows:GetChildren()) do
        if not window:IsA("UIListLayout") then
            windowPositions[window] = window.AbsolutePosition
        end
    end

    layout:Destroy()

    for window, pos in pairs(windowPositions) do
        window.Position = UDim2.new(0, pos.X, 0, pos.Y)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    local toggleKey = (typeof(DEFAULT_UI_OPTIONS.toggle_key) == "EnumItem") and DEFAULT_UI_OPTIONS.toggle_key or Enum.KeyCode.RightShift
    if input.KeyCode == toggleKey and not State.isBindingKey then
        imgui.Enabled = not imgui.Enabled
    end
end)

-- Syntax Highlighting Utilities
local function highlightText(text, keywords)
    local keywordMap = {}
    for _, word in ipairs(keywords) do keywordMap[word] = true end
    
    local tokens = {["="]=true, ["."]=true, [","]=true, ["("]=true, [")"]=true, ["["]=true, ["]"]=true, ["{"]=true, ["}"]=true, [":"]=true, ["*"]=true, ["/"]=true, ["+"]=true, ["-"]=true, ["%"]=true, [";"]=true, ["~"]=true}
    
    text = text:gsub(".", function(c) return tokens[c] and "\32" or c end)
    text = text:gsub("%S+", function(c) return keywordMap[c] and c or (" "):rep(#c) end)
    return text
end

local function highlightTokens(text)
    local tokens = {["="]=true, ["."]=true, [","]=true, ["("]=true, [")"]=true, ["["]=true, ["]"]=true, ["{"]=true, ["}"]=true, [":"]=true, ["*"]=true, ["/"]=true, ["+"]=true, ["-"]=true, ["%"]=true, [";"]=true, ["~"]=true}
    return text:gsub(".", function(c)
        if tokens[c] then return c
        elseif c == "\n" then return "\n"
        elseif c == "\t" then return "\t"
        else return "\32" end
    end)
end

local function highlightStrings(text)
    local result = ""
    local inQuote = false
    text:gsub(".", function(c)
        if c == "\34" then inQuote = not inQuote end
        if c == "\34" then result = result .. "\34"
        elseif c == "\n" then result = result .. "\n"
        elseif c == "\t" then result = result .. "\t"
        elseif inQuote then result = result .. c
        else result = result .. "\32" end
    end)
    return result
end

local function highlightInfo(text)
    local result = ""
    local inBracket = false
    text:gsub(".", function(c)
        if c == "[" then inBracket = true
        elseif c == "]" then inBracket = false end
        if c == "]" then result = result .. "]"
        elseif c == "\n" then result = result .. "\n"
        elseif c == "\t" then result = result .. "\t"
        elseif inBracket then result = result .. c
        else result = result .. "\32" end
    end)
    return result
end

local function highlightComments(text)
    local result = ""
    text:gsub("[^\r\n]+", function(line)
        local isComment = false
        local i = 0
        line:gsub(".", function(char)
            i = i + 1
            if line:sub(i, i + 1) == "--" then isComment = true end
            result = result .. (isComment and char or "\32")
        end)
        result = result .. "\n"
    end)
    return result
end

local function highlightNumbers(text)
    return text:gsub(".", function(c)
        if tonumber(c) then return c
        elseif c == "\n" then return "\n"
        elseif c == "\t" then return "\t"
        else return "\32" end
    end)
end

local function updateConsoleHighlighting(sourceBox, scrollingFrame, linesLabel, sourceType)
    local function applyHighlighting()
        local text = sourceBox.Text:gsub("\13", ""):gsub("\t", "      ")
        
        if sourceType == "Lua" then
            sourceBox.Keywords.Text = highlightText(text, LUA_KEYWORDS)
            sourceBox.Globals.Text = highlightText(text, GLOBAL_ENV)
            sourceBox.RemoteHighlight.Text = highlightText(text, {"FireServer", "fireServer", "InvokeServer", "invokeServer"})
            sourceBox.Tokens.Text = highlightTokens(text)
            sourceBox.Numbers.Text = highlightNumbers(text)
            sourceBox.Strings.Text = highlightStrings(text)
            sourceBox.Comments.Text = highlightComments(text)
        elseif sourceType == "Logs" then
            sourceBox.Info.Text = highlightInfo(text)
        end

        local lineCount = 1
        text:gsub("\n", function() lineCount = lineCount + 1 end)
        
        linesLabel.Text = ""
        for i = 1, lineCount do
            linesLabel.Text = linesLabel.Text .. i .. "\n"
        end
        
        scrollingFrame.CanvasSize = UDim2.new(0, 0, lineCount * 0.153846154, 0)
    end

    applyHighlighting()
    sourceBox.Changed:Connect(function(prop) 
        if prop == "Text" then applyHighlighting() end 
    end)
end

-- 7. UI Builders & 10. Entry Point
local Library = {}
Library.FormatWindows = formatWindows

function Library:AddWindow(title, options)
    State.windowCount += 1
    title = tostring(title or "New Window")
    options = setmetatable(typeof(options) == "table" and options or {}, {__index = DEFAULT_UI_OPTIONS})
    options.tween_time = 0.1

    local window = Prefabs.Window:Clone()
    window.Parent = Windows
    window.Title.Text = title
    window.Size = UDim2.new(0, options.min_size.X, 0, options.min_size.Y)
    window.ZIndex += (State.windowCount * 10)

    task.spawn(function()
        while true do
            window.Bar.BackgroundColor3 = options.main_color
            window.Bar.Base.BackgroundColor3 = options.main_color
            window.Bar.Base.ImageColor3 = options.main_color
            window.Bar.Top.ImageColor3 = options.main_color
            window.TabSelection.Frame.BackgroundColor3 = options.main_color
            RunService.Heartbeat:Wait()
        end
    end)

    local resizer = window.Resizer
    local isResizing = false
    local isHoveringResizer = false
    local originalIcon = Mouse.Icon

    resizer.MouseEnter:Connect(function()
        window.Draggable = false
        isHoveringResizer = true
        if options.can_resize then
            originalIcon = Mouse.Icon
        end
    end)

    resizer.MouseLeave:Connect(function()
        isHoveringResizer = false
        if options.can_resize then
            Mouse.Icon = originalIcon
        end
        window.Draggable = true
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = true
            task.spawn(function()
                if isHoveringResizer and resizer.Active and options.can_resize then
                    while isResizing and resizer.Active do
                        local mousePos = getMousePosition()
                        local x = mousePos.X - window.AbsolutePosition.X
                        local y = mousePos.Y - window.AbsolutePosition.Y

                        local newX = math.max(x, options.min_size.X)
                        local newY = math.max(y, options.min_size.Y)

                        tweenProperty(window, {Size = UDim2.new(0, newX, 0, newY)}, options.tween_time)
                        RunService.Heartbeat:Wait()
                    end
                end
            end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = false
        end
    end)

    local toggleButton = window.Bar.Toggle
    local isOpen = true
    local canToggle = true
    local savedTabVisibility = {}
    local savedHeight = window.AbsoluteSize.Y

    toggleButton.MouseButton1Click:Connect(function()
        if not canToggle then return end
        canToggle = false

        if isOpen then
            for _, tab in ipairs(window.Tabs:GetChildren()) do
                savedTabVisibility[tab] = tab.Visible
                tab.Visible = false
            end
            resizer.Active = false
            savedHeight = window.AbsoluteSize.Y

            tweenProperty(toggleButton, {Rotation = 0}, options.tween_time)
            tweenProperty(window, {Size = UDim2.new(0, window.AbsoluteSize.X, 0, 26)}, options.tween_time)
            toggleButton.Parent.Base.Transparency = 1
        else
            for tab, visible in pairs(savedTabVisibility) do
                tab.Visible = visible
            end
            resizer.Active = true

            tweenProperty(toggleButton, {Rotation = 90}, options.tween_time)
            tweenProperty(window, {Size = UDim2.new(0, window.AbsoluteSize.X, 0, savedHeight)}, options.tween_time)
            toggleButton.Parent.Base.Transparency = 0
        end

        isOpen = not isOpen
        task.wait(options.tween_time)
        canToggle = true
    end)

    local tabsContainer = window.Tabs
    local tabSelection = window.TabSelection
    local tabButtonsContainer = tabSelection.TabButtons
    local windowData = {}

    function windowData:AddTab(tabName)
        local tabData = {}
        tabName = tostring(tabName or "New Tab")
        tabSelection.Visible = true

        local tabButton = Prefabs.TabButton:Clone()
        tabButton.Parent = tabButtonsContainer
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(0, getTextWidth(tabButton), 0, 20)
        tabButton.ZIndex += (State.windowCount * 10)
        tabButton.TextButton_Roundify_4px.ZIndex += (State.windowCount * 10)

        local tabFrame = Prefabs.Tab:Clone()
        tabFrame.Parent = tabsContainer
        tabFrame.ZIndex += (State.windowCount * 10)

        local function showTab()
            if State.isDropdownOpen then return end

            for _, btn in ipairs(tabButtonsContainer:GetChildren()) do
                if not btn:IsA("UIListLayout") then
                    btn.TextButton_Roundify_4px.ImageColor3 = Color3.fromRGB(52, 53, 56)
                    tweenProperty(btn, {Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 20)}, options.tween_time)
                end
            end

            for _, tab in ipairs(tabsContainer:GetChildren()) do
                tab.Visible = false
            end

            tweenProperty(tabButton, {Size = UDim2.new(0, tabButton.AbsoluteSize.X, 0, 25)}, options.tween_time)
            tabButton.TextButton_Roundify_4px.ImageColor3 = Color3.fromRGB(73, 75, 79)
            tabFrame.Visible = true
        end

        tabButton.MouseButton1Click:Connect(showTab)

        function tabData:Show()
            showTab()
        end

        function tabData:AddLabel(labelText)
            labelText = tostring(labelText or "New Label")
            local label = Prefabs.Label:Clone()
            label.Parent = tabFrame
            label.Text = labelText
            label.Size = UDim2.new(0, getTextWidth(label), 0, 20)
            label.ZIndex += (State.windowCount * 10)
            return label
        end

        function tabData:AddButton(buttonText, callback)
            buttonText = tostring(buttonText or "New Button")
            callback = typeof(callback) == "function" and callback or function() end

            local button = Prefabs.Button:Clone()
            button.Parent = tabFrame
            button.Text = buttonText
            button.Size = UDim2.new(0, getTextWidth(button), 0, 20)
            button.ZIndex += (State.windowCount * 10)
            button.TextButton_Roundify_4px.ZIndex += (State.windowCount * 10)

            task.spawn(function()
                while true do
                    if button and button.TextButton_Roundify_4px then
                        button.TextButton_Roundify_4px.ImageColor3 = options.main_color
                    end
                    RunService.Heartbeat:Wait()
                end
            end)

            button.MouseButton1Click:Connect(function()
                createRipple(button, Mouse.X, Mouse.Y)
                pcall(callback)
            end)

            return button
        end

        function tabData:AddSwitch(switchText, callback)
            local switchData = {}
            switchText = tostring(switchText or "New Switch")
            callback = typeof(callback) == "function" and callback or function() end

            local switch = Prefabs.Switch:Clone()
            switch.Parent = tabFrame
            switch.Title.Text = switchText
            switch.Title.ZIndex += (State.windowCount * 10)
            switch.ZIndex += (State.windowCount * 10)
            switch.TextButton_Roundify_4px.ZIndex += (State.windowCount * 10)

            task.spawn(function()
                while true do
                    if switch and switch.TextButton_Roundify_4px then
                        switch.TextButton_Roundify_4px.ImageColor3 = options.main_color
                    end
                    RunService.Heartbeat:Wait()
                end
            end)

            local isToggled = false
            switch.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                switch.Text = isToggled and utf8.char(10003) or ""
                pcall(callback, isToggled)
            end)

            function switchData:Set(bool)
                isToggled = (typeof(bool) == "boolean") and bool or false
                switch.Text = isToggled and utf8.char(10003) or ""
                pcall(callback, isToggled)
            end

            return switchData, switch
        end

        function tabData:AddTextBox(placeholderText, callback, textBoxOptions)
            placeholderText = tostring(placeholderText or "New TextBox")
            callback = typeof(callback) == "function" and callback or function() end
            textBoxOptions = typeof(textBoxOptions) == "table" and textBoxOptions or {}
            local clearOnFocusLost = (textBoxOptions.clear == true)

            local textBox = Prefabs.TextBox:Clone()
            textBox.Parent = tabFrame
            textBox.PlaceholderText = placeholderText
            textBox.ZIndex += (State.windowCount * 10)
            textBox.TextBox_Roundify_4px.ZIndex += (State.windowCount * 10)

            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and #textBox.Text > 0 then
                    pcall(callback, textBox.Text)
                    if clearOnFocusLost then
                        textBox.Text = ""
                    end
                end
            end)

            return textBox
        end

        function tabData:AddSlider(sliderText, callback, sliderOptions)
            local sliderData = {}
            sliderText = tostring(sliderText or "New Slider")
            callback = typeof(callback) == "function" and callback or function() end
            sliderOptions = typeof(sliderOptions) == "table" and sliderOptions or {}
            
            local minValue = sliderOptions.min or 0
            local maxValue = sliderOptions.max or 100
            local isReadOnly = sliderOptions.readonly or false

            local slider = Prefabs.Slider:Clone()
            slider.Parent = tabFrame
            slider.ZIndex += (State.windowCount * 10)

            local title = slider.Title
            local indicator = slider.Indicator
            local valueText = slider.Value
            
            title.ZIndex += (State.windowCount * 10)
            indicator.ZIndex += (State.windowCount * 10)
            valueText.ZIndex += (State.windowCount * 10)
            title.Text = sliderText

            local isHovering = false
            slider.MouseEnter:Connect(function()
                isHovering = true
                window.Draggable = false
            end)
            slider.MouseLeave:Connect(function()
                isHovering = false
                window.Draggable = true
            end)

            local isDragging = false
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    task.spawn(function()
                        if isHovering and not isReadOnly then
                            while isDragging and not State.isDropdownOpen do
                                local mousePos = getMousePosition()
                                local relativeX = (mousePos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                                local clampedX = math.clamp(relativeX, 0, 1)

                                tweenProperty(indicator, {Size = UDim2.new(clampedX, 0, 0, 20)}, options.tween_time)
                                
                                local diff = maxValue - minValue
                                local currentValue = math.floor((diff * clampedX) + minValue)

                                valueText.Text = tostring(currentValue)
                                pcall(callback, currentValue)

                                RunService.Heartbeat:Wait()
                            end
                        end
                    end)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)

            function sliderData:Set(newValue)
                newValue = tonumber(newValue) or 0
                local percentage = math.clamp(newValue, 0, 100) / 100

                tweenProperty(indicator, {Size = UDim2.new(percentage, 0, 0, 20)}, options.tween_time)
                
                local diff = maxValue - minValue
                local currentValue = math.floor((diff * percentage) + minValue)

                valueText.Text = tostring(currentValue)
                pcall(callback, currentValue)
            end

            sliderData:Set(minValue)
            return sliderData, slider
        end

        function tabData:AddKeybind(keybindName, callback, keybindOptions)
            local keybindData = {}
            keybindName = tostring(keybindName or "New Keybind")
            callback = typeof(callback) == "function" and callback or function() end
            keybindOptions = typeof(keybindOptions) == "table" and keybindOptions or {}
            
            local standardKey = keybindOptions.standard or Enum.KeyCode.RightShift

            local keybind = Prefabs.Keybind:Clone()
            local inputButton = keybind.Input
            local title = keybind.Title
            
            keybind.ZIndex += (State.windowCount * 10)
            inputButton.ZIndex += (State.windowCount * 10)
            inputButton.Input_Roundify_4px.ZIndex += (State.windowCount * 10)
            title.ZIndex += (State.windowCount * 10)

            keybind.Parent = tabFrame
            title.Text = "  " .. keybindName
            keybind.Size = UDim2.new(0, getTextWidth(title) + 80, 0, 20)

            local currentKey = standardKey

            function keybindData:SetKeybind(keyObj)
                local keyName = SHORTCUT_KEYS[keyObj.Name] or keyObj.Name
                inputButton.Text = keyName
                currentKey = keyObj
            end

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if State.isBindingKey then
                    task.spawn(function()
                        task.wait()
                        State.isBindingKey = false
                    end)
                    return
                end
                if input.KeyCode == currentKey and not gameProcessed then
                    pcall(callback, currentKey)
                end
            end)

            keybindData:SetKeybind(standardKey)

            inputButton.MouseButton1Click:Connect(function()
                if State.isBindingKey then return end
                inputButton.Text = "..."
                State.isBindingKey = true
                local newInput, _ = UserInputService.InputBegan:Wait()
                keybindData:SetKeybind(newInput.KeyCode)
            end)

            return keybindData, keybind
        end

        function tabData:AddDropdown(dropdownName, callback)
            local dropdownData = {}
            dropdownName = tostring(dropdownName or "New Dropdown")
            callback = typeof(callback) == "function" and callback or function() end

            local dropdown = Prefabs.Dropdown:Clone()
            local box = dropdown.Box
            local objects = box.Objects
            local indicator = dropdown.Indicator
            
            dropdown.ZIndex += (State.windowCount * 10)
            box.ZIndex += (State.windowCount * 10)
            objects.ZIndex += (State.windowCount * 10)
            indicator.ZIndex += (State.windowCount * 10)
            dropdown.TextButton_Roundify_4px.ZIndex += (State.windowCount * 10)

            dropdown.Parent = tabFrame
            dropdown.Text = "      " .. dropdownName
            box.Size = UDim2.new(1, 0, 0, 0)

            local isOpen = false
            dropdown.MouseButton1Click:Connect(function()
                isOpen = not isOpen

                local itemCount = #objects:GetChildren() - 1
                local height = math.min(itemCount, 10) * 20
                objects.CanvasSize = (itemCount >= 10) and UDim2.new(0, 0, itemCount * 0.1, 0) or UDim2.new(0, 0, 0, 0)

                if isOpen then
                    if State.isDropdownOpen then return end
                    State.isDropdownOpen = true
                    tweenProperty(box, {Size = UDim2.new(1, 0, 0, height)}, options.tween_time)
                    tweenProperty(indicator, {Rotation = 90}, options.tween_time)
                else
                    State.isDropdownOpen = false
                    tweenProperty(box, {Size = UDim2.new(1, 0, 0, 0)}, options.tween_time)
                    tweenProperty(indicator, {Rotation = -90}, options.tween_time)
                end
            end)

            function dropdownData:Add(itemName)
                local objectData = {}
                itemName = tostring(itemName or "New Object")

                local itemButton = Prefabs.DropdownButton:Clone()
                itemButton.Parent = objects
                itemButton.Text = itemName
                itemButton.ZIndex += (State.windowCount * 10)

                itemButton.MouseEnter:Connect(function()
                    itemButton.BackgroundColor3 = options.main_color
                end)
                itemButton.MouseLeave:Connect(function()
                    itemButton.BackgroundColor3 = Color3.fromRGB(33, 34, 36)
                end)

                if isOpen then
                    local itemCount = #objects:GetChildren() - 1
                    local height = math.min(itemCount, 10) * 20
                    objects.CanvasSize = (itemCount >= 10) and UDim2.new(0, 0, itemCount * 0.1, 0) or UDim2.new(0, 0, 0, 0)
                    tweenProperty(box, {Size = UDim2.new(1, 0, 0, height)}, options.tween_time)
                end

                itemButton.MouseButton1Click:Connect(function()
                    if State.isDropdownOpen then
                        dropdown.Text = "      [ " .. itemName .. " ]"
                        State.isDropdownOpen = false
                        isOpen = false
                        tweenProperty(box, {Size = UDim2.new(1, 0, 0, 0)}, options.tween_time)
                        tweenProperty(indicator, {Rotation = -90}, options.tween_time)
                        pcall(callback, itemName)
                    end
                end)

                function objectData:Remove()
                    itemButton:Destroy()
                end

                return itemButton, objectData
            end

            return dropdownData, dropdown
        end

        function tabData:AddColorPicker(callback)
            local colorPickerData = {}
            callback = typeof(callback) == "function" and callback or function() end

            local colorPicker = Prefabs.ColorPicker:Clone()
            colorPicker.Parent = tabFrame
            colorPicker.ZIndex += (State.windowCount * 10)

            local palette = colorPicker.Palette
            local sample = colorPicker.Sample
            local saturation = colorPicker.Saturation
            
            palette.ZIndex += (State.windowCount * 10)
            sample.ZIndex += (State.windowCount * 10)
            saturation.ZIndex += (State.windowCount * 10)

            local h, s, v = 0, 1, 1

            local function updateColor()
                local color = Color3.fromHSV(h, s, v)
                sample.ImageColor3 = color
                saturation.ImageColor3 = Color3.fromHSV(h, 1, 1)
                pcall(callback, color)
            end

            updateColor()

            local isHoveringPalette, isHoveringSaturation = false, false
            
            palette.MouseEnter:Connect(function() window.Draggable = false; isHoveringPalette = true end)
            palette.MouseLeave:Connect(function() window.Draggable = true; isHoveringPalette = false end)
            saturation.MouseEnter:Connect(function() window.Draggable = false; isHoveringSaturation = true end)
            saturation.MouseLeave:Connect(function() window.Draggable = true; isHoveringSaturation = false end)

            local paletteIndicator = palette.Indicator
            local saturationIndicator = saturation.Indicator
            paletteIndicator.ZIndex += (State.windowCount * 10)
            saturationIndicator.ZIndex += (State.windowCount * 10)

            local isDragging = false
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    task.spawn(function()
                        while isDragging and not State.isDropdownOpen do
                            local mousePos = getMousePosition()
                            
                            if isHoveringPalette then
                                local origX = (palette.AbsoluteSize.X - (mousePos.X - palette.AbsolutePosition.X)) + 1
                                local origY = (palette.AbsoluteSize.Y - (mousePos.Y - palette.AbsolutePosition.Y)) + 1.5
                                h = origX / 100
                                s = origY / 100

                                tweenProperty(paletteIndicator, {
                                    Position = UDim2.new(0, math.abs(origX - 100) - (paletteIndicator.AbsoluteSize.X / 2), 0, math.abs(origY - 100) - (paletteIndicator.AbsoluteSize.Y / 2))
                                }, options.tween_time)
                            end

                            if isHoveringSaturation then
                                local origY = (palette.AbsoluteSize.Y - (mousePos.Y - palette.AbsolutePosition.Y)) + 1.5
                                v = origY / 100
                                tweenProperty(saturationIndicator, {
                                    Position = UDim2.new(0, 0, 0, math.abs(origY - 100))
                                }, options.tween_time)
                            end

                            updateColor()
                            RunService.Heartbeat:Wait()
                        end
                    end)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)

            function colorPickerData:Set(color)
                color = typeof(color) == "Color3" and color or Color3.new(1, 1, 1)
                local h2, s2, v2 = rgbToHsv(color.R * 255, color.G * 255, color.B * 255)
                h, s, v = h2, s2, v2
                sample.ImageColor3 = color
                saturation.ImageColor3 = Color3.fromHSV(h2, 1, 1)
                pcall(callback, color)
            end

            return colorPickerData, colorPicker
        end

        function tabData:AddConsole(consoleOptions)
            local consoleData = {}
            consoleOptions = typeof(consoleOptions) == "table" and consoleOptions or {}
            
            local height = tonumber(consoleOptions.y) or 200
            local sourceType = consoleOptions.source or "Logs"
            local isReadOnly = (consoleOptions.readonly == true)
            local isFull = (consoleOptions.full == true)

            local console = Prefabs.Console:Clone()
            console.Parent = tabFrame
            console.ZIndex += (State.windowCount * 10)
            console.Size = UDim2.new(1, 0, isFull and 1 or 0, height)

            local scrollingFrame = console.ScrollingFrame
            local sourceBox = scrollingFrame.Source
            local linesLabel = scrollingFrame.Lines
            
            sourceBox.ZIndex += (State.windowCount * 10)
            linesLabel.ZIndex += (State.windowCount * 10)
            sourceBox.TextEditable = not isReadOnly

            for _, child in ipairs(sourceBox:GetChildren()) do
                child.ZIndex += (State.windowCount * 10) + 1
            end
            sourceBox.Comments.ZIndex += 1

            if sourceType == "Lua" or sourceType == "Logs" then
                if sourceType == "Logs" then linesLabel.Visible = false end
                updateConsoleHighlighting(sourceBox, scrollingFrame, linesLabel, sourceType)
            end

            function consoleData:Set(code)
                sourceBox.Text = tostring(code)
            end

            function consoleData:Get()
                return sourceBox.Text
            end

            function consoleData:Log(msg)
                sourceBox.Text = sourceBox.Text .. "[*] " .. tostring(msg) .. "\n"
            end

            return consoleData, console
        end

        function tabData:AddHorizontalAlignment()
            local haData = {}
            local ha = Prefabs.HorizontalAlignment:Clone()
            ha.Parent = tabFrame

            function haData:AddButton(...)
                local result = {tabData:AddButton(...)}
                local data, object = result[1], result[2]
                if typeof(data) == "table" then
                    object.Parent = ha
                    return data, object
                else
                    object = data
                    object.Parent = ha
                    return object
                end
            end

            return haData, ha
        end

        function tabData:AddFolder(folderName)
            local folderData = {}
            folderName = tostring(folderName or "New Folder")

            local folder = Prefabs.Folder:Clone()
            local button = folder.Button
            local objects = folder.Objects
            local toggle = button.Toggle
            
            folder.ZIndex += (State.windowCount * 10)
            button.ZIndex += (State.windowCount * 10)
            objects.ZIndex += (State.windowCount * 10)
            toggle.ZIndex += (State.windowCount * 10)
            button.TextButton_Roundify_4px.ZIndex += (State.windowCount * 10)

            folder.Parent = tabFrame
            button.Text = "      " .. folderName

            task.spawn(function()
                while true do
                    if button and button.TextButton_Roundify_4px then
                        button.TextButton_Roundify_4px.ImageColor3 = options.main_color
                    end
                    RunService.Heartbeat:Wait()
                end
            end)

            local function getFolderHeight()
                local height = 25
                for _, child in ipairs(objects:GetChildren()) do
                    if not child:IsA("UIListLayout") then
                        height += child.AbsoluteSize.Y + 5
                    end
                end
                return height
            end

            local isOpen = false
            button.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                tweenProperty(toggle, {Rotation = isOpen and 90 or 0}, options.tween_time)
                objects.Visible = isOpen
            end)

            task.spawn(function()
                while true do
                    tweenProperty(folder, {Size = UDim2.new(1, 0, 0, isOpen and getFolderHeight() or 20)}, options.tween_time)
                    task.wait()
                end
            end)

            for methodName, methodFunc in pairs(tabData) do
                folderData[methodName] = function(...)
                    local result = {methodFunc(...)}
                    local data, object = result[1], result[2]
                    if typeof(data) == "table" then
                        object.Parent = objects
                        return data, object
                    else
                        object = data
                        object.Parent = objects
                        return object
                    end
                end
            end

            return folderData, folder
        end

        return tabData, tabFrame
    end

    for _, descendant in ipairs(window:GetDescendants()) do
        if hasProperty(descendant, "ZIndex") then
            descendant.ZIndex += (State.windowCount * 10)
        end
    end

    return windowData, window
end

script.Parent = imgui
return Library
