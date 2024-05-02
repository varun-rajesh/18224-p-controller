import copy
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
import random
   
async def duty_cycle_test(dut, setpoint):
    await FallingEdge(dut.clk)
    dut.setpoint.value = setpoint

    await FallingEdge(dut.clk)
    assert dut.motor_a_duty_cycle.value == 127 + setpoint
    assert dut.motor_b_duty_cycle.value == 127 - setpoint

@cocotb.test()
async def check_duty_cycle(dut):
    # Run the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.reset_n.value = 1

    await FallingEdge(dut.clk)
    dut.reset_n.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 1

    for i in range(3):
        await FallingEdge(dut.clk)


    for i in range(100):
        await duty_cycle_test(dut, random.randrange(-127, 127))

    print("Motor Driver Passed")
