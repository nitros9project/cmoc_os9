-- gfx40buf scenario: type-8 (320x200, 16 colors) window exercising
-- the cgfx buffer/bitmap APIs (dfngpbuf, getblk, putblk, kilbuf).
-- Single static snapshot.

local g = require "gxtest"

g.wait(10)
g.snapshot("01-gfx40buf", { compare = "ssim", min_ssim = 0.85 })
