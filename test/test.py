# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

# When submitting your design, change this to 16 + the peripheral number
# in peripherals.v.  e.g. if your design is i_user_simple00, set this to 16.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 16

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI 
    # interface to read and write the registers.
    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # Reset, always start the test by resetting TinyQV
    await tqv.reset()

    dut._log.info("Test project behavior")

    async def apply_sample(val):
        dut.ui_in.value = val
        dut.data_write.value = 1
        await RisingEdge(dut.clk)
        dut.data_write.value = 0
        await RisingEdge(dut.clk)

    # Test sequence of samples
    inputs = [10, 20, 30, 40, 50]
    expected_outputs = []

    # Calculate expected moving average (coeffs = [1,1,1,1] / 4)
    taps = [0, 0, 0, 0]
    for val in inputs:
        taps = [val] + taps[:-1]
        avg = sum(taps) >> 2
        expected_outputs.append(avg)

    # Apply and check outputs
    for i, val in enumerate(inputs):
        await apply_sample(val)
        # allow one extra clock for output to update
        await ClockCycles(dut.clk, 1)
        out_val = int(dut.uo_out.value)
        dut._log.info(f"Sample {i}: Input={val}, Output={out_val}, Expected={expected_outputs[i]}")
        assert out_val == expected_outputs[i], \
            f"Mismatch at sample {i}: got {out_val}, expected {expected_outputs[i]}"
