module stability_detector (  
    input   logic   clk,
    input   logic   data_in,
    output  logic   data_out
);

    logic[2:0] data_buffer;

    always_ff @ (posedge clk) begin
        data_buffer <= {data_buffer[1:0], data_in};
    end

    always_ff @ (posedge clk) begin
        if (data_buffer == 3'b111) begin
            data_out <= 1'b1;
        end else if (data_buffer == 3'b000) begin
            data_out <= 1'b0;
        end
    end

endmodule : stability_detector