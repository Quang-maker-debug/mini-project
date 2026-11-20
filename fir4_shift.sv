module fir4_shift (
    input  logic               clk,
    input  logic               rst,
    input  logic               in_valid,
    input  logic signed [7:0]  x_in,
    output logic signed [7:0]  q0,
    output logic signed [7:0]  q1,
    output logic signed [7:0]  q2,
    output logic signed [7:0]  q3
);

    always_ff @(posedge clk) begin
        if (rst) begin
            q0 <= '0;
            q1 <= '0;
            q2 <= '0;
            q3 <= '0;
        end else if (in_valid) begin
            q0 <= x_in;
            q1 <= q0;
            q2 <= q1;
            q3 <= q2;
        end
    end

endmodule