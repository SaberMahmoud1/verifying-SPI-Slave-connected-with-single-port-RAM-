module top ();
    bit clk;
    initial begin
        forever begin
          #1 clk=!clk;
        end
    end

FIFO_Interface inter1(clk);

FIFO DUT(inter1);
FIFO_TB TEST(inter1);
FIFO_monitor monitor(inter1);

endmodule