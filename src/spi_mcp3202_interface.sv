module spi_mcp3202_interface (
    input   logic       sys_clk,
    input   logic       sys_reset_n,
    output  logic       spi_clk,
    input   logic       spi_miso,
    output  logic       spi_mosi,
    output  logic       spi_cs_n,
    output  logic[11:0] sensor_reading,
    output  logic       reading_valid
);

    typedef enum {IDLE, START, SGL, SIGN, MSBF, NULL,
                  DATA11, DATA10, DATA9, DATA8, DATA7, DATA6, DATA5, DATA4, DATA3, DATA2, DATA1, DATA0,
                  DONENC, DONE, DONEW} controller_state;     

    controller_state state;
    controller_state next_state;

    logic[4:0] counter;
    logic[8:0] done_counter;

    always_ff @ (posedge sys_clk) begin
        if (~sys_reset_n) begin
            counter <= '0;
            done_counter <= '0;
            state <= IDLE;
        end else begin
            counter <= counter + 1;

            if (state == DONE) begin
                done_counter <= '0;
            end else begin
                done_counter <= done_counter + 1;
            end

            state <= next_state;
        end
    end

    always_ff @ (posedge sys_clk) begin
        spi_clk <= (next_state == IDLE || next_state == DONEW) ? 1'b0 : counter[4];
        spi_cs_n <= (next_state == IDLE || next_state == DONEW);
    end

    always_ff @ (posedge sys_clk) begin
        if (next_state == START) begin
            spi_mosi <= 1'b1;
        end else if (next_state == SGL) begin
            spi_mosi <= 1'b1;
        end else if (next_state == SIGN) begin
            spi_mosi <= 1'b0;
        end else if (next_state == MSBF) begin
            spi_mosi <= 1'b1;
        end else begin
            spi_mosi <= 1'b0;
        end
    end

    always_ff @ (posedge sys_clk) begin
        if (counter == 5'b10000) begin
            if (next_state == DATA11) begin
                sensor_reading[11] <= spi_miso;
            end else if (next_state == DATA10) begin
                sensor_reading[10] <= spi_miso;
            end else if (next_state == DATA9) begin
                sensor_reading[9] <= spi_miso;
            end else if (next_state == DATA8) begin
                sensor_reading[8] <= spi_miso;
            end else if (next_state == DATA7) begin
                sensor_reading[7] <= spi_miso;
            end else if (next_state == DATA6) begin
                sensor_reading[6] <= spi_miso;
            end else if (next_state == DATA5) begin
                sensor_reading[5] <= spi_miso;
            end else if (next_state == DATA4) begin
                sensor_reading[4] <= spi_miso;
            end else if (next_state == DATA3) begin
                sensor_reading[3] <= spi_miso;
            end else if (next_state == DATA2) begin
                sensor_reading[2] <= spi_miso;
            end else if (next_state == DATA1) begin
                sensor_reading[1] <= spi_miso;
            end else if (next_state == DATA0) begin
                sensor_reading[0] <= spi_miso;
            end else if (next_state == DONENC) begin
                reading_valid <= 1'b1;
            end
        end else begin
            reading_valid <= 1'b0;
        end
    end

    always_comb begin
        next_state = state;
        if (counter == 5'b00000) begin
            case (state)
                IDLE:   next_state = START;
                START:  next_state = SGL;
                SGL:    next_state = SIGN;
                SIGN:   next_state = MSBF;
                MSBF:   next_state = NULL;
                NULL:   next_state = DATA11;
                DATA11: next_state = DATA10;
                DATA10: next_state = DATA9;
                DATA9:  next_state = DATA8;
                DATA8:  next_state = DATA7;
                DATA7:  next_state = DATA6;
                DATA6:  next_state = DATA5;
                DATA5:  next_state = DATA4;
                DATA4:  next_state = DATA3;
                DATA3:  next_state = DATA2;
                DATA2:  next_state = DATA1;
                DATA1:  next_state = DATA0;
                DATA0:  next_state = DONENC;
                DONENC: next_state = DONE;
                DONE:   next_state = DONEW;
                DONEW:  next_state = (&done_counter) ? IDLE : DONEW;
            endcase 
        end
    end

endmodule : spi_mcp3202_interface