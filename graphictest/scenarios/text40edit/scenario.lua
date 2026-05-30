-- text40edit scenario: two snapshots of a type-1 text window.
--
-- The program holds each phase via _os9_sleep(300 ticks = ~5s), giving us
-- a generous window to fire the snapshot. Phase 1 = cursor-move markers
-- over a fill pattern; phase 2 = the same fill with erline / ereoline /
-- ereoscrn / insline / delline applied.
--
-- Deterministic output (no blink, no randomness) -> ssim should land at
-- 1.0; keep the floor moderately high to catch regressions without
-- failing on sub-pixel rendering noise.

local g = require "gxtest"

g.wait(4)
g.snapshot("01-cursor-moves", { compare = "ssim", min_ssim = 0.85 })

g.wait(6)
g.snapshot("02-line-edits", { compare = "ssim", min_ssim = 0.85 })
