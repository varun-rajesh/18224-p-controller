import copy
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
import random

async def pwm_test(dut, duty_cycle):
    await FallingEdge(dut.clk) # type: ignore
    dut.duty_cycle.value = duty_cycle

    high_time = 0
    low_time = 0
    for i in range(1024):
        await FallingEdge(dut.clk)
        if dut.pwm_out.value == 0:
            low_time += 1
        else:
            high_time += 1
    
    duty_cycle_actual = high_time / (low_time + high_time)
    error = duty_cycle / 256 - duty_cycle_actual

    assert abs(error) < 0.01


@cocotb.test()
async def check_pwm(dut):
    # Run the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.reset_n.value = 1
    dut.duty_cycle.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 1

    for i in range(3):
        await FallingEdge(dut.clk)

    await pwm_test(dut, 50)
    await pwm_test(dut, 25)
    await pwm_test(dut, 75)

    print("PWM Test Passed")



