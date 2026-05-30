-- gfx80 scenario: type-7 (640x200, 4 colors, 80x25) window exercising
-- the text features text screens lack -- 6x8 font, bold, proportional
-- spacing, transparency, border color. Single static snapshot.

local g = require "gxtest"

g.wait(10)
g.snapshot("01-gfx80", { compare = "ssim", min_ssim = 0.85 })
