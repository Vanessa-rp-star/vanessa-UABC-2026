# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 1

    # Test ADD: 3 + 2 = 5
    dut.ui_in.value = (2 << 4) | 3   # B=2, A=3
    dut.uio_in.value = 0             # ADD
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 5

    # Test AND: 3 & 1 = 1
    dut.ui_in.value = (1 << 4) | 3
    dut.uio_in.value = 2
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 1

    # Test OR: 3 | 4 = 7
    dut.ui_in.value = (4 << 4) | 3
    dut.uio_in.value = 3
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 7
