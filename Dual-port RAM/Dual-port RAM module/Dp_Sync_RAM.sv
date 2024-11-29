module Dp_Sync_RAM(clk, rst_n, din, rx_valid, dout, tx_valid);
	parameter MEM_DEPTH = 256;
	parameter ADDR_SIZE = 8;

	input clk, rst_n, rx_valid;
	input [9:0] din;
	output reg tx_valid;
	output reg [7:0] dout;


	reg [7:0] mem [MEM_DEPTH-1:0];
	reg [ADDR_SIZE-1:0] addr_rd;
	reg [ADDR_SIZE-1:0] addr_wr;

	integer i;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
		   dout <= 0;
		   addr_rd<=0;
		   addr_wr<=0;
		   tx_valid<=0;
		   for(i=0; i<MEM_DEPTH; i=i+1)
			mem[i] <= 0;
		end
		else if (rx_valid) begin
		   tx_valid <= 1'b0;
		   case (din[9:8])
			2'b00: addr_wr <= din[7:0];
			2'b01: mem[addr_wr] <= din[7:0];
			2'b10: addr_rd <= din[7:0];
			2'b11: {dout, tx_valid} <= {mem[addr_rd], 1'b1};
		   endcase
		end
	end

	`ifdef SIM_PARAM
 
  //sequential
  property p1;
  @(posedge clk) disable iff (!rst_n) (tx_valid && (din[9:8]==3)) |=> dout==(mem[$past(addr_rd)]) ;
  endproperty

  property p2;
  @(posedge clk) disable iff (!rst_n) (rx_valid && (din[9:8]==3)) |=> tx_valid==1'b1 ;
  endproperty


  // Assertion for write
  assert property (p1);
  cover property (p1);

  // Assertion for tx valid
  assert property (p2);
  cover property (p2);
`endif


endmodule
