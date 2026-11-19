# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# Pin map of the smoke test: ui_in[7] = write enable, ui_in[6:0] = address,
# uio_in = write data, uo_out = read data.
ADDRS = [0, 1, 2, 5, 16, 63, 64, 127]


def pattern(a):
    return (a * 37 + 11) & 0xFF


async def write(dut, addr, data):
    dut.ui_in.value = 0x80 | addr
    dut.uio_in.value = data
    await ClockCycles(dut.clk, 2)


async def read(dut, addr):
    dut.ui_in.value = addr
    await ClockCycles(dut.clk, 2)
    return int(dut.uo_out.value)


@cocotb.test()
async def test_sram_readback(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    for a in ADDRS:
        await write(dut, a, pattern(a))

    for a in ADDRS:
        got = await read(dut, a)
        assert got == pattern(a), f"addr {a}: got {got:#04x}, expected {pattern(a):#04x}"

    # Rewrite one address and confirm only that one changed
    await write(dut, 5, 0xA5)
    assert await read(dut, 5) == 0xA5
    assert await read(dut, 2) == pattern(2)
