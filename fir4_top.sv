module fir4_top #(
    parameter logic signed [7:0] H0 =  8'sd2,
    parameter logic signed [7:0] H1 = -8'sd1,
    parameter logic signed [7:0] H2 =  8'sd3,
    parameter logic signed [7:0] H3 =  8'sd4
) (
    input  logic               clk,
    input  logic               rst,
    input  logic               in_valid,
    input  logic signed [7:0]  x_in,
    output logic signed [17:0] y_out,
    output logic               out_valid
);

    logic signed [7:0]  q0, q1, q2, q3;
    logic signed [17:0] y_comb;

    fir4_shift u_shift (
        .clk      (clk),
        .rst      (rst),
        .in_valid (in_valid),
        .x_in     (x_in),
        .q0       (q0),
        .q1       (q1),
        .q2       (q2),
        .q3       (q3)
    );

    fir4_datapath #(
        .H0 (H0),
        .H1 (H1),
        .H2 (H2),
        .H3 (H3)
    ) u_datapath (
        .q0     (q0),
        .q1     (q1),
        .q2     (q2),
        .q3     (q3),
        .y_comb (y_comb)
    );

    fir4_out u_out (
        .clk       (clk),
        .rst       (rst),
        .in_valid  (in_valid),
        .y_comb    (y_comb),
        .y_out     (y_out),
        .out_valid (out_valid)
    );

endmodule
