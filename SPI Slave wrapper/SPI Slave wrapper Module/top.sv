import shared_pak::shared_clk;
module top ();

logic clk;

initial begin
    clk=0;
    forever begin
       #1 clk=!clk;
         shared_clk=clk;
    end
end

SPI_Interface inter1(clk);

SPI_Slave Slave(inter1);

Dp_Sync_RAM RAM(inter1);

SPI_wrapper_tb TEST(inter1);

endmodule