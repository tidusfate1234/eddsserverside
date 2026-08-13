--^#^ F.U.S.I.O.N    U.I.    L.I.B.A.R.Y ^#^--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Fusion = {}
Fusion.__index = Fusion

Fusion.Flags = {}
Fusion.Theme = {
	Accent = Color3.fromRGB(62, 142, 247),
	AccentDark = Color3.fromRGB(38, 100, 199),
	Background = Color3.fromRGB(18, 24, 34),
	Glass = Color3.fromRGB(32, 42, 58),
	GlassLight = Color3.fromRGB(46, 58, 78),
	Stroke = Color3.fromRGB(70, 90, 115),
	Text = Color3.fromRGB(235, 240, 248),
	SubText = Color3.fromRGB(160, 172, 190),
	Error = Color3.fromRGB(235, 90, 90),
}

local function GetGui()
	local existing = CoreGui:FindFirstChild("FusionUI")
	if existing then
		existing:Destroy()
	end
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "FusionUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999
	local ok = pcall(function()
		ScreenGui.Parent = CoreGui
	end)
	if not ok then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	return ScreenGui
end

local function Create(class, props, children)
	local inst = Instance.new(class)
	for prop, value in pairs(props or {}) do
		inst[prop] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function Corner(radius)
	return Create("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

local function Stroke(color, thickness, transparency)
	return Create("UIStroke", {
		Color = color or Fusion.Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function Pad(l, t, r, b)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or l or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
	})
end

local function Gradient(rotation, colorSeq, transSeq)
	return Create("UIGradient", {
		Rotation = rotation or 90,
		Color = colorSeq,
		Transparency = transSeq,
	})
end

local function Tween(inst, props, time, style, direction)
	local info = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local tw = TweenService:Create(inst, info, props)
	tw:Play()
	return tw
end

local function GlassPanel(props, children)
	local base = Create("Frame", {
		BackgroundColor3 = Fusion.Theme.Glass,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
	}, children)
	for k, v in pairs(props or {}) do
		base[k] = v
	end
	Corner(14).Parent = base
	Stroke(Fusion.Theme.Stroke, 1, 0.6).Parent = base
	Gradient(90, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	}), NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.92),
		NumberSequenceKeypoint.new(1, 0.97),
	})).Parent = base
	return base
end

local function MakeDraggable(handle, target)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

