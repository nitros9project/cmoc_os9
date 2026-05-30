-- wintest scenario: boot, let wintest run a maze, snapshot two states.
--
-- wintest seeds with time(0) so mazes vary per boot. We use SSIM tolerance.

local g = require "gxtest"

-- Boot delay + DOS boot + NitrOS-9 startup runs `wintest` automatically (the
-- runner injects it). Give the GIME enough time to switch to the graphics
-- window and draw the first maze.
g.wait(15)
g.snapshot("01-first-maze", { compare = "ssim", min_ssim = 0.55 })

-- wintest loops, drawing a new maze each iteration. After another ~10 sec
-- we should see a different but structurally similar screen.
g.wait(10)
g.snapshot("02-second-maze", { compare = "ssim", min_ssim = 0.55 })
