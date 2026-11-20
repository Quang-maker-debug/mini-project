`timescale 1ns/1ps

module fir4_top_tb;

    logic clk;
    logic rst;
    logic in_valid;
    logic signed [7:0]  x_in;
    logic signed [17:0] y_out;
    logic               out_valid;

    // Signals copied from the DUT for convenient waveform observation.
    logic signed [7:0]  q0, q1, q2, q3;
    logic signed [17:0] y_comb;
    logic               sample_valid;

    integer cycle;
    integer error_count;

    fir4_top dut (
        .clk       (clk),
        .rst       (rst),
        .in_valid  (in_valid),
        .x_in      (x_in),
        .y_out     (y_out),
        .out_valid (out_valid)
    );

    assign q0           = dut.q0;
    assign q1           = dut.q1;
    assign q2           = dut.q2;
    assign q3           = dut.q3;
    assign y_comb       = dut.y_comb;
    assign sample_valid = dut.u_out.sample_valid;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_cycle (
        input logic               rst_value,
        input logic               valid_value,
        input integer             data_value,
        input logic               expected_out_valid,
        input logic signed [17:0] expected_y_out
    );
        begin
            // First call drives at 0 ns. Later calls drive at falling edges.
            rst      = rst_value;
            in_valid = valid_value;
            x_in     = data_value[7:0];

            @(posedge clk);
            #1;

            assert (out_valid === expected_out_valid)
            else begin
                error_count = error_count + 1;
                $error("Cycle %0d: out_valid=%b, expected=%b",
                       cycle, out_valid, expected_out_valid);
            end

            assert (y_out === expected_y_out)
            else begin
                error_count = error_count + 1;
                $error("Cycle %0d: y_out=%0d, expected=%0d",
                       cycle, y_out, expected_y_out);
            end

            $display("Cycle %0d: rst=%b in_valid=%b x_in=%0d q=[%0d,%0d,%0d,%0d] sample_valid=%b y_comb=%0d out_valid=%b y_out=%0d",
                     cycle, rst, in_valid, x_in, q0, q1, q2, q3,
                     sample_valid, y_comb, out_valid, y_out);

            cycle = cycle + 1;
            @(negedge clk);
        end
    endtask

    initial begin
        rst         = 1'b1;
        in_valid    = 1'b0;
        x_in        = '0;
        cycle       = 0;
        error_count = 0;
        // Cycles 0-16 reproduce the table approved in Step 2.
        check_cycle(1, 0,    0, 0,    0); // 0: reset
        check_cycle(0, 1,   10, 0,    0); // 1: first sample
        check_cycle(0, 1,   -4, 1,   20); // 2: receive and output together
        check_cycle(0, 0,    0, 1,  -18); // 3: drain pending result
        check_cycle(0, 1,    6, 0,  -18); // 4: resume input
        check_cycle(0, 1,   -2, 1,   46); // 5
        check_cycle(0, 0,    0, 1,   18); // 6
        check_cycle(0, 0,    0, 0,   18); // 7: hold output
        check_cycle(0, 1,    0, 0,   18); // 8: zero is a valid sample
        check_cycle(0, 0,  127, 1,    4); // 9: ignore invalid data
        check_cycle(0, 0, -128, 0,    4); // 10
        check_cycle(0, 1,    5, 0,    4); // 11: pending result is 28
        check_cycle(1, 1,    9, 0,    0); // 12: reset cancels pending result
        check_cycle(0, 0,   55, 0,    0); // 13: idle after reset
        check_cycle(0, 1, -128, 0,    0); // 14: minimum signed input
        check_cycle(0, 1,  127, 1, -256); // 15: maximum signed input
        check_cycle(0, 0,    0, 1,  382); // 16: final pending result

        check_cycle(1, 0,    0, 0,    0); // 17: clear previous history
        check_cycle(0, 1,    1, 0,    0); // 18
        check_cycle(0, 1,    0, 1,    2); // 19: H0
        check_cycle(0, 1,    0, 1,   -1); // 20: H1
        check_cycle(0, 1,    0, 1,    3); // 21: H2
        check_cycle(0, 1,    0, 1,    4); // 22: H3
        check_cycle(0, 0,    0, 1,    0); // 23: response returns to zero
        check_cycle(0, 0,    0, 0,    0); // 24: idle

        if (error_count == 0) begin
            $display("PASS: %0d cycles, %0d output checks passed.", cycle, 2 * cycle);
            $stop;
        end else begin
            $fatal(1, "FAIL: %0d errors detected.", error_count);
        end
    end

    initial begin
        #1000;
        $fatal(1, "FAIL: simulation timed out.");
    end

endmodule
```[cite: 5, 6, 7]