-- gfx80draw scenario: type-7 (640x200, 4 colors) window exercising
-- cgfx drawing primitives in a 2x2 quadrant grid. Single static
-- snapshot; deterministic output -> ssim should land near 1.0.

local g = require "gxtest"

g.wait(10)
g.snapshot("01-gfx80draw", { compare = "ssim", min_ssim = 0.85 })
