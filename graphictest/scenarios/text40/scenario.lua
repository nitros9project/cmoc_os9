-- text40 scenario: type-1 (40x25) text window exercising attributes and
-- palette slots. The program draws once then spins on _SS_KEYSENSE_SPACE,
-- so a single static snapshot is enough -- except for the "Blinking" row,
-- which toggles ~twice per second. SSIM with a moderate floor keeps the
-- test robust to that one row's phase while still catching gross
-- regressions (wrong palette, missing attributes, layout drift).

local g = require "gxtest"

-- Boot + the program's setup (open /w, dwset type 1, palette x16, layout
-- writes) takes a few emulated seconds after we land at the shell prompt.
g.wait(15)
g.snapshot("01-text40", { compare = "ssim", min_ssim = 0.85 })
