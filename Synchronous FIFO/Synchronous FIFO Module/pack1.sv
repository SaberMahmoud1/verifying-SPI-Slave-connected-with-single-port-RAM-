package FIFO_transaction_pkg;
  class FIFO_transaction;
    // Properties for FIFO inputs and outputs
    rand logic [15:0] data_in;
    rand logic wr_en;
    rand logic rd_en;
    rand logic rst_n;
    logic [15:0] data_out;
    logic wr_ack;
    logic overflow;
    logic full;
    logic empty;
    logic almostfull;
    logic almostempty;
    logic underflow;

    // Properties for distribution values
    int WR_EN_ON_DIST = 70;
    int RD_EN_ON_DIST = 30;

    // Constraint block 1: Assert reset less often
    constraint reset_constraint {
      // Customize the distribution as needed
    rst_n dist {1:=98, 0:=2};
    }

    // Constraint block 2: Constraint for write enable
    constraint wr_en_constraint {
      wr_en dist {
        1:=WR_EN_ON_DIST,
        0:=100-WR_EN_ON_DIST
      };
    }

    // Constraint block 3: Constraint for read enable
    constraint rd_en_constraint {
      rd_en dist {
        1:=RD_EN_ON_DIST,
        0:=100-RD_EN_ON_DIST
      };
    }
  endclass
endpackage
