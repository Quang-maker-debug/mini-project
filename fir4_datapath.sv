module fir4_datapath #(
    parameter logic signed [7:0] H0 =  8'sd2,
    parameter logic signed [7:0] H1 = -8'sd1,
    parameter logic signed [7:0] H2 =  8'sd3,
    parameter logic signed [7:0] H3 =  8'sd4
) (
    input  logic signed [7:0]  q0,
    input  logic signed [7:0]  q1,
    input  logic signed [7:0]  q2,
    input  logic signed [7:0]  q3,
    output logic signed [17:0] y_comb
);

    logic signed [15:0] p0, p1, p2, p3;
    logic signed [16:0] s01, s23;

    assign p0 = q0 * H0;
    assign p1 = q1 * H1;
    assign p2 = q2 * H2;
    assign p3 = q3 * H3;

    assign s01 = $signed({p0[15], p0}) + $signed({p1[15], p1});
    assign s23 = $signed({p2[15], p2}) + $signed({p3[15], p3});

    assign y_comb = $signed({s01[16], s01})
                  + $signed({s23[16], s23});

endmodule