import shared_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_transaction_pkg::*;
module FIFO_monitor (FIFO_Interface.monitor fifo_intf);
  // Create objects of FIFO_transaction, FIFO_scoreboard, and FIFO_coverage classes
  FIFO_transaction F_txn=new;
  FIFO_scoreboard F_sb=new;
  FIFO_coverage F_cov=new;

  initial  begin
    forever begin
    @(negedge fifo_intf.clk);
      // Sample the interface ports and assign them to F_txn
      F_txn.data_in = fifo_intf.data_in;
      F_txn.wr_en = fifo_intf.wr_en;
      F_txn.rd_en = fifo_intf.rd_en;
      F_txn.rst_n=fifo_intf.rst_n;
      F_txn.data_out=fifo_intf.data_out;
      F_txn.wr_ack=fifo_intf.wr_ack;
      F_txn.overflow=fifo_intf.overflow;
      F_txn.full=fifo_intf.full;
      F_txn.empty=fifo_intf.empty;
      F_txn.almostfull=fifo_intf.almostfull;
      F_txn.almostempty=fifo_intf.almostempty;
      F_txn.underflow=fifo_intf.underflow;

      // Fork-join block
      fork 
      //process one
      begin
        // Call the sample_data function of FIFO_coverage
        F_cov.sample_data(F_txn);
      end
      //process two
      begin
        // Call the check_data function of FIFO_scoreboard
        F_sb.check_data(F_txn);
      end

      join_none

      // Check if the simulation should finish
      if (test_finished == 1) begin
        $display("Simulation finished. Summary:");
        $display("Correct Count: %d", correct_count);
        $display("Error Count: %d", error_count);
        $stop;
      end
    end
  end  
endmodule
