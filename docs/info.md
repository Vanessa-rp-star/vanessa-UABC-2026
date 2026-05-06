<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
# 4-bit ALU

## Description
This project implements a simple ALU that performs arithmetic and logical operations between two 4-bit operands.

## How it works

The system takes two operands:
- A = ui_in[3:0]
- B = ui_in[7:4]

And an operation defined by:
- op = uio_in[2:0]

Available operations:
- 000 → A + B
- 001 → A - B
- 010 → A AND B
- 011 → A OR B
- 100 → A XOR B
- 101 → A < B

The result is output on:
- uo_out[7:0]


## How to test

1. Assign values to A and B using `ui_in`
2. Select the operation using `uio_in[2:0]`
3. Observe the result on `uo_out`

Example:
- A = 20
- B = 30
- op = 000 (addition)


## External hardware

- uo_out = 50
