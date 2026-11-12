-- anti hub universal UI library
-- local Lib = loadstring(game:HttpGet("URL_RAW_DESTE_ARQUIVO"))()
-- Win = Lib:CreateWindow{Name=, Accent=, ToggleKey=, Scale=}
-- Cat = Win:AddCategory{Name=, Icon="rbxassetid://..."}   Prev = Cat:AddPreview{Title=, User=}
-- Tab = Cat:AddTab("nome")
-- Tab/Expand: AddToggle AddSlider AddDropdown AddButton AddLabel AddExpand
local Lib = {}

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local PL = game:GetService("Players")
local RS = game:GetService("RunService")

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local W, BG, PANEL, ROW, ROW2, LINE, DIM, MUTED = C(255,255,255), C(13,14,18), C(18,19,24), C(24,25,31), C(30,31,39), C(38,40,48), C(150,155,168), C(100,105,118)
local TXT, RED, GREEN, BLACK = C(225,228,235), C(230,80,80), C(60,200,80), C(0,0,0)
local HOVER = ROW:Lerp(W, 0.04)
local FONT, FONTB = Enum.Font.Gotham, Enum.Font.GothamBold
local LEFT, CENTER, RIGHT = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right

local function tween(o, props, t) return TS:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props) end
local function play(o, props, t) local tw = tween(o, props, t) tw:Play() return tw end
local function tw(o, props, t) if not pcall(play, o, props, t) then for k, v in props do o[k] = v end end end
local function new(cls, props, parent)
	local o = Instance.new(cls)
	for k, v in props do o[k] = v end
	o.Parent = parent
	return o
