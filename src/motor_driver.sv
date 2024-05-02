`default_nettype none

module motor_driver (
    input   logic               clk,
    input   logic               reset_n,
    input   logic signed[7:0]   setpoint,
    output  logic               pwm_a,
    output  logic               pwm_b
);

    logic[7:0] motor_a_duty_cycle;
    logic[7:0] motor_b_duty_cycle;

    always_ff @ (posedge clk) begin
        if (~reset_n) begin
            motor_a_duty_cycle <= 8'd127;
            motor_b_duty_cycle <= 8'd127;
        end else begin
            motor_a_duty_cycle <= $signed(8'd127) + setpoint;
            motor_b_duty_cycle <= $signed(8'd127) - setpoint;
        end
    end

    pwm a (
        .clk        (clk),
        .reset_n    (reset_n),
        .duty_cycle (motor_a_duty_cycle),
        .pwm_out    (pwm_a)
    );

    pwm b (
        .clk        (clk),
        .reset_n    (reset_n),
        .duty_cycle (motor_b_duty_cycle),
        .pwm_out    (pwm_b)
    );


endmodule : motor_driver