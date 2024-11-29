package FIFO_coverage_pkg;

  // Import the previous package
  import FIFO_transaction_pkg::*;

  class FIFO_coverage;
    // Object of the class FIFO_transaction
    FIFO_transaction F_cvg_txn;

    // Function to sample data
    function void sample_data(FIFO_transaction F_txn);
      // Assign F_txn to F_cvg_txn
      F_cvg_txn = F_txn;

      // Trigger the sampling of the covergroup
      sample_covergroup.sample();
    endfunction

    // Covergroup definition
    covergroup sample_covergroup;
      option.per_instance = 1;

      // Define the coverage points for cross coverage
     wr_en_cp: coverpoint F_cvg_txn.wr_en {
        bins enabled = {1};
        bins disabled = {0};
      }

     rd_en_cp: coverpoint F_cvg_txn.rd_en {
        bins enabled = {1};
        bins disabled = {0};
      }

     wr_ack_cp: coverpoint F_cvg_txn.wr_ack {
        bins acked = {1};
        bins not_acked = {0};
      }

     overflow_cp: coverpoint F_cvg_txn.overflow {
        bins overflowed = {1};
        bins not_overflowed = {0};
      }

      underflow_cp: coverpoint F_cvg_txn.underflow {
        bins underflowed = {1};
        bins not_underflowed = {0};
      }

     full_cp: coverpoint F_cvg_txn.full {
        bins full = {1};
        bins not_full = {0};
      }

     empty_cp: coverpoint F_cvg_txn.empty {
        bins empty = {1};
        bins not_empty = {0};
      }

      almost_full_cp:coverpoint F_cvg_txn.almostfull {
        bins almost_full = {1};
        bins not_almost_full = {0};
      }

      almost_empty_cp:coverpoint F_cvg_txn.almostempty {
        bins almost_empty = {1};
        bins not_almost_empty = {0};
      }

      cross wr_en_cp,rd_en_cp,wr_ack_cp;
      cross wr_en_cp,rd_en_cp,overflow_cp;
      cross wr_en_cp,rd_en_cp,full_cp;
      cross wr_en_cp,rd_en_cp,empty_cp;
      cross wr_en_cp,rd_en_cp,almost_full_cp;
      cross wr_en_cp,rd_en_cp,almost_empty_cp;
      cross wr_en_cp,rd_en_cp,underflow_cp;
    endgroup

 // Constructor
    function new();
      F_cvg_txn = new();
      sample_covergroup=new();
    endfunction

  endclass

endpackage
