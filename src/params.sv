module params (
    input   logic       clk,
    input   logic       reset_n,
    input   logic       write_en,
    input   logic       address,
    input   logic[7:0]  param,
    output  logic[7:0]  p,
    output  logic[7:0]  setpoint
);  

    always_ff @ (posedge clk) begin
        if (~reset_n) begin
            p        <= 16;
            setpoint <= 127;
        end else begin
            if (write_en) begin
                case (address)
                    0: p        <= param;
                    1: setpoint <= param;
                endcase
            end
        end
    end

endmodule : params