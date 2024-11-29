module SPI (MOSI,MISO,SS_n,clk,rst_n , rx_data , rx_valid , tx_data , tx_valid);
parameter IDLE =3'b000 ;
parameter CHK_CMD=3'b001 ;
parameter WRITE=3'b010 ;
parameter READ_DATA=3'b011 ;
parameter READ_ADD=3'b100 ;

input MOSI, SS_n, clk, rst_n , tx_valid;
input wire [7:0] tx_data;
output reg rx_valid ;
output reg MISO;
output reg [9:0] rx_data;
  

reg [2:0] cs, ns;
    // Parallel output
    reg [9:0] PO;
    wire [7:0] temp;
    // Serial output
    reg SO, flag_rd = 0;
    integer state_count = 0, final_count = 0;

    assign MISO = SO;
    assign rx_data = PO;

    // CS logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // Adding if statement to cover when the reset occurs and removing SS_n from the sensitivity list
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            flag_rd <= 0;
            PO <= 0;
            state_count <= 0;
            SO <= 0;
            final_count <= 0;
        end
        else begin
            if (ns == CHK_CMD) begin
                state_count <= 0;
                final_count <= 0;
            end
            else if ((cs == WRITE) || (cs == READ_ADD) || ((cs == READ_DATA) && (!tx_valid))) begin
                if (state_count != 10) begin
                    PO <= {PO[8:0], MOSI};
                    state_count <= state_count + 1;
                    rx_valid <= 0;
                end
                else begin
                    rx_valid <= 1;
                end
            end
            else if ((cs == READ_DATA) && tx_valid) begin
                SO <= tx_data[7 - final_count];
                final_count <= final_count + 1;
            end
        end
    end

    // NS logic
    // Corrections on the flow for rd_flag
    always @(MOSI, SS_n, cs) begin
        case (cs)
            IDLE: begin
                if (SS_n)
                    ns = IDLE;
                else
                    ns = CHK_CMD;
            end
            CHK_CMD:
                if (SS_n)
                    ns = IDLE;
                else begin
                    if (!MOSI)
                        ns = WRITE;
                    else begin
                        if (!flag_rd)
                            ns = READ_ADD;
                        else
                            ns = READ_DATA;
                    end
                end

            WRITE: begin
                if (SS_n)
                    ns = IDLE;
                else
                    ns = WRITE;
            end

            READ_ADD:
                if (SS_n)
                    ns = IDLE;
                else begin
                    ns = READ_ADD;
                    flag_rd = 1;
                end

            READ_DATA:
                if (SS_n)
                    ns = IDLE;
                else begin
                    ns = READ_DATA;
                    flag_rd = 0;
                end
            default: ns = IDLE;
        endcase
    end

endmodule