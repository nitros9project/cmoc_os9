-- gfx40win scenario: three windows on one type-8 screen, then an
-- owset/owend overlay cycle on the main window.

local g = require "gxtest"

-- Phase 1 holds for ~7 emulated seconds after setup; snapshot in the
-- middle of the hold.
g.wait(5)
g.snapshot("01-three-windows", { compare = "ssim", min_ssim = 0.85 })

g.wait(7)
g.snapshot("02-overlay", { compare = "ssim", min_ssim = 0.85 })

g.wait(7)
g.snapshot("03-restored", { compare = "ssim", min_ssim = 0.85 })
