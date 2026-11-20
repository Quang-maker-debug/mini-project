module fir4_out (
    input  logic               clk,
    input  logic               rst,
    input  logic               in_valid,
    input  logic signed [17:0] y_comb,
    output logic signed [17:0] y_out,
    output logic               out_valid
);

    logic sample_valid;

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_valid <= 1'b0;
            out_valid    <= 1'b0;
            y_out        <= '0;
        end else begin
            sample_valid <= in_valid;
            out_valid    <= sample_valid;

            if (sample_valid) begin
                y_out <= y_comb;
            end
        end
    end

endmodule
