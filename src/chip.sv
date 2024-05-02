`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);

    top dut (
        .clk            (clock),
        .reset_n        (~reset),   
        .input_spi_clk  (io_in[11]),
        .input_spi_mosi (io_in[10]),
        .input_spi_cs_n (io_in[9]),
        .adc_spi_clk    (io_out[11]),
        .adc_spi_miso   (io_in[8]),
        .adc_spi_mosi   (io_out[10]),
        .adc_spi_cs_n   (io_out[9]),
        .pwm_a          (io_out[8]),
        .pwm_b          (io_out[7])
    );

endmodule : my_chip