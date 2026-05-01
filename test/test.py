# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Running CPU...")

    # Deja correr varios ciclos para que la CPU haga algo
    await ClockCycles(dut.clk, 20)

    # Solo verificamos que NO sea X o Z
    assert dut.uo_out.value.is_resolvable, "Salida inválida (X o Z)"

    dut._log.info(f"Salida: {dut.uo_out.value}")
