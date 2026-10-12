# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer


@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting 6-bit ALU tests")

    test_cases = [
        # A,    B,    opcode, expected result
        (5,     3,    0b0000, 8),   # ADD
        (63,    1,    0b0000, 0),   # ADD overflow
        (5,     3,    0b0001, 2),   # SUB
        (0,     1,    0b0001, 63),  # SUB underflow
        (0b111100, 0b101010, 0b0010, 0b101000),  # AND
        (0b111100, 0b001011, 0b0011, 0b111111),  # OR
        (0b111100, 0b001011, 0b0100, 0b110111),  # XOR
        (1,     5,    0b0101, 32),   # SLL
        (32,    1,    0b0110, 16),   # SRL
        (32,    1,    0b0111, 48),   # SRA: -32 >> 1 = -16
        (63,    1,    0b1000, 1),    # SLT: -1 < 1
        (63,    1,    0b1001, 0),    # SLTU: 63 < 1 is false
        (32,    31,   0b1000, 1),    # SLT: -32 < 31
        (32,    31,   0b1001, 0),    # SLTU: 32 < 31 is false
        (7,     7,    0b1000, 0),    # SLT: equal
        (7,     7,    0b1001, 0),    # SLTU: equal
        (0,     0,    0b0000, 0),    # Zero result
        (63,    63,   0b0100, 0),    # XOR produces zero
    ]

    # Start clock: 10 us period (100 kHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    for a, b, op, expected in test_cases:
        dut.A.value = a
        dut.B.value = b
        dut.alu_opc.value = op

        # Allow combinational logic to settle
        await Timer(1, unit="ns")

        actual = int(dut.result.value)
        actual_zero = int(dut.zero.value)
        expected_zero = int(expected == 0)

        assert actual == expected, (
            f"A={a:06b}, B={b:06b}, opcode={op:04b}: "
            f"expected {expected:06b}, got {actual:06b}"
        )

        assert actual_zero == expected_zero, (
            f"Zero flag mismatch: A={a:06b}, B={b:06b}, "
            f"opcode={op:04b}, expected={expected_zero}, "
            f"got={actual_zero}"
        )

    dut._log.info("All 6-bit ALU tests passed")
