`default_nettype none

module top (
    input   logic       clk,
    input   logic       reset_n,
    input   logic       input_spi_clk,
    input   logic       input_spi_mosi,
    input   logic       input_spi_cs_n,
    output  logic       adc_spi_clk,
    input   logic       adc_spi_miso,
    output  logic       adc_spi_mosi,
    output  logic       adc_spi_cs_n,
    output  logic       pwm_a,
    output  logic       pwm_b,
    output  logic[11:0] sensor_reading_captured,
    output  logic       sensor_reading_valid,
    output  logic[7:0]  setpoint,
    output  logic[7:0]  p,
    output  logic signed[7:0]  motor_setpoint
);

    logic[15:0] input_mosi_buffer;
    logic       input_mosi_buffer_valid;

    logic       param_address;
    logic[7:0]  param_value;

    // logic[7:0]  p;
    // logic[7:0]  setpoint;

    logic[11:0] sensor_reading;
    // logic[11:0] sensor_reading_captured;
    // logic       sensor_reading_valid;

    // logic signed[7:0] motor_setpoint;

    assign param_address = input_mosi_buffer[8];
    assign param_value = input_mosi_buffer[7:0];

    always_ff @ (posedge clk) begin
        if (sensor_reading_valid) begin
            sensor_reading_captured <= sensor_reading;
        end
    end

    spi_mosi_interface # (16) input_spi_interface (
        .sys_clk            (clk),
        .sys_reset_n        (reset_n),
        .spi_clk            (input_spi_clk),
        .spi_mosi           (input_spi_mosi),
        .spi_cs_n           (input_spi_cs_n),
        .mosi_buffer        (input_mosi_buffer),
        .mosi_buffer_valid  (input_mosi_buffer_valid)
    );

    params p_setpoint_storage (
        .clk                (clk),
        .reset_n            (reset_n),
        .write_en           (input_mosi_buffer_valid),
        .address            (param_address),
        .param              (param_value),
        .p                  (p),
        .setpoint           (setpoint)
    );

    spi_mcp3202_interface mcp3202 (
        .sys_clk            (clk),
        .sys_reset_n        (reset_n),
        .spi_clk            (adc_spi_clk),
        .spi_miso           (adc_spi_miso),
        .spi_mosi           (adc_spi_mosi),
        .spi_cs_n           (adc_spi_cs_n),
        .sensor_reading     (sensor_reading),
        .reading_valid      (sensor_reading_valid)
    );

    p_controller p_cont (
        .clk                (clk),
        .reset_n            (reset_n),
        .sensor_reading     (sensor_reading_captured),
        .setpoint           (setpoint),
        .p                  (p),
        .output_setpoint    (motor_setpoint)  
    );

    motor_driver driver (
        .clk                (clk),
        .reset_n            (reset_n),
        .setpoint           (motor_setpoint),
        .pwm_a              (pwm_a),
        .pwm_b              (pwm_b)
    );

endmodule : top