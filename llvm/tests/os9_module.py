#!/usr/bin/env python3
"""Check the OS-9 header, size, header parity, and whole-module CRC."""
from pathlib import Path
import sys

def table_entry(value):
    value <<= 16
    for _ in range(8):
        value <<= 1
        if value & 0x1000000:
            value ^= 0x800063
    return value & 0xffffff

CRC_TABLE = tuple(table_entry(n) for n in range(256))

def validate(path):
    data = Path(path).read_bytes()
    if len(data) < 16 or data[:2] != b'\x87\xcd':
        raise ValueError(f'{path}: invalid OS-9 module header')
    if int.from_bytes(data[2:4], 'big') != len(data):
        raise ValueError(f'{path}: incorrect module size')
    parity = 0
    for byte in data[:9]:
        parity ^= byte
    if parity != 0xff:
        raise ValueError(f'{path}: incorrect header parity')
    crc = 0xffffff
    for byte in data:
        crc = ((crc << 8) & 0xffffff) ^ CRC_TABLE[((crc >> 16) ^ byte) & 255]
    if crc != 0x800fe3:
        raise ValueError(f'{path}: incorrect module CRC')

if __name__ == '__main__':
    for path in sys.argv[1:]:
        validate(path)
    print(f'OS-9 module validation: {len(sys.argv)-1} passed.')
