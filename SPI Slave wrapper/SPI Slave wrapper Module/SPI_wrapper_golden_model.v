module SPI_Wrapper (MOSI , MISO , SS_n , clk , rst_n);

input wire MOSI , SS_n , clk , rst_n ;
output wire MISO ; 

wire [7:0] tx_data ;
wire [9:0] rx_data ; 
wire rx_valid , tx_valid ;
SPI slave_spi (MOSI , MISO , SS_n , clk , rst_n , rx_data , rx_valid , tx_data , tx_valid);
SPI_RAM RAM (clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);
    
endmodule

