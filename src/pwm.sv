module pwm (
    input   logic       clk,
    input   logic       reset_n,
    input   logic[7:0]  duty_cycle,
    output  logic       pwm_out
);

    logic[9:0] counter;
    logic[9:0] switch_threshold;

    assign switch_threshold = {duty_cycle, 2'b00};

    always_ff @ (posedge clk) begin
        if (~reset_n) begin
            counter <= '0;
        end else begin
            counter <= counter + 1;
        end
    end

    always_ff @ (posedge clk) begin
        if (counter > switch_threshold) begin
            pwm_out <= 1'b0;
        end else begin
            pwm_out <= 1'b1;
        end
    end


endmodule : pwm