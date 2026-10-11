`default_nettype none
``timescale 10ps/1ps

module tb_alu_6bit;

    reg  [5:0] A;
    reg  [5:0] B;
    reg  [3:0] alu_opc;

    wire [5:0] result;
    wire       zero;

    integer passed;
    integer failed;

    // Change alu_6bit if your module has a different name.
    tt_um_alu_6bit dut (
        .A(A),
        .B(B),
        .alu_opc(alu_opc),
        .result(result),
        .zero(zero)
    );

    // Self-checking test task
    task check;
        input [3:0] op;
        input [5:0] a;
        input [5:0] b;
        input [5:0] expected;

        begin
            alu_opc = op;
            A = a;
            B = b;

            #10;

            if ((result === expected) &&
                (zero === (expected == 6'b000000))) begin

                $display(
                    "PASS | OP=%b A=%b B=%b RESULT=%b ZERO=%b",
                    op, a, b, result, zero
                );

                passed = passed + 1;
            end
            else begin

                $display(
                    "FAIL | OP=%b A=%b B=%b EXPECTED=%b ACTUAL=%b ZERO=%b",
                    op, a, b, expected, result, zero
                );

                failed = failed + 1;
            end
        end
    endtask

    initial begin
        A = 0;
        B = 0;
        alu_opc = 0;
        passed = 0;
        failed = 0;

        $display("======================================");
        $display("       6-BIT ALU TESTBENCH");
        $display("======================================");

        // ---------------------------------
        // 1. ADD (0000)
        // ---------------------------------
        $display("\n--- ADD ---");

        check(4'b0000, 6'd0,  6'd0,  6'd0);
        check(4'b0000, 6'd1,  6'd1,  6'd2);
        check(4'b0000, 6'd31, 6'd1,  6'b100000);
        check(4'b0000, 6'd63, 6'd1,  6'd0);
        check(4'b0000, 6'd32, 6'd63, 6'd31);
        check(4'b0000, 6'd63, 6'd63, 6'd62);

        // ---------------------------------
        // 2. SUB (0001)
        // ---------------------------------
        $display("\n--- SUB ---");

        check(4'b0001, 6'd0,  6'd0,  6'd0);
        check(4'b0001, 6'd5,  6'd3,  6'd2);
        check(4'b0001, 6'd3,  6'd5,  6'd62);
        check(4'b0001, 6'd0,  6'd1,  6'd63);
        check(4'b0001, 6'd32, 6'd1,  6'd31);
        check(4'b0001, 6'd31, 6'd63, 6'd32);

        // ---------------------------------
        // 3. AND (0010)
        // ---------------------------------
        $display("\n--- AND ---");

        check(4'b0010, 6'b000000, 6'b111111, 6'b000000);
        check(4'b0010, 6'b111111, 6'b111111, 6'b111111);
        check(4'b0010, 6'b101010, 6'b010101, 6'b000000);
        check(4'b0010, 6'b101010, 6'b111100, 6'b101000);

        // ---------------------------------
        // 4. OR (0011)
        // ---------------------------------
        $display("\n--- OR ---");

        check(4'b0011, 6'b000000, 6'b000000, 6'b000000);
        check(4'b0011, 6'b000000, 6'b111111, 6'b111111);
        check(4'b0011, 6'b101010, 6'b010101, 6'b111111);
        check(4'b0011, 6'b101000, 6'b000100, 6'b101100);

        // ---------------------------------
        // 5. XOR (0100)
        // ---------------------------------
        $display("\n--- XOR ---");

        check(4'b0100, 6'b000000, 6'b000000, 6'b000000);
        check(4'b0100, 6'b111111, 6'b111111, 6'b000000);
        check(4'b0100, 6'b101010, 6'b010101, 6'b111111);
        check(4'b0100, 6'b101010, 6'b111100, 6'b010110);

        // ---------------------------------
        // 6. SLL (0101)
        // ---------------------------------
        $display("\n--- SLL ---");

        check(4'b0101, 6'b000001, 6'd0,  6'b000001);
        check(4'b0101, 6'b000001, 6'd1,  6'b000010);
        check(4'b0101, 6'b000001, 6'd5,  6'b100000);
        check(4'b0101, 6'b000011, 6'd2,  6'b001100);
        check(4'b0101, 6'b111111, 6'd1,  6'b111110);
        check(4'b0101, 6'b000001, 6'd6,  6'b000000);

        // ---------------------------------
        // 7. SRL (0110)
        // ---------------------------------
        $display("\n--- SRL ---");

        check(4'b0110, 6'b100000, 6'd0,  6'b100000);
        check(4'b0110, 6'b100000, 6'd1,  6'b010000);
        check(4'b0110, 6'b111111, 6'd1,  6'b011111);
        check(4'b0110, 6'b111111, 6'd5,  6'b000001);
        check(4'b0110, 6'b101010, 6'd2,  6'b001010);
        check(4'b0110, 6'b101010, 6'd6,  6'b000000);

        // ---------------------------------
        // 8. SRA (0111)
        // ---------------------------------
        $display("\n--- SRA ---");

        check(4'b0111, 6'b000000, 6'd1,  6'b000000);
        check(4'b0111, 6'b011111, 6'd1,  6'b001111);
        check(4'b0111, 6'b100000, 6'd1,  6'b110000);
        check(4'b0111, 6'b111111, 6'd1,  6'b111111);
        check(4'b0111, 6'b100000, 6'd5,  6'b111111);
        check(4'b0111, 6'b100000, 6'd6,  6'b111111);

        // ---------------------------------
        // 9. SLT - SIGNED (1000)
        // ---------------------------------
        $display("\n--- SLT SIGNED ---");

        check(4'b1000, 6'b000000, 6'b000000, 6'd0);
        check(4'b1000, 6'b000001, 6'b000010, 6'd1);
        check(4'b1000, 6'b000010, 6'b000001, 6'd0);
        check(4'b1000, 6'b100000, 6'b011111, 6'd1);
        check(4'b1000, 6'b011111, 6'b100000, 6'd0);
        check(4'b1000, 6'b100000, 6'b111111, 6'd1);
        check(4'b1000, 6'b111111, 6'b100000, 6'd0);

        // ---------------------------------
        // 10. SLTU - UNSIGNED (1001)
        // ---------------------------------
        $display("\n--- SLTU UNSIGNED ---");

        check(4'b1001, 6'b000000, 6'b000000, 6'd0);
        check(4'b1001, 6'b000001, 6'b000010, 6'd1);
        check(4'b1001, 6'b000010, 6'b000001, 6'd0);
        check(4'b1001, 6'b011111, 6'b100000, 6'd1);
        check(4'b1001, 6'b100000, 6'b011111, 6'd0);
        check(4'b1001, 6'b000000, 6'b111111, 6'd1);
        check(4'b1001, 6'b111111, 6'b000000, 6'd0);

        // ---------------------------------
        // FINAL SUMMARY
        // ---------------------------------
        $display("\n======================================");
        $display("           TEST SUMMARY");
        $display("======================================");
        $display("Total tests : %0d", passed + failed);
        $display("Passed      : %0d", passed);
        $display("Failed      : %0d", failed);

        if (failed == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: SOME TESTS FAILED");

        $display("======================================");

        $finish;
    end

endmodule
