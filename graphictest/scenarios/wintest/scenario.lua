-- wintest scenario: functionally identical to maze (same source code, modulo
-- comment formatting). Captures here should match the maze captures because
-- both seed srand with time(0), which is stubbed to return 0.

local g = require "gxtest"

g.wait(15)
g.snapshot("01-first-maze", { compare = "ssim", min_ssim = 0.55 })

g.wait(10)
g.snapshot("02-second-maze", { compare = "ssim", min_ssim = 0.55 })
