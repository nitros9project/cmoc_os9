-- gxtest: small Lua API for driving CoCo 3 graphics-test scenarios in MAME.
--
-- Scenarios are MAME autoboot_script files that drive emulated time and ask the
-- harness to capture screen snapshots. The host-side runner.sh launches MAME,
-- post-processes the PNGs MAME emits, and pairs them with the logical names
-- this module records in `manifest.tsv`.
--
-- API:
--   g.wait(secs)                 -- advance N emulated seconds
--   g.wait_idle(secs)            -- wait for the framebuffer to be stable N secs
--   g.type(str)                  -- post a string through the natural keyboard
--   g.snapshot(name, opts)       -- take a snapshot
--       opts.compare       = "pixel" (default) or "ssim"
--       opts.max_delta     = max per-channel delta for pixel  (default 5)
--       opts.max_diff_pct  = max % differing pixels for pixel (default 0.1)
--       opts.min_ssim      = min similarity for ssim          (default 0.97)
--       opts.mask          = mask basename in masks/          (optional)

local g = {}

local results_dir = os.getenv("GXTEST_RESULTS") or "/tmp/gxtest"
local scenario    = os.getenv("GXTEST_SCENARIO") or "scenario"
local manifest_path = results_dir .. "/manifest.tsv"

local manifest = assert(io.open(manifest_path, "w"),
	"gxtest: cannot open manifest " .. manifest_path)

local function get_screen()
	for _, scr in pairs(manager.machine.screens) do return scr end
end
local screen = get_screen()
assert(screen, "gxtest: no screen device found")

-- emu.wait(secs) yields the autoboot coroutine back to MAME for `secs` emulated
-- seconds, then resumes. This is the canonical pause primitive in MAME Lua.
function g.wait(secs) emu.wait(secs) end

-- Hash a coarse grid of pixels to detect whether the framebuffer has changed.
-- Cheap, not robust against subtle variation -- adequate for "screen settled".
local function frame_hash()
	local w, h = screen.width, screen.height
	local x = 2166136261
	for sy = 0, 5 do
		for sx = 0, 7 do
			local px = math.floor((sx + 0.5) * w / 8)
			local py = math.floor((sy + 0.5) * h / 6)
			x = (x ~ screen:pixel(px, py)) * 16777619 % 4294967296
		end
	end
	return x
end

function g.wait_idle(secs)
	local last = frame_hash()
	local stable_at = manager.machine.time
	local cap = secs * 4 + 5
	local started = manager.machine.time
	while true do
		g.wait(1 / 30)
		local h = frame_hash()
		if h ~= last then last = h; stable_at = manager.machine.time end
		if (manager.machine.time - stable_at):as_double() >= secs then return end
		if (manager.machine.time - started):as_double() >= cap then return end
	end
end

function g.type(str)
	str = str:gsub("\n", "\r")
	local nk = manager.machine.natkeyboard
	if nk and nk.post then nk:post(str) end
	g.wait(#str * 0.1 + 0.5) -- give the buffer a chance to drain
end

local snapshot_index = 0
function g.snapshot(name, opts)
	opts = opts or {}
	snapshot_index = snapshot_index + 1
	manifest:write(string.format("%d\t%s\t%s\t%s\t%s\t%s\t%s\n",
		snapshot_index, name,
		tostring(opts.compare or "pixel"),
		tostring(opts.max_delta or 5),
		tostring(opts.max_diff_pct or 0.1),
		tostring(opts.min_ssim or 0.97),
		tostring(opts.mask or "")))
	manifest:flush()
	screen:snapshot()
end

print(string.format("[gxtest] loaded scenario=%s results=%s screen=%dx%d",
	scenario, results_dir, screen.width, screen.height))
io.flush()
return g
