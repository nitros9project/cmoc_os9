-- gfx40draw scenario: type-8 (320x200, 16 colors) window exercising
-- the same drawing-primitive set as gfx80draw at mode-8 native
-- resolution. Single static snapshot.

local g = require "gxtest"

g.wait(10)
g.snapshot("01-gfx40draw", { compare = "ssim", min_ssim = 0.85 })
