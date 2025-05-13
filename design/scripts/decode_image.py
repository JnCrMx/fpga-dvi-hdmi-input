#!/usr/bin/env python3

import sys
import numpy as np
from PIL import Image

if len(sys.argv) <= 4:
    print(f"Usage: {sys.argv[0]} input output width height")
    sys.exit(2)

input_path = sys.argv[1]
output_path = sys.argv[2]

with open(input_path, 'r') as file:
    hex_data = file.read().strip()

i = hex_data.rindex("> \n")
hex_data = hex_data[i+3:]
if(hex_data.endswith(">")):
    hex_data = hex_data[:-1]

if len(hex_data) % 2 != 0:
    hex_data = hex_data[:-1]

byte_data = bytes.fromhex(hex_data)

print(f"Read {len(byte_data)} pixels.")

width = int(sys.argv[3])
height = int(sys.argv[4])

img = Image.new("RGB", (width, height))

pixels = img.load()
try:
    for y in range(height):
        for x in range(width):
            color = byte_data[y*width+x]
            r = color & 0b11100000
            g = (color & 0b00011100) << 3
            b = (color & 0b00000011) << 6
            pixels[x, y] = (r, g, b)
except(IndexError):
    pass

img.save(output_path)
