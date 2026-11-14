
--========================================
-- CitraUI Example
--========================================

local URL = "https://raw.githubusercontent.com/gilgameshfate59/ohbfoosk8tid/refs/heads/main/CitraUI.lua"

-- Load Library
local Success, CitraUI = pcall(function()
    return loadstring(game:HttpGet(URL))()
end)

if not Success or not CitraUI then
    warn("[CitraUI] Failed to load library")
    return
end

local WindUI = CitraUI.WindUI

-- Set Theme
WindUI:SetTheme("Citra")

--========================================
-- Create Window
--========================================

local Window = WindUI:CreateWindow({
    Title = "CitraUI Example",
    ToggleKey = "RightShift"
})

--========================================
-- Main Tab
--========================================

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house"
})

local MainSection = MainTab:Section({
    Title = "Main Controls"
})

-- Toggle
MainSection:Toggle({
    Title = "Example Toggle",
    Desc = "ตัวอย่าง Toggle",
    Value = false,
    Flag = "ExampleToggle",

    Callback = function(Value)
        print("Toggle:", Value)
    end
})

-- Slider
MainSection:Slider({
    Title = "WalkSpeed",
    Desc = "ตัวอย่าง Slider",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16
    },
    Suffix = " WS",

    Callback = function(Value)
        print("Slider:", Value)
    end
})

-- Dropdown
MainSection:Dropdown({
    Title = "Select Option",
    Desc = "เลือกตัวเลือก",
    Values = {
        "Option 1",
        "Option 2",
        "Option 3"
    },
    Value = "Option 1",

    Callback = function(Value)
        print("Selected:", Value)
    end
})

-- Input
MainSection:Input({
    Title = "Player Name",
    Desc = "กรอกข้อความ",
    Value = "",
    Placeholder = "Enter name...",

    Callback = function(Value)
        print("Input:", Value)
    end
})

-- Keybind
MainSection:Keybind({
    Title = "Test Keybind",
    Desc = "เลือกปุ่มสำหรับทดสอบ",
    Value = "K",

    Callback = function(Key)
        print("Keybind:", Key)
    end
})

-- Colorpicker
MainSection:Colorpicker({
    Title = "Select Color",
    Default = Color3.fromRGB(255, 138, 32),

    Callback = function(Color)
        print("Color:", Color)
    end
})

--========================================
-- Actions Tab
--========================================

local ActionsTab = Window:Tab({
    Title = "Actions",
    Icon = "zap"
})

local ActionsSection = ActionsTab:Section({
    Title = "Actions"
})

-- Button
ActionsSection:Button({
    Title = "Show Notification",
    Desc = "แสดง Notification",

    Callback = function()
        WindUI:Notify({
            Title = "CitraUI",
            Content = "Hello! This is a notification.",
            Duration = 4,
            Icon = "bell"
        })
    end
})

-- Another Button
ActionsSection:Button({
    Title = "Print Hello",

    Callback = function()
        print("Hello from CitraUI!")
    end
})

--========================================
-- Settings Tab
--========================================

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

local SettingsSection = SettingsTab:Section({
    Title = "UI Settings"
})

-- Theme Selector
SettingsSection:Dropdown({
    Title = "UI Theme",
    Values = {
        "Citra",
        "Ember",
        "Azure",
        "Emerald",
        "Ocean",
        "Rose"
    },
    Value = "Citra",

    Callback = function(Value)
        WindUI:SetTheme(Value)
    end
})

-- Destroy UI
SettingsSection:Button({
    Title = "Unload UI",
    Desc = "ปิดและลบ UI",

    Callback = function()
        Window:Destroy()
    end
})

--========================================
-- Window Events
--========================================

Window:OnOpen(function()
    print("UI Opened")
end)

Window:OnClose(function()
    print("UI Closed")
end)

print("[CitraUI] Loaded Successfully!")
