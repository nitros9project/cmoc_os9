#!/usr/bin/env python3
"""Audit the active CMOC public library API against LLVM archives.

The inventory is checked in: additions to original headers require an explicit
mapping. Native symbols are checked separately from compatibility symbols.
"""
import argparse,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def public_api():
    result={}
    for p in sorted((ROOT/'include').rglob('*.h')):
        if p.name in ('mat.h','local.h','dbg.h'):continue
        s=re.sub(r'/\*.*?\*/','',p.read_text(),flags=re.S)
        for ret,name,args in re.findall(r'(?m)^([A-Za-z_][^\n;{}]*?)\b([A-Za-z_]\w*)\s*\(([^;{}]*?)\);',s,re.S):
            if not ret.strip().startswith('typedef'): result[name]=str(p.relative_to(ROOT))
    # math.h has comma-separated declarations on single lines.
    for name in re.findall(r"\b(\w+)\([^()]*\)",re.sub(r"/\*.*?\*/", "",(ROOT/"include/math.h").read_text(),flags=re.S)):
        if name != "defined": result[name]="include/math.h"
    return result

def symbols(nm,paths):
    out=subprocess.check_output([nm,'--defined-only','--extern-only',*map(str,paths)],text=True)
    return set(re.findall(r'(?m)^\S*\s+[A-Za-z]\s+(\S+)$',out))

def main():
    p=argparse.ArgumentParser();p.add_argument('--nm',required=True);p.add_argument('--clang',required=True);p.add_argument('--sysroot',required=True);p.add_argument('--out',required=True);p.add_argument('--runtime',required=True);a=p.parse_args()
    api=public_api();inventory=json.loads((ROOT/'llvm/api-map.json').read_text());errors=[]
    if set(api)!=set(inventory):
        errors.append('Inventory mismatch: new='+str(sorted(set(api)-set(inventory)))+' removed='+str(sorted(set(inventory)-set(api))))
    compat=symbols(a.nm,[Path(a.out)/'libcmoc_os9_compat.a'])
    native=symbols(a.nm,[Path(a.sysroot)/'lib/libc.a',Path(a.sysroot)/'lib/libos9.a',Path(a.sysroot)/'lib/libm.a',Path(a.runtime)])
    for name,m in inventory.items():
        available=compat if m['provider']=='compat' else native
        if m['symbol'] not in available:errors.append(name+' -> missing '+m['symbol'])
    source = '#include "cmoc_os9.h"\n#include <math.h>\n#include <ctype.h>\n#include <strings.h>\n#include <errno.h>\n#include <fcntl.h>\n#include <setjmp.h>\n'
    for i, symbol in enumerate(sorted({m['symbol'] for m in inventory.values()})):
        source += f'__typeof__(&{symbol}) api_ref_{i} = &{symbol};\n'
    check = Path(a.out) / 'api-headers.c'
    check.write_text(source)
    subprocess.run([a.clang, '--target=mc6809-unknown-os9', '--sysroot=' + a.sysroot,
                    '-Werror', '-Wno-deprecated-declarations', '-Iinclude', '-c', str(check),
                    '-o', str(Path(a.out) / 'api-headers.o')], check=True)
    if errors:raise SystemExit('\n'.join(errors))
    print(f'API audit: {len(inventory)} callable interfaces covered; no missing symbols.')
if __name__=='__main__':main()
