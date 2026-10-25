-- EvadeTouchContinuity loader for Delta
-- Experimental only. Rejoin to fully reset executor hooks.
local url = "https://raw.githubusercontent.com/hshsagaga1-commits/EvadeTouchContinuity/main/EvadeTouchContinuity.lua?nocache=" .. tostring(os.time())
local ok, err = pcall(function()
    loadstring(game:HttpGet(url))()
end)
if not ok then
    warn("[EvadeTouchContinuity] Loader failed:", tostring(err))
end
