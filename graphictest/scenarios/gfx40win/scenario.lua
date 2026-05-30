-- gfx40win scenario: three windows on one type-8 screen, then run
-- through owset/owend overlay, cwarea redraw, and dwend.

local g = require "gxtest"

g.wait(4)
g.snapshot("01-three-windows",  { compare = "ssim", min_ssim = 0.85 })

g.wait(5)
g.snapshot("02-overlay",        { compare = "ssim", min_ssim = 0.85 })

g.wait(5)
g.snapshot("03-restored",       { compare = "ssim", min_ssim = 0.85 })

g.wait(5)
g.snapshot("04-cwarea",         { compare = "ssim", min_ssim = 0.85 })

g.wait(5)
g.snapshot("05-dwend",          { compare = "ssim", min_ssim = 0.85 })
