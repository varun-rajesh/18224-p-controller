module spi_mcp3202_interface_tb;
    logic       sys_clk;
    logic       sys_reset_n;
    logic       spi_clk;
    logic       spi_miso;
    logic       spi_mosi;
    logic       spi_cs_n;
    logic[11:0] sensor_reading;
    logic       reading_valid;

    initial begin
        sys_clk = 1'b0;
        forever #5 sys_clk = ~sys_clk;
    end

    initial begin
        sys_reset_n = 1'b0;

        #15;
        sys_reset_n = 1'b1;
    end

    initial begin
        spi_miso = 1'b0;
        forever #2000 spi_miso = ~spi_miso;
    end

    initial begin
        #100000;

        $stop;
        $finish;
    end

    initial begin
        @ (posedge reading_valid);
        if (sensor_reading == 12'h7e0) begin
            $display("MCP3202 Interface Passes");
        end else begin
            $display("MCP3202 Interfaec Fails");
        end
    end

    spi_mcp3202_interface dut (.*);

endmodule : spi_mcp3202_interface_tb