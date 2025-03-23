
Library = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fetching"
ScreenGui.Parent = not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui

function Library:CreateWindow(info)
	local Transparency = info.Transparency
	local MainColor = info.MainColor
	local DropColor = info.DropColor
	local U, Tw =
		game:GetService("UserInputService"),
	game:GetService("TweenService")
	local HAA, R = false, false
	local function gl(i)
		if type(i) == 'string' and not i:find('rbxassetid://') then
			return "rbxassetid://".. i
		elseif type(i) == 'number' then
			return "rbxassetid://".. i
		else
			return i
		end
	end
	local function tw(info)
		return Tw:Create(info.v,TweenInfo.new(info.t, info.s, Enum.EasingDirection[info.d]),info.g)
	end
	local function changecanvas(ScrollingFrame, UIListLayout, Plus)
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tw({v = ScrollingFrame, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + Plus or 5)}}):Play()
		end)
	end
	local function changecanvas2(ScrollingFrame, UIListLayout, Plus)
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local contentWidth = UIListLayout.AbsoluteContentSize.X
			local contentHeight = UIListLayout.AbsoluteContentSize.Y

			local canvasWidth = contentWidth + (Plus or 5)
			local canvasHeight = contentHeight

			tw({
				v = ScrollingFrame,
				t = 0.15,
				s = Enum.EasingStyle.Linear,
				d = "Out",
				g = {
					CanvasSize = UDim2.new(0, canvasWidth, 0, canvasHeight)
				}
			}):Play()
		end)
	end

	local UserInputService = game:GetService("UserInputService")

	local function init(getFrame)
		local MTREL = "Glass"
		local binds = {}
		local root = Instance.new('Folder', workspace.CurrentCamera)
		root.Name = 'BlurSnox'

		local gTokenMH = 99999999
		local gToken = math.random(1, gTokenMH)

		local DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
		DepthOfField.FarIntensity = 0
		DepthOfField.FocusDistance = 51.6
		DepthOfField.InFocusRadius = 50
		DepthOfField.NearIntensity = 1
		DepthOfField.Name = "DPT_"..gToken

		local frame = Instance.new('Frame')
		frame.Parent = getFrame
		frame.Size = UDim2.new(0.95, 0, 0.95, 0)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundTransparency = 1

		local GenUid; do
			local id = 0
			function GenUid()
				id = id + 1
				return 'neon::'..tostring(id)
			end
		end

		do
			local function IsNotNaN(x)
				return x == x
			end
			local continue = IsNotNaN(workspace.CurrentCamera:ScreenPointToRay(0,0).Origin.x)
			while not continue do
				game:GetService('RunService').RenderStepped:wait()
				continue = IsNotNaN(workspace.CurrentCamera:ScreenPointToRay(0,0).Origin.x)
			end
		end

		local DrawQuad; do
			local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
			local sz = 0.2

			local function DrawTriangle(v1, v2, v3, p0, p1)
				local s1 = (v1 - v2).magnitude
				local s2 = (v2 - v3).magnitude
				local s3 = (v3 - v1).magnitude
				local smax = max(s1, s2, s3)
				local A, B, C
				if s1 == smax then
					A, B, C = v1, v2, v3
				elseif s2 == smax then
					A, B, C = v2, v3, v1
				elseif s3 == smax then
					A, B, C = v3, v1, v2
				end

				local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
				local perp = sqrt((C-A).magnitude^2 - para*para)
				local dif_para = (A - B).magnitude - para

				local st = CFrame.new(B, A)
				local za = CFrame.Angles(pi/2,0,0)

				local cf0 = st

				local Top_Look = (cf0 * za).lookVector
				local Mid_Point = A + CFrame.new(A, B).lookVector * para
				local Needed_Look = CFrame.new(Mid_Point, C).lookVector
				local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

				local ac = CFrame.Angles(0, 0, acos(dot))

				cf0 = cf0 * ac
				if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
					cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
				end
				cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

				local cf1 = st * ac * CFrame.Angles(0, pi, 0)
				if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
					cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
				end
				cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

				if not p0 then
					p0 = Instance.new('Part')
					p0.FormFactor = 'Custom'
					p0.TopSurface = 0
					p0.BottomSurface = 0
					p0.Anchored = true
					p0.CanCollide = false
					p0.CastShadow = false
					p0.Material = MTREL
					p0.Size = Vector3.new(sz, sz, sz)
					local mesh = Instance.new('SpecialMesh', p0)
					mesh.MeshType = 2
					mesh.Name = 'WedgeMesh'
				end
				p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
				p0.CFrame = cf0

				if not p1 then
					p1 = p0:clone()
				end
				p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
				p1.CFrame = cf1

				return p0, p1
			end

			function DrawQuad(v1, v2, v3, v4, parts)
				parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
				parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
			end
		end

		if binds[frame] then
			return binds[frame].parts
		end

		local uid = GenUid()
		local parts = {}
		local f = Instance.new('Folder', root)
		f.Name = frame.Name

		local parents = {}
		do
			local function add(child)
				if child:IsA'GuiObject' then
					parents[#parents + 1] = child
					add(child.Parent)
				end
			end
			add(frame)
		end

		local function UpdateOrientation(fetchProps)
			local properties = {
				Transparency = 0.98;
				BrickColor = BrickColor.new('Institutional white');
			}
			local zIndex = 1 - 0.05*frame.ZIndex

			local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
			do
				local rot = 0;
				for _, v in ipairs(parents) do
					rot = rot + v.Rotation
				end
				if rot ~= 0 and rot%180 ~= 0 then
					local mid = tl:lerp(br, 0.5)
					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
					local vec = tl
					tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
					tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
					bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
					br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
				end
			end
			DrawQuad(
				workspace.CurrentCamera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
				workspace.CurrentCamera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
				workspace.CurrentCamera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
				workspace.CurrentCamera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
				parts
			)
			if fetchProps then
				for _, pt in pairs(parts) do
					pt.Parent = f
				end
				for propName, propValue in pairs(properties) do
					for _, pt in pairs(parts) do
						pt[propName] = propValue
					end
				end
			end
		end

		UpdateOrientation(true)
		game:GetService('RunService'):BindToRenderStep(uid, 2000, UpdateOrientation)
		return {
			DepthOfField,
			frame
		}
	end

	local function gs(side, pl, pr)
		if not side then
			return pl
		end

		local sideLower = string.lower(tostring(side))
		if sideLower == "r" or sideLower == "right" or side == 2 then
			return pr
		elseif sideLower == "l" or sideLower == "left" or side == 1 then
			return pl
		else
			return pl
		end
	end
	local function jc(c, p)
		local Mouse = game.Players.LocalPlayer:GetMouse()

		local relativeX = Mouse.X - c.AbsolutePosition.X
		local relativeY = Mouse.Y - c.AbsolutePosition.Y

		if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
			return
		end

		local ClickButtonCircle = Instance.new("Frame")
		ClickButtonCircle.Parent = p
		ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ClickButtonCircle.BackgroundTransparency = 0.7
		ClickButtonCircle.BorderSizePixel = 0
		ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
		ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
		ClickButtonCircle.ZIndex = 10

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = ClickButtonCircle

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local goal = {
			Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
			BackgroundTransparency = 1
		}

		local expandTween = game:GetService("TweenService"):Create(ClickButtonCircle, tweenInfo, goal)

		expandTween.Completed:Connect(function()
			ClickButtonCircle:Destroy()
		end)

		expandTween:Play()
	end
	local function jcf(p, p2)
		local ClickButtonCircle = Instance.new("Frame")
		ClickButtonCircle.Parent = p
		ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ClickButtonCircle.BackgroundTransparency = 0.7
		ClickButtonCircle.BorderSizePixel = 0
		ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		ClickButtonCircle.Position = UDim2.new(0, p2.AbsolutePosition.X - p.AbsolutePosition.X + p2.AbsoluteSize.X / 2, 
			0, p2.AbsolutePosition.Y - p.AbsolutePosition.Y + p2.AbsoluteSize.Y / 2)
		ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
		ClickButtonCircle.ZIndex = 10

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = ClickButtonCircle

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local goal = {
			Size = UDim2.new(0, p2.AbsoluteSize.X * 5, 0, p2.AbsoluteSize.X * 5),
			BackgroundTransparency = 1
		}

		local expandTween = game:GetService("TweenService"):Create(ClickButtonCircle, tweenInfo, goal)

		expandTween.Completed:Connect(function()
			ClickButtonCircle:Destroy()
		end)

		expandTween:Play()
	end
	local function lak(o)
		local a, b, c, d
		local function u(i)
			local dt = i.Position - c
			tw({v = o, t = 0.15, s = Enum.EasingStyle.Linear, d = "InOut", g = {Position = UDim2.new(d.X.Scale, d.X.Offset + dt.X, d.Y.Scale, d.Y.Offset + dt.Y)}}):Play()
		end
		o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then a = true c = i.Position d = o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then a = false end end) end end)
		o.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then b = i end end)
		U.InputChanged:Connect(function(i) if i == b and a then u(i) end end)
	end
	local function lak2(t, o)
		local a, b, c, d
		local function u(i)
			local dt = i.Position - c
			tw({v = o, t = 0.15, s = Enum.EasingStyle.Linear, d = "InOut", g = {Position = UDim2.new(d.X.Scale, d.X.Offset + dt.X, d.Y.Scale, d.Y.Offset + dt.Y)}}):Play()
		end
		t.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then a = true c = i.Position d = o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then a = false end end) end end)
		t.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then b = i end end)
		U.InputChanged:Connect(function(i) if i == b and a then u(i) end end)
	end
	local function click(p)
		local Click = Instance.new("TextButton")

		Click.Name = "Click"
		Click.Parent = p
		Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Click.BackgroundTransparency = 1.000
		Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Click.BorderSizePixel = 0
		Click.Size = UDim2.new(1, 0, 1, 0)
		Click.Font = Enum.Font.SourceSans
		Click.Text = ""
		Click.TextColor3 = Color3.fromRGB(0, 0, 0)
		Click.TextSize = 14.000

		return Click
	end
	local function background(p, t, d)
		local ToggleDesc = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local Frame_4 = Instance.new("Frame")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local UIPadding_2 = Instance.new("UIPadding")
		local TextLabel_1 = Instance.new("TextLabel")
		local Title_1 = Instance.new("TextLabel")

		ToggleDesc.Name = "ToggleDesc"
		ToggleDesc.Parent = p
		ToggleDesc.BackgroundTransparency = Transparency
		ToggleDesc.BackgroundColor3 = Color3.fromRGB(36, 39, 46)
		ToggleDesc.BorderColor3 = Color3.fromRGB(0,0,0)
		ToggleDesc.BorderSizePixel = 0
		ToggleDesc.Size = UDim2.new(1, 0,0, 35)
		ToggleDesc.ClipsDescendants = true

		UICorner_1.Parent = ToggleDesc
		UICorner_1.CornerRadius = UDim.new(0,4)

		Frame_4.Parent = ToggleDesc
		Frame_4.AnchorPoint = Vector2.new(0, 0.5)
		Frame_4.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_4.BackgroundTransparency = 1
		Frame_4.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_4.BorderSizePixel = 0
		Frame_4.Position = UDim2.new(0, 0,0.5, 0)
		Frame_4.Size = UDim2.new(1, 0,1, 0)

		UIListLayout_2.Parent = Frame_4
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

		UIPadding_2.Parent = Frame_4
		UIPadding_2.PaddingLeft = UDim.new(0,13)
		UIPadding_2.PaddingRight = UDim.new(0,70)

		TextLabel_1.Parent = Frame_4
		TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_1.BackgroundTransparency = 1
		TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_1.BorderSizePixel = 0
		TextLabel_1.LayoutOrder = 1
		TextLabel_1.Size = UDim2.new(1, 0,0, 16)
		TextLabel_1.Font = Enum.Font.Gotham
		TextLabel_1.RichText = true
		TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
		TextLabel_1.TextSize = 9
		TextLabel_1.TextTransparency = 0.5
		TextLabel_1.TextWrapped = true
		TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel_1.Visible = false
		TextLabel_1.AutomaticSize = Enum.AutomaticSize.Y
		TextLabel_1.Name = 'Desc'

		Title_1.Name = "Title"
		Title_1.Parent = Frame_4
		Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_1.BackgroundTransparency = 1
		Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_1.BorderSizePixel = 0
		Title_1.Size = UDim2.new(1, 0,0, 16)
		Title_1.Font = Enum.Font.GothamBold
		Title_1.RichText = true
		Title_1.Text = t
		Title_1.TextColor3 = Color3.fromRGB(255,255,255)
		Title_1.TextSize = 13
		Title_1.TextWrapped = true
		Title_1.TextXAlignment = Enum.TextXAlignment.Left
		Title_1.AutomaticSize = Enum.AutomaticSize.Y

		if d and d ~= "" then
			TextLabel_1.Visible = true
			TextLabel_1.Text = d
			local function updateSize()
				task.defer(function()
					local newSize = UIListLayout_2.AbsoluteContentSize.Y + 20
					if ToggleDesc.Size.Y.Offset ~= newSize then
						ToggleDesc.Size = UDim2.new(1, 0, 0, newSize)
					end
				end)
			end

			UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

			updateSize()
		end

		return ToggleDesc
	end

	local Logo = info.Logo
	local Keycode = info.Keycode
	local Size = info.Size
	local Background_1 = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local UIStroke_1 = Instance.new("UIStroke")
	local Topbar_1 = Instance.new("Frame")
	local Line_1 = Instance.new("Frame")
	local Func_1 = Instance.new("Frame")
	local UIPadding_1 = Instance.new("UIPadding")
	local ImageLabel_1 = Instance.new("ImageLabel")
	local TabFrame_1 = Instance.new("Frame")
	local Shadow = Instance.new("ImageLabel")
	local resize = Instance.new("TextButton")
	local effect = Instance.new("ImageLabel")
	local effectcircle = Instance.new("ImageLabel")
	local effectcircle2 = Instance.new("ImageLabel")
	local effectcircle3 = Instance.new("ImageLabel")
	local effectcircle4 = Instance.new("ImageLabel")
	local effectcircle5 = Instance.new("ImageLabel")

	local UIcornEffect = Instance.new("UICorner")
	local frameef = Instance.new("Frame")

	Background_1.Name = "Background"
	Background_1.Parent = ScreenGui
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundTransparency = Transparency
	Background_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = Size
	local BlurFrame2 = init(Background_1)
	UICorner_1.Parent = Background_1

	UIStroke_1.Parent = Background_1
	UIStroke_1.Color = Color3.fromRGB(47,48,51)
	UIStroke_1.Transparency = 0.3
	UIStroke_1.Thickness = 3

	resize.Parent = Background_1
	resize.AnchorPoint = Vector2.new(1, 1)
	resize.Size = UDim2.new(0, 25, 0, 25)
	resize.Position = UDim2.new(1, 0, 1, 0)
	resize.BackgroundTransparency = 1
	resize.BorderSizePixel = 0
	resize.Text = ''

	frameef.Parent = Background_1
	frameef.BackgroundTransparency = 1
	frameef.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
	frameef.BorderColor3 = Color3.fromRGB(0,0,0)
	frameef.BorderSizePixel = 0
	frameef.Size = UDim2.new(1,0,1,0)
	frameef.ClipsDescendants = true
	effect.Parent = Background_1
	effect.Size = UDim2.new(1,0,1,0)
	effect.Image = "rbxassetid://133167155418861"
	effect.ImageTransparency = 0.85
	effect.BackgroundTransparency = 1
	effect.Position = UDim2.new(0,0,0,0)
	UIcornEffect.Parent = effect

	effectcircle.Parent = frameef
	effectcircle.Size = UDim2.new(0,400,0,400)
	effectcircle.Image = "rbxassetid://132180927784800"
	effectcircle.ImageTransparency = 0.8
	effectcircle.BackgroundTransparency = 1
	effectcircle.Position = UDim2.new(0.5, 0, 0.5, 0)

	effectcircle2.Parent = frameef
	effectcircle2.Size = UDim2.new(0,400,0,400)
	effectcircle2.Image = "rbxassetid://135880574040377"
	effectcircle2.ImageTransparency = 0.8
	effectcircle2.BackgroundTransparency = 1

	effectcircle3.Parent = frameef
	effectcircle3.Size = UDim2.new(0,600,0,600)
	effectcircle3.Image = "rbxassetid://78169354814171"
	effectcircle3.ImageTransparency = 0.8
	effectcircle3.BackgroundTransparency = 1
	effectcircle3.Position = UDim2.new(0.5, 0, 0.1, 0)

	effectcircle4.Parent = frameef
	effectcircle4.Size = UDim2.new(0,600,0,600)
	effectcircle4.Image = "rbxassetid://119323583847129"
	effectcircle4.ImageTransparency = 0.8
	effectcircle4.BackgroundTransparency = 1
	effectcircle4.Position = UDim2.new(0.9,0,0.5,0)

	effectcircle5.Parent = frameef
	effectcircle5.Size = UDim2.new(0,600,0,600)
	effectcircle5.Image = "rbxassetid://133790688650660"
	effectcircle5.ImageTransparency = 0.8
	effectcircle5.BackgroundTransparency = 1
	effectcircle5.Position = UDim2.new(0.9,0,0.5,0)


	local function checkBoundaries(object)
		local backgroundSize = frameef.AbsoluteSize
		local objectSize = object.AbsoluteSize
		local position = object.Position
		if position.X.Scale < 0 then
			position = UDim2.new(0, 0, position.Y.Scale, position.Y.Offset)
		elseif position.X.Scale > 1 then
			position = UDim2.new(1, -objectSize.X, position.Y.Scale, position.Y.Offset)
		end
		if position.Y.Scale < 0 then
			position = UDim2.new(position.X.Scale, position.X.Offset, 0, 0)
		elseif position.Y.Scale > 1 then
			position = UDim2.new(position.X.Scale, position.X.Offset, 1, -objectSize.Y)
		end

		return position
	end
	local function randomTween(object)
		while true do
			local randomX = math.random() * 2 - 1
			local randomY = math.random() * 2 - 1
			local randomPosition = UDim2.new(
				math.clamp(randomX, 0, 1), 0,
				math.clamp(randomY, 0, 1), 0
			)
			local tweenInfo = TweenInfo.new(
				math.random(5, 10),
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut,
				0,
				false
			)
			local tween = game:GetService("TweenService"):Create(object, tweenInfo, {Position = randomPosition})
			tween:Play()
			tween.Completed:Wait()
			object.Position = checkBoundaries(object)
		end
	end
	coroutine.wrap(function()
		randomTween(effectcircle)
	end)()
	coroutine.wrap(function()
		randomTween(effectcircle3)
	end)()
	coroutine.wrap(function()
		randomTween(effectcircle2)
	end)()
	coroutine.wrap(function()
		randomTween(effectcircle4)
	end)()
	coroutine.wrap(function()
		randomTween(effectcircle5)
	end)()

	Shadow.Parent = Background_1
	Shadow.Name = "DropShadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundColor3 = Color3.fromRGB(28,28,30)
	Shadow.BackgroundTransparency = 1
	Shadow.BorderColor3 = Color3.fromRGB(0,0,0)
	Shadow.BorderSizePixel = 0
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 120, 1, 116)
	Shadow.ZIndex = 0
	Shadow.Image = "rbxassetid://8992230677"
	Shadow.ImageColor3 = Color3.new(0, 0, 0)
	Shadow.ImageTransparency = 0.4
	Shadow.ResampleMode = Enum.ResamplerMode.Default
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceScale = 1
	Shadow.TileSize = UDim2.new(1, 0, 1, 0)
	Shadow.SliceCenter = Rect.new(99, 99, 99, 99)


	Topbar_1.Name = "Topbar"
	Topbar_1.Parent = Background_1
	Topbar_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Topbar_1.BackgroundTransparency = 1
	Topbar_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Topbar_1.BorderSizePixel = 0
	Topbar_1.Size = UDim2.new(1, 0,0, 50)
	lak2(Topbar_1,Background_1)

	Line_1.Name = "Line"
	Line_1.Parent = Topbar_1
	Line_1.AnchorPoint = Vector2.new(0, 1)
	Line_1.BackgroundColor3 = Color3.fromRGB(54, 58, 69)
	Line_1.BackgroundTransparency = Transparency
	Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Line_1.BorderSizePixel = 0
	Line_1.Position = UDim2.new(0, 0,1, 0)
	Line_1.Size = UDim2.new(1, 0,0, 2)

	Func_1.Name = "Func"
	Func_1.Parent = Topbar_1
	Func_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Func_1.BackgroundTransparency = 1
	Func_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Func_1.BorderSizePixel = 0
	Func_1.Size = UDim2.new(1, 0,1, 0)

	UIPadding_1.Parent = Func_1
	UIPadding_1.PaddingLeft = UDim.new(0,5)
	UIPadding_1.PaddingRight = UDim.new(0,10)

	ImageLabel_1.Parent = Func_1
	ImageLabel_1.AnchorPoint = Vector2.new(0, 0.5)
	ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_1.BackgroundTransparency = 1
	ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_1.BorderSizePixel = 0
	ImageLabel_1.Position = UDim2.new(0, 0,0.5, 0)
	ImageLabel_1.Size = UDim2.new(0, 45,0, 45)
	ImageLabel_1.Image = gl(Logo)

	TabFrame_1.Name = "TabFrame"
	TabFrame_1.Parent = Func_1
	TabFrame_1.AnchorPoint = Vector2.new(0, 0.5)
	TabFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabFrame_1.BackgroundTransparency = 1
	TabFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TabFrame_1.BorderSizePixel = 0
	TabFrame_1.Position = UDim2.new(0, 0,0.5, 0)
	TabFrame_1.Size = UDim2.new(1, 0,0, 50)

	local Profile = Instance.new("ImageLabel")
	local UICornerProfile_1 = Instance.new("UICorner")
	local UIStrokeProfile_1 = Instance.new("UIStroke")
	local ProfileImage_1 = Instance.new("ImageLabel")

	Profile.Name = "Profile"
	Profile.Parent = Func_1
	Profile.AnchorPoint = Vector2.new(1, 0.5)
	Profile.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Profile.BackgroundTransparency = 1
	Profile.BorderColor3 = Color3.fromRGB(0,0,0)
	Profile.BorderSizePixel = 0
	Profile.Position = UDim2.new(1, 0,0.5, 0)
	Profile.Size = UDim2.new(0, 30,0, 30)
	Profile.Image = game:GetService("Players"):GetUserThumbnailAsync(game:GetService("Players").LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

	UICornerProfile_1.Name = "UICornerProfile"
	UICornerProfile_1.Parent = Profile
	UICornerProfile_1.CornerRadius = UDim.new(1,0)

	UIStrokeProfile_1.Name = "UIStrokeProfile"
	UIStrokeProfile_1.Parent = Profile
	UIStrokeProfile_1.Color = Color3.fromRGB(54, 58, 69)
	UIStrokeProfile_1.Thickness = 1.5


	local UIPadding_2 = Instance.new("UIPadding")
	local ScrollingFrame_1 = Instance.new("ScrollingFrame")
	local FrameTab_1 = Instance.new("Frame")

	UIPadding_2.Parent = TabFrame_1
	UIPadding_2.PaddingLeft = UDim.new(0,50)

	ScrollingFrame_1.Name = "ScrollingFrame"
	ScrollingFrame_1.Parent = TabFrame_1
	ScrollingFrame_1.Active = true
	ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ScrollingFrame_1.BackgroundTransparency = 1
	ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_1.BorderSizePixel = 0
	ScrollingFrame_1.Size = UDim2.new(1, 0,1, 0)
	ScrollingFrame_1.ClipsDescendants = true
	ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
	ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
	ScrollingFrame_1.CanvasSize = UDim2.new(2, 0,0, 0)
	ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	ScrollingFrame_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_1.ScrollBarImageTransparency = 0
	ScrollingFrame_1.ScrollBarThickness = 0
	ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
	ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

	FrameTab_1.Name = "FrameTab"
	FrameTab_1.Parent = ScrollingFrame_1
	FrameTab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	FrameTab_1.BackgroundTransparency = 1
	FrameTab_1.BorderColor3 = Color3.fromRGB(0,0,0)
	FrameTab_1.BorderSizePixel = 0
	FrameTab_1.Size = UDim2.new(1, 0,1, 0)

	local UIPadding_5 = Instance.new("UIPadding")
	local UIListLayout_3 = Instance.new("UIListLayout")
	local Select_1 = Instance.new("Frame")
	local UIGradient_5 = Instance.new("UIGradient")

	UIPadding_5.Parent = FrameTab_1
	UIPadding_5.PaddingLeft = UDim.new(0,5)

	UIListLayout_3.Parent = FrameTab_1
	UIListLayout_3.Padding = UDim.new(0,8)
	UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

	Select_1.Name = "Select"
	Select_1.Parent = ScrollingFrame_1
	Select_1.AnchorPoint = Vector2.new(0, 1)
	Select_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Select_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Select_1.BorderSizePixel = 0
	Select_1.Position = UDim2.new(0, 0,1, 0)
	Select_1.Size = UDim2.new(0, 33,0, 2)

	UIGradient_5.Parent = Select_1
	UIGradient_5.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

	local Notification = Instance.new("Frame")
	local UIListLayout_1 = Instance.new("UIListLayout")

	Notification.Name = "Notification"
	Notification.Parent = ScreenGui
	Notification.AnchorPoint = Vector2.new(1, 1)
	Notification.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Notification.BackgroundTransparency = 1
	Notification.BorderColor3 = Color3.fromRGB(0,0,0)
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(0.99000001, 0,0.99000001, 0)
	Notification.Size = UDim2.new(0, 100,0, 100)

	UIListLayout_1.Parent = Notification
	UIListLayout_1.Padding = UDim.new(0,8)
	UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local PageFolder = Instance.new("Frame")
	local UIPageLayout = Instance.new("UIPageLayout")

	PageFolder.Name = "PageFolder"
	PageFolder.Parent = Background_1
	PageFolder.BackgroundColor3 = Color3.fromRGB(255,255,255)
	PageFolder.BackgroundTransparency = 1
	PageFolder.BorderColor3 = Color3.fromRGB(0,0,0)
	PageFolder.BorderSizePixel = 0
	PageFolder.Size = UDim2.new(1, 0,1, 0)
	PageFolder.ClipsDescendants = true

	UIPageLayout.Parent = PageFolder
	UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
	UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIPageLayout.EasingStyle = Enum.EasingStyle.Exponential
	UIPageLayout.GamepadInputEnabled = false
	UIPageLayout.ScrollWheelInputEnabled = false
	UIPageLayout.TouchInputEnabled = false

	Library.Tabs = {
		Value = false
	}

	function Library.Tabs:CreateHeader(info)
		local Title = info.Title
		local Icon = info.Icon

		local Tab = Instance.new("Frame")
		local Tab_1 = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIStroke_2 = Instance.new("UIStroke")
		local UIGradient_1 = Instance.new("UIGradient")
		local UIGradient_2 = Instance.new("UIGradient")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local ImageLabel_2 = Instance.new("ImageLabel")
		local UIPadding_3 = Instance.new("UIPadding")
		local Title_1 = Instance.new("TextLabel")
		local UICorner_3 = Instance.new("UICorner")

		Tab.Name = "Tab"
		Tab.Parent = FrameTab_1
		Tab.BackgroundColor3 = Color3.fromRGB(36, 39, 46)
		Tab.BackgroundTransparency = Transparency
		Tab.BorderColor3 = Color3.fromRGB(0,0,0)
		Tab.BorderSizePixel = 0
		Tab.Size = UDim2.new(0, 30,0, 30)
		Tab.AutomaticSize = Enum.AutomaticSize.X

		UICorner_3.Parent = Tab
		UICorner_3.CornerRadius = UDim.new(1 ,0)

		Tab_1.Name = "Tab"
		Tab_1.Parent = Tab
		Tab_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Tab_1.BackgroundTransparency = 1
		Tab_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Tab_1.BorderSizePixel = 0
		Tab_1.Size = UDim2.new(1, 0,1, 0)

		UICorner_2.Parent = Tab_1
		UICorner_2.CornerRadius = UDim.new(1 ,0)

		UIStroke_2.Parent = Tab_1
		UIStroke_2.Color = Color3.fromRGB(255,255,255)
		UIStroke_2.Thickness = 2
		UIStroke_2.Transparency = Transparency

		UIGradient_1.Parent = UIStroke_2
		UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
		UIGradient_1.Rotation = 90

		UIGradient_2.Parent = Tab_1
		UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

		ImageLabel_2.Parent = Tab_1
		ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_2.BackgroundTransparency = 1
		ImageLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_2.BorderSizePixel = 0
		ImageLabel_2.Size = UDim2.new(0, 15,0, 15)
		ImageLabel_2.Image = gl(Icon)
		ImageLabel_2.ScaleType = Enum.ScaleType.Crop
		ImageLabel_2.Position = UDim2.new(0.5, 0,0.5, 0)

		local Page_1 = Instance.new("Frame")
		local UIPadding_1Tab = Instance.new("UIPadding")
		local TabFrame_1Tab = Instance.new("Frame")
		local ScrollingFrame_1Tab = Instance.new("ScrollingFrame")
		local Frame_1 = Instance.new("Frame")
		local UIPadding_2Tab = Instance.new("UIPadding")
		local UIListLayout_1Tab = Instance.new("UIListLayout")
		local SelectTab = Instance.new("Frame")
		local UIGradient_3Tab = Instance.new("UIGradient")

		Page_1.Name = "Page"
		Page_1.Parent = PageFolder
		Page_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Page_1.BackgroundTransparency = 1
		Page_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Page_1.BorderSizePixel = 0
		Page_1.Size = UDim2.new(1, 0,1, 0)
		Page_1.ClipsDescendants = true

		UIPadding_1Tab.Parent = Page_1
		UIPadding_1Tab.PaddingTop = UDim.new(0,50)

		TabFrame_1Tab.Name = "TabFrame"
		TabFrame_1Tab.Parent = Page_1
		TabFrame_1Tab.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TabFrame_1Tab.BackgroundTransparency = 1
		TabFrame_1Tab.BorderColor3 = Color3.fromRGB(0,0,0)
		TabFrame_1Tab.BorderSizePixel = 0
		TabFrame_1Tab.Size = UDim2.new(0, 70,1, 0)

		local Line = Instance.new("Frame")

		Line.Name = "Line"
		Line.Parent = TabFrame_1Tab
		Line.AnchorPoint = Vector2.new(0, 1)
		Line.BackgroundColor3 = Color3.fromRGB(54, 58, 69)
		Line.BorderColor3 = Color3.fromRGB(0,0,0)
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(1, 0,1, 0)
		Line.Size = UDim2.new(0, 2,1, 0)
		Line.BackgroundTransparency = Transparency

		ScrollingFrame_1Tab.Name = "ScrollingFrame"
		ScrollingFrame_1Tab.Parent = TabFrame_1Tab
		ScrollingFrame_1Tab.Active = true
		ScrollingFrame_1Tab.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ScrollingFrame_1Tab.BackgroundTransparency = 1
		ScrollingFrame_1Tab.BorderColor3 = Color3.fromRGB(0,0,0)
		ScrollingFrame_1Tab.BorderSizePixel = 0
		ScrollingFrame_1Tab.Size = UDim2.new(1, 0,1, 0)
		ScrollingFrame_1Tab.ClipsDescendants = true
		ScrollingFrame_1Tab.AutomaticCanvasSize = Enum.AutomaticSize.None
		ScrollingFrame_1Tab.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		ScrollingFrame_1Tab.CanvasPosition = Vector2.new(0, 0)
		ScrollingFrame_1Tab.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		ScrollingFrame_1Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame_1Tab.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		ScrollingFrame_1Tab.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
		ScrollingFrame_1Tab.ScrollBarImageTransparency = 0
		ScrollingFrame_1Tab.ScrollBarThickness = 0
		ScrollingFrame_1Tab.ScrollingDirection = Enum.ScrollingDirection.XY
		ScrollingFrame_1Tab.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		ScrollingFrame_1Tab.VerticalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame_1Tab.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		Frame_1.Parent = ScrollingFrame_1Tab
		Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_1.BackgroundTransparency = 1
		Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_1.BorderSizePixel = 0
		Frame_1.Size = UDim2.new(1, 0,1, 0)

		UIPadding_2Tab.Parent = Frame_1
		UIPadding_2Tab.PaddingBottom = UDim.new(0,5)
		UIPadding_2Tab.PaddingLeft = UDim.new(0,5)
		UIPadding_2Tab.PaddingRight = UDim.new(0,5)
		UIPadding_2Tab.PaddingTop = UDim.new(0,6)

		UIListLayout_1Tab.Parent = Frame_1
		UIListLayout_1Tab.Padding = UDim.new(0,5)
		UIListLayout_1Tab.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_1Tab.SortOrder = Enum.SortOrder.LayoutOrder

		SelectTab.Name = "Line"
		SelectTab.Parent = ScrollingFrame_1Tab
		SelectTab.BackgroundColor3 = Color3.fromRGB(255,255,255)
		SelectTab.BorderColor3 = Color3.fromRGB(0,0,0)
		SelectTab.BorderSizePixel = 0
		SelectTab.Position = UDim2.new(0, 0,0, 4)
		SelectTab.Size = UDim2.new(0, 2,0, 52)

		UIGradient_3Tab.Parent = SelectTab
		UIGradient_3Tab.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

		Title_1.Size = UDim2.new(0, Title_1.TextBounds.X + 10, 0, 20)

		local function twSelect()
			local scrollingFrame = Select_1.Parent
			local tabScrollingFrame = Tab.Parent

			local targetX = (Tab.AbsolutePosition.X - tabScrollingFrame.AbsolutePosition.X) 
				+ (scrollingFrame.AbsolutePosition.X - Select_1.Parent.AbsolutePosition.X - 2)
			local pos = UDim2.new(0, targetX, 1, 0)
			tw({v = Select_1, t = 0.5, s = Enum.EasingStyle.Exponential, d = "Out", g = {
				Position = pos
			}}):Play()
		end

		local function update()
			for i ,v in pairs(FrameTab_1:GetChildren()) do
				if v:IsA('Frame') then
					tw({v = v.Tab, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 1}}):Play()
					tw({v = v.Tab.ImageLabel, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 0.5}}):Play()
					v.Tab.UIStroke.Color = Color3.fromRGB(67, 67, 69)
					v.Tab.UIStroke.UIGradient.Enabled = false
				end
			end
			UIPageLayout:JumpTo(Page_1)
			UIGradient_1.Enabled = true
			tw({v = UIStroke_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Color = Color3.fromRGB(255, 255, 255)}}):Play()
			tw({v = ImageLabel_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 0}}):Play()
			tw({v = Tab_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 0}}):Play()
			twSelect()
		end

		local Click = click(Tab)

		Click.MouseButton1Click:Connect(update)

		delay(0, function()
			if not Library.Tabs.Value then
				update()
				Library.Tabs.Value = true
			end
		end)

		changecanvas2(ScrollingFrame_1, UIListLayout_3, 10)

		local Sections = {
			Value = false
		}

		function Sections:CreateTab(info)
			local Title = info.Title
			local Icon = info.Icon
			local Tab_2 = Instance.new("Frame")
			local Tab_1 = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UICorner_12 = Instance.new("UICorner")
			local UIGradient_2 = Instance.new("UIGradient")
			local UIListLayout_2 = Instance.new("UIListLayout")
			local ImageLabel_1 = Instance.new("ImageLabel")
			local UIPadding_3 = Instance.new("UIPadding")
			local Title_1 = Instance.new("TextLabel")

			Tab_2.Name = "Tab"
			Tab_2.Parent = Frame_1
			Tab_2.BackgroundColor3 = Color3.fromRGB(36, 39, 46)
			Tab_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Tab_2.BorderSizePixel = 0
			Tab_2.Size = UDim2.new(0, 60,0, 50)
			Tab_2.BackgroundTransparency = Transparency

			UICorner_12.Parent = Tab_2
			UICorner_12.CornerRadius = UDim.new(0,5)

			Tab_1.Name = "Tab"
			Tab_1.Parent = Tab_2
			Tab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Tab_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Tab_1.BorderSizePixel = 0
			Tab_1.Size = UDim2.new(1, 0,1, 0)
			Tab_1.BackgroundTransparency = 1

			UICorner_1.Parent = Tab_1
			UICorner_1.CornerRadius = UDim.new(0,8)

			UIGradient_2.Parent = Tab_1
			UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
			UIGradient_2.Rotation = 180

			ImageLabel_1.Parent = Tab_1
			ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
			ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ImageLabel_1.BackgroundTransparency = 1
			ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			ImageLabel_1.BorderSizePixel = 0
			ImageLabel_1.Size = UDim2.new(0, 22,0, 22)
			ImageLabel_1.Position = UDim2.new(0.5, 0,0.33, 0)
			ImageLabel_1.Image = gl(Icon)
			ImageLabel_1.ScaleType = Enum.ScaleType.Crop
			ImageLabel_1.ImageTransparency = 0.5

			Title_1.Name = "Title"
			Title_1.Parent = Tab_1
			Title_1.AnchorPoint = Vector2.new(0.5, 1)
			Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Title_1.BackgroundTransparency = 1
			Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Title_1.BorderSizePixel = 0
			Title_1.LayoutOrder = 1
			Title_1.Size = UDim2.new(0, 50,0, 15)
			Title_1.Font = Enum.Font.GothamBold
			Title_1.Text = Title
			Title_1.TextColor3 = Color3.fromRGB(255,255,255)
			Title_1.TextSize = 11
			Title_1.TextXAlignment = Enum.TextXAlignment.Center
			Title_1.Position = UDim2.new(0.5, 0, 0.87, 0)

			local FuncFrameSec = Instance.new("Frame")
			local UIPaddingSec_1 = Instance.new("UIPadding")
			local Section_1 = Instance.new("ScrollingFrame")
			local UIListLayoutSec_1 = Instance.new("UIListLayout")

			FuncFrameSec.Name = "FuncFrameSec"
			FuncFrameSec.Parent = Page_1
			FuncFrameSec.BackgroundColor3 = Color3.fromRGB(255,255,255)
			FuncFrameSec.BackgroundTransparency = 1
			FuncFrameSec.BorderColor3 = Color3.fromRGB(0,0,0)
			FuncFrameSec.BorderSizePixel = 0
			FuncFrameSec.Size = UDim2.new(1, 0,1, 0)
			FuncFrameSec.Visible = false

			UIPaddingSec_1.Name = "UIPaddingSec"
			UIPaddingSec_1.Parent = FuncFrameSec
			UIPaddingSec_1.PaddingBottom = UDim.new(0,5)
			UIPaddingSec_1.PaddingLeft = UDim.new(0,80)
			UIPaddingSec_1.PaddingRight = UDim.new(0,5)
			UIPaddingSec_1.PaddingTop = UDim.new(0,5)

			Section_1.Name = "Section"
			Section_1.Parent = FuncFrameSec
			Section_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Section_1.BackgroundTransparency = 1
			Section_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Section_1.BorderSizePixel = 0
			Section_1.Size = UDim2.new(1, 0,1, 0)
			Section_1.ClipsDescendants = true
			Section_1.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Section_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
			Section_1.CanvasPosition = Vector2.new(0, 0)
			Section_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
			Section_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
			Section_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
			Section_1.ScrollBarImageTransparency = 0
			Section_1.ScrollBarThickness = 0
			Section_1.ScrollingDirection = Enum.ScrollingDirection.XY
			Section_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
			Section_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
			Section_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

			UIListLayoutSec_1.Name = "UIListLayoutSec"
			UIListLayoutSec_1.Parent = Section_1
			UIListLayoutSec_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayoutSec_1.Padding = UDim.new(0, 5)

			changecanvas(Section_1, UIListLayoutSec_1, 5)

			local Click = click(Tab_2)

			local function twSelect()
				local scrollingFrame = SelectTab.Parent
				local tabScrollingFrame = Tab_2.Parent

				local targetY = (Tab_2.AbsolutePosition.Y - tabScrollingFrame.AbsolutePosition.Y) 
					+ (scrollingFrame.AbsolutePosition.Y - SelectTab.Parent.AbsolutePosition.Y - 2)

				local pos = UDim2.new(0, SelectTab.Position.X.Offset, 0, targetY)

				tw({v = SelectTab, t = 0.5, s = Enum.EasingStyle.Exponential, d = "Out", g = {
					Position = pos
				}}):Play()
			end

			local function update()
				for i, v in pairs(Page_1:GetChildren()) do
					if v:IsA('Frame') and v.Name == 'FuncFrameSec' then
						v.Visible = false
					end
				end
				for i, v in pairs(Frame_1:GetChildren()) do
					if v:IsA('Frame') then
						tw({v = v.Tab, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 1}}):Play()
						tw({v = v.Tab.ImageLabel, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {ImageTransparency = 0.5}}):Play()
					end
				end
				FuncFrameSec.Visible = true
				tw({v = Tab_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 0}}):Play()
				tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {ImageTransparency = 0}}):Play()
				twSelect()
			end

			Click.MouseButton1Click:Connect(update)

			delay(0, function()
				if not Sections.Value then
					update()
					Sections.Value = true
				end
			end)

			local Main = {}

			function Main:CreateSection(info)
				local Title = info.Title
				local Section_2 = Instance.new("Frame")
				local TextLabel_2 = Instance.new("TextLabel")
				local UIPadding_3Sec = Instance.new("UIPadding")

				Section_2.Name = "Section"
				Section_2.Parent = Section_1
				Section_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Section_2.BackgroundTransparency = 1
				Section_2.BorderColor3 = Color3.fromRGB(0,0,0)
				Section_2.BorderSizePixel = 0
				Section_2.Size = UDim2.new(1, 0,0, 30)

				TextLabel_2.Parent = Section_2
				TextLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextLabel_2.BackgroundTransparency = 1
				TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
				TextLabel_2.BorderSizePixel = 0
				TextLabel_2.RichText = true
				TextLabel_2.Size = UDim2.new(0, 200,0, 30)
				TextLabel_2.Font = Enum.Font.GothamBold
				TextLabel_2.Text = Title
				TextLabel_2.TextColor3 = Color3.fromRGB(255,255,255)
				TextLabel_2.TextSize = 18
				TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding_3Sec.Parent = Section_2
				UIPadding_3Sec.PaddingLeft = UDim.new(0,3)
				local New = {}

				function New:SetTitle(a)
					TextLabel_2.Text = a
				end
				return New
			end

			function Main:CreateToggle(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Value = info.Value or false
				local Callback = info.Callback or function() end
				local Toggle = background(Section_1, Title, Desc)

				local Frame = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local Frame_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Frame_2 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIGradient_1 = Instance.new("UIGradient")
				local UIStroke_1 = Instance.new("UIStroke")

				Frame.Parent = Toggle
				Frame.AnchorPoint = Vector2.new(1, 0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(1, 0,0.5, 0)
				Frame.Size = UDim2.new(0, 100,0.800000012, 0)
				Frame.Name = 'Toggle List Function'

				UIListLayout_1.Parent = Frame
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Frame
				UIPadding_1.PaddingRight = UDim.new(0,13)

				Frame_1.Parent = Frame
				Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame_1.BorderSizePixel = 0
				Frame_1.Size = UDim2.new(0, 45,0, 23)
				Frame_1.BackgroundTransparency = 1

				UICorner_1.Parent = Frame_1
				UICorner_1.CornerRadius = UDim.new(1,0)

				Frame_2.Parent = Frame_1
				Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame_2.BorderSizePixel = 0
				Frame_2.Position = UDim2.new(0.3, 0,0.5, 0)
				Frame_2.Size = UDim2.new(0, 18,0, 18)

				UICorner_2.Parent = Frame_2
				UICorner_2.CornerRadius = UDim.new(1,0)

				UIGradient_1.Parent = Frame_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
				UIGradient_1.Rotation = -150
				UIStroke_1.Parent = Frame_1
				UIStroke_1.Color = Color3.fromRGB(106,130,146)
				UIStroke_1.Thickness = 1.5
				UIStroke_1.Transparency = 0.8

				local Click = click(Toggle)

				Value = not Value

				local function change()
					Value = not Value
					Callback(Value)
					if Value then
						tw({v = Toggle.Frame.Title, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0}}):Play()
						tw({v = Frame_2, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Position = UDim2.new(0.75, 0,0.5, 0), BackgroundColor3 = Color3.fromRGB(255,255,255)}}):Play()
						tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 0}}):Play()
						tw({v = UIStroke_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 0}}):Play()
					else
						tw({v = Toggle.Frame.Title, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.5}}):Play()
						tw({v = Frame_2, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Position = UDim2.new(0.27, 0,0.5, 0), BackgroundColor3 = Color3.fromRGB(54, 58, 69)}}):Play()
						tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 1}}):Play()
						tw({v = UIStroke_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 0.8}}):Play()
					end
				end

				Click.MouseButton1Click:Connect(change)

				delay(0.1, change)

				local New = {}

				function New:SetTitle(a)
					Toggle.Frame.Title.Text = a
				end

				function New:SetDesc(a)
					if a and a ~= '' then
						Toggle.Frame.Desc.Text = a
						Toggle.Frame.Desc.Visible = true
					else
						Toggle.Frame.Desc.Visible = false
					end
				end

				function New:Visible(a)
					Toggle.Visible = a
				end

				function New:SetValue(a)
					if type(a) == "boolean" and Value ~= a then
						Value = a
						change()
					end
				end

				return New
			end

			function Main:CreateSlider(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Min = info.Min or 0
				local Max = info.Max or 100
				local Value = info.Value or Max/2
				local Rounding = info.Rounding or 0
				local Callback = info.Callback or function() end
				local Slider = background(Section_1, Title, Desc)

				Slider.Frame.UIPadding.PaddingRight = UDim.new(0, 270)

				local Frame = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local ValueBar_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local BarValue_1 = Instance.new("Frame")
				local Frame_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIGradient_1 = Instance.new("UIGradient")
				local UICorner_3 = Instance.new("UICorner")
				local UIGradient_2 = Instance.new("UIGradient")
				local Click_1 = Instance.new("TextButton")
				local ValueBox_1 = Instance.new("Frame")
				local UICorner_4 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local TextBox_1 = Instance.new("TextBox")

				Frame.Parent = Slider
				Frame.AnchorPoint = Vector2.new(1, 0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(1, 0,0.5, 0)
				Frame.Size = UDim2.new(0, 260,0.800000012, 0)

				UIListLayout_1.Parent = Frame
				UIListLayout_1.Padding = UDim.new(0,15)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Frame
				UIPadding_1.PaddingRight = UDim.new(0,13)

				ValueBar_1.Name = "ValueBar"
				ValueBar_1.Parent = Frame
				ValueBar_1.BackgroundColor3 = Color3.fromRGB(47,48,51)
				ValueBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBar_1.BorderSizePixel = 0
				ValueBar_1.Size = UDim2.new(0, 200,0, 4)

				UICorner_1.Parent = ValueBar_1
				UICorner_1.CornerRadius = UDim.new(1,0)

				BarValue_1.Name = "BarValue"
				BarValue_1.Parent = ValueBar_1
				BarValue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				BarValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
				BarValue_1.BorderSizePixel = 0
				BarValue_1.Size = UDim2.new(0.800000012, 0,1, 0)

				Frame_1.Parent = BarValue_1
				Frame_1.AnchorPoint = Vector2.new(1, 0.5)
				Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame_1.BorderSizePixel = 0
				Frame_1.Position = UDim2.new(1, 0,0.5, 0)
				Frame_1.Size = UDim2.new(0, 13,0, 13)

				UICorner_2.Parent = Frame_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				UIGradient_1.Parent = Frame_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

				UICorner_3.Parent = BarValue_1
				UICorner_3.CornerRadius = UDim.new(1,0)

				UIGradient_2.Parent = BarValue_1
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

				Click_1.Name = "Click"
				Click_1.Parent = ValueBar_1
				Click_1.Active = true
				Click_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Click_1.Size = UDim2.new(1, 0,3, 0)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Frame
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(28,28,30)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.LayoutOrder = -1
				ValueBox_1.Size = UDim2.new(0, 25,0, 15)

				UICorner_4.Parent = ValueBox_1
				UICorner_4.CornerRadius = UDim.new(1,0)

				UIStroke_1.Parent = ValueBox_1
				UIStroke_1.Color = Color3.fromRGB(47,48,51)
				UIStroke_1.Thickness = 2.5

				TextBox_1.Parent = ValueBox_1
				TextBox_1.Active = true
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.Size = UDim2.new(1, 0,1, 0)
				TextBox_1.Font = Enum.Font.Gotham
				TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				TextBox_1.PlaceholderText = ""
				TextBox_1.Text = "80"
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 9

				local function roundToDecimal(value, decimals)
					local factor = 10 ^ decimals
					return math.floor(value * factor + 0.5) / factor
				end

				local function updateSlider(value)
					value = math.clamp(value, Min, Max)
					value = roundToDecimal(value, Rounding)
					tw({v = BarValue_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}}):Play()

					TextBox_1.Text = tostring(roundToDecimal(value, Rounding))

					tw({v = ValueBox_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, TextBox_1.TextBounds.X + 10, 0, 15)}}):Play()

					Callback(value)
				end

				updateSlider(Value or 0)

				TextBox_1.FocusLost:Connect(function()
					local value = tonumber(TextBox_1.Text) or Min
					updateSlider(value)
				end)

				local function move(input)
					local sliderBar = ValueBar_1
					local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local value = relativeX * (Max - Min) + Min
					updateSlider(value)
				end

				local dragging = false

				Click_1.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						move(input)
					end
				end)

				Click_1.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				U.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						move(input)
					end
				end)

				local New = {}

				function New:SetTitle(a)
					Slider.Frame.Title.Text = a
				end

				function New:SetDesc(a)
					if a and a ~= '' then
						Slider.Frame.Desc.Text = a
						Slider.Frame.Desc.Visible = true
					else
						Slider.Frame.Desc.Visible = false
					end
				end

				function New:SetValue(a)
					updateSlider(a)
				end

				return New
			end

			function Main:CreateDropdown(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local List = info.List or {}
				local Value = info.Value or List[1]
				local Multi = info.Multi or false
				local Callback = info.Callback or function() end
				local Dropdown = background(Section_1, Title, Desc)

				Dropdown.Frame.UIPadding.PaddingRight = UDim.new(0, 150)

				local Frame = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local ValueBox_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local TextLabelValue_1 = Instance.new("TextLabel")
				local UIPadding_2 = Instance.new("UIPadding")
				local ImageLabel_1D = Instance.new("ImageLabel")

				Frame.Parent = Dropdown
				Frame.AnchorPoint = Vector2.new(1, 0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(1, 0,0.5, 0)
				Frame.Size = UDim2.new(0, 150,0.8, 0)

				UIListLayout_1.Parent = Frame
				UIListLayout_1.Padding = UDim.new(0,15)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Frame
				UIPadding_1.PaddingRight = UDim.new(0,13)

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Frame
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.LayoutOrder = -1
				ValueBox_1.Size = UDim2.new(0, 120,0, 25)

				UICorner_1.Parent = ValueBox_1
				UICorner_1.CornerRadius = UDim.new(0,6)

				UIStroke_1.Parent = ValueBox_1
				UIStroke_1.Color = Color3.fromRGB(54, 58, 69)
				UIStroke_1.Thickness = 2.5

				TextLabelValue_1.Name = "TextBox"
				TextLabelValue_1.Parent = ValueBox_1
				TextLabelValue_1.Active = true
				TextLabelValue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextLabelValue_1.BackgroundTransparency = 1
				TextLabelValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextLabelValue_1.BorderSizePixel = 0
				TextLabelValue_1.Size = UDim2.new(0.800000012, 0,1, 0)
				TextLabelValue_1.Font = Enum.Font.GothamBold
				TextLabelValue_1.Text = tostring(Value)
				TextLabelValue_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextLabelValue_1.TextSize = 10
				TextLabelValue_1.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabelValue_1.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding_2.Parent = ValueBox_1
				UIPadding_2.PaddingLeft = UDim.new(0,5)
				UIPadding_2.PaddingRight = UDim.new(0,5)

				ImageLabel_1D.Parent = ValueBox_1
				ImageLabel_1D.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1D.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1D.BackgroundTransparency = 1
				ImageLabel_1D.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1D.BorderSizePixel = 0
				ImageLabel_1D.Position = UDim2.new(1, 0,0.5, 0)
				ImageLabel_1D.Size = UDim2.new(0, 15,0, 15)
				ImageLabel_1D.Image = "rbxassetid://13858857904"
				ImageLabel_1D.ImageTransparency = 0.5
				ImageLabel_1D.Rotation = 90

				local MainDD = Instance.new("Frame")
				local DropdownSelect = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Search_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local TextBox_1 = Instance.new("TextBox")
				local UIPadding_1 = Instance.new("UIPadding")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIPadding_2 = Instance.new("UIPadding")
				local ScrollingFrame_1 = Instance.new("ScrollingFrame")
				local UIListLayout_2 = Instance.new("UIListLayout")

				MainDD.Name = "Frame2"
				MainDD.Parent = Background_1
				MainDD.AnchorPoint = Vector2.new(0.5,0.5)
				MainDD.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
				MainDD.BackgroundTransparency = 1
				MainDD.BorderColor3 = Color3.fromRGB(0,0,0)
				MainDD.BorderSizePixel = 0
				MainDD.Position = UDim2.new(0.5, 0,0.5, 0)
				MainDD.Size = UDim2.new(0, 300,0, 0)
				MainDD.Visible = false
				MainDD.ClipsDescendants = false
				MainDD.Name = 'Dropdown Select'

				local Shadow = Instance.new("ImageLabel")
				Shadow.Parent = MainDD
				Shadow.Name = "DropShadow"
				Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
				Shadow.BackgroundColor3 = Color3.fromRGB(28,28,30)
				Shadow.BackgroundTransparency = 1
				Shadow.BorderColor3 = Color3.fromRGB(0,0,0)
				Shadow.BorderSizePixel = 0
				Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
				Shadow.Size = UDim2.new(0, 450, 0, 450)
				Shadow.ZIndex = 0
				Shadow.Image = "rbxassetid://8992230677"
				Shadow.ImageColor3 = Color3.new(0, 0, 0)
				Shadow.ImageTransparency = 0.6
				Shadow.ResampleMode = Enum.ResamplerMode.Default
				Shadow.ScaleType = Enum.ScaleType.Slice
				Shadow.SliceScale = 1
				Shadow.TileSize = UDim2.new(1, 0, 1, 0)
				Shadow.SliceCenter = Rect.new(99, 99, 99, 99)
				Shadow.ZIndex = 1

				DropdownSelect.Name = "DropdownSelect"
				DropdownSelect.Parent = MainDD
				DropdownSelect.AnchorPoint = Vector2.new(0.5,0.5)
				DropdownSelect.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
				DropdownSelect.BackgroundTransparency = 0
				DropdownSelect.BorderColor3 = Color3.fromRGB(0,0,0)
				DropdownSelect.BorderSizePixel = 0
				DropdownSelect.Position = UDim2.new(0.5, 0,0.5, 0)
				DropdownSelect.Size = UDim2.new(1, 0,1, 0)
				DropdownSelect.ClipsDescendants = true


				UICorner_1.Parent = DropdownSelect

				UIStroke_1.Parent = DropdownSelect
				UIStroke_1.Color = Color3.fromRGB(54, 58, 69)
				UIStroke_1.Thickness = 2.5
				UIStroke_1.Transparency = 0.5

				UIListLayout_1.Parent = DropdownSelect
				UIListLayout_1.Padding = UDim.new(0,5)
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

				Search_1.Name = "Search"
				Search_1.Parent = DropdownSelect
				Search_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
				Search_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Search_1.BorderSizePixel = 0
				Search_1.LayoutOrder = -1
				Search_1.Size = UDim2.new(1, 0,0, 20)

				UICorner_2.Parent = Search_1
				UICorner_2.CornerRadius = UDim.new(1,0)


				TextBox_1.Parent = Search_1
				TextBox_1.Active = true
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.Size = UDim2.new(1, 0,1, 0)
				TextBox_1.Font = Enum.Font.Gotham
				TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				TextBox_1.PlaceholderText = "Search"
				TextBox_1.Text = ""
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 9
				TextBox_1.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding_1.Parent = Search_1
				UIPadding_1.PaddingLeft = UDim.new(0,5)
				UIPadding_1.PaddingRight = UDim.new(0,5)

				ImageLabel_1.Parent = Search_1
				ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(1, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(0, 10,0, 10)
				ImageLabel_1.Image = "rbxassetid://14897613248"
				ImageLabel_1.ImageTransparency = 0.5

				UIPadding_2.Parent = DropdownSelect
				UIPadding_2.PaddingLeft = UDim.new(0,8)
				UIPadding_2.PaddingRight = UDim.new(0,8)
				UIPadding_2.PaddingTop = UDim.new(0,8)

				ScrollingFrame_1.Name = "ScrollingFrame"
				ScrollingFrame_1.Parent = DropdownSelect
				ScrollingFrame_1.Active = true
				ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ScrollingFrame_1.BackgroundTransparency = 1
				ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ScrollingFrame_1.BorderSizePixel = 0
				ScrollingFrame_1.Size = UDim2.new(1, 0,0, 262)
				ScrollingFrame_1.ClipsDescendants = true
				ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
				ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
				ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
				ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
				ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
				ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
				ScrollingFrame_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
				ScrollingFrame_1.ScrollBarImageTransparency = 0
				ScrollingFrame_1.ScrollBarThickness = 0
				ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
				ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
				ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
				ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

				UIListLayout_2.Parent = ScrollingFrame_1
				UIListLayout_2.Padding = UDim.new(0,3)
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

				TextBox_1.Changed:Connect(function()
					local SearchT = string.lower(TextBox_1.Text)
					for i,v in pairs(ScrollingFrame_1:GetChildren()) do
						if v:IsA("Frame") then
							if SearchT ~= "" and v:FindFirstChild("TextLabel") then
								if string.find(string.lower(v.TextLabel.Text), SearchT) then
									v.Visible = true
								else
									v.Visible = false
								end
							else
								v.Visible = true
							end
						end
					end
				end)

				local Click = click(Dropdown)
				local isopen = false

				local function open()
					MainDD.Visible = true
					tw({v = DropdownSelect, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.5, 0, 0.5, 0)}}):Play()
					tw({v = UIStroke_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 0}}):Play()
					tw({v = ImageLabel_1D, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Rotation = 0}}):Play()
					isopen = true	
				end

				local function close()
					local gdsg = tw({v = DropdownSelect, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 300, 0, 0)}})
					gdsg:Play()
					tw({v = ImageLabel_1D, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Rotation = 90}}):Play()
					tw({v = UIStroke_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 1}}):Play()
					gdsg.Completed:Connect(function()
						MainDD.Visible = false
					end)
					isopen = false
				end	

				UserInputService.InputBegan:Connect(function(A)
					if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
						local B, C = DropdownSelect.AbsolutePosition, DropdownSelect.AbsoluteSize
						if game:GetService "Players".LocalPlayer:GetMouse().X < B.X or game:GetService "Players".LocalPlayer:GetMouse().X > B.X + C.X or game:GetService "Players".LocalPlayer:GetMouse().Y < (B.Y - 20 - 1) or game:GetService "Players".LocalPlayer:GetMouse().Y > B.Y + C.Y then
							if isopen then
								close()
							end
						end
					end
				end)

				Click.MouseButton1Click:Connect(function()
					if not isopen then
						open()
					else
						close()
					end
				end)

				local itemslist = {}
				local selectedValues = {}
				local selectedItem

				function itemslist:Clear(a)
					local function shouldClear(v)
						if a == nil then
							return true
						elseif type(a) == "string" then
							return v:FindFirstChild("TextLabel") and v.TextLabel.Text == a
						elseif type(a) == "table" then
							for _, name in ipairs(a) do
								if v:FindFirstChild("TextLabel") and v.TextLabel.Text == name then
									return true
								end
							end
						end
						return false
					end

					for _, v in ipairs(ScrollingFrame_1:GetChildren()) do
						if v:IsA("Frame") and shouldClear(v) then
							if selectedItem and v:FindFirstChild("TextLabel") and v.TextLabel.Text == selectedItem then
								selectedItem = nil
								TextLabelValue_1.Text = ""
							end
							v:Destroy()
						end
					end

					if selectedItem == a or TextLabelValue_1.Text == a then
						selectedItem = nil
						TextLabelValue_1.Text = ""
					end

					if a == nil then
						selectedItem = nil
						TextLabelValue_1.Text = ""
					end
				end

				function itemslist:Add(text)
					local Item_1 = Instance.new("Frame")
					local UICorner_3 = Instance.new("UICorner")
					local TextLabel_1 = Instance.new("TextLabel")
					local UIPadding_3 = Instance.new("UIPadding")
					local Fade = Instance.new("UIGradient")

					Item_1.Name = "Item"
					Item_1.Parent = ScrollingFrame_1
					Item_1.BackgroundColor3 = Color3.fromRGB(200, 217, 255)
					Item_1.BackgroundTransparency = 1
					Item_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Item_1.BorderSizePixel = 0
					Item_1.Size = UDim2.new(1, 0,0, 25)

					UICorner_3.Parent = Item_1
					UICorner_3.CornerRadius = UDim.new(0,6)


					TextLabel_1.Parent = Item_1
					TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					TextLabel_1.BackgroundTransparency = 1
					TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
					TextLabel_1.BorderSizePixel = 0
					TextLabel_1.Size = UDim2.new(1, 0,1, 0)
					TextLabel_1.Font = Enum.Font.GothamBold
					TextLabel_1.Text = text
					TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
					TextLabel_1.TextSize = 10
					TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel_1.TextTransparency = 0.5

					UIPadding_3.Parent = Item_1
					UIPadding_3.PaddingLeft = UDim.new(0,5)
					UIPadding_3.PaddingRight = UDim.new(0,5)

					local ClickItem = click(Item_1)
					ClickItem.ZIndex = 3
					local function unselect()
						tw({v = TextLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.5}}):Play()
						tw({v = Item_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 1}}):Play()
					end
					local function hasselect()
						tw({v = TextLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0}}):Play()
						tw({v = Item_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 0.8}}):Play()
					end

					ClickItem.MouseButton1Click:Connect(function()
						if Multi then
							if selectedValues[text] then
								selectedValues[text] = nil
								unselect()
							else
								selectedValues[text] = true
								hasselect()
							end
							local selectedList = {}
							for i, v in pairs(selectedValues) do
								table.insert(selectedList, i)
							end
							if #selectedList > 0 then
								TextLabelValue_1.Text = table.concat(selectedList, ", ")
							else
								TextLabelValue_1.Text = ""
							end
							pcall(function()
								Callback(selectedList)
							end)
						else
							for i,v in pairs(ScrollingFrame_1:GetChildren()) do
								if v:IsA("Frame") then
									tw({v = v.TextLabel, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.5}}):Play()
									tw({v = v, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 1}}):Play()
								end
							end
							hasselect()
							Value = text
							TextLabelValue_1.Text = text
							Callback(TextLabelValue_1.Text)
						end
					end)

					local function isValueInTable(val, tbl)
						if type(tbl) ~= "table" then
							return false
						end

						for _, v in pairs(tbl) do
							if v == val then
								return true
							end
						end
						return false
					end

					delay(0,function()
						if Multi then
							if isValueInTable(text, Value) then
								hasselect()
								selectedValues[text] = true
								local selectedList = {}
								for i, v in pairs(selectedValues) do
									table.insert(selectedList, i)
								end
								if #selectedList > 0 then
									TextLabelValue_1.Text = table.concat(selectedList, ", ")
								else
									TextLabelValue_1.Text = ""
								end
								pcall(function()
									Callback(selectedList)
								end)
							end
						else
							if text == Value then
								hasselect()
								Value = text
								TextLabelValue_1.Text = text
								Callback(TextLabelValue_1.Text)
							end
						end
					end)
				end

				for i, v in ipairs(List) do
					itemslist:Add(v, i)
				end

				changecanvas(ScrollingFrame_1, UIListLayout_2, 5)

				local New = {}

				function New:SetTitle(a)
					Dropdown.Frame.Title.Text = a
				end

				function New:SetDesc(a)
					if a and a ~= '' then
						Dropdown.Frame.Desc.Text = a
						Dropdown.Frame.Desc.Visible = true
					else
						Dropdown.Frame.Desc.Visible = false
					end
				end

				return itemslist
			end

			function Main:CreateButton(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Callback = info.Callback or function() end

				local Button = background(Section_1, Title, Desc)
				local Click = click(Button)

				Button.Frame.UIPadding.PaddingRight = UDim.new(0, 50)

				local Frame = Instance.new("Frame")
				local UIPadding_1 = Instance.new("UIPadding")
				local ImageLabel_1 = Instance.new("ImageLabel")

				Frame.Parent = Button
				Frame.AnchorPoint = Vector2.new(1, 0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(1, 0,0.5, 0)
				Frame.Size = UDim2.new(0, 30,0.800000012, 0)

				UIPadding_1.Parent = Frame
				UIPadding_1.PaddingRight = UDim.new(0,13)

				ImageLabel_1.Parent = Frame
				ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(1, 0,0.5, 0)
				ImageLabel_1.Rotation = 270
				ImageLabel_1.Size = UDim2.new(0, 15,0, 15)
				ImageLabel_1.Image = "rbxassetid://13858857904"
				ImageLabel_1.ImageTransparency = 0.5

				Click.MouseButton1Click:Connect(function()
					jc(Click, Button)
					pcall(Callback)
				end)

				local New = {}

				function New:SetTitle(a)
					Button.Frame.Title.Text = a
				end

				function New:SetDesc(a)
					if a and a ~= '' then
						Button.Frame.Desc.Text = a
						Button.Frame.Desc.Visible = true
					else
						Button.Frame.Desc.Visible = false
					end
				end
				function New:Visible(a)
					Button.Visible = a
				end
				return New
			end

			function Main:CreateLabel(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Icon = info.Icon or ''
				local Label = background(Section_1, Title, Desc)

				local Image = Instance.new("ImageLabel")
				local UICorner = Instance.new("UICorner")
				UICorner.Parent = Image
				UICorner.CornerRadius = UDim.new(0,6)
				Image.Parent = Label
				Image.AnchorPoint = Vector2.new(0, 0.5)
				Image.Size = UDim2.new(0, 40, 0, 40)
				Image.Position = UDim2.new(0.9, 0, 0.5, 0)
				Image.BackgroundTransparency = 1
				Image.Image = gl(Icon)
				Label.Frame.UIPadding.PaddingRight = UDim.new(0, 13)

				local New = {}

				function New:SetTitle(a)
					Label.Frame.Title.Text = a
				end

				function New:SetImage(a)
					Image.Image = gl(a)
				end

				function New:SetDesc(a)
					if a and a ~= '' then
						Label.Frame.Desc.Text = a
						Label.Frame.Desc.Visible = true
					else
						Label.Frame.Desc.Visible = false
					end
				end

				function New:Visible(a)
					Label.Visible = a
				end

				return New
			end

			function Main:CreateKeybind(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Value = info.Value or false
				local Key = info.Key or Enum.KeyCode.E
				local Callback = info.Callback or function() end
				local Keybind = background(Section_1, Title, Desc)

				Keybind.Frame.UIPadding.PaddingRight = UDim.new(0, 100)
				local Title_1 = Keybind.Frame.Title

				local Frame = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local ValueBox_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local TextBox_1 = Instance.new("TextLabel")

				Frame.Parent = Keybind
				Frame.AnchorPoint = Vector2.new(1, 0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(1, 0,0.5, 0)
				Frame.Size = UDim2.new(0, 100,0.800000012, 0)

				UIListLayout_1.Parent = Frame
				UIListLayout_1.Padding = UDim.new(0,15)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Frame
				UIPadding_1.PaddingRight = UDim.new(0,13)

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Frame
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.LayoutOrder = -1
				ValueBox_1.Size = UDim2.new(0, 25,0, 25)

				UICorner_1.Parent = ValueBox_1
				UICorner_1.CornerRadius = UDim.new(0,6)

				UIStroke_1.Parent = ValueBox_1
				UIStroke_1.Color = Color3.fromRGB(54, 58, 69)
				UIStroke_1.Thickness = 2.5

				TextBox_1.Name = "TextBox"
				TextBox_1.Parent = ValueBox_1
				TextBox_1.Active = true
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.Size = UDim2.new(1, 0,1, 0)
				TextBox_1.Font = Enum.Font.GothamBold
				TextBox_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 14
				TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd

				local Click = click(Keybind)
				local changeing = false

				local function adjustBoxBindSize()
					local textSize = game:GetService("TextService"):GetTextSize(TextBox_1.Text, TextBox_1.TextSize, TextBox_1.Font, Vector2.new(1000, 1000))
					tw({v = ValueBox_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, textSize.X + 20, 0, 25)}}):Play()
				end

				adjustBoxBindSize()

				local function changeKey()
					changeing = true
					TextBox_1.Text = "..."
					local inputConnection
					inputConnection = U.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							Key = input.KeyCode
							TextBox_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
							adjustBoxBindSize()
							inputConnection:Disconnect()
							Callback(Key, Value)
							task.wait(.1)
							changeing = false
						end
					end)
				end

				local function va(v)
					if v then
						tw({v = Title_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0}}):Play()
					else
						tw({v = Title_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.5}}):Play()
					end
					Callback(Key, v)
				end

				U.InputBegan:Connect(function(input, gameProcessed)
					if input.KeyCode == Key and not changeing then
						Value = not Value
						va(Value)
					end
				end)

				delay(0, function()
					Callback(Key, Value)
				end)

				Click.MouseButton1Click:Connect(function()
					changeKey()
				end)

				local New = {}

				function New:SetTitle(a)
					Keybind.Frame.Title.Text = a
				end

				function New:SetDesc(a)
					if a and a ~= '' then
						Keybind.Frame.Desc.Text = a
						Keybind.Frame.Desc.Visible = true
					else
						Keybind.Frame.Desc.Visible = false
					end
				end

				function New:SetValue(a)
					va(a)
				end

				function New:SetKeybind(a)
					TextBox_1.Text = tostring(a):gsub("Enum.KeyCode.", "")
					adjustBoxBindSize()
				end

				return New
			end

			function Main:CreateTextBox(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Value = info.Value or ''
				local Placeholder = info.Placeholder or 'Paste Your Text'
				local ClearText = info.ClearText or info.ClearTextOnFocus or false
				local Callback = info.Callback or function() end

				local Textbox = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Box_1 = Instance.new("Frame")
				local ValueBox_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local TextBox_1 = Instance.new("TextBox")
				local UIPadding_1 = Instance.new("UIPadding")
				local Frame_1 = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local UIPadding_2 = Instance.new("UIPadding")

				Textbox.Name = "Textbox"
				Textbox.Parent = Section_1
				Textbox.BackgroundColor3 = Color3.fromRGB(36, 39, 46)
				Textbox.BackgroundTransparency = Transparency
				Textbox.BorderColor3 = Color3.fromRGB(0,0,0)
				Textbox.BorderSizePixel = 0
				Textbox.Size = UDim2.new(1, 0,0, 65)
				Textbox.ClipsDescendants = true

				UICorner_1.Parent = Textbox
				UICorner_1.CornerRadius = UDim.new(0,4)


				Box_1.Name = "Box"
				Box_1.Parent = Textbox
				Box_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Box_1.BackgroundTransparency = 1
				Box_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Box_1.BorderSizePixel = 0
				Box_1.Size = UDim2.new(1, 0,1, 0)

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Box_1
				ValueBox_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.LayoutOrder = -1
				ValueBox_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ValueBox_1.Size = UDim2.new(1, 0,1, 0)

				UICorner_2.Parent = ValueBox_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				UIStroke_1.Parent = ValueBox_1
				UIStroke_1.Color = Color3.fromRGB(54, 58, 69)
				UIStroke_1.Thickness = 2.5

				TextBox_1.Parent = ValueBox_1
				TextBox_1.Active = true
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.Size = UDim2.new(1, 0,1, 0)
				TextBox_1.Font = Enum.Font.Gotham
				TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				TextBox_1.PlaceholderText = Placeholder
				TextBox_1.Text = Value
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 12

				UIPadding_1.Parent = Box_1
				UIPadding_1.PaddingBottom = UDim.new(0,10)
				UIPadding_1.PaddingLeft = UDim.new(0,10)
				UIPadding_1.PaddingRight = UDim.new(0,10)
				UIPadding_1.PaddingTop = UDim.new(0,30)

				Frame_1.Parent = Textbox
				Frame_1.AnchorPoint = Vector2.new(0, 0.5)
				Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame_1.BackgroundTransparency = 1
				Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame_1.BorderSizePixel = 0
				Frame_1.Position = UDim2.new(0, 0,0.5, 0)
				Frame_1.Size = UDim2.new(1, 0,1, 0)

				Title_1.Name = "Title"
				Title_1.Parent = Frame_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(1, 0,0, 16)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.RichText = true
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 13
				Title_1.TextWrapped = true
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding_2.Parent = Frame_1
				UIPadding_2.PaddingLeft = UDim.new(0,13)
				UIPadding_2.PaddingRight = UDim.new(0,13)
				UIPadding_2.PaddingTop = UDim.new(0,7)

				local function o()
					if #TextBox_1.Text > 0 then
						pcall(Callback, TextBox_1.Text)
					end
				end

				TextBox_1.FocusLost:Connect(o)

				delay(0, o)

				local New = {}

				function New:SetTitle(a)
					Title_1.Text = a
				end

				function New:SetValue(a)
					TextBox_1.Text = a
					pcall(Callback, TextBox_1.Text)
				end

				return New
			end

			function Main:CreateSelect(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Value = info.Value or ''
				local Callback = info.Callback or function() end
				local List = info.List or {}
				local Selected = background(Section_1, Title, Desc)
				Selected.Frame.UIPadding.PaddingRight = UDim.new(0, 170)

				local Frame = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local ValueBox_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local UIPadding_2 = Instance.new("UIPadding")
				local UIPageLayout_1 = Instance.new("UIPageLayout")
				local Left_1 = Instance.new("ImageButton")
				local Right_1 = Instance.new("ImageButton")

				Frame.Parent = Selected
				Frame.AnchorPoint = Vector2.new(1, 0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(1, 0,0.5, 0)
				Frame.Size = UDim2.new(0, 150,0.800000012, 0)

				UIListLayout_1.Parent = Frame
				UIListLayout_1.Padding = UDim.new(0,5)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Frame
				UIPadding_1.PaddingRight = UDim.new(0,13)

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Frame
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.Size = UDim2.new(0, 100,0, 25)
				ValueBox_1.ClipsDescendants = true

				UICorner_1.Parent = ValueBox_1
				UICorner_1.CornerRadius = UDim.new(1,0)

				UIStroke_1.Parent = ValueBox_1
				UIStroke_1.Color = Color3.fromRGB(54, 58, 69)
				UIStroke_1.Thickness = 2.5

				UIPadding_2.Parent = ValueBox_1
				UIPadding_2.PaddingLeft = UDim.new(0,5)
				UIPadding_2.PaddingRight = UDim.new(0,5)

				UIPageLayout_1.Parent = ValueBox_1
				UIPageLayout_1.EasingStyle = Enum.EasingStyle.Exponential
				UIPageLayout_1.Circular = true
				UIPageLayout_1.GamepadInputEnabled = false
				UIPageLayout_1.ScrollWheelInputEnabled = false
				UIPageLayout_1.TouchInputEnabled = false

				Left_1.Name = "Left"
				Left_1.Parent = Frame
				Left_1.AnchorPoint = Vector2.new(1, 0.5)
				Left_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Left_1.BackgroundTransparency = 1
				Left_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Left_1.BorderSizePixel = 0
				Left_1.LayoutOrder = -1
				Left_1.Position = UDim2.new(1, 0,0.5, 0)
				Left_1.Size = UDim2.new(0, 18,0, 18)
				Left_1.Image = "rbxassetid://13858862016"
				Left_1.ImageTransparency = 0.5

				Right_1.Name = "Right"
				Right_1.Parent = Frame
				Right_1.AnchorPoint = Vector2.new(1, 0.5)
				Right_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Right_1.BackgroundTransparency = 1
				Right_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Right_1.BorderSizePixel = 0
				Right_1.LayoutOrder = 1
				Right_1.Position = UDim2.new(1, 0,0.5, 0)
				Right_1.Size = UDim2.new(0, 18,0, 18)
				Right_1.Image = "rbxassetid://13858863890"
				Right_1.ImageTransparency = 0.5

				local g = {}

				function g:addlist(item)
					local Value_1 = Instance.new("TextLabel")
					Value_1.Name = "Value"
					Value_1.Parent = ValueBox_1
					Value_1.Active = true
					Value_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Value_1.BackgroundTransparency = 1
					Value_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Value_1.BorderSizePixel = 0
					Value_1.Size = UDim2.new(1, 0,1, 0)
					Value_1.Font = Enum.Font.GothamBold
					Value_1.Text = item
					Value_1.TextColor3 = Color3.fromRGB(255,255,255)
					Value_1.TextSize = 10
					Value_1.TextTruncate = Enum.TextTruncate.AtEnd
				end

				for _, item in ipairs(List) do
					g:addlist(item)
				end

				tw({v = ValueBox_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 50, 0, 25)}}):Play()

				Right_1.MouseButton1Click:Connect(function()
					UIPageLayout_1:Next()
					pcall(Callback, UIPageLayout_1.CurrentPage.Text)
					tw({v = ValueBox_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 50, 0, 25)}}):Play()
				end)

				Left_1.MouseButton1Click:Connect(function()
					UIPageLayout_1:Previous()
					pcall(Callback, UIPageLayout_1.CurrentPage.Text)
					tw({v = ValueBox_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 50, 0, 25)}}):Play()
				end)

				delay(0,function()
					for i, v in pairs(ValueBox_1:GetChildren()) do
						if v:IsA("TextLabel") and v.Text == Value then
							UIPageLayout_1:JumpTo(v)
						end
					end
					tw({v = ValueBox_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 50, 0, 25)}}):Play()
				end)


				function g:SetTitle(a)
					Selected.Frame.Title.Text = a
				end

				function g:SetDesc(a)
					if a and a ~= '' then
						Selected.Frame.Desc.Text = a
						Selected.Frame.Desc.Visible = true
					else
						Selected.Frame.Desc.Visible = false
					end
				end

				function g:SetValue(a)
					UIPageLayout_1:JumpTo(a)
					pcall(Callback, UIPageLayout_1.CurrentPage.Text)
				end

				return g
			end

			function Main:Discord(info)
				local Title = info.Title
				local Desc = info.Desc or ''
				local Icon = info.Icon
				local Color = info.Color or Color3.fromRGB(255, 255, 255)
				local Callback = info.Callback or function() end

				local Discord = Instance.new("Frame")
				local Click = click(Discord)
				local UICorner_1 = Instance.new("UICorner")
				local Frame_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local TextLabel_1 = Instance.new("TextLabel")
				local Title_1 = Instance.new("TextLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Icon_1 = Instance.new("Frame")
				local IconDiscord_1 = Instance.new("ImageLabel")
				local Frame_2 = Instance.new("Frame")
				local UIPadding_2 = Instance.new("UIPadding")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local TextLabel_2 = Instance.new("TextButton")

				Discord.Name = "Discord"
				Discord.Parent = Section_1
				Discord.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Discord.BackgroundTransparency = Transparency
				Discord.BorderColor3 = Color3.fromRGB(0,0,0)
				Discord.BorderSizePixel = 0
				Discord.Size = UDim2.new(1, 0,0, 50)
				Discord.ClipsDescendants = true

				UICorner_1.Parent = Discord
				UICorner_1.CornerRadius = UDim.new(0,4)

				Frame_1.Parent = Discord
				Frame_1.AnchorPoint = Vector2.new(0, 0.5)
				Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame_1.BackgroundTransparency = 1
				Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame_1.BorderSizePixel = 0
				Frame_1.Position = UDim2.new(0, 0,0.5, 0)
				Frame_1.Size = UDim2.new(1, 0,1, 0)

				UIListLayout_1.Parent = Frame_1
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Frame_1
				UIPadding_1.PaddingLeft = UDim.new(0,60)
				UIPadding_1.PaddingRight = UDim.new(0,13)

				TextLabel_1.Parent = Frame_1
				TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextLabel_1.BackgroundTransparency = 1
				TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextLabel_1.BorderSizePixel = 0
				TextLabel_1.LayoutOrder = 1
				TextLabel_1.Size = UDim2.new(1, 0,0, 16)
				TextLabel_1.Font = Enum.Font.GothamBold
				TextLabel_1.RichText = true
				TextLabel_1.Text = '<i>'..Desc..'</i>'
				TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextLabel_1.TextSize = 11
				TextLabel_1.TextTransparency = 0.5
				TextLabel_1.TextWrapped = true
				TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left

				Title_1.Name = "Title"
				Title_1.Parent = Frame_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(1, 0,0, 16)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.RichText = true
				Title_1.Text = '<i>'..Title..'</i>'
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextWrapped = true
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient_1.Parent = Discord
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 34, 40))}

				Icon_1.Name = "Icon"
				Icon_1.Parent = Discord
				Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Icon_1.BackgroundTransparency = 1
				Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Icon_1.BorderSizePixel = 0
				Icon_1.Size = UDim2.new(0, 60,0, 50)

				IconDiscord_1.Name = "IconDiscord"
				IconDiscord_1.Parent = Icon_1
				IconDiscord_1.AnchorPoint = Vector2.new(0.5, 0.5)
				IconDiscord_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				IconDiscord_1.BackgroundTransparency = 1
				IconDiscord_1.BorderColor3 = Color3.fromRGB(0,0,0)
				IconDiscord_1.BorderSizePixel = 0
				IconDiscord_1.Position = UDim2.new(0.5, 0,0.5, 0)
				IconDiscord_1.Size = UDim2.new(0, 30,0, 25)
				IconDiscord_1.Image = gl(Icon)
				IconDiscord_1.ScaleType = Enum.ScaleType.Fit

				Frame_2.Parent = Discord
				Frame_2.AnchorPoint = Vector2.new(1, 0.5)
				Frame_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame_2.BackgroundTransparency = 1
				Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame_2.BorderSizePixel = 0
				Frame_2.Position = UDim2.new(1, 0,0.5, 0)
				Frame_2.Size = UDim2.new(0, 100,0.800000012, 0)

				UIPadding_2.Parent = Frame_2
				UIPadding_2.PaddingRight = UDim.new(0,13)

				ImageLabel_1.Parent = Frame_2
				ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(1, 0,0.5, 0)
				ImageLabel_1.Rotation = 270
				ImageLabel_1.Size = UDim2.new(0, 15,0, 15)
				ImageLabel_1.Image = "rbxassetid://112715466942614"
				ImageLabel_1.ImageTransparency = 0.5

				TextLabel_2.Name = "TextLabel"
				TextLabel_2.Parent = Frame_2
				TextLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextLabel_2.BackgroundTransparency = 1
				TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
				TextLabel_2.BorderSizePixel = 0
				TextLabel_2.Size = UDim2.new(1, 0,1, 0)
				TextLabel_2.Font = Enum.Font.GothamBold
				TextLabel_2.RichText = true
				TextLabel_2.Text = "<i><u>Click Here</u></i>"
				TextLabel_2.TextColor3 = Color3.fromRGB(255,255,255)
				TextLabel_2.TextSize = 14
				TextLabel_2.TextTransparency = 0.5
				TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

				TextLabel_2.MouseButton1Click:Connect(function()
					jc(Click, Discord)
					pcall(Callback)
					tw({v = TextLabel_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0}}):Play()
					tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 0}}):Play()
					task.wait(0.1)
					tw({v = TextLabel_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.5}}):Play()
					tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 0.5}}):Play()
				end)
			end

			function Main:Image(info)
				local Icon = info.Icon
				local Size = info.Size
				local Image_1 = Instance.new("ImageLabel")
				local UICorner_1 = Instance.new("UICorner")

				Image_1.Parent = Section_1
				Image_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Image_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Image_1.BackgroundTransparency = 1
				Image_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Image_1.BorderSizePixel = 0
				Image_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Image_1.Size = Size
				Image_1.Image = gl(Icon)
				Image_1.ScaleType = Enum.ScaleType.Crop

				UICorner_1.Parent = Image_1
				UICorner_1.CornerRadius = UDim.new(0,4)
			end

			function Main:Line()
				local Line_1 = Instance.new("Frame")
				Line_1.Name = "Line"
				Line_1.Parent = Section_1
				Line_1.AnchorPoint = Vector2.new(0, 1)
				Line_1.BackgroundColor3 = Color3.fromRGB(54, 58, 69)
				Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Line_1.BorderSizePixel = 0
				Line_1.Position = UDim2.new(0, 0,1, 0)
				Line_1.Size = UDim2.new(1, 0,0, 2)
			end

			return Main
		end	
		return Sections
	end
	function Library.Tabs:Notify(info)
		local Title = info.Title
		local Desc = info.Desc or ''
		local Time = info.Time or 5
		local Button = info.Button or {}
		local Notifytemple_1 = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local UIStroke_1 = Instance.new("UIStroke")
		local Frame_1 = Instance.new("Frame")
		local UIPadding_1 = Instance.new("UIPadding")
		local Desc_1 = Instance.new("TextLabel")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local Title_1 = Instance.new("TextLabel")
		local ImageLabel_1 = Instance.new("ImageLabel")

		local Background = Instance.new("Frame")
		local UIListLayoutBackgorund = Instance.new("UIListLayout")

		Background.Name = "Background"
		Background.Parent = Notification
		Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Background.BackgroundTransparency = 1.000
		Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(0, 100, 0, 0)

		UIListLayoutBackgorund.Name = "UIListLayoutBackgorund"
		UIListLayoutBackgorund.Parent = Background
		UIListLayoutBackgorund.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayoutBackgorund.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayoutBackgorund.VerticalAlignment = Enum.VerticalAlignment.Bottom
		UIListLayoutBackgorund.Padding = UDim.new(0, 8)

		Notifytemple_1.Name = "Notifytemple"
		Notifytemple_1.Parent = Background
		Notifytemple_1.BackgroundColor3 = Color3.fromRGB(28,28,30)
		Notifytemple_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Notifytemple_1.BorderSizePixel = 0
		Notifytemple_1.Size = UDim2.new(0, 0,0, 0)
		Notifytemple_1.ClipsDescendants = true

		UICorner_1.Parent = Notifytemple_1

		UIStroke_1.Parent = Notifytemple_1
		UIStroke_1.Color = Color3.fromRGB(41,42,45)
		UIStroke_1.Thickness = 2

		Frame_1.Parent = Notifytemple_1
		Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_1.BackgroundTransparency = 1
		Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_1.BorderSizePixel = 0
		Frame_1.Size = UDim2.new(1, 0,1, 0)

		UIPadding_1.Parent = Frame_1
		UIPadding_1.PaddingBottom = UDim.new(0,5)
		UIPadding_1.PaddingLeft = UDim.new(0,10)
		UIPadding_1.PaddingRight = UDim.new(0,10)
		UIPadding_1.PaddingTop = UDim.new(0,5)

		Desc_1.Name = "Desc"
		Desc_1.Parent = Frame_1
		Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Desc_1.BackgroundTransparency = 1
		Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Desc_1.BorderSizePixel = 0
		Desc_1.LayoutOrder = 1
		Desc_1.Size = UDim2.new(1, 0,0, 65)
		Desc_1.Font = Enum.Font.Gotham
		Desc_1.Text = Desc
		Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
		Desc_1.TextSize = 12
		Desc_1.TextTransparency = 0.5
		Desc_1.TextXAlignment = Enum.TextXAlignment.Left
		Desc_1.TextYAlignment = Enum.TextYAlignment.Top
		Desc_1.TextWrapped = true

		UIListLayout_2.Parent = Frame_1
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

		Title_1.Name = "Title"
		Title_1.Parent = Frame_1
		Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_1.BackgroundTransparency = 1
		Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_1.BorderSizePixel = 0
		Title_1.Size = UDim2.new(1, 0,0, 20)
		Title_1.Font = Enum.Font.GothamBold
		Title_1.Text = Title
		Title_1.TextColor3 = Color3.fromRGB(255,255,255)
		Title_1.TextSize = 14
		Title_1.TextXAlignment = Enum.TextXAlignment.Left

		ImageLabel_1.Parent = Notifytemple_1
		ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
		ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_1.BackgroundTransparency = 1
		ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_1.BorderSizePixel = 0
		ImageLabel_1.Position = UDim2.new(1.5, 0,0.5, 0)
		ImageLabel_1.Size = UDim2.new(0, 200,0, 200)
		ImageLabel_1.Image = "rbxassetid://128185233852701"
		ImageLabel_1.ImageTransparency = 0.8999999761581421

		tw({v = Background, t = 1.3, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 100,0, 80)}}):Play()
		local f = tw({v = Notifytemple_1, t = 0.3, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 150,0, 0)}})
		f:Play()
		f.Completed:Connect(function()
			tw({v = Notifytemple_1, t = 1, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 150,0, 80)}}):Play()
		end)

		if type(Time) == "number" then
			local Cool_1 = Instance.new("Frame")
			local Cooldown_1 = Instance.new("Frame")
			local UIStroke_2 = Instance.new("UIStroke")
			local Cooldown_2 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UICorner_3 = Instance.new("UICorner")
			local UIPadding_2 = Instance.new("UIPadding")

			Cool_1.Name = "Cool"
			Cool_1.Parent = Notifytemple_1
			Cool_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Cool_1.BackgroundTransparency = 1
			Cool_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Cool_1.BorderSizePixel = 0
			Cool_1.Size = UDim2.new(1, 0,1, 0)

			Cooldown_1.Name = "Cooldown"
			Cooldown_1.Parent = Cool_1
			Cooldown_1.AnchorPoint = Vector2.new(0, 1)
			Cooldown_1.BackgroundColor3 = Color3.fromRGB(41,42,45)
			Cooldown_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Cooldown_1.BorderSizePixel = 0
			Cooldown_1.Position = UDim2.new(0, 0,1, 0)
			Cooldown_1.Size = UDim2.new(1, 0,0, 4)

			UIStroke_2.Parent = Cooldown_1
			UIStroke_2.Color = Color3.fromRGB(41,42,45)
			UIStroke_2.Thickness = 3

			Cooldown_2.Name = "Cooldown"
			Cooldown_2.Parent = Cool_1
			Cooldown_2.AnchorPoint = Vector2.new(0, 1)
			Cooldown_2.BackgroundColor3 = Color3.fromRGB(161,161,161)
			Cooldown_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Cooldown_2.BorderSizePixel = 0
			Cooldown_2.Position = UDim2.new(0, 0,1, 0)
			Cooldown_2.Size = UDim2.new(1, 0,0, 4)

			UICorner_2.Parent = Cooldown_1

			UICorner_3.Parent = Cooldown_2

			UIPadding_2.Parent = Cool_1
			UIPadding_2.PaddingBottom = UDim.new(0,5)
			UIPadding_2.PaddingLeft = UDim.new(0,5)
			UIPadding_2.PaddingRight = UDim.new(0,5)

			task.spawn(function()
				for i = Time, 1, -1 do
					local sizeRatio = i / Time 
					tw({v = Cooldown_2, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(sizeRatio, 0, 0, 4)}}):Play()
					task.wait(1)
				end
				local f = tw({v = Notifytemple_1, t = 1, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 150,0, 0)}})
				f:Play()
				f.Completed:Connect(function()
					tw({v = Background, t = 0.3, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 100,0, 0)}}):Play()
					local t = tw({v = Notifytemple_1, t = 0.3, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 0,0, 0)}})
					t:Play()
					t.Completed:Connect(function()
						Notifytemple_1:Destroy()
					end)
				end)
			end)
		end
	end

	do
		local Closeui = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local UIStroke_1 = Instance.new("UIStroke")
		local ImageLabel_1 = Instance.new("ImageLabel")
		local Click_1 = Instance.new("TextButton")

		Closeui.Name = "Closeui"
		Closeui.Parent = ScreenGui
		Closeui.AnchorPoint = Vector2.new(0, 1)
		Closeui.BackgroundColor3 = Color3.fromRGB(36, 39, 46)
		Closeui.BorderColor3 = Color3.fromRGB(0,0,0)
		Closeui.BorderSizePixel = 0
		Closeui.Position = UDim2.new(0.00999999978, 0,0.99000001, 0)
		Closeui.Size = UDim2.new(0, 45,0, 45)

		UICorner_1.Parent = Closeui
		UICorner_1.CornerRadius = UDim.new(1,0)


		UIStroke_1.Parent = Closeui
		UIStroke_1.Color = Color3.fromRGB(54, 58, 69)
		UIStroke_1.Thickness = 4
		UIStroke_1.Transparency = 0.7

		game:GetService("RunService").RenderStepped:Connect(function()
			local fps = 1 / game:GetService("RunService").RenderStepped:Wait() -- คำนวณ FPS
			if fps > 45 then
				tw({v = UIStroke_1, t = 1, s = Enum.EasingStyle.Back, d = "Out", g = {Color = Color3.fromRGB(0, 170, 255)}}):Play()
			elseif fps > 29 then
				tw({v = UIStroke_1, t = 1, s = Enum.EasingStyle.Back, d = "Out", g = {Color = Color3.fromRGB(255, 255, 0)}}):Play()
			elseif fps > 15 then
				tw({v = UIStroke_1, t = 1, s = Enum.EasingStyle.Back, d = "Out", g = {Color = Color3.fromRGB(255, 165, 0)}}):Play()
			elseif fps > 0 then
				tw({v = UIStroke_1, t = 1, s = Enum.EasingStyle.Back, d = "Out", g = {Color = Color3.fromRGB(255, 0, 0)}}):Play()
			end
			task.wait(0.4)
		end)

		local UserInputService = game:GetService("UserInputService")

		local function Resize(DragFrame, Frame)
			local resizing = false
			local startSize, startMouse
			local function StartResize(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					resizing = true
					startSize = Frame.Size
					startMouse = UserInputService:GetMouseLocation()
				end
			end
			local function UpdateResize(input)
				if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local mouseDelta = UserInputService:GetMouseLocation() - startMouse
					local newSize = startSize + UDim2.new(0, mouseDelta.X, 0, mouseDelta.Y)
					newSize = UDim2.new(0, math.max(newSize.X.Offset, 540), 0, math.max(newSize.Y.Offset, 350))
					Frame.Size = newSize
				end
			end
			local function EndResize(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					resizing = false
				end
			end
			DragFrame.InputBegan:Connect(StartResize)
			UserInputService.InputChanged:Connect(UpdateResize)
			UserInputService.InputEnded:Connect(EndResize)
		end
		Resize(resize, Background_1)


		ImageLabel_1.Parent = Closeui
		ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_1.BackgroundTransparency = 1
		ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_1.BorderSizePixel = 0
		ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
		ImageLabel_1.Size = UDim2.new(0.9, 0,0.9, 0)
		ImageLabel_1.Image = gl(Logo)

		Click_1.Name = "Click"
		Click_1.Parent = Closeui
		Click_1.Active = true
		Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Click_1.BackgroundTransparency = 1
		Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Click_1.BorderSizePixel = 0
		Click_1.Size = UDim2.new(1, 0,1, 0)
		Click_1.Font = Enum.Font.SourceSans
		Click_1.Text = ""
		Click_1.TextSize = 14

		lak2(Click_1, Closeui)
		local OpenUI = true
		local function o()
			if OpenUI then
				OpenUI = false
				Background_1.Visible = false
				frameef.Visible = false
				for i = 1,2 do
					BlurFrame2[i]:Destroy()
				end
			else
				OpenUI = true
				Background_1.Visible = true
				frameef.Visible = true
				BlurFrame2 = init(Background_1)
			end
			tw({v = Closeui, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {BackgroundColor3 = Color3.fromRGB(31, 34, 40)}}):Play()
			tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {Size = UDim2.new(0.80, 0, 0.80, 0)}}):Play()
			delay(0.016, function()
				tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {Size = UDim2.new(0.9, 0, 0.9, 0)}}):Play()
				tw({v = Closeui, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {BackgroundColor3 = Color3.fromRGB(36, 39, 46)}}):Play()
			end)
		end
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Keycode then
				o()
			end
		end)
		Click_1.MouseButton1Click:Connect(o)
	end

	return Library.Tabs
end

return Library