end
local function round(o, r) new("UICorner", {CornerRadius = UDim.new(0, r or 6)}, o) return o end
local function stroke(o, c, t) return new("UIStroke", {Color = c or LINE, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o) end
local function label(parent, t, size, color, pos, sz, xa, font)
	return new("TextLabel", {BackgroundTransparency = 1, Text = t, TextSize = size, TextColor3 = color, Font = font or FONT, Position = pos, Size = sz, TextXAlignment = xa or LEFT}, parent)
end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local function fire(f, ...) if f then task.spawn(f, ...) end end

function Lib:CreateWindow(cfg)
	cfg = cfg or {}
	local ACC = cfg.Accent or C(235, 60, 60)
	local NAME = cfg.Name or "ui library"
	local KEY = cfg.ToggleKey or Enum.KeyCode.RightShift
	local Win = {Flags = {}, Notifications = true}
	local accentEls, conns, cats, activeCat = {}, {}, {}, nil
	Win._extraConns = {}
	local function track(sig, f) local c = sig:Connect(f) table.insert(conns, c) return c end

	-- gui
	local gui = Instance.new("ScreenGui")
	gui.Name = cfg.GuiName or "antihub" gui.ResetOnSpawn = false
	gui.DisplayOrder = 999
	gui.IgnoreGuiInset = true
	-- PlayerGui primeiro (funciona no mobile); depois gethui/CoreGui como fallback
	local pg = PL.LocalPlayer:FindFirstChildOfClass("PlayerGui") or PL.LocalPlayer:WaitForChild("PlayerGui", 10)
	gui.Parent = pg
	if not gui.Parent and gethui then pcall(function() gui.Parent = gethui() end) end
	if not gui.Parent then pcall(function() gui.Parent = game:GetService("CoreGui") end) end

	local win = new("Frame", {
		Size = UDim2.fromOffset(700, 452), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = BG, BorderSizePixel = 0,
	}, gui)
	round(win, 12) stroke(win, LINE, 1)
	local winCorner = win.UICorner
	local winScale = new("UIScale", {Scale = 1}, win)
	local open, mini, miniTok, lastPos, scalePct = true, false, 0, win.Position, 100

	Win.ScalePct = 100
	local function setScale(v)
		scalePct = math.clamp(v, 50, 150)
		Win.ScalePct = scalePct
		if open and not mini then winScale.Scale = scalePct / 100 end
	end
	if cfg.Scale then setScale(cfg.Scale) else
		local okV, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
		if okV and vp and vp.X > 0 and (vp.X < 760 or vp.Y < 480) then setScale(math.floor(math.min(vp.X / 760, vp.Y / 480) * 100)) end
	end

	local topLine = new("Frame", {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 0, 2), BackgroundColor3 = W, BorderSizePixel = 0}, win)
	local topGrad = new("UIGradient", {Color = ColorSequence.new(ACC, BG)}, topLine)
	table.insert(accentEls, {fn = function(c) topGrad.Color = ColorSequence.new(c, BG) end})

	local bar = new("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1}, win)
	local dotMark = new("Frame", {Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(24, 26), BackgroundColor3 = ACC, BorderSizePixel = 0}, bar) round(dotMark, 999)
	table.insert(accentEls, {el = dotMark, prop = "BackgroundColor3"})
	local tw0 = #NAME * 8 + 6
	label(bar, NAME, 14, W, UDim2.fromOffset(36, 18), UDim2.fromOffset(tw0, 22), LEFT, FONTB)
	local function barBtn(txt, x, size, hoverCol)
		local b = new("TextButton", {Text = txt, Font = FONTB, TextSize = size, TextColor3 = MUTED, BackgroundColor3 = ROW, BackgroundTransparency = 1, AutoButtonColor = false, Position = UDim2.fromOffset(x, 15), Size = UDim2.fromOffset(28, 28), ZIndex = 5}, bar) round(b, 7)
		b.MouseEnter:Connect(function() b.TextColor3 = hoverCol play(b, {BackgroundTransparency = 0}, 0.1) end)
		b.MouseLeave:Connect(function() b.TextColor3 = MUTED play(b, {BackgroundTransparency = 1}, 0.1) end)
		return b
	end
	local minBtn = barBtn("−", 36 + tw0 + 8, 18, W)
	local closeBtn = barBtn("✕", 36 + tw0 + 40, 12, RED)

	-- arrastar (mouse + toque)
	local drag, ds, sp
	bar.InputBegan:Connect(function(i) if isPress(i) then drag, ds, sp = true, i.Position, win.Position end end)
	track(UIS.InputChanged, function(i)
		if drag and isMove(i) then
			local d = i.Position - ds
			win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
	track(UIS.InputEnded, function(i) if isPress(i) then drag = false end end)

	-- painel esquerdo
	local left = new("Frame", {Position = UDim2.fromOffset(14, 104), Size = UDim2.fromOffset(672, 336), BackgroundColor3 = PANEL, BorderSizePixel = 0}, win) round(left, 10) stroke(left, LINE, 1)
	local hdr = label(left, "", 12, ACC, UDim2.fromOffset(16, 10), UDim2.fromOffset(300, 18), LEFT, FONTB)
	table.insert(accentEls, {el = hdr, prop = "TextColor3"})
	new("Frame", {Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -32, 0, 1), BackgroundColor3 = LINE, BorderSizePixel = 0}, left)
	local underline = new("Frame", {Size = UDim2.fromOffset(20, 3), Position = UDim2.fromOffset(22, 90), BackgroundColor3 = ACC, BorderSizePixel = 0, Visible = false}, win) round(underline, 2)
	table.insert(accentEls, {el = underline, prop = "BackgroundColor3"})

	local function applyAccent(col)
		ACC = col
		for i = #accentEls, 1, -1 do
			local t = accentEls[i]
			if t.el and t.el.Parent == nil then table.remove(accentEls, i)
			elseif t.fn then t.fn(col)
			else t.el[t.prop] = col end
		end
		if Win._paintCats then Win._paintCats() end
	end

	-- dropdown
	local ddBack, ddPop
	local function closeDD() if ddPop then ddPop:Destroy() ddBack:Destroy() ddPop, ddBack = nil, nil end end
	local function openDropdown(btn, st)
		closeDD()
		ddBack = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 59}, win)
		ddBack.MouseButton1Click:Connect(closeDD)
		local pos = btn.AbsolutePosition - win.AbsolutePosition
		local h = #st.opts * 28 + 8
		local y = pos.Y + btn.AbsoluteSize.Y + 4
		if y + h > 446 then y = math.max(8, pos.Y - h - 4) end
		ddPop = new("Frame", {Position = UDim2.fromOffset(pos.X, y), Size = UDim2.fromOffset(btn.AbsoluteSize.X, h), BackgroundColor3 = ROW2, BorderSizePixel = 0, ZIndex = 60}, win) round(ddPop, 8) stroke(ddPop, LINE, 1)
		ddPop.BackgroundTransparency = 1 play(ddPop, {BackgroundTransparency = 0}, 0.12)
		new("UIListLayout", {Padding = UDim.new(0, 2)}, ddPop)
		new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4)}, ddPop)
		for i, o in st.opts do
			local isSel = i == st.idx
			local b = new("TextButton", {
				Text = "  " .. o, Size = UDim2.new(1, -8, 0, 26), BackgroundTransparency = 1, BackgroundColor3 = HOVER,
				TextXAlignment = LEFT, Font = isSel and FONTB or FONT, TextSize = 11, TextColor3 = isSel and ACC or W, AutoButtonColor = false, ZIndex = 61,
			}, ddPop) round(b, 4)
			b.MouseEnter:Connect(function() play(b, {BackgroundTransparency = 0}, 0.1) end)
			b.MouseLeave:Connect(function() play(b, {BackgroundTransparency = 1}, 0.1) end)
			b.MouseButton1Click:Connect(function() st.set(i) closeDD() end)
		end
	end

	-- color picker
	local picker, pickBack, pickTarget, hue, sat, val, grid, hb, svMark, hMark, hex, prev
	local cells, COLS, ROWS = {}, 18, 12
	local function apply()
		local col = Color3.fromHSV(hue, sat, val)
		pickTarget.color = col
		if pickTarget.swatch and pickTarget.swatch.Parent then pickTarget.swatch.BackgroundColor3 = col end
		hex.Text = "#" .. col:ToHex() prev.BackgroundColor3 = col
		svMark.Position = UDim2.fromOffset(sat * 180 - 5, (1 - val) * 108 - 5)
		hMark.Position = UDim2.fromOffset(hue * 180 - 2, -2)
		if pickTarget.onColor then pickTarget.onColor(col) end
	end
	local function paintSV() for _, c in cells do c.f.BackgroundColor3 = Color3.fromHSV(hue, c.s, c.v) end end
	local function closePicker() if picker then picker.Visible = false pickBack.Visible = false end end
	local function buildPicker()
		pickBack = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 79, Visible = false}, win)
		pickBack.MouseButton1Click:Connect(closePicker)
		picker = new("Frame", {Size = UDim2.fromOffset(204, 204), BackgroundColor3 = ROW2, BorderSizePixel = 0, ZIndex = 80, Visible = false}, win) round(picker, 10) stroke(picker, LINE, 1)
		grid = new("Frame", {Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(184, 112), BackgroundColor3 = W, BorderSizePixel = 0, ClipsDescendants = true}, picker) round(grid, 4)
		for j = 0, ROWS - 1 do for i = 0, COLS - 1 do
			table.insert(cells, {f = new("Frame", {Size = UDim2.new(1 / COLS, 0, 1 / ROWS, 0), Position = UDim2.fromScale(i / COLS, j / ROWS), BorderSizePixel = 0}, grid), s = i / (COLS - 1), v = 1 - j / (ROWS - 1)})
		end end
		svMark = new("Frame", {Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, BorderSizePixel = 0}, grid) round(svMark, 5) stroke(svMark, W, 2)
		hb = new("Frame", {Position = UDim2.fromOffset(10, 132), Size = UDim2.fromOffset(184, 12), BackgroundColor3 = W, BorderSizePixel = 0}, picker) round(hb, 6)
		local K = ColorSequenceKeypoint.new
		new("UIGradient", {Color = ColorSequence.new({K(0, C(255,0,0)), K(1/6, C(255,255,0)), K(2/6, C(0,255,0)), K(3/6, C(0,255,255)), K(4/6, C(0,0,255)), K(5/6, C(255,0,255)), K(1, C(255,0,0))})}, hb)
		hMark = new("Frame", {Size = UDim2.fromOffset(4, 16), BackgroundColor3 = W, BorderSizePixel = 0}, hb) round(hMark, 2) stroke(hMark, BLACK, 1)
		prev = new("Frame", {Position = UDim2.fromOffset(10, 158), Size = UDim2.fromOffset(30, 28), BorderSizePixel = 0}, picker) round(prev, 6) stroke(prev, LINE, 1)
		hex = new("TextBox", {Position = UDim2.fromOffset(48, 158), Size = UDim2.fromOffset(146, 28), BackgroundColor3 = BG, BorderSizePixel = 0, Text = "", Font = FONTB, TextSize = 12, TextColor3 = W, ClearTextOnFocus = false}, picker) round(hex, 6) stroke(hex, LINE, 1)
		hex.FocusLost:Connect(function()
			local ok, c = pcall(Color3.fromHex, hex.Text)
			if ok and c then hue, sat, val = c:ToHSV() paintSV() end
			apply()
		end)
		local mode
		local function setSV(p) sat = math.clamp((p.X - grid.AbsolutePosition.X) / 184, 0, 1) val = 1 - math.clamp((p.Y - grid.AbsolutePosition.Y) / 112, 0, 1) apply() end
		local function setH(p) hue = math.clamp((p.X - hb.AbsolutePosition.X) / 184, 0, 1) paintSV() apply() end
		grid.InputBegan:Connect(function(i) if isPress(i) then mode = "sv" setSV(i.Position) end end)
		hb.InputBegan:Connect(function(i) if isPress(i) then mode = "h" setH(i.Position) end end)
		track(UIS.InputChanged, function(i) if mode and isMove(i) then if mode == "sv" then setSV(i.Position) else setH(i.Position) end end end)
		track(UIS.InputEnded, function(i) if isPress(i) then mode = nil end end)
	end
	local function openPicker(st)
		if not picker then buildPicker() end
		pickTarget = st
		hue, sat, val = st.color:ToHSV()
		paintSV() apply()
		local sw, wp = st.swatch, win.AbsolutePosition
		picker.Position = UDim2.fromOffset(math.clamp(sw.AbsolutePosition.X - wp.X - 212, 8, 486), math.clamp(sw.AbsolutePosition.Y - wp.Y + 22, 8, 234))
		pickBack.Visible, picker.Visible = true, true
	end

	-- notificações
	local toasts = {}
	local function layoutToasts() for i, t in toasts do play(t, {Position = UDim2.new(1, -16, 1, -16 - (i - 1) * 38)}, 0.15) end end
	function Win:Notify(text, on)
		if not Win.Notifications then return end
		local t = new("Frame", {Size = UDim2.fromOffset(210, 30), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 230, 1, -16), BackgroundColor3 = PANEL, BorderSizePixel = 0, ZIndex = 100}, gui)
		round(t, 8) stroke(t, LINE, 1)
		local d = new("Frame", {Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = on == false and RED or on and GREEN or ACC, BorderSizePixel = 0, ZIndex = 101}, t) round(d, 999)
		label(t, text, 11, TXT, UDim2.fromOffset(26, 0), UDim2.new(1, -34, 1, 0), LEFT, FONTB).ZIndex = 101
		table.insert(toasts, 1, t)
		if #toasts > 4 then local o = table.remove(toasts) o:Destroy() end
		layoutToasts()
		task.delay(2, function()
			local i = table.find(toasts, t)
			if i then table.remove(toasts, i) end
			if t.Parent then
				play(t, {Position = UDim2.new(1, 240, t.Position.Y.Scale, t.Position.Y.Offset)}, 0.2)
				task.delay(0.22, function() t:Destroy() end)
			end
			layoutToasts()
		end)
	end

	----------------------------------------------------------------- componentes
	local function addToggle(parent, o, order)
		local name = o.Name or "Toggle"
		local st = {on = o.Default == true, color = o.Color, isAccent = o.Accent == true}
		local r = new("Frame", {Size = UDim2.new(1, -6, 0, 40), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = order}, parent) round(r, 8)
		label(r, name, 11, TXT, UDim2.fromOffset(42, 0), UDim2.new(1, -95, 1, 0), LEFT, FONTB)
		r.MouseEnter:Connect(function() play(r, {BackgroundColor3 = HOVER}, 0.12) end)
		r.MouseLeave:Connect(function() play(r, {BackgroundColor3 = ROW}, 0.12) end)
		local sq = new("TextButton", {Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = st.on and W or ROW2, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 12, 0.5, -10), ClipsDescendants = true, ZIndex = 2}, r) round(sq, 5)
		local sqs = stroke(sq, st.on and W or LINE, 1)
		local rip = new("Frame", {Size = UDim2.fromOffset(0, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = ACC, BorderSizePixel = 0, Visible = false, ZIndex = 3}, sq) round(rip, 999)
		local chk = new("TextLabel", {BackgroundTransparency = 1, Text = "✓", Font = FONTB, TextSize = 15, TextColor3 = BG, Size = UDim2.fromScale(1, 1), TextTransparency = st.on and 0 or 1, ZIndex = 4}, sq)
		local token = 0
		local function visual(on, anim)
			token += 1
			local my = token
			if on then
				if anim then
					sq.BackgroundColor3 = ROW2 chk.TextTransparency = 1
					rip.Size = UDim2.fromOffset(0, 0) rip.BackgroundColor3 = ACC rip.BackgroundTransparency = 0.2 rip.Visible = true
					play(rip, {Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 0}, 0.24)
					task.delay(0.18, function()
						if my ~= token or not chk.Parent then return end
						play(chk, {TextTransparency = 0}, 0.12) play(rip, {BackgroundTransparency = 1}, 0.15)
					end)
					task.delay(0.34, function()
						if my ~= token or not sq.Parent then return end
						rip.Visible = false sq.BackgroundColor3 = W chk.TextTransparency = 0 sqs.Color = W
					end)
				else
					rip.Visible = false sq.BackgroundColor3 = W chk.TextTransparency = 0 sqs.Color = W
				end
			else
				rip.Visible = false chk.TextTransparency = 1 sqs.Color = LINE
				if anim then play(sq, {BackgroundColor3 = ROW2}, 0.12) else sq.BackgroundColor3 = ROW2 end
			end
		end
		local obj = {}
		local function setOn(v, byClick)
			st.on = v
			if o.Flag then Win.Flags[o.Flag] = v end
			visual(v, byClick)
			if byClick then Win:Notify(name .. (v and " enabled" or " disabled"), v) end
			fire(o.Callback, v)
		end
		sq.MouseButton1Click:Connect(function() setOn(not st.on, true) end)
		if st.color then
			local sw = new("TextButton", {Text = "", Size = UDim2.fromOffset(24, 16), Position = UDim2.new(1, -34, 0.5, -8), BackgroundColor3 = st.color, AutoButtonColor = false, BorderSizePixel = 0}, r) round(sw, 4) stroke(sw, LINE, 1)
			st.swatch = sw
			st.onColor = function(c) if st.isAccent then applyAccent(c) end fire(o.ColorCallback, c) end
			sw.MouseButton1Click:Connect(function() openPicker(st) end)
		end
		function obj:Set(v) v = v and true or false if v ~= st.on then setOn(v, false) end end
		function obj:Get() return st.on end
		function obj:SetColor(c) st.color = c if st.swatch then st.swatch.BackgroundColor3 = c end fire(o.ColorCallback, c) end
		if o.Flag then Win.Flags[o.Flag] = st.on end
		fire(o.Callback, st.on)
		return obj
	end

	local function addSlider(parent, o, order)
		local mn, mx, step = o.Min or 0, o.Max or 100, o.Step or 1
		local st = {val = math.clamp(o.Default or mn, mn, mx)}
		local r = new("Frame", {Size = UDim2.new(1, -6, 0, 46), BackgroundTransparency = 1, LayoutOrder = order}, parent)
		label(r, o.Name or "Slider", 11, TXT, UDim2.fromOffset(4, 0), UDim2.new(1, -70, 0, 18), LEFT, FONTB)
		local valLbl = label(r, "", 11, MUTED, UDim2.new(1, -70, 0, 0), UDim2.fromOffset(66, 18), RIGHT, FONTB)
		local track0 = new("Frame", {Position = UDim2.fromOffset(4, 26), Size = UDim2.new(1, -8, 0, 12), BackgroundColor3 = ROW2, BorderSizePixel = 0}, r) round(track0, 6) stroke(track0, LINE, 1)
		local fill = new("Frame", {Size = UDim2.fromScale((st.val - mn) / (mx - mn), 1), BackgroundColor3 = ACC, BorderSizePixel = 0}, track0) round(fill, 6)
		table.insert(accentEls, {el = fill, prop = "BackgroundColor3"})
		local knob = new("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = W, BorderSizePixel = 0, ZIndex = 2}, fill) round(knob, 999)
		local kst = stroke(knob, ACC, 2)
		table.insert(accentEls, {fn = function(c) kst.Color = c end, el = kst})
		local pctLbl = new("TextLabel", {BackgroundTransparency = 1, Text = "", Font = FONTB, TextSize = 10, TextColor3 = W, Size = UDim2.new(1, -10, 1, 0), TextXAlignment = CENTER, ZIndex = 3}, fill)
		local function fmt(v) return tostring(math.floor(v * 10000 + 0.5) / 10000) end
		local function refresh()
			local a = (st.val - mn) / (mx - mn)
			valLbl.Text = fmt(st.val) .. (o.Suffix or "")
			pctLbl.Text = math.floor(a * 100 + 0.5) .. "%"
			pctLbl.Visible = a > 0.14
			fill.Size = UDim2.fromScale(a, 1)
		end
		refresh()
		local down = false
		local function setX(x)
			local a = math.clamp((x - track0.AbsolutePosition.X) / track0.AbsoluteSize.X, 0, 1)
			local v = math.clamp(math.floor((mn + (mx - mn) * a) / step + 0.5) * step, mn, mx)
			if v == st.val then return end
			st.val = v refresh()
			if o.Flag then Win.Flags[o.Flag] = v end
			fire(o.Callback, v)
		end
		track0.InputBegan:Connect(function(i) if isPress(i) then down = true setX(i.Position.X) play(knob, {Size = UDim2.fromOffset(18, 18)}, 0.1) end end)
		track(UIS.InputChanged, function(i) if down and isMove(i) then setX(i.Position.X) end end)
		track(UIS.InputEnded, function(i) if isPress(i) and down then down = false play(knob, {Size = UDim2.fromOffset(14, 14)}, 0.1) end end)
		local obj = {}
		function obj:Set(v) st.val = math.clamp(v, mn, mx) refresh() if o.Flag then Win.Flags[o.Flag] = st.val end fire(o.Callback, st.val) end
		function obj:Get() return st.val end
		if o.Flag then Win.Flags[o.Flag] = st.val end
		fire(o.Callback, st.val)
		return obj
	end

	local function addDropdown(parent, o, order)
		local opts = o.Options or {}
		local st = {opts = opts, idx = 1}
		if type(o.Default) == "number" then st.idx = math.clamp(o.Default, 1, #opts) elseif type(o.Default) == "string" then st.idx = table.find(opts, o.Default) or 1 end
		local r = new("Frame", {Size = UDim2.new(1, -6, 0, 54), BackgroundTransparency = 1, LayoutOrder = order}, parent)
		label(r, o.Name or "Dropdown", 10, MUTED, UDim2.fromOffset(4, 0), UDim2.new(1, 0, 0, 16), LEFT, FONTB)
		local b = new("TextButton", {Text = "  " .. tostring(opts[st.idx]), Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, BorderSizePixel = 0, TextXAlignment = LEFT, Font = FONTB, TextSize = 11, TextColor3 = W, AutoButtonColor = false}, r) round(b, 8) stroke(b, LINE, 1)
		label(b, "⌄", 12, MUTED, UDim2.new(1, -26, 0, 0), UDim2.fromOffset(16, 30), CENTER, FONTB)
		b.MouseEnter:Connect(function() play(b, {BackgroundColor3 = HOVER}, 0.1) end)
		b.MouseLeave:Connect(function() play(b, {BackgroundColor3 = ROW}, 0.1) end)
		b.MouseButton1Click:Connect(function() openDropdown(b, st) end)
		st.set = function(i)
			st.idx = i b.Text = "  " .. tostring(opts[i])
			if o.Flag then Win.Flags[o.Flag] = opts[i] end
			fire(o.Callback, opts[i], i)
		end
		local obj = {}
		function obj:Set(v) local i = type(v) == "number" and v or table.find(opts, v) if i and opts[i] then st.set(i) end end
		function obj:Get() return opts[st.idx], st.idx end
		if o.Flag then Win.Flags[o.Flag] = opts[st.idx] end
		fire(o.Callback, opts[st.idx], st.idx)
		return obj
	end

	local function addButton(parent, o, order)
		local b = new("TextButton", {Text = o.Name or "Button", Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = ROW, BorderSizePixel = 0, Font = FONTB, TextSize = 11, TextColor3 = TXT, AutoButtonColor = false, LayoutOrder = order}, parent) round(b, 8) stroke(b, LINE, 1)
		b.MouseEnter:Connect(function() play(b, {BackgroundColor3 = HOVER}, 0.1) end)
		b.MouseLeave:Connect(function() play(b, {BackgroundColor3 = ROW}, 0.1) end)
		b.MouseButton1Click:Connect(function()
			b.BackgroundColor3 = ACC play(b, {BackgroundColor3 = HOVER}, 0.3)
			fire(o.Callback)
		end)
		local obj = {}
		function obj:SetText(t) b.Text = t end
		return obj
	end

	local makeSection
	makeSection = function(container)
		local sec, n = {}, 0
		local function nx() n += 1 return n end
		function sec:AddToggle(o) return addToggle(container, o or {}, nx()) end
		function sec:AddSlider(o) return addSlider(container, o or {}, nx()) end
		function sec:AddDropdown(o) return addDropdown(container, o or {}, nx()) end
		function sec:AddButton(o) return addButton(container, o or {}, nx()) end
		function sec:AddLabel(text)
			local l = label(container, text or "", 10, MUTED, UDim2.new(), UDim2.new(1, -6, 0, 18), LEFT, FONTB) l.LayoutOrder = nx()
			local obj = {} function obj:SetText(t) l.Text = t end return obj
		end
		function sec:AddExpand(o)
			if type(o) == "string" then o = {Name = o} end
			local st = {open = o.Open == true}
			local ord = nx() nx()
			local r = new("Frame", {Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = ord}, container) round(r, 8)
			local arrow = label(r, "▸", 13, MUTED, UDim2.fromOffset(12, 0), UDim2.fromOffset(18, 38), LEFT, FONTB)
			label(r, o.Name or "Expand", 11, TXT, UDim2.fromOffset(32, 0), UDim2.new(1, -40, 1, 0), LEFT, FONTB)
			r.MouseEnter:Connect(function() play(r, {BackgroundColor3 = HOVER}, 0.12) end)
			r.MouseLeave:Connect(function() play(r, {BackgroundColor3 = ROW}, 0.12) end)
			local inner = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = ord + 1, Visible = st.open}, container)
			new("UIPadding", {PaddingLeft = UDim.new(0, 20)}, inner)
			new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, inner)
			local function refresh()
				inner.Size = UDim2.new(1, 0, 0, 0)
				inner.AutomaticSize = st.open and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
				inner.Visible = st.open
				arrow.Text = st.open and "▾" or "▸"
				arrow.TextColor3 = st.open and ACC or MUTED
			end
			refresh()
			r.InputBegan:Connect(function(i) if isPress(i) then st.open = not st.open refresh() end end)
			return makeSection(inner)
		end
		return sec
	end

	----------------------------------------------------------------- categorias / abas
	local function paintCats()
		for _, c in cats do
			c.img.ImageColor3 = c == activeCat and ACC or W
			c.img.ImageTransparency = c == activeCat and 0 or 0.55
			c.btn.TextColor3 = c == activeCat and ACC or MUTED
		end
	end
	Win._paintCats = paintCats

	local function selectTab(cat, tab, instant)
		cat.activeTab = tab
		closeDD() closePicker()
		for _, c in cats do for _, t in c.tabs do t.page.Visible = t == tab end end
		for _, t in cat.tabs do
			t.b.TextColor3 = t == tab and W or MUTED
			t.bg.BackgroundTransparency = t == tab and 0 or 1
		end
		hdr.Text = tab.Name
		underline.Visible = true
		local pos, size = UDim2.fromOffset(tab.x, 90), UDim2.fromOffset(tab.w, 3)
		if instant then underline.Position = pos underline.Size = size else play(underline, {Position = pos, Size = size}, 0.2) end
	end

	local function selectCat(cat)
		activeCat = cat
		closeDD() closePicker()
		for _, c in cats do
			for _, t in c.tabs do t.bg.Visible = c == cat end
			if c.right then c.right.Visible = c == cat end
		end
		paintCats()
		tw(left, {Size = UDim2.fromOffset(cat.right and 404 or 672, 336)}, 0.2)
		local t = cat.activeTab or cat.tabs[1]
		if t then selectTab(cat, t, true) else
			hdr.Text = "" underline.Visible = false
			for _, c in cats do for _, x in c.tabs do x.page.Visible = false end end
		end
	end

	function Win:AddCategory(o)
		o = type(o) == "string" and {Name = o} or o or {}
		local cat = {tabs = {}, tx = 22, Name = o.Name}
		local btn = new("TextButton", {Text = o.Glyph or "", Font = FONTB, TextSize = 17, TextColor3 = MUTED, BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.fromOffset(30, 30)}, win)
		local img = new("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(5, 5), ScaleType = Enum.ScaleType.Fit, ImageColor3 = W, Image = o.Icon or ""}, btn)
		cat.btn, cat.img = btn, img
		if o.Icon and o.Icon ~= "" then
			-- se o asset não carregar no executor, mostra o glifo no lugar
			-- 1) rbxassetid (Image)  2) rbxthumb do mesmo id (Decal)  3) glifo
			local aid = string.match(o.Icon, "(%d+)")
			task.delay(1.5, function()
				if img.IsLoaded or not aid then return end
				img.Image = "rbxthumb://type=Asset&id=" .. aid .. "&w=150&h=150"
				task.delay(2, function()
					if not img.IsLoaded then img.Visible = false btn.Text = o.Glyph or "●" btn.TextColor3 = MUTED end
				end)
			end)
		else
			img.Visible = false btn.Text = o.Glyph or "●"
		end
		table.insert(cats, cat)
		for i, c in cats do c.btn.Position = UDim2.new(1, -(22 + (#cats - i + 1) * 36), 0, 14) end
		btn.MouseButton1Click:Connect(function() selectCat(cat) end)
		btn.MouseEnter:Connect(function() if cat ~= activeCat then img.ImageTransparency = 0 btn.TextColor3 = W end end)
		btn.MouseLeave:Connect(paintCats)
		if not activeCat then selectCat(cat) else paintCats() end

		function cat:AddTab(name)
			local w = #name * 7.6 + 16
			local bg = new("Frame", {BackgroundColor3 = C(28, 34, 46), BackgroundTransparency = 1, Size = UDim2.fromOffset(w, 24), Position = UDim2.fromOffset(cat.tx, 62), BorderSizePixel = 0, Visible = activeCat == cat}, win) round(bg, 6)
			local b = new("TextButton", {Text = name, Font = FONTB, TextSize = 11, BackgroundTransparency = 1, TextColor3 = MUTED, Size = UDim2.fromOffset(w, 24), ZIndex = 2}, bg)
			local page = new("ScrollingFrame", {
				Position = UDim2.fromOffset(10, 42), Size = UDim2.new(1, -20, 1, -52), BackgroundTransparency = 1, BorderSizePixel = 0,
				ScrollBarThickness = 3, ScrollBarImageColor3 = LINE, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
			}, left)
			new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
			new("UIPadding", {PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 6)}, page)
			local tab = makeSection(page)
			tab.Name, tab.bg, tab.b, tab.page, tab.x, tab.w = name, bg, b, page, cat.tx, w
			cat.tx += w + 8
			table.insert(cat.tabs, tab)
			b.MouseButton1Click:Connect(function() selectTab(cat, tab) end)
			b.MouseEnter:Connect(function() if tab ~= cat.activeTab then b.TextColor3 = DIM end end)
			b.MouseLeave:Connect(function() if tab ~= cat.activeTab then b.TextColor3 = MUTED end end)
			if activeCat == cat and not cat.activeTab then selectTab(cat, tab, true) end
			return tab
		end

function cat:AddPreview(po)
			po = po or {}
			local right = new("Frame", {Position = UDim2.fromOffset(428, 104), Size = UDim2.fromOffset(258, 336), BackgroundColor3 = PANEL, BorderSizePixel = 0, Visible = activeCat == cat}, win) round(right, 10) stroke(right, LINE, 1)
			local rTitle = label(right, po.Title or "ESP preview", 11, ACC, UDim2.fromOffset(16, 10), UDim2.fromOffset(200, 16), LEFT, FONTB)
			table.insert(accentEls, {el = rTitle, prop = "TextColor3"})
			new("Frame", {Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -32, 0, 1), BackgroundColor3 = LINE, BorderSizePixel = 0}, right)
			local view = new("Frame", {Position = UDim2.fromOffset(12, 42), Size = UDim2.fromOffset(234, 282), BackgroundTransparency = 1}, right)
			local nameLbl = label(view, "", 10, W, UDim2.new(), UDim2.new(1, 0, 0, 14), CENTER, FONTB)
			-- avatar 3D real: ViewportFrame + clone do personagem, gira sozinho
			local vpf = new("ViewportFrame", {Position = UDim2.fromOffset(7, 18), Size = UDim2.fromOffset(220, 244), BackgroundTransparency = 1, BorderSizePixel = 0, Ambient = C(200, 200, 200), LightColor = W, LightDirection = Vector3.new(-1, -1, -1)}, view)
			local wmodel = new("WorldModel", {}, vpf)
			local cam = new("Camera", {FieldOfView = 30}, vpf)
			vpf.CurrentCamera = cam
			local box = new("Frame", {Position = UDim2.fromOffset(62, 26), Size = UDim2.fromOffset(110, 212), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3}, view) stroke(box, W, 1)
			local hpBar = new("Frame", {Position = UDim2.fromOffset(55, 26), Size = UDim2.fromOffset(3, 212), BackgroundColor3 = GREEN, BorderSizePixel = 0, ZIndex = 3}, view) round(hpBar, 2)
			local distLbl = label(view, "[ 42m ]", 9, MUTED, UDim2.fromOffset(0, 266), UDim2.new(1, 0, 0, 14), CENTER, FONTB)
			cat.right = right
			if activeCat == cat then tw(left, {Size = UDim2.fromOffset(404, 336)}, 0.2) end

			local P = {s = {Boxes = true, Names = true, Health = true, Distance = false, Chams = false, ChamsOnly = false, ChamsColor = C(170, 140, 50)}}
			local model, hl, spinConn, angle, loadId = nil, nil, nil, 0, 0

			local function refresh()
				box.Visible, nameLbl.Visible, hpBar.Visible, distLbl.Visible = P.s.Boxes, P.s.Names, P.s.Health, P.s.Distance
				if hl then
					hl.Enabled = P.s.Chams
					hl.FillColor = P.s.ChamsColor
					hl.OutlineColor = P.s.ChamsColor
					hl.FillTransparency = P.s.ChamsOnly and 0.75 or 0.4
					hl.DepthMode = P.s.ChamsOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
				end
			end
			-- Boxes Names Health Distance Chams ChamsOnly ChamsColor
			function P:Set(k, v) P.s[k] = v refresh() end

			local function clear()
				if spinConn then spinConn:Disconnect() spinConn = nil end
				if model then model:Destroy() model, hl = nil, nil end
			end

			function P:SetUser(name)
				name = string.gsub(tostring(name or ""), "%s+", "")
				if name == "" then return end
				loadId += 1
				local my = loadId
				nameLbl.Text = name
				task.spawn(function()
					local ok, uid = pcall(PL.GetUserIdFromNameAsync, PL, name)
					if my ~= loadId then return end
					if not ok then warn("[avatar] " .. tostring(uid)) return end
					local ok2, m = pcall(PL.GetCharacterAppearanceAsync, PL, uid)
					if my ~= loadId then if ok2 and m then m:Destroy() end return end
					if not ok2 or not m then warn("[avatar] " .. tostring(m)) return end
					clear()
					for _, d in m:GetDescendants() do
						if d:IsA("Script") or d:IsA("LocalScript") then d:Destroy()
						elseif d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end
					end
					local hum = m:FindFirstChildOfClass("Humanoid")
					if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
					m.Parent = wmodel
					m:PivotTo(CFrame.new())
					local cf, size = m:GetBoundingBox()
					local dist = (size.Magnitude / 2) / math.tan(math.rad(cam.FieldOfView / 2)) * 1.05
					local cy = cf.Position.Y
					cam.CFrame = CFrame.new(Vector3.new(0, cy, dist), Vector3.new(0, cy, 0))
					hl = new("Highlight", {}, m)
					model = m
					refresh()
					angle = 0
					spinConn = RS.RenderStepped:Connect(function(dt)
						if not (model and model.Parent) then return end
						angle += dt * 0.8
						model:PivotTo(CFrame.Angles(0, angle, 0))
					end)
					table.insert(Win._extraConns, spinConn)
				end)
			end

			refresh()
			if po.User then P:SetUser(po.User) end
			return P
		end
		return cat
	end

	----------------------------------------------------------------- minimizar / fechar / tecla
	local cover = new("TextButton", {Text = "●", Font = FONTB, TextSize = 16, TextColor3 = ACC, BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 200, Visible = false}, win)
	round(cover, 999)
	table.insert(accentEls, {el = cover, prop = "TextColor3"})
	local function minimize()
		if mini then return end
		mini, miniTok = true, miniTok + 1
		local my = miniTok
		closeDD() closePicker()
		lastPos = win.Position
		win.ClipsDescendants = true
		winScale.Scale = 1
		tw(winCorner, {CornerRadius = UDim.new(0, 999)}, 0.25)
		tw(win, {Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0.5, 0, 0, 36)}, 0.3)
		task.delay(0.3, function() if my == miniTok then cover.Visible = true end end)
	end
	local function expandMini()
		if not mini then return end
		mini, miniTok = false, miniTok + 1
		local my = miniTok
		cover.Visible = false
		winScale.Scale = scalePct / 100
		tw(winCorner, {CornerRadius = UDim.new(0, 12)}, 0.25)
		tw(win, {Size = UDim2.fromOffset(700, 452), Position = lastPos}, 0.3)
		task.delay(0.32, function() if my == miniTok then win.ClipsDescendants = false end end)
	end
	minBtn.MouseButton1Click:Connect(minimize)
	cover.MouseButton1Click:Connect(expandMini)

	function Win:Toggle()
		if mini then expandMini() return end
		open = not open
		local base = scalePct / 100
		closeDD() closePicker()
		if open then
			win.Visible = true winScale.Scale = base * 0.92
			play(winScale, {Scale = base}, 0.18)
		else
			play(winScale, {Scale = base * 0.92}, 0.14)
			task.delay(0.15, function() if not open then win.Visible = false end end)
		end
	end
	track(UIS.InputBegan, function(i, gp)
		if gp then return end
		if i.KeyCode == KEY then Win:Toggle() end
	end)

	function Win:Destroy()
		for _, c in conns do c:Disconnect() end
		for _, c in Win._extraConns do c:Disconnect() end
		table.clear(conns)
		gui:Destroy()
	end
	closeBtn.MouseButton1Click:Connect(function() Win:Destroy() end)

	Win.SetAccent = function(_, col) applyAccent(col) end
	Win.SetScale = function(_, v) setScale(v) end
	Win.Gui = gui
	return Win
end

return Lib
