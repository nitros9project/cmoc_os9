-- maze scenario: boot NitrOS-9, run the maze graphics demo, snapshot two states.
--
-- maze opens /w, switches the GIME to its graphics window, and loops drawing
-- a new random maze every ~3 seconds until SPACE is pressed. Each maze is
-- seeded from time(0) so the exact pixels differ between runs; we compare
-- with SSIM to allow for that randomness while still catching gross failures
-- (e.g. blank screen, BASIC OK prompt, wrong palette, terminal output).

local g = require "gxtest"

-- The runner already booted us into NitrOS-9 and typed `maze` at the OS-9
-- shell. Give the program time to fork, open /w, switch the display, and
-- finish drawing the first maze (~12-15s on a real CoCo, faster in MAME).
g.wait(15)
g.snapshot("01-first-maze", { compare = "ssim", min_ssim = 0.55 })

-- maze sleeps ENDPAUSE ticks (~3s) between mazes. After another 10 seconds
-- we should be partway through a second, structurally similar maze.
g.wait(10)
g.snapshot("02-second-maze", { compare = "ssim", min_ssim = 0.55 })
