`default_nettype none
`timescale 10ps/1ps

module tb_alu_32bit;

    // Inputs to the ALU
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  alu_opc;

    // Outputs from the ALU
    wire [31:0] result;
    wire        zero;

    integer tests;
    integer errors;

    // Instantiate the ALU
    tt_um_alu_32bit #(
        .WIDTH(32)
    ) DUT (
        .A(A),
        .B(B),
        .alu_opc(alu_opc),
        .result(result),
        .zero(zero)
    );

    // Self-checking test task
    task run_test;
        input [31:0] test_A;
        input [31:0] test_B;
        input [3:0]  test_op;
        input [31:0] expected;

        reg expected_zero;

        begin
            A       = test_A;
            B       = test_B;
            alu_opc = test_op;

            // Expected zero flag
            expected_zero = (expected == 32'b0);

            // Allow combinational logic to settle
            #10;

            tests = tests + 1;

            if ((result !== expected) ||
                (zero !== expected_zero)) begin

                errors = errors + 1;

                $display("FAIL | OP=%b A=%h B=%h",
                         test_op, test_A, test_B);
                $display("     | Expected=%h Zero=%b",
                         expected, expected_zero);
                $display("     | Actual  =%h Zero=%b",
                         result, zero);
            end
            else begin
                $display("PASS | OP=%b A=%h B=%h Result=%h Zero=%b",
                         test_op, test_A, test_B, result, zero);
            end
        end
    endtask

    initial begin
        A       = 32'b0;
        B       = 32'b0;
        alu_opc = 4'b0;
        tests   = 0;
        errors  = 0;

        $display("======================================");
        $display("       32-BIT ALU VERIFICATION");
        $display("======================================");

        // 0000: ADD
        run_test(32'd5, 32'd3, 4'b0000, 32'd8);
        run_test(32'h7FFFFFFF, 32'd1,
                 4'b0000, 32'h80000000);

        // 0001: SUB
        run_test(32'd5, 32'd5, 4'b0001, 32'd0);
        run_test(32'd3, 32'd5, 4'b0001, 32'hFFFFFFFE);

        // 0010: AND
        run_test(32'hF0F0F0F0, 32'h0FF00FF0,
                 4'b0010, 32'h00F000F0);

        // 0011: OR
        run_test(32'hF0000000, 32'h0000000F,
                 4'b0011, 32'hF000000F);

        // 0100: XOR
        run_test(32'hAAAAAAAA, 32'hFFFFFFFF,
                 4'b0100, 32'h55555555);

        // 0101: SLL
        run_test(32'd1, 32'd4, 4'b0101, 32'd16);
        run_test(32'd1, 32'd31,
                 4'b0101, 32'h80000000);

        // 0110: SRL
        run_test(32'h80000000, 32'd1,
                 4'b0110, 32'h40000000);
        run_test(32'hFFFFFFFF, 32'd31,
                 4'b0110, 32'd1);

        // 0111: SRA
        run_test(32'h80000000, 32'd1,
                 4'b0111, 32'hC0000000);
        run_test(32'h80000000, 32'd31,
                 4'b0111, 32'hFFFFFFFF);
        run_test(32'h40000000, 32'd1,
                 4'b0111, 32'h20000000);

        // 1000: SLT (signed comparison)
        run_test(32'hFFFFFFFF, 32'd1,
                 4'b1000, 32'd1);
        run_test(32'd5, 32'd3, 4'b1000, 32'd0);
        run_test(32'h80000000, 32'd1,
                 4'b1000, 32'd1);

        // 1001: SLTU (unsigned comparison)
        run_test(32'hFFFFFFFF, 32'd1,
                 4'b1001, 32'd0);
        run_test(32'd3, 32'd5, 4'b1001, 32'd1);
        run_test(32'h80000000, 32'd1,
                 4'b1001, 32'd0);

        // ADD
        run_test(32'hFFFFFFFF, 32'd1, 4'b0000, 32'h00000000);
        run_test(32'h7FFFFFFF, 32'd1, 4'b0000, 32'h80000000);

        // SUB
        run_test(32'd0, 32'd1, 4'b0001, 32'hFFFFFFFF);
        run_test(32'h80000000, 32'd1, 4'b0001, 32'h7FFFFFFF);

        // AND, OR, XOR
        run_test(32'hFFFFFFFF, 32'h00000000, 4'b0010, 32'h00000000);
        run_test(32'hAAAAAAAA, 32'h55555555, 4'b0011, 32'hFFFFFFFF);
        run_test(32'hAAAAAAAA, 32'hAAAAAAAA, 4'b0100, 32'h00000000);

        // SLL, SRL, SRA
        run_test(32'h00000001, 32'd31, 4'b0101, 32'h80000000);
        run_test(32'h80000000, 32'd31, 4'b0110, 32'h00000001);
        run_test(32'h80000000, 32'd31, 4'b0111, 32'hFFFFFFFF);

        // SLT (signed) and SLTU (unsigned)
        run_test(32'hFFFFFFFF, 32'd1, 4'b1000, 32'd1);
        run_test(32'hFFFFFFFF, 32'd1, 4'b1001, 32'd0);
        run_test(32'h80000000, 32'h7FFFFFFF, 4'b1000, 32'd1);
        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b1001, 32'd0);

        // Unsupported opcode: default result must be zero
        run_test(32'h12345678, 32'h87654321,
                 4'b1010, 32'd0);


        // Final summary
        $display("");
        $display("======================================");
        $display("             TEST SUMMARY");
        $display("======================================");
        $display("Total tests : %0d", tests);
        $display("Passed      : %0d", tests - errors);
        $display("Failed      : %0d", errors);

        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: VERIFICATION FAILED");

        $display("======================================");

        $finish;
    end

endmodule
