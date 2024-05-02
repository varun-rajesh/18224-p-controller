import copy
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
import random

async def p_write_test(dut):
    p = random.randrange(0, 256)

    await FallingEdge(dut.clk)
    dut.write_en.value = 1
    dut.param.value = p
    dut.address.value = 0

    await FallingEdge(dut.clk)
    dut.write_en.value = 0

    assert dut.p.value == p

async def set_write_test(dut):
    set = random.randrange(0, 256)

    await FallingEdge(dut.clk)
    dut.write_en.value = 1
    dut.param.value = set
    dut.address.value = 1

    await FallingEdge(dut.clk)
    dut.write_en.value = 0

    assert dut.setpoint.value == set

@cocotb.test()
async def check_p_write(dut):
    # Run the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.reset_n.value = 1
    dut.write_en.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 1

    for i in range(3):
        await FallingEdge(dut.clk)

    for i in range(10):
        await p_write_test(dut)
    
    print("P Write Passed")

@cocotb.test()
async def check_set_write(dut):
    # Run the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.reset_n.value = 1
    dut.write_en.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 1

    for i in range(3):
        await FallingEdge(dut.clk)

    for i in range(10):
        await set_write_test(dut)
    
    print("Set Write Passed")




