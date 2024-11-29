////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design with Interface
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO (FIFO_Interface.DUT fifo_intf);
  localparam max_fifo_addr = $clog2(fifo_intf.FIFO_DEPTH);
  reg [fifo_intf.FIFO_WIDTH-1:0] mem [fifo_intf.FIFO_DEPTH-1:0];
  reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
  reg [max_fifo_addr:0] count;

  always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
    if (!fifo_intf.rst_n) begin
      wr_ptr <= 0;
    end
    //adding brakets to make sure the operations is in right sequence
    else if (fifo_intf.wr_en && (count < fifo_intf.FIFO_DEPTH)) begin
      mem[wr_ptr] <= fifo_intf.data_in;
      fifo_intf.wr_ack <= 1;
      wr_ptr <= wr_ptr + 1;
    end
    else begin 
      fifo_intf.wr_ack <= 0; 
      //should be logic and(&&) not bit wise and (&) 
      if (fifo_intf.full && fifo_intf.wr_en)
        fifo_intf.overflow <= 1;
      else
        fifo_intf.overflow <= 0;
    end
  end

  always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
    if (!fifo_intf.rst_n) begin
      rd_ptr <= 0;
      fifo_intf.underflow<=0;
    end
    else if (fifo_intf.rd_en && count != 0) begin
      fifo_intf.data_out <= mem[rd_ptr];
      rd_ptr <= rd_ptr + 1;
    end
    //making the underflow seq
    else begin  
      if (fifo_intf.empty && fifo_intf.rd_en)
        fifo_intf.underflow <= 1;
      else
        fifo_intf.underflow <= 0;
    end
  end

  always @(posedge fifo_intf.clk or negedge fifo_intf.rst_n) begin
    if (!fifo_intf.rst_n) begin
      count <= 0;
    end
    else begin
      if ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b10 && !fifo_intf.full) 
        count <= count + 1;
      else if ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b01 && !fifo_intf.empty)
        count <= count - 1;
    //adding case to cover if the read and write both enabled and the mem is FULL
      else if ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b11 && fifo_intf.full)
        count <= count - 1;

      else if ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b11 && fifo_intf.empty)
        count <= count + 1;  
    end
  end

  assign fifo_intf.full = (count === fifo_intf.FIFO_DEPTH) ? 1 : 0;
  assign fifo_intf.empty = (count === 0) ? 1 : 0;
  assign fifo_intf.almostfull = (count === fifo_intf.FIFO_DEPTH-1) ? 1 : 0; 
  assign fifo_intf.almostempty = (count === 1) ? 1 : 0;



  `ifdef SIM_PARAM
  //combinational
  property p1;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (count == fifo_intf.FIFO_DEPTH) |-> fifo_intf.full ;
  endproperty

  property p2;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (count == 0) |-> fifo_intf.empty ;
  endproperty

  property p3;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (count == fifo_intf.FIFO_DEPTH-1) |-> fifo_intf.almostfull ;
  endproperty

  property p4;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (count == 1) |-> fifo_intf.almostempty ;
  endproperty
  
  //sequential

  
  property p5;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (fifo_intf.empty && fifo_intf.rd_en) |=> fifo_intf.underflow;
  endproperty

  property p6;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (fifo_intf.wr_en && count < fifo_intf.FIFO_DEPTH) |=> (fifo_intf.wr_ack) ;
  endproperty

  property p7;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) (fifo_intf.full && fifo_intf.wr_en) |=> (fifo_intf.overflow) ;
  endproperty

  property p8;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b10 && !fifo_intf.full) |=> count==($past(count)+3'b001);
  endproperty

  property p9;
  @(posedge fifo_intf.clk) disable iff (!fifo_intf.rst_n) ({fifo_intf.wr_en, fifo_intf.rd_en} == 2'b01 && !fifo_intf.empty) |=> count==($past(count)-3'b001);
  endproperty


  // Assertion for full flag
  assert property (p1);
  cover property (p1);

  // Assertion for empty flag
  assert property (p2);
  cover property (p2);

  // Assertion for almostfull flag
  assert property (p3);
  cover property (p3);

  // Assertion for almostempty flag
  assert property (p4);
  cover property (p4);

  // Assertion for wr_ack
  assert property (p5);
  cover property (p5);

  // Assertion for overflow
  assert property (p6);
  cover property (p6);

  // Assertion for underflow
  assert property (p7); 
  cover property (p7);

  // Assertion for the internal count
  assert property (p8);
  cover property (p8);

  assert property (p9);
  cover property (p9);
  // End of assertions
`endif



endmodule
