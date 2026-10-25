-- EvadeTouchContinuity.lua
-- EXPERIMENTAL: suppresses a suspicious first non-zero camera delta after re-touch.
-- It does NOT synthesize/hold a physical touch and cannot guarantee trimp momentum.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

if not player then
    warn("[EvadeTouchContinuity] LocalPlayer unavailable.")
    return
end

-- Clean up a previous copy of this test.
if _G.EvadeTouchContinuity_Stop then
    pcall(_G.EvadeTouchContinuity_Stop)
end

local enabled = true
local touchActive = false
local suppressFirstDelta = false
local suppressedDeltaCount = 0
local lastSuppressedMagnitude = 0
local hooked = false
local originalGetRotation

local function log(...)
    print("[EvadeTouchContinuity]", ...)
end

local function onTouchStarted(input, processed)
    if input and input.UserInputType == Enum.UserInputType.Touch then
        touchActive = true
        -- Arm the guard for the next actual camera movement after re-touch.
        -- Zero/empty samples do not consume the guard.
        suppressFirstDelta = true
    end
end

local function onTouchEnded(input, processed)
    if input and input.UserInputType == Enum.UserInputType.Touch then
        -- TouchEnded can fire for one finger while another is still down.
        task.defer(function()
            local ok, touches = pcall(function()
                return UIS:GetTouches()
            end)
            touchActive = ok and touches ~= nil and #touches > 0
        end)
    end
end

local startConn = UIS.TouchStarted:Connect(onTouchStarted)
local endConn = UIS.TouchEnded:Connect(onTouchEnded)

local function findCameraInput()
    local ps = player:FindFirstChild("PlayerScripts")
    if not ps then return nil end

    local playerModule = ps:FindFirstChild("PlayerModule")
    if not playerModule then return nil end

    local cameraModule = playerModule:FindFirstChild("CameraModule")
    if not cameraModule then return nil end

    return cameraModule:FindFirstChild("CameraInput")
end

local function attachHook()
    local cameraInput = findCameraInput()
    if not cameraInput then
        log("CameraInput not found in PlayerScripts; this Roblox build may store it differently.")
        return false
    end

    local ok, module = pcall(function()
        return require(cameraInput)
    end)
    if not ok or type(module) ~= "table" or type(module.getRotation) ~= "function" then
        log("Could not access CameraInput.getRotation.")
        return false
    end

    if type(hookfunction) ~= "function" then
        log("This executor does not expose hookfunction; no camera hook was installed.")
        return false
    end

    local targetFunction = module.getRotation
    local oldFunction

    local success, err = pcall(function()
        oldFunction = hookfunction(targetFunction, function(...)
            local results = table.pack(oldFunction(...))
            if enabled and touchActive and suppressFirstDelta then
                local delta = results[1]
                if typeof(delta) == "Vector2" and delta.Magnitude > 0.0001 then
                    -- Drop only the first non-zero rotation sample after a new touch.
                    -- This targets a possible re-touch spike without changing sensitivity
                    -- or smoothing every camera movement.
                    lastSuppressedMagnitude = delta.Magnitude
                    suppressedDeltaCount = suppressedDeltaCount + 1
                    results[1] = Vector2.zero
                    suppressFirstDelta = false
                    log("Suppressed first re-touch rotation sample; magnitude:", lastSuppressedMagnitude)
                end
            end
            return table.unpack(results, 1, results.n)
        end)
    end)

    if not success then
        log("Hook failed:", tostring(err))
        return false
    end

    hooked = true
    log("Camera rotation hook installed. First non-zero re-touch delta guard is armed per touch.")
    return true
end

-- Compact status panel with a stop button only; no report UI.
local gui
pcall(function()
    gui = Instance.new("ScreenGui")
    gui.Name = "EvadeTouchContinuityGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.Size = UDim2.fromOffset(230, 68)
    frame.Position = UDim2.new(0.5, -115, 0.72, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 25)
    label.Position = UDim2.fromOffset(6, 2)
    label.BackgroundTransparency = 1
    label.Text = "Touch Continuity • TEST"
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 29)
    button.Position = UDim2.fromOffset(8, 32)
    button.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
    button.BorderSizePixel = 0
    button.Text = "STOP"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 7)
    bc.Parent = button


    button.Activated:Connect(function()
        if _G.EvadeTouchContinuity_Stop then
            _G.EvadeTouchContinuity_Stop()
        end
    end)
end)

_G.EvadeTouchContinuity_Stop = function()
    if not enabled then return end
    enabled = false
    if startConn then pcall(function() startConn:Disconnect() end) end
    if endConn then pcall(function() endConn:Disconnect() end) end
    if gui then pcall(function() gui:Destroy() end) end
    _G.EvadeTouchContinuity_Stop = nil
    log("Stopped. Note: executor hooks may remain until you rejoin; rejoin to fully reset.")
end

-- PlayerModule may be created a little after the script starts.
local deadline = os.clock() + 8
while enabled and os.clock() < deadline and not hooked do
    if attachHook() then break end
    task.wait(0.5)
end

if not hooked and enabled then
    warn("[EvadeTouchContinuity] Hook could not be installed. No camera changes were made.")
end
