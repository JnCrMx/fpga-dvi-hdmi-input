#!/usr/bin/env python3

from collections import Counter
from pathlib import Path

def lnot(x : int):
    return 1 if x == 0 else 0

def get_symbols(data : int):
    D = [1 if c == '1' else 0 for c in reversed(f'{data:08b}')]
    q_m = [0] * 9
    if D.count(1) > 4 or (D.count(1) == 4 and D[0] == 0):
        q_m[0] = D[0]
        q_m[1] = lnot(q_m[0] ^ D[1])
        q_m[2] = lnot(q_m[1] ^ D[2])
        q_m[3] = lnot(q_m[2] ^ D[3])
        q_m[4] = lnot(q_m[3] ^ D[4])
        q_m[5] = lnot(q_m[4] ^ D[5])
        q_m[6] = lnot(q_m[5] ^ D[6])
        q_m[7] = lnot(q_m[6] ^ D[7])
        q_m[8] = 0
    else:
        q_m[0] = D[0]
        q_m[1] = q_m[0] ^ D[1]
        q_m[2] = q_m[1] ^ D[2]
        q_m[3] = q_m[2] ^ D[3]
        q_m[4] = q_m[3] ^ D[4]
        q_m[5] = q_m[4] ^ D[5]
        q_m[6] = q_m[5] ^ D[6]
        q_m[7] = q_m[6] ^ D[7]
        q_m[8] = 1
    outputs = []
    outputs += [
        (q_m[0:8] if q_m[8] == 1 else [lnot(x) for x in q_m[0:8]])
        +
        [q_m[8]]
        +
        [lnot(q_m[8])]
    ]
    if q_m[0:8].count(1) != q_m[0:8].count(0):
        outputs += [
            q_m[0:8]
            +
            [q_m[8]]
            +
            [0]
        ]
        outputs += [
            [lnot(x) for x in q_m[0:8]]
            +
            [q_m[8]]
            +
            [1]
        ]
    outputs = [list(reversed(x)) for x in outputs]
    outputs = ["".join([str(y) for y in x]) for x in outputs]
    outputs = set(outputs)
    return outputs

def generate(output: Path):
    with open(output, "w") as output_file:
        for i in range(0, 256):
            output_file.write(f'// Data {i:02x}\n')
            symbols = get_symbols(i)
            for s in symbols:
                output_file.write(f'10\'b{s}: valid = 1;\n')
