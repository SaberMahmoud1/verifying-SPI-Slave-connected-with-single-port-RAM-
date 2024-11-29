interface SPI_Interface(clk);
  // Define signals in the interface
  input logic clk;  
  logic MOSI, SS_n, rst_n;
  logic MISO;
  logic rx_valid, tx_valid;
  logic [9:0] rx_data;
  logic [7:0] tx_data;
  // Specify directions for the signals
  modport RAM (
    input clk, rst_n, rx_valid,rx_data,
	output tx_valid,tx_data
  );

  modport Slave (
   input MOSI, SS_n, clk, rst_n, tx_valid,tx_data,
   output MISO,rx_valid,rx_data
  );

  modport TEST (
   input MOSI,SS_n,clk,rst_n,
   output MISO,tx_data                         //we added tx_data to TB for checking simplicity only but its not useful there
  );
endinterface