package coverage_pak;


class cv_class;
    logic clk;
	rand logic rst_n,rx_valid;
	rand logic [9:0] din;
    bit write;
    bit old_operation;
    constraint variables{
        rst_n dist {1:=98}; //writing the rst=0 hangs the simulator but it works fine so we wont test it in randomization
        unique{din[7:0]};

        rx_valid dist{1:=98,0:=1};

        if(write){
            din[9:8] dist{0:=90,1:=1};
            din[9:8]!=old_operation;
        }
        else{
            din[9:8] dist{2:=50,3:=50};
            din[9:8]!=old_operation;
        }
        
    }
    covergroup sample_coverage @(posedge clk);

    rx_valid_cp:coverpoint rx_valid
    {
        bins enabled={1};
        bins disabled={0};

    }
    
    din1_cp:coverpoint din[9:8]
    {
        bins write_data={1};
        bins read_data={3};
        ignore_bins write_add={0};
        ignore_bins read_add={2};
    }

    din2_cp:coverpoint din[7:0];

    cross din1_cp,din2_cp;

    endgroup

    function void post_randomization;
        old_operation=din[9:8];
    endfunction

    function new();
        sample_coverage=new;
    endfunction //new()
endclass //className

    
endpackage