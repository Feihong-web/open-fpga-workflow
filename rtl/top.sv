`default_nettype none

module top #(
    parameter integer CLK_HZ   = 12_000_000,
    parameter integer BLINK_HZ = 2
) (
    input  logic CLK,
    output logic LED
);

    localparam integer HALF_PERIOD =
        (CLK_HZ / (2 * BLINK_HZ) < 1) ? 1 : CLK_HZ / (2 * BLINK_HZ);
    localparam integer COUNTER_WIDTH =
        (HALF_PERIOD <= 1) ? 1 : $clog2(HALF_PERIOD);
    localparam logic [COUNTER_WIDTH-1:0] LAST_COUNT =
        COUNTER_WIDTH'(HALF_PERIOD - 1);

    logic [COUNTER_WIDTH-1:0] counter = '0;
    initial LED = 1'b0;

    always_ff @(posedge CLK) begin
        if (counter == LAST_COUNT) begin
            counter <= '0;
            LED     <= ~LED;
        end else begin
            counter <= counter + 1'b1;
        end
    end

endmodule

`default_nettype wire
