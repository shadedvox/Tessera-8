import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cpu_smoke(dut):
    dut._log.info("Tessera-8 smoke test - Pray to God")

    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # Hold reset low for 5 cycles
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)

    # Release reset and clock CPU for 20 cycles
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 20)