`timescale 1ns/1ps
`default_nettype none

module tb_top;

    logic clk = 1'b0;
    logic led;
    integer toggle_count = 0;
    logic previous_led;

    always #5 clk = ~clk;

    top #(
        .CLK_HZ(100),
        .BLINK_HZ(5)
    ) dut (
        .CLK(clk),
        .LED(led)
    );

    initial begin
        $dumpfile("build/wave.vcd");
        $dumpvars(0, tb_top);
        previous_led = led;

        repeat (100) begin
            @(posedge clk);
            #1;
            if (led !== previous_led) begin
                toggle_count = toggle_count + 1;
                previous_led = led;
            end
        end

        if (toggle_count < 8) begin
            $fatal(1, "FAIL: expected at least 8 LED toggles, observed %0d", toggle_count);
        end

        $display("PASS: observed %0d LED toggles", toggle_count);
        $finish;
    end

endmodule

`default_nettype wire
