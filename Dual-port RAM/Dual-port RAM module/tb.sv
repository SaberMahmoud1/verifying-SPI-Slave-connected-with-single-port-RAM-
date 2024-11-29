import coverage_pak::*;
module tb ();
    parameter TESTS=1000;

	logic clk, rst_n, rx_valid;
	logic [9:0] din;
	logic tx_valid,tx_valid_golden_module;
	logic [7:0] dout,dout_golden_module;

    cv_class f_cvg=new;
    int correct_count=0,error_count=0;
    Dp_Sync_RAM DUT1(clk, rst_n, din, rx_valid, dout, tx_valid);

    SPI_RAM DUT2 (clk,rst_n,din,rx_valid,dout_golden_module,tx_valid_golden_module);

    initial begin
        clk=0;
        forever begin
          #1 clk=!clk;
          f_cvg.clk=clk;
        end
    end

    initial begin
        rst_n=0;
        #10;
        rst_n=1;
        #10;
        f_cvg.write=1;
        for(int i=0;i<TESTS;i++)begin
            @(negedge clk);
            assert (f_cvg.randomize()); 
            rst_n=f_cvg.rst_n;
            din=f_cvg.din;
            rx_valid=f_cvg.rx_valid;
            f_cvg.post_randomization();
            if(din[9:8]==3 && rst_n)
            check_result();
        end
/////////////////////////////////////////
        f_cvg.write=0;
        for(int i=0;i<TESTS;i++)begin
            @(negedge clk);
            assert (f_cvg.randomize()); 
            rst_n=f_cvg.rst_n;
            din=f_cvg.din;
            rx_valid=f_cvg.rx_valid;
            f_cvg.post_randomization();
            if(din[9:8]==3 && rst_n)
            check_result();
        end
        rst_n=0;
        #10;
        rst_n=1;

    $display("simulation finished");
    $display("summery");
    $display("correct_count=%d error_count=%d",correct_count,error_count);

    $stop;


    end

    task check_result();
        @(negedge clk);
        if(dout==dout_golden_module)
        correct_count++;
        else begin
            error_count++;
            $display("%t Erorr:dout=%d expected=%d",$time,dout,dout_golden_module);
        end
    endtask //check_result

endmodule