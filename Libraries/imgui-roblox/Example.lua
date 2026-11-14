
local ImGui = loadstring(game:HttpGet(
    "https://github.com/lithium1on/imgui-roblox/releases/latest/download/imgui.luau"
))()

ImGui.Init({
    Font = "Monospace",
    FontSize = 14
})

local State = {
    Enabled = true,
    Volume = 0.5,
    Count = 5,
    Mode = 0,
    Name = "",
    Amount = 10,
    Color = {0.26, 0.59, 0.98, 1},
    Clicks = 0,
    Progress = 0
}

local Modes = {
    "Normal",
    "Balanced",
    "Performance"
}

ImGui.OnFrame(function()

    ImGui.SetNextWindowSize(
        Vector2.new(550, 450),
        ImGui.Cond.FirstUseEver
    )

    if not ImGui.Begin("NOVA UI Dashboard") then
        ImGui.End()
        return
    end

    ImGui.Text("NOVA // Dear ImGui")
    ImGui.Separator()

    if ImGui.BeginTabBar("MainTabs") then

        -- Dashboard
        if ImGui.BeginTabItem("Dashboard") then

            ImGui.SeparatorText("Overview")

            ImGui.Text("Welcome to NOVA")

            ImGui.Text(
                "Version: %s",
                ImGui.GetVersion()
            )

            ImGui.Text(
                "FPS: %.1f",
                ImGui.GetIO().Framerate
            )

            ImGui.SeparatorText("Statistics")

            ImGui.Text(
                "Button clicks: %d",
                State.Clicks
            )

            if ImGui.Button("Click Me") then
                State.Clicks += 1
            end

            ImGui.SameLine()

            if ImGui.Button("Reset") then
                State.Clicks = 0
            end

            ImGui.EndTabItem()
        end

        -- Controls
        if ImGui.BeginTabItem("Controls") then

            local Changed

            ImGui.SeparatorText("Checkbox")

            Changed, State.Enabled =
                ImGui.Checkbox(
                    "Enable Settings",
                    State.Enabled
                )

            ImGui.SeparatorText("Sliders")

            ImGui.BeginDisabled(not State.Enabled)

            Changed, State.Volume =
                ImGui.SliderFloat(
                    "Volume",
                    State.Volume,
                    0,
                    1,
                    "%.2f"
                )

            Changed, State.Count =
                ImGui.SliderInt(
                    "Count",
                    State.Count,
                    1,
                    100
                )

            ImGui.EndDisabled()

            ImGui.SeparatorText("Radio Buttons")

            for Index, Name in ipairs(Modes) do

                if ImGui.RadioButton(
                    Name,
                    State.Mode == Index - 1
                ) then
                    State.Mode = Index - 1
                end

                if Index < #Modes then
                    ImGui.SameLine()
                end
            end

            ImGui.SeparatorText("Dropdown")

            Changed, State.Mode =
                ImGui.Combo(
                    "Operating Mode",
                    State.Mode,
                    Modes
                )

            ImGui.EndTabItem()
        end

        -- Inputs
        if ImGui.BeginTabItem("Inputs") then

            local Changed

            ImGui.SeparatorText("Text Input")

            Changed, State.Name =
                ImGui.InputTextWithHint(
                    "Username",
                    "Enter your name...",
                    State.Name
                )

            ImGui.SeparatorText("Number Input")

            Changed, State.Amount =
                ImGui.InputInt(
                    "Amount",
                    State.Amount
                )

            ImGui.SeparatorText("Color Picker")

            Changed, State.Color =
                ImGui.ColorEdit4(
                    "Accent Color",
                    State.Color
                )

            if ImGui.Button("Print Values") then
                print("Name:", State.Name)
                print("Amount:", State.Amount)
                print("Mode:", Modes[State.Mode + 1])
            end

            ImGui.EndTabItem()
        end

        -- Appearance
        if ImGui.BeginTabItem("Appearance") then

            ImGui.SeparatorText("Progress Bar")

            State.Progress = (
                State.Progress +
                ImGui.GetIO().DeltaTime * 0.2
            ) % 1

            ImGui.ProgressBar(
                State.Progress,
                Vector2.new(-1, 0)
            )

            ImGui.SeparatorText("Collapsing Header")

            if ImGui.CollapsingHeader("Advanced Settings") then

                ImGui.TextWrapped(
                    "This section demonstrates expandable UI components."
                )

                if ImGui.TreeNode("More Options") then

                    ImGui.BulletText("Option One")
                    ImGui.BulletText("Option Two")
                    ImGui.BulletText("Option Three")

                    ImGui.TreePop()
                end
            end

            ImGui.EndTabItem()
        end

        ImGui.EndTabBar()
    end

    ImGui.End()
end)

print("[NOVA] UI Loaded")
