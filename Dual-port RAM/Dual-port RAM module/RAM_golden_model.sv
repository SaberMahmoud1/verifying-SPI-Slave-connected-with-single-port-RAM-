module SPI_RAM #(
    parameter MEM_WIDTH = 8,
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
  )
  (
    input clk,
    input rst_n,

    input [9:0] din,
    input rx_valid,

    output reg [MEM_WIDTH-1:0] dout,
    output reg tx_valid
  );

  reg [MEM_WIDTH-1:0] mem [MEM_DEPTH-1 : 0];
  reg [MEM_WIDTH-1:0] write_addr, read_addr;
  wire read_en, write_en, blk_select;

  always@(posedge clk) begin
    if(~rst_n) begin
      write_addr <=0;
      read_addr <=0;
      tx_valid <=0;
        for(int i=0; i<MEM_DEPTH; i=i+1)begin
			mem[i] <= 0;
		end
    end
    else if(rx_valid)begin
        case (din[9:8])
          2'b00 : write_addr <= din[7:0];
          2'b10 : read_addr <= din[7:0];
          2'b11 : tx_valid <=1;
        endcase
    end
    else
      tx_valid <= 0;
    
  end

  always@(posedge clk) begin
    if(~rst_n) 
      dout <= 0;
    else if(blk_select) begin
      if(write_en) begin
        mem[write_addr] <= din[7:0];  
      end
      if(read_en) begin
        dout <= mem[read_addr];
      end
        
    end
  end

/* Memory Signals */
assign blk_select = (rx_valid == 1 && (read_en || write_en)) ? 1 : 0;
assign read_en = (din[9:8] == 2'b11) ? 1 : 0;
assign write_en = (din[9:8] == 2'b01) ? 1 : 0;

endmodule 