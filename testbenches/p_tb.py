import copy
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
import random


def clip_256(value):
    if value >= 256:
        return 255
    else:
        return value
    

def positify(value, bits):
    if value < 0:
        return value + 2 ** bits
    else:
        return value


async def sensor_rounding_test(dut, value):
    await FallingEdge(dut.clk)
    dut.sensor_reading.value = value*16

    await FallingEdge(dut.clk)
    assert dut.round_reading.value == clip_256(value)

    await FallingEdge(dut.clk)
    dut.sensor_reading.value = value*16 + 6

    await FallingEdge(dut.clk)
    assert dut.round_reading.value == clip_256(value)

    await FallingEdge(dut.clk)
    dut.sensor_reading.value = value*16 + 8

    await FallingEdge(dut.clk)
    assert dut.round_reading.value == clip_256(value + 1)

    await FallingEdge(dut.clk)
    dut.sensor_reading.value = value*16 + 9

    await FallingEdge(dut.clk)
    assert dut.round_reading.value == clip_256(value + 1)

    await FallingEdge(dut.clk)
    dut.sensor_reading.value = value*16 + 15

    await FallingEdge(dut.clk)
    assert dut.round_reading.value == clip_256(value + 1)


@cocotb.test()
async def check_sensor_rounding(dut):
    # Run the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.reset_n.value = 1

    await FallingEdge(dut.clk)
    dut.reset_n.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 1

    for i in range(3):
        await FallingEdge(dut.clk)

    await sensor_rounding_test(dut, 25)
    await sensor_rounding_test(dut, 255)
    await sensor_rounding_test(dut, 0)
    await sensor_rounding_test(dut, 32)

    print("Sensor Rounding Test Passed")


async def p_controller_test(dut, setpoint, sensor_reading, p):
    sensor_reading_expanded = (sensor_reading * 16) + random.randrange(-8, 8)
    
    await FallingEdge(dut.clk)
    dut.sensor_reading.value = sensor_reading_expanded
    dut.setpoint.value = setpoint
    dut.p.value = p

    await FallingEdge(dut.clk)

    await FallingEdge(dut.clk)

    await FallingEdge(dut.clk)

    await FallingEdge(dut.clk)

    assert dut.error.value == positify(setpoint - sensor_reading, 9)
    assert dut.internal_output_setpoint.value == positify((setpoint - sensor_reading) * p, 18)
    assert dut.output_setpoint.value == positify(((setpoint - sensor_reading) * p) // 1024, 8)


@cocotb.test()
async def check_p_controller(dut):
    # Run the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.reset_n.value = 1

    await FallingEdge(dut.clk)
    dut.reset_n.value = 0

    await FallingEdge(dut.clk)
    dut.reset_n.value = 1

    for i in range(3):
        await FallingEdge(dut.clk)

    await p_controller_test(dut, 10, 24, 4)
    await p_controller_test(dut, 0, 255, 255)
    await p_controller_test(dut, 255, 0, 255)
    await p_controller_test(dut, 24, 10, 32)
    await p_controller_test(dut, 31, 1, 4)

    print("P Controller Test Passed")


    

    





    