# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb


@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting 32-bit ALU tests")

    test_cases = [
        # A, B, opcode, expected result
        (0x00000005, 0x00000003, 0b0000, 0x00000008),  # ADD
        (0x00000005, 0x00000003, 0b0001, 0x00000002),  # SUB
        (0x0000000F, 0x0000000A, 0b0010, 0x0000000A),  # AND
        (0x0000000F, 0x0000000A, 0b0011, 0x0000000F),  # OR
        (0x0000000F, 0x0000000A, 0b0100, 0x00000005),  # XOR
        (0x00000001, 0x00000004, 0b0101, 0x00000010),  # SLL
        (0x00000010, 0x00000002, 0b0110, 0x00000004),  # SRL
        (0x80000000, 0x00000001, 0b0111, 0xC0000000),  # SRA
        (0xFFFFFFFF, 0x00000001, 0b1000, 0x00000001),  # SLT signed
        (0xFFFFFFFF, 0x00000001, 0b1001, 0x00000000),  # SLTU unsigned
    ]

    for a, b, op, expected in test_cases:
        dut.A.value = a
        dut.B.value = b
        dut.alu_opc.value = op

        # Allow combinational logic to settle
        await cocotb.triggers.Timer(1, unit="ns")

        actual = int(dut.result.value)
        zero = int(dut.zero.value)
        expected_zero = int(expected == 0)

        assert actual == expected, (
            f"A={a:#010x}, B={b:#010x}, opcode={op:04b}: "
            f"expected {expected:#010x}, got {actual:#010x}"
        )

        assert zero == expected_zero, (
            f"Incorrect zero flag for opcode={op:04b}: "
            f"expected {expected_zero}, got {zero}"
        )

    dut._log.info("All ALU tests passed")