function Fusion:CreateWindow(config)
	config = config or {}
	local Title = config.Title or "Fusion"
	local SubTitle = config.SubTitle or ""
	local Size = config.Size or UDim2.fromOffset(620, 420)
	local Theme = config.Theme
	if Theme then
		for k, v in pairs(Theme) do
			Fusion.Theme[k] = v
		end
	end

	local ScreenGui = GetGui()

	local Window = GlassPanel({
		Name = "Window",
		Size = Size,
		Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2),
		Parent = ScreenGui,
		ClipsDescendants = true,
	})

	local TopBar = Create("Frame", {
		Name = "TopBar",
		BackgroundColor3 = Fusion.Theme.GlassLight,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 56),
		Parent = Window,
	})
	Corner(14).Parent = TopBar
	Create("Frame", {
		BackgroundColor3 = Fusion.Theme.GlassLight,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		BorderSizePixel = 0,
		ZIndex = 0,
	}).Parent = TopBar

	local TitleLabel = Create("TextLabel", {
		Name = "TitleLabel",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 8),
		Size = UDim2.new(0.6, 0, 0, 22),
		Font = Enum.Font.GothamBold,
		Text = Title,
		TextColor3 = Fusion.Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TopBar,
	})

	local SubLabel = Create("TextLabel", {
		Name = "SubLabel",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 28),
		Size = UDim2.new(0.6, 0, 0, 16),
		Font = Enum.Font.Gotham,
		Text = SubTitle,
		TextColor3 = Fusion.Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TopBar,
	})

	local CloseBtn = Create("TextButton", {
		Name = "CloseBtn",
		BackgroundColor3 = Color3.fromRGB(235, 90, 90),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(1, -30, 0, 21),
		Text = "",
		AutoButtonColor = false,
		Parent = TopBar,
	})
	Corner(7).Parent = CloseBtn
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(Window, { Size = UDim2.fromOffset(0, 0) }, 0.25)
		task.wait(0.25)
		ScreenGui:Destroy()
	end)

	local MinBtn = Create("TextButton", {
		Name = "MinBtn",
		BackgroundColor3 = Color3.fromRGB(240, 190, 70),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(1, -52, 0, 21),
		Text = "",
		AutoButtonColor = false,
		Parent = TopBar,
	})
	Corner(7).Parent = MinBtn

	MakeDraggable(TopBar, Window)

	local TabBar = Create("Frame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 0, 34),
		Position = UDim2.new(0, 20, 0, 62),
		Parent = Window,
	})
	local TabLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	TabLayout.Parent = TabBar

	local PageHolder = Create("Frame", {
		Name = "PageHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, -110),
		Position = UDim2.new(0, 20, 0, 104),
		Parent = Window,
	})

	local minimized = false
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			Tween(Window, { Size = UDim2.new(0, Size.X.Offset, 0, 56) }, 0.3)
		else
			Tween(Window, { Size = Size }, 0.3)
		end
	end)

	local WindowObj = {}
	WindowObj.Tabs = {}
	WindowObj._firstTab = nil

	function WindowObj:CreateTab(name)
		local TabButton = Create("TextButton", {
			Name = name .. "Tab",
			BackgroundColor3 = Fusion.Theme.GlassLight,
			BackgroundTransparency = 0.3,
			Size = UDim2.fromOffset(0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.GothamMedium,
			Text = "  " .. name .. "  ",
			TextColor3 = Fusion.Theme.SubText,
			TextSize = 13,
			AutoButtonColor = false,
			Parent = TabBar,
		})
		Corner(8).Parent = TabButton

		local Page = Create("ScrollingFrame", {
			Name = name .. "Page",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Fusion.Theme.Accent,
			ScrollBarImageTransparency = 0.3,
			Visible = false,
			Parent = PageHolder,
		})
		local PageLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		PageLayout.Parent = Page

		local function selectTab()
			for _, t in pairs(WindowObj.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, { BackgroundTransparency = 0.3, TextColor3 = Fusion.Theme.SubText }, 0.2)
			end
			Page.Visible = true
			Tween(TabButton, { BackgroundTransparency = 0, TextColor3 = Fusion.Theme.Text }, 0.2)
		end

		TabButton.MouseButton1Click:Connect(selectTab)

		local TabObj = { Button = TabButton, Page = Page }
		table.insert(WindowObj.Tabs, TabObj)

		if not WindowObj._firstTab then
			WindowObj._firstTab = TabObj
			selectTab()
		end

		local Elements = {}

		function Elements:CreateSection(title)
			local SectionLabel = Create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Font = Enum.Font.GothamBold,
				Text = title,
				TextColor3 = Fusion.Theme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Page,
			})
			return SectionLabel
		end

		function Elements:CreateButton(config)
			config = config or {}
			local Callback = config.Callback or function() end
			local Btn = GlassPanel({
				Size = UDim2.new(1, 0, 0, 38),
				Parent = Page,
			})
			local ClickArea = Create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Button",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				AutoButtonColor = false,
				Parent = Btn,
			})
			ClickArea.MouseButton1Click:Connect(function()
				Tween(Btn, { BackgroundColor3 = Fusion.Theme.Accent }, 0.15)
				task.wait(0.15)
				Tween(Btn, { BackgroundColor3 = Fusion.Theme.Glass }, 0.15)
				Callback()
			end)
			return Btn
		end

		function Elements:CreateToggle(config)
			config = config or {}
			local Flag = config.Flag or config.Text
			local Default = config.Default or false
			local Callback = config.Callback or function() end

			local Holder = GlassPanel({
				Size = UDim2.new(1, 0, 0, 38),
				Parent = Page,
			})
			Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -70, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Toggle",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Holder,
			})

			local Switch = Create("Frame", {
				Size = UDim2.fromOffset(40, 22),
				Position = UDim2.new(1, -54, 0.5, -11),
				BackgroundColor3 = Default and Fusion.Theme.Accent or Fusion.Theme.GlassLight,
				Parent = Holder,
			})
			Corner(11).Parent = Switch

			local Knob = Create("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = Default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = Switch,
			})
			Corner(8).Parent = Knob

			local ClickArea = Create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Text = "",
				Parent = Holder,
			})

			local state = Default
			local function set(value, fire)
				state = value
				if value then
					Tween(Switch, { BackgroundColor3 = Fusion.Theme.Accent }, 0.2)
					Tween(Knob, { Position = UDim2.new(1, -19, 0.5, -8) }, 0.2)
				else
					Tween(Switch, { BackgroundColor3 = Fusion.Theme.GlassLight }, 0.2)
					Tween(Knob, { Position = UDim2.new(0, 3, 0.5, -8) }, 0.2)
				end
				if fire ~= false then
					Callback(value)
				end
				if Flag then
					Fusion.Flags[Flag] = value
				end
			end

			ClickArea.MouseButton1Click:Connect(function()
				set(not state)
			end)

			if Flag then
				Fusion.Flags[Flag] = state
			end

			return { Set = set, Get = function() return state end }
		end

		function Elements:CreateSlider(config)
			config = config or {}
			local Min = config.Min or 0
			local Max = config.Max or 100
			local Default = config.Default or Min
			local Increment = config.Increment or 1
			local Flag = config.Flag or config.Text
			local Callback = config.Callback or function() end

			local Holder = GlassPanel({
				Size = UDim2.new(1, 0, 0, 50),
				Parent = Page,
			})
			Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 6),
				Size = UDim2.new(0.6, 0, 0, 18),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Slider",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Holder,
			})
			local ValueLabel = Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -70, 0, 6),
				Size = UDim2.new(0, 56, 0, 18),
				Font = Enum.Font.GothamBold,
				Text = tostring(Default),
				TextColor3 = Fusion.Theme.Accent,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = Holder,
			})

			local Track = Create("Frame", {
				Size = UDim2.new(1, -28, 0, 6),
				Position = UDim2.new(0, 14, 0, 32),
				BackgroundColor3 = Fusion.Theme.GlassLight,
				Parent = Holder,
			})
			Corner(3).Parent = Track

			local Fill = Create("Frame", {
				Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0),
				BackgroundColor3 = Fusion.Theme.Accent,
				Parent = Track,
			})
			Corner(3).Parent = Fill

			local Knob = Create("Frame", {
				Size = UDim2.fromOffset(14, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((Default - Min) / (Max - Min), 0, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = Track,
			})
			Corner(7).Parent = Knob
			Stroke(Fusion.Theme.Accent, 2, 0).Parent = Knob

			local dragging = false
			local function update(input)
				local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local raw = Min + (Max - Min) * relative
				local stepped = math.floor(raw / Increment + 0.5) * Increment
				stepped = math.clamp(stepped, Min, Max)
				local scale = (stepped - Min) / (Max - Min)
				Fill.Size = UDim2.new(scale, 0, 1, 0)
				Knob.Position = UDim2.new(scale, 0, 0.5, 0)
				ValueLabel.Text = tostring(stepped)
				Callback(stepped)
				if Flag then
					Fusion.Flags[Flag] = stepped
				end
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					update(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			if Flag then
				Fusion.Flags[Flag] = Default
			end

			return Holder
		end

		function Elements:CreateDropdown(config)
			config = config or {}
			local Options = config.Options or {}
			local Default = config.Default or Options[1]
			local Flag = config.Flag or config.Text
			local Callback = config.Callback or function() end

			local Holder = GlassPanel({
				Size = UDim2.new(1, 0, 0, 38),
				ClipsDescendants = false,
				Parent = Page,
				ZIndex = 5,
			})
			Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Dropdown",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Holder,
			})

			local SelectedBtn = Create("TextButton", {
				Size = UDim2.new(0, 140, 0, 26),
				Position = UDim2.new(1, -154, 0.5, -13),
				BackgroundColor3 = Fusion.Theme.GlassLight,
				Font = Enum.Font.Gotham,
				Text = tostring(Default) .. "  ▾",
				TextColor3 = Fusion.Theme.SubText,
				TextSize = 12,
				AutoButtonColor = false,
				ZIndex = 6,
				Parent = Holder,
			})
			Corner(7).Parent = SelectedBtn

			local ListFrame = Create("Frame", {
				Size = UDim2.new(0, 140, 0, math.min(#Options * 26, 130)),
				Position = UDim2.new(1, -154, 1, 4),
				BackgroundColor3 = Fusion.Theme.Glass,
				BackgroundTransparency = 0.05,
				Visible = false,
				ZIndex = 20,
				Parent = Holder,
			})
			Corner(8).Parent = ListFrame
			Stroke(Fusion.Theme.Stroke, 1, 0.4).Parent = ListFrame
			local ListScroll = Create("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 2,
				ZIndex = 20,
				Parent = ListFrame,
			})
			Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }).Parent = ListScroll

			local open = false
			SelectedBtn.MouseButton1Click:Connect(function()
				open = not open
				ListFrame.Visible = open
			end)

			local function select(option)
				SelectedBtn.Text = tostring(option) .. "  ▾"
				open = false
				ListFrame.Visible = false
				Callback(option)
				if Flag then
					Fusion.Flags[Flag] = option
				end
			end

			for _, option in ipairs(Options) do
				local OptBtn = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Text = tostring(option),
					TextColor3 = Fusion.Theme.Text,
					TextSize = 12,
					AutoButtonColor = false,
					ZIndex = 20,
					Parent = ListScroll,
				})
				OptBtn.MouseButton1Click:Connect(function()
					select(option)
				end)
			end

			if Flag then
				Fusion.Flags[Flag] = Default
			end

			return { Select = select }
		end

		function Elements:CreateInput(config)
			config = config or {}
			local Flag = config.Flag or config.Text
			local Callback = config.Callback or function() end

			local Holder = GlassPanel({
				Size = UDim2.new(1, 0, 0, 38),
				Parent = Page,
			})
			Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(0.4, 0, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Input",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Holder,
			})

			local Box = Create("TextBox", {
				Size = UDim2.new(0.5, -14, 0, 26),
				Position = UDim2.new(0.5, 0, 0.5, -13),
				BackgroundColor3 = Fusion.Theme.GlassLight,
				Font = Enum.Font.Gotham,
				Text = config.Default or "",
				PlaceholderText = config.Placeholder or "",
				TextColor3 = Fusion.Theme.Text,
				PlaceholderColor3 = Fusion.Theme.SubText,
				TextSize = 13,
				ClearTextOnFocus = false,
				Parent = Holder,
			})
			Pad(8, 0, 8, 0).Parent = Box
			Corner(7).Parent = Box

			Box.FocusLost:Connect(function(enterPressed)
				Callback(Box.Text, enterPressed)
				if Flag then
					Fusion.Flags[Flag] = Box.Text
				end
			end)

			if Flag then
				Fusion.Flags[Flag] = config.Default or ""
			end

			return Box
		end

		function Elements:CreateKeybind(config)
			config = config or {}
			local Flag = config.Flag or config.Text
			local Default = config.Default or Enum.KeyCode.Unknown
			local Callback = config.Callback or function() end

			local Holder = GlassPanel({
				Size = UDim2.new(1, 0, 0, 38),
				Parent = Page,
			})
			Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Keybind",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Holder,
			})

			local KeyBtn = Create("TextButton", {
				Size = UDim2.new(0, 100, 0, 26),
				Position = UDim2.new(1, -114, 0.5, -13),
				BackgroundColor3 = Fusion.Theme.GlassLight,
				Font = Enum.Font.GothamBold,
				Text = Default.Name,
				TextColor3 = Fusion.Theme.Accent,
				TextSize = 12,
				AutoButtonColor = false,
				Parent = Holder,
			})
			Corner(7).Parent = KeyBtn

			local listening = false
			local currentKey = Default

			KeyBtn.MouseButton1Click:Connect(function()
				listening = true
				KeyBtn.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, gpe)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = input.KeyCode
					KeyBtn.Text = currentKey.Name
					listening = false
					if Flag then
						Fusion.Flags[Flag] = currentKey
					end
				elseif not gpe and input.KeyCode == currentKey then
					Callback()
				end
			end)

			if Flag then
				Fusion.Flags[Flag] = Default
			end

			return { GetKey = function() return currentKey end }
		end

		function Elements:CreateColorPicker(config)
			config = config or {}
			local Flag = config.Flag or config.Text
			local Default = config.Default or Fusion.Theme.Accent
			local Callback = config.Callback or function() end

			local Holder = GlassPanel({
				Size = UDim2.new(1, 0, 0, 38),
				ClipsDescendants = false,
				ZIndex = 5,
				Parent = Page,
			})
			Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(0.6, 0, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = config.Text or "Color",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Holder,
			})

			local Swatch = Create("TextButton", {
				Size = UDim2.fromOffset(26, 26),
				Position = UDim2.new(1, -40, 0.5, -13),
				BackgroundColor3 = Default,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 6,
				Parent = Holder,
			})
			Corner(7).Parent = Swatch
			Stroke(Fusion.Theme.Stroke, 1, 0.4).Parent = Swatch

			local Popup = GlassPanel({
				Size = UDim2.fromOffset(220, 300),
				Position = UDim2.new(1, -220, 1, 8),
				Visible = false,
				ZIndex = 30,
				Parent = Holder,
			})
			Pad(14, 14, 14, 14).Parent = Popup

			Create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.GothamBold,
				Text = "Color",
				TextColor3 = Fusion.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 30,
				Parent = Popup,
			})

			local Wheel = Create("ImageLabel", {
				Size = UDim2.fromOffset(160, 160),
				Position = UDim2.new(0.5, -80, 0, 26),
				BackgroundTransparency = 1,
				Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
				ZIndex = 30,
				Parent = Popup,
			})
			Create("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				}),
				Rotation = 0,
			}).Parent = Wheel
			Corner(80).Parent = Wheel

			local SatOverlay = Create("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 31,
				Parent = Wheel,
			})
			Corner(80).Parent = SatOverlay
			Create("UIGradient", {
				Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}).Parent = SatOverlay

			local WheelCursor = Create("Frame", {
				Size = UDim2.fromOffset(10, 10),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 32,
				Parent = Wheel,
			})
			Corner(5).Parent = WheelCursor
			Stroke(Color3.fromRGB(0, 0, 0), 2, 0).Parent = WheelCursor

			local HexBox = Create("TextBox", {
				Size = UDim2.new(1, 0, 0, 26),
				Position = UDim2.new(0, 0, 0, 196),
				BackgroundColor3 = Fusion.Theme.GlassLight,
				Font = Enum.Font.Gotham,
				Text = "#" .. Default:ToHex(),
				TextColor3 = Fusion.Theme.Text,
				TextSize = 13,
				ClearTextOnFocus = false,
				ZIndex = 30,
				Parent = Popup,
			})
			Corner(7).Parent = HexBox
			Pad(8, 0, 8, 0).Parent = HexBox

			local RGBLabel = Create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 16),
				Position = UDim2.new(0, 0, 0, 226),
				Font = Enum.Font.Gotham,
				Text = string.format("R %d  G %d  B %d", Default.R * 255, Default.G * 255, Default.B * 255),
				TextColor3 = Fusion.Theme.SubText,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 30,
				Parent = Popup,
			})

			local SwatchRow = Create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 0, 248),
				ZIndex = 30,
				Parent = Popup,
			})
			Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
			}).Parent = SwatchRow

			local presets = {
				Color3.fromRGB(235, 90, 90),
				Color3.fromRGB(240, 160, 70),
				Color3.fromRGB(230, 220, 90),
				Color3.fromRGB(90, 210, 120),
				Color3.fromRGB(70, 190, 220),
				Color3.fromRGB(62, 142, 247),
				Color3.fromRGB(150, 100, 235),
				Color3.fromRGB(230, 90, 200),
			}

			local currentColor = Default

			local function applyColor(color, fromHex)
				currentColor = color
				Swatch.BackgroundColor3 = color
				if not fromHex then
					HexBox.Text = "#" .. color:ToHex()
				end
				RGBLabel.Text = string.format("R %d  G %d  B %d", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
				Callback(color)
				if Flag then
					Fusion.Flags[Flag] = color
				end
			end

			for _, preset in ipairs(presets) do
				local PresetBtn = Create("TextButton", {
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = preset,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 30,
					Parent = SwatchRow,
				})
				Corner(9).Parent = PresetBtn
				PresetBtn.MouseButton1Click:Connect(function()
					applyColor(preset)
				end)
			end

			local wheelDragging = false
			local function updateWheel(input)
				local center = Wheel.AbsolutePosition + Wheel.AbsoluteSize / 2
				local pos = Vector2.new(input.Position.X, input.Position.Y)
				local diff = pos - center
				local radius = Wheel.AbsoluteSize.X / 2
				local dist = math.clamp(diff.Magnitude / radius, 0, 1)
				local angle = math.atan2(diff.Y, diff.X)
				local hue = (angle / (math.pi * 2)) % 1
				local sat = dist
				local color = Color3.fromHSV(hue, sat, 1)
				local clampedDiff = diff.Magnitude > radius and diff.Unit * radius or diff
				WheelCursor.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(clampedDiff.X, clampedDiff.Y)
				applyColor(color)
			end

			Wheel.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					wheelDragging = true
					updateWheel(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if wheelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateWheel(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					wheelDragging = false
				end
			end)

			HexBox.FocusLost:Connect(function()
				local hex = HexBox.Text:gsub("#", "")
				local ok, color = pcall(function()
					return Color3.fromHex(hex)
				end)
				if ok then
					applyColor(color, true)
				else
					HexBox.Text = "#" .. currentColor:ToHex()
				end
			end)

			local popupOpen = false
			Swatch.MouseButton1Click:Connect(function()
				popupOpen = not popupOpen
				Popup.Visible = popupOpen
			end)

			if Flag then
				Fusion.Flags[Flag] = Default
			end

			return { Set = applyColor, Get = function() return currentColor end }
		end

		return Elements
	end

	return WindowObj
end

function Fusion:Notify(config)
	config = config or {}
	local ScreenGui = CoreGui:FindFirstChild("FusionUI")
	if not ScreenGui then
		ScreenGui = GetGui()
	end

	local Notif = GlassPanel({
		Size = UDim2.fromOffset(280, 70),
		Position = UDim2.new(1, 20, 1, -100),
		AnchorPoint = Vector2.new(0, 0),
		Parent = ScreenGui,
	})
	Notif.Position = UDim2.new(1, 20, 1, -100)

	Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 10),
		Size = UDim2.new(1, -28, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = config.Title or "Notification",
		TextColor3 = Fusion.Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Notif,
	})
	Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 30),
		Size = UDim2.new(1, -28, 0, 32),
		Font = Enum.Font.Gotham,
		Text = config.Content or "",
		TextColor3 = Fusion.Theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = Notif,
	})

	Tween(Notif, { Position = UDim2.new(1, -300, 1, -100) }, 0.4)
	task.delay(config.Duration or 4, function()
		Tween(Notif, { Position = UDim2.new(1, 20, 1, -100) }, 0.4)
		task.wait(0.4)
		Notif:Destroy()
	end)
end

return Fusion
