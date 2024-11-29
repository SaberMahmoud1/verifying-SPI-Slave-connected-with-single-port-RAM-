package shared_pak;
parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;
parameter addr_randomize_required =$clog2(MEM_DEPTH);
bit shared_clk;
endpackage