#!/usr/bin/env python3
"""Link each callable symbol as an explicit linker root.

One monolithic image exceeds OS-9's 64 KiB module limit. Separate images
retain every function and its transitive dependencies without that limit.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import re
from os9_module import validate

p = argparse.ArgumentParser()
p.add_argument('--clang', required=True)
p.add_argument('--sysroot', required=True)
p.add_argument('--nm', required=True)
p.add_argument('--out', required=True)
p.add_argument('--opt', required=True)
a = p.parse_args()
out = Path(a.out)
dest = out / 'link-check'
dest.mkdir(exist_ok=True)
library = out / 'libcmoc_os9_compat.a'
nm = subprocess.check_output([a.nm, '--defined-only', '--extern-only', str(library)], text=True)
symbols = sorted(set(re.findall(r'(?m)^\S*\s+[TW]\s+(\S+)$', nm)))
def link(symbol):
    target = dest / symbol
    command = [a.clang, '--target=mc6809-unknown-os9', '--sysroot=' + a.sysroot,
               '-' + a.opt, '-Iinclude', 'tests/os9_smoke.c', str(library),
               '-Wl,-u,' + symbol, '-o', str(target)]
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    if result.returncode:
        raise RuntimeError(symbol + ':\n' + result.stdout)
    validate(target)
with ThreadPoolExecutor(max_workers=4) as pool:
    list(pool.map(link, symbols))
print(f'Link check: {len(symbols)} callable archive symbols and their dependencies retained and linked.')
