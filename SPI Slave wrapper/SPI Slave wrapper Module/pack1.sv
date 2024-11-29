package random_test_pak;
import shared_pak::shared_clk;
class coverage_class;
    parameter WRITE_ADD=0;
    parameter WRITE_DATA=1;
    parameter READ_ADD=2;
    parameter READ_DATA=3; 
    logic SS_n;
    rand logic [10:0] random_MOSI_seq;
    bit [1:0] old_operation;
    rand logic rst_n;
    logic valid_operations,write;
    int randomizations_counter;
    // constrain the reset to be dis_activated mostly
    constraint var_const{
        rst_n dist{1:=99}; //we will not randomize the reset as it causes hanging in simulation but we made sure it works perfect at the begining of the sim
        
        unique{random_MOSI_seq[7:0]};

        if(valid_operations){
        if(write==1){
            random_MOSI_seq[10]==0;
            random_MOSI_seq[9:8] dist{0:=90,1:=1};
            if(randomizations_counter!=0)
            random_MOSI_seq[9:8]!=old_operation;
        }
        else{
            random_MOSI_seq[10]==1;
            random_MOSI_seq[9:8] dist{2:=50,3:=50};
            if(randomizations_counter!=0){
            random_MOSI_seq[9:8]!=old_operation;
            }
            else{
            random_MOSI_seq[9:8]==2;
            }
        }
      }
    }

    covergroup sample_covergroup @(posedge shared_clk);
        option.per_instance = 1;
         // Define the coverage points for cross coverage
        MOSI_seq_cp: coverpoint random_MOSI_seq[9:8] {
        bins writing_transation = (WRITE_ADD=>WRITE_DATA);
        bins reading_transation = (READ_ADD=>READ_DATA);
      }

       SS_n_cp: coverpoint SS_n {
        bins enabled = {1};
        bins disabled = {0};
        bins transation_1=(0=>1);
        bins transation_2=(1=>0);
      }


    endgroup

    function void post_randomization();
      old_operation=random_MOSI_seq[9:8];
    endfunction

    function new();
      sample_covergroup=new;
    endfunction //new()
endclass //var_class
endpackage