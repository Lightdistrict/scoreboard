# MAX Scoreboard

Click-to-expand DarkRP scoreboard: job-colored rows, usergroup icon, country flag, OS icon, mute toggle, ping bars, pin-to-stay-open, and a search box while pinned.

## Install

Drop this whole repo into `garrysmod/addons/maxscoreboard/` and restart. Make sure your `max_assets` icon workshop addon is in your server's workshop collection too — this addon expects the icons to already be there (see below), it doesn't ship or download them itself.

## Configuration

`lua/maxscoreboard/config/sh_config.lua`:
- `communityName` — text shown in the header (no logo image needed)

`lua/maxscoreboard/config/cl_config.lua`:
- `rankIcons` — maps a usergroup name (from `ply:GetUserGroup()`, kept in sync by SAM/ULX via CAMI) to an icon filename. The `user` group is always skipped (no icon) so default members don't get one.

## Icons

This addon expects icons at these paths, which resolve into your `max_assets` addon's `materials/scoreboard/icons/` folder (the `max_assets` addon folder name itself doesn't matter — `materials/` is a shared global namespace, not addon-scoped):

```
materials/scoreboard/icons/group_user.png          (fallback rank icon)
materials/scoreboard/icons/group_<name>.png         (per rankIcons config entries)
materials/scoreboard/icons/voice_on.png
materials/scoreboard/icons/voice_off.png
materials/scoreboard/icons/pin.png
materials/scoreboard/icons/country/<CODE>.png        (2-letter, e.g. US.png)
materials/scoreboard/icons/country/_unknown.png
materials/scoreboard/icons/os/windows.png
materials/scoreboard/icons/os/linux.png
materials/scoreboard/icons/os/osx.png
materials/scoreboard/icons/os/unknown.png
```

## What changed from the version you found

- Renamed away from the original "Studio Network's Scoreboard" branding (Lua globals, material paths, header logo, footer watermark) to this addon's own.
- **Fixed a real bug**: the flag and OS icons were drawn from `system.GetCountry()` / `system.IsWindows()` etc. directly, which only ever reflects the *local viewer's own* country/OS — every row would show your own flag and OS, not each player's. Fixed by having each client self-report its own country/OS once on spawn, relayed server-side to everyone (`src/sv_misc.lua` + `src/cl_misc.lua`) — same technique, applied to both.
- Created `src/sv_misc.lua`, which was referenced by `sh_init.lua`'s include list but never actually existed — would have thrown a server-side "couldn't include file" error.
- Removed dead code: an unused blur/web-material utility file (`cl_util.lua`) whose `getWebMaterial` function referenced a table that was never initialized, and a leftover `HUDShouldDraw` hook checking for a HUD component name (`studionet.hud`) from an unrelated addon that was never included here.
- Replaced the hardcoded, studio-specific usergroup name list (`Network President`, `Studioist`, etc.) with the config-driven `rankIcons` table above.
- Bundled and force-downloads the Montserrat font (`resource/fonts/montserrat-regular.ttf`) for the header title.
- No backdoors, obfuscation, or unexpected network calls found in the original code during review — it was just missing a file and had the per-viewer country/OS bug above.
