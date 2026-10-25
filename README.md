# EvadeTouchContinuity (experimental)

A separate, experimental Delta/Luau test for the **mobile camera re-touch transition** in Evade Overhaul.

## What this version tries to do
When a finger is lifted and immediately placed back down, this script arms a guard for the next non-zero camera-rotation sample. It suppresses that one sample, then lets subsequent camera movement pass normally. The goal is to test whether a sudden first-sample rotation spike is causing the tiny camera hitch and bhop/trimp speed loss.

This is deliberately different from smoothing every rotation for a fixed time: it does **not** change the sensitivity setting or apply continuous easing to all camera movements. It only drops the first non-zero rotation sample after each new touch.

## Important limitations
This is an experiment, not a confirmed fix. If the first sample is normal intended movement rather than an artificial spike, that tiny initial movement will also be ignored. It cannot keep a real finger touch alive after the finger leaves the screen, and it cannot guarantee that Evade's trimp momentum will be preserved. Roblox's touch lifecycle is controlled by the client.

## Install / run
1. Copy [Loader.lua](Loader.lua) into Delta and execute it, or run EvadeTouchContinuity.lua directly.
2. Run it **separately** from your camera sensitivity script. Do not edit or replace the sensitivity script.
3. Test in a private/low-risk session, using your normal settings.
4. Use the on-screen **STOP** button to stop the test. Rejoining the game clears executor hooks.

## What to report
- Does the little camera hitch disappear when you re-touch and immediately drag?
- Does trimp speed still drop (for example, 120 to 117)?
- The **COPIAR RELATÓRIO** button now reports how many first rotation samples were suppressed and the magnitude of the last one.
- Any red error message in Delta's console?

## Safety / compatibility
- It only attempts to wrap the local Roblox camera module's rotation getter.
- It does not change character WalkSpeed, velocity, or the existing sensitivity script.
- Roblox updates and executor differences may prevent the hook from attaching.