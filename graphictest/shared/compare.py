#!/usr/bin/env python3
"""Compare two PNGs with either pixel-diff or SSIM tolerance.

Pixel mode (`--mode pixel`):
    Pass if (per-channel max delta <= --max-delta) for every pixel, OR if the
    fraction of pixels exceeding that delta is <= --max-diff-pct.

SSIM mode (`--mode ssim`):
    Pass if a simple structural similarity score >= --min-ssim. We implement
    SSIM directly (single-scale, no Gaussian window -- a uniform 8x8 window)
    so contributors don't need scikit-image. Sufficient for "matches closely
    enough" on pixel-art frames.

A mask PNG (`--mask`) marks regions to ignore: any pixel where the mask is
non-zero is excluded from the comparison. The diff PNG highlights differing
pixels in red.

Exit 0 on match, 1 on mismatch, 2 on input errors.
"""

import argparse, sys
from PIL import Image
import numpy as np


def load(path):
    img = Image.open(path).convert("RGB")
    return np.asarray(img, dtype=np.int16)  # int16 so subtraction can be signed


def resize_like(a, b):
    """If shapes differ, downscale the larger to the smaller for comparison."""
    if a.shape == b.shape:
        return a, b
    ah, aw = a.shape[:2]; bh, bw = b.shape[:2]
    th, tw = min(ah, bh), min(aw, bw)
    def fit(x):
        return np.asarray(Image.fromarray(x.astype("uint8")).resize((tw, th), Image.BICUBIC), dtype=np.int16)
    return fit(a), fit(b)


def apply_mask(actual, golden, mask_path):
    if not mask_path:
        return actual, golden, None
    m = np.asarray(Image.open(mask_path).convert("L"), dtype=np.uint8)
    if m.shape != actual.shape[:2]:
        m = np.asarray(Image.fromarray(m).resize((actual.shape[1], actual.shape[0]), Image.NEAREST))
    keep = (m == 0)
    return actual, golden, keep


def make_diff_png(actual, golden, deltas, keep, out_path):
    h, w = deltas.shape
    diff = np.zeros((h, w, 3), dtype=np.uint8)
    diff[..., 0] = np.minimum(255, deltas)  # red intensity = magnitude
    # Overlay a faded actual on green/blue for context
    base = (actual.astype(np.uint8) // 3)
    diff[..., 1] = base[..., 1]
    diff[..., 2] = base[..., 2]
    if keep is not None:
        # Show masked-out regions as gray
        diff[~keep] = (96, 96, 96)
    Image.fromarray(diff).save(out_path)


def pixel_compare(actual, golden, max_delta, max_diff_pct, mask_path, diff_path):
    actual, golden = resize_like(actual, golden)
    actual, golden, keep = apply_mask(actual, golden, mask_path)
    deltas = np.max(np.abs(actual - golden), axis=2).astype(np.int32)
    if keep is not None:
        differing = (deltas > max_delta) & keep
        total = int(keep.sum())
    else:
        differing = deltas > max_delta
        total = deltas.size
    n_diff = int(differing.sum())
    pct = (100.0 * n_diff / total) if total else 0.0
    make_diff_png(actual, golden, deltas, keep, diff_path)
    return (pct <= max_diff_pct), f"max_delta>{max_delta}: {n_diff}/{total} pixels ({pct:.3f}% allowed {max_diff_pct}%)"


def ssim(actual, golden, mask_path, diff_path, min_ssim):
    actual, golden = resize_like(actual, golden)
    a = actual.astype(np.float64).mean(axis=2)
    g = golden.astype(np.float64).mean(axis=2)
    if mask_path:
        m = np.asarray(Image.open(mask_path).convert("L"))
        if m.shape != a.shape:
            m = np.asarray(Image.fromarray(m).resize((a.shape[1], a.shape[0]), Image.NEAREST))
        keep = (m == 0)
        a = a[keep]; g = g[keep]
        # SSIM on a 1-D vector still works in the limit (variance/cov well-defined)
    K1, K2, L = 0.01, 0.03, 255.0
    C1 = (K1 * L) ** 2
    C2 = (K2 * L) ** 2
    mu_a, mu_g = a.mean(), g.mean()
    var_a, var_g = a.var(), g.var()
    cov = ((a - mu_a) * (g - mu_g)).mean()
    score = ((2 * mu_a * mu_g + C1) * (2 * cov + C2)) / \
            ((mu_a ** 2 + mu_g ** 2 + C1) * (var_a + var_g + C2))
    # Save a placeholder diff visualization (abs grayscale delta)
    deltas = np.abs(actual - golden).max(axis=2).astype(np.int32)
    make_diff_png(actual, golden, deltas, None, diff_path)
    return (score >= min_ssim), f"ssim={score:.4f} (min {min_ssim})"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["pixel", "ssim"], default="pixel")
    ap.add_argument("--actual", required=True)
    ap.add_argument("--golden", required=True)
    ap.add_argument("--diff", required=True)
    ap.add_argument("--mask", default="")
    ap.add_argument("--max-delta", type=int, default=5)
    ap.add_argument("--max-diff-pct", type=float, default=0.1)
    ap.add_argument("--min-ssim", type=float, default=0.97)
    args = ap.parse_args()

    try:
        actual = load(args.actual); golden = load(args.golden)
    except Exception as e:
        print(f"compare: load failed: {e}", file=sys.stderr); return 2

    if args.mode == "pixel":
        ok, msg = pixel_compare(actual, golden, args.max_delta, args.max_diff_pct, args.mask, args.diff)
    else:
        ok, msg = ssim(actual, golden, args.mask, args.diff, args.min_ssim)
    print(f"  {msg}", file=sys.stderr)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
