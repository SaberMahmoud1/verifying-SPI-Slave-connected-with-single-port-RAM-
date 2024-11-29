package FIFO_scoreboard_pkg;
  // Import the FIFO_transaction package and the shared package
  import FIFO_transaction_pkg::*;  
  import shared_pkg::*;

  class FIFO_scoreboard;
   parameter FIFO_WIDTH = 16;
   parameter FIFO_DEPTH = 8;
   localparam max_fifo_addr = $clog2(FIFO_DEPTH);
    // Variables for reference values
    logic [15:0] data_out_ref;
    logic full_ref;
    logic empty_ref;
    logic almostfull_ref;
    logic almostempty_ref;
    logic underflow_ref;
    logic overflow_ref;
    logic wr_ack_ref;

    // Error and correct count
  reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
  reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
  reg [max_fifo_addr:0] count;
  int first_check;
    // Constructor
    function new();
      count=0;
      wr_ptr=0;
      rd_ptr=0;
      first_check=1;
    endfunction

    // Function to check data
    function void check_data(FIFO_transaction F_txn);
      // Call the reference_model function
      reference_model(F_txn);

      if(first_check)begin
      first_check=0;
      correct_count++;
      return;
      end
      // Compare the reference outputs with the received object's outputs
     casex ({F_txn.rst_n,F_txn.wr_en,F_txn.rd_en,full_ref,empty_ref})
     //case reset is asserted
      5'b0xxxx: begin
         if(empty_ref===F_txn.empty && full_ref===F_txn.full) begin
          correct_count++;
        end else begin
        error_count++;
        $display("%t Error: Mismatch in FIFO outputs. empty_ref=%d expected=%d full_ref=%d expected=%d",$time,empty_ref,F_txn.empty,full_ref,F_txn.full);
        // You can display more information here if needed.
      end
      end
      //case reading empty fifo
      5'b101x1:begin
         if(underflow_ref===F_txn.underflow) begin
          correct_count++;
        end else begin
        error_count++;
        $display("%t Error: Mismatch in FIFO outputs underflow_ref=%d expected=%d .",$time,underflow_ref,F_txn.underflow);
        // You can display more information here if needed.
      end 
       end
       //case reading non empty nor full fifo
      5'b10100:begin
         if(underflow_ref===F_txn.underflow) begin
          correct_count++;
        end else begin
        error_count++;
        $display("%t Error: Mismatch in FIFO outputs.",$time);
        // You can display more information here if needed.
      end
       end

     //case writing in full fifo 
    5'b1101x: begin
         if(overflow_ref===F_txn.overflow) begin
          correct_count++;
        end else begin
        error_count++;
        $display("%t Error: Mismatch in FIFO outputs.",$time);
        // You can display more information here if needed.
      end
       end

       //case writing in non full nor empty fifo 
    5'b11000: begin
         if(overflow_ref===F_txn.overflow) begin
          correct_count++;
        end else begin
        error_count++;
        $display("%t Error: Mismatch in FIFO outputs.",$time);
        // You can display more information here if needed.
      end
       end
       default:  begin
         if((full_ref===F_txn.full)
            && (empty_ref===F_txn.empty)
            && (almostfull_ref===F_txn.almostfull)
            && (almostempty_ref===F_txn.almostempty)
         ) begin
          correct_count++;
        end else begin
        error_count++;
        $display("%t Error: Mismatch in FIFO outputs.",$time);
        // You can display more information here if needed.
      end
       end
     endcase
    endfunction

    // Reference model function
    function void reference_model(FIFO_transaction F_txn);
      // Calculate reference values based on input object
     // Fork-join block
      fork 
        
      //process one
      begin
    if (!F_txn.rst_n) begin
      wr_ptr = 0;
    end
    else if (F_txn.wr_en && (count < FIFO_DEPTH)) begin
      mem[wr_ptr] = F_txn.data_in;
      wr_ack_ref = 1;
      wr_ptr = wr_ptr + 1;
    end
    else begin 
      wr_ack_ref = 0; 
      if (F_txn.full && F_txn.wr_en)
        overflow_ref = 1;
      else
        overflow_ref = 0;
    end
      end

      //process two
      begin
    if (!F_txn.rst_n) begin
      rd_ptr = 0;
      underflow_ref=0;
    end
    else if (F_txn.rd_en && count != 0) begin
      data_out_ref = mem[rd_ptr];
      rd_ptr = rd_ptr + 1;
    end
      
    else begin  
      if (F_txn.empty && F_txn.rd_en)
        underflow_ref = 1;
      else
        underflow_ref = 0;
    end
end
      //process three
      begin
    if (!F_txn.rst_n) begin
      count = 0;
    end
    else begin
      if ({F_txn.wr_en, F_txn.rd_en} == 2'b10 && !F_txn.full) 
        count = count + 1;
      else if ({F_txn.wr_en, F_txn.rd_en} == 2'b01 && !F_txn.empty)
        count = count - 1;
      else if ({F_txn.wr_en, F_txn.rd_en} == 2'b11 && F_txn.full)
        count = count - 1;
      else if ({F_txn.wr_en, F_txn.rd_en} == 2'b11 && F_txn.empty)
        count = count + 1;    
    end
      end

      //process four
      begin
      full_ref = (count === FIFO_DEPTH) ? 1 : 0;
      empty_ref = (count === 0) ? 1 : 0;
      almostfull_ref = (count === FIFO_DEPTH-1) ? 1 : 0;
      almostempty_ref = (count === 1) ? 1 : 0;
      end

      join_none
    endfunction

  endclass

endpackage