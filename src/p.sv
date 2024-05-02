module p_controller (
    input   logic               clk,
    input   logic               reset_n,
    input   logic[11:0]         sensor_reading,
    input   logic[7:0]          setpoint,
    input   logic[7:0]          p,
    output  logic signed[7:0]   output_setpoint
);

    logic[7:0]          round_reading;
    logic signed[8:0]   error;
    logic signed[17:0]  internal_output_setpoint;

    always_ff @ (posedge clk) begin
        if (sensor_reading[3] == 1'b1 && sensor_reading[11:4] != '1) begin
            round_reading <= sensor_reading[11:4] + 1;
        end else begin
            round_reading <= sensor_reading[11:4];
        end
    end

    always_ff @ (posedge clk) begin
        error <= $signed(setpoint) - $signed(round_reading);
    end

    always_ff @ (posedge clk) begin
        internal_output_setpoint <= error * $signed({1'b0, p});
    end

    always_ff @ (posedge clk) begin
        output_setpoint <= (internal_output_setpoint >>> 10);
    end



endmodule : p_controller