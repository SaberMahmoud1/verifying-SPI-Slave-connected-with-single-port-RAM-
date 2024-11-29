import shared_pak::*;
module Dp_Sync_RAM(SPI_Interface.RAM RAM_intf);
	//intfnal signals declaration

	reg [7:0] mem [MEM_DEPTH-1:0];
	reg [ADDR_SIZE-1:0] addr_rd;
	reg [ADDR_SIZE-1:0] addr_wr;

	integer i;
	always @(posedge RAM_intf.clk,negedge RAM_intf.rst_n) begin
		if (!RAM_intf.rst_n) begin
		   RAM_intf.tx_data <= 0;
		   addr_rd<=0;
		   addr_wr<=0;
		   RAM_intf.tx_valid<=0;
		   for(i=0; i<MEM_DEPTH; i=i+1)
			mem[i] <= 0;
		end
		else if (RAM_intf.rx_valid) begin
		   RAM_intf.tx_valid <= 0;
		   casex (RAM_intf.rx_data[9:8])
			2'b00: addr_wr <= RAM_intf.rx_data[7:0];
			2'b01: mem[addr_wr] <= RAM_intf.rx_data[7:0];
			2'b10: addr_rd <= RAM_intf.rx_data[7:0];
			2'b11: {RAM_intf.tx_data, RAM_intf.tx_valid} <= {mem[addr_rd], 1'b1};
		   endcase
		end
	end

`ifdef SIM_PARAM
 
  //sequential
  property p1;
  @(posedge RAM_intf.clk) disable iff (!RAM_intf.rst_n) (RAM_intf.tx_valid && (RAM_intf.rx_data[9:8]==3)) |=> RAM_intf.tx_data==(mem[$past(addr_rd)]) ;
  endproperty

  property p2;
  @(posedge RAM_intf.clk) disable iff (!RAM_intf.rst_n) (RAM_intf.rx_valid && (RAM_intf.rx_data[9:8]==3)) |=> RAM_intf.tx_valid==1'b1 ;
  endproperty

  property p3;
  @(posedge RAM_intf.clk) disable iff (!RAM_intf.rst_n) (RAM_intf.rx_valid && (RAM_intf.rx_data[9:8]==1)) |=>mem[addr_wr]==$past(RAM_intf.rx_data[7:0]);
  endproperty



  // Assertion for read
  assert property (p1);
  cover property (p1);

  // Assertion for tx valid
  assert property (p2);
  cover property (p2);

   // Assertion for write
  assert property (p3);
  cover property (p3);
`endif

endmodule
