# EvadeTouchContinuity (experimental)

A separate, experimental Delta/Luau test for the **mobile camera re-touch transition** in Evade Overhaul.

## What this test tries to do
When a finger is lifted and placed back down after reaching the edge of the screen, Roblox starts a new touch input. This script detects a new touch and briefly eases the first camera-rotation input back in, aiming to reduce a sudden camera jump or harsh transition.

**Important limitation:** this cannot keep a real finger touch alive after the finger leaves the screen, and it cannot guarantee that Evade's trimp momentum will be preserved. Roblox's touch lifecycle is controlled by the client; changing a `Touch` boolean does not synthesize a continuous physical touch. This is a test, not a confirmed fix.

## Install / run
1. Open `EvadeTouchContinuity.lua`.
2. Copy the full file into Delta and execute it **separately** from your camera sensitivity script.
3. Test in a private/low-risk session, with the same camera settings you normally use.
4. To stop it, use the on-screen **STOP** button. Rejoining the game also clears the hooks.

## What to report
- Does the camera feel smoother when you lift and re-touch?
- Does trimp speed still drop (for example, 120 to 117)?
- Any red error message in Delta's console?

## Safety / compatibility
- It only attempts to wrap the local Roblox camera module's rotation getter.
- It does not change character WalkSpeed, velocity, or the existing sensitivity script.
- Roblox updates and executor differences may prevent the hook from attaching.
