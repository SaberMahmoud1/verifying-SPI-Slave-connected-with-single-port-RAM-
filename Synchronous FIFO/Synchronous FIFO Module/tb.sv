import shared_pkg::*;
import FIFO_transaction_pkg::*;

module FIFO_TB (FIFO_Interface.TEST fifo_intf);

  localparam TESTS=100000;  
  FIFO_transaction F_txn_tb=new;  

  initial begin
    fifo_intf.rst_n=0;
    @(negedge fifo_intf.clk);
    fifo_intf.rst_n=1;
    for(int i=0;i<TESTS;i++)begin
        @(negedge fifo_intf.clk);
        assert(F_txn_tb.randomize());
        fifo_intf.data_in=F_txn_tb.data_in;
        fifo_intf.wr_en=F_txn_tb.wr_en;
        fifo_intf.rd_en=F_txn_tb.rd_en;
        fifo_intf.rst_n=F_txn_tb.rst_n;
    end
    test_finished=1;
  end


endmodule