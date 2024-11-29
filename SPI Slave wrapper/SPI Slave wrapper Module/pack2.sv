//this pack is used only if we want to direct test the 

package direct_test_pak;
import shared_pak::*;

class add_data_rand_class; 
   randc logic [addr_randomize_required-1:0] random_address;
   rand logic [7:0] random_data;
constraint data_constraint{
    random_data!=0;
    random_address < MEM_DEPTH;
}
covergroup RAM_samble_group @(posedge shared_clk);

option.per_instance = 1;

add_cp:coverpoint random_address;   //make sure we accessed the whole memory

endgroup
    function new();
    endfunction //new()
endclass //var_class
endpackage