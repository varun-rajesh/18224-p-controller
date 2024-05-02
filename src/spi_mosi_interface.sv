module spi_mosi_interface # (
    parameter WIDTH = 16
) (
    input   logic                   sys_clk,
    input   logic                   sys_reset_n,
    input   logic                   spi_clk,
    input   logic                   spi_mosi,
    input   logic                   spi_cs_n,
    output  logic[WIDTH-1:0]        mosi_buffer,
    output  logic                   mosi_buffer_valid
);

    logic sync_spi_clk;
    logic sync_spi_mosi;

    logic sync_spi_cs_n;
    logic sync_spi_cs_n_del;
    logic internal_reset_n;

    logic[$clog2(WIDTH):0] mosi_buffer_counter;
    always_ff @ (posedge sys_clk, negedge sys_reset_n) begin
        if (~sys_reset_n) begin
            internal_reset_n <= 1'b0;
            sync_spi_cs_n_del <= 1'b1;
        end else begin
            if (sync_spi_cs_n == 1'b0 && sync_spi_cs_n_del == 1'b1) begin
                internal_reset_n <= 1'b0;
            end else begin
                internal_reset_n <= 1'b1;
            end
            sync_spi_cs_n_del <= sync_spi_cs_n;
        end
    end

    always_ff @ (posedge sync_spi_clk, negedge internal_reset_n) begin
        if (~internal_reset_n) begin
            mosi_buffer_counter <= '0;
            mosi_buffer <= '0;
        end else begin
            mosi_buffer <= {mosi_buffer[WIDTH-2:0], sync_spi_mosi};
            mosi_buffer_counter <= mosi_buffer_counter + 1'b1;
        end
    end

    assign mosi_buffer_valid = (mosi_buffer_counter == WIDTH);

    stability_detector clk (sys_clk, spi_clk, sync_spi_clk);
    stability_detector mosi (sys_clk, spi_mosi, sync_spi_mosi);
    stability_detector cs_n (sys_clk, spi_cs_n, sync_spi_cs_n);


endmodule : spi_mosi_interface
