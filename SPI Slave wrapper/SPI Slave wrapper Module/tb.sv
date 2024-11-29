import random_test_pak::*;
import direct_test_pak::*;
import shared_pak::*;
module SPI_wrapper_tb(SPI_Interface.TEST tb_intf);

//array to hold the addresses and temp variable to hold the full address before writing the array
bit [ADDR_SIZE-1:0] addr_array [MEM_DEPTH];
bit [ADDR_SIZE-1:0] temp_addr;
//create assosiative aray to hold the data and temp variable to use it
bit [7:0] data_array [logic[ADDR_SIZE-1:0]];
bit [7:0] temp_data;
//create variable of the classes
coverage_class Slave_cvg=new;
add_data_rand_class RAM_cvg=new; 

int correct_count=0,error_count=0;
reg [7:0] golden_model_MISO_reg,MISO_reg; //reg to hold the data of the golden model
logic clk,rst_n,MOSI,SS_n,golden_model_MISO;
//inestantiate the golden model
assign clk=tb_intf.clk;
assign rst_n=tb_intf.rst_n;
assign MOSI=tb_intf.MOSI;
assign SS_n=tb_intf.SS_n;

SPI_Wrapper W1(MOSI ,golden_model_MISO, SS_n , clk , rst_n);

parameter TESTS=500;  //the number of tests


initial begin

  /*completing the code coverage*/
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  /***************************************/
  tb_intf.rst_n=0;
  #10;
  tb_intf.rst_n=1;
  #10;

/********************************************RANDOM TESTING****************************************/
/*************************************************************************/

direct_testing();

/*first test writing mostly*/
//////////////////////////////////////

Slave_cvg.valid_operations=1;
Slave_cvg.write=1;
for(int i=0;i<TESTS;i++)begin
 @(negedge tb_intf.clk);
 tb_intf.SS_n=0;
 Slave_cvg.SS_n=tb_intf.SS_n;

//->chck_cmd
Slave_cvg.randomizations_counter=i;
assert(Slave_cvg.randomize());
Slave_cvg.post_randomization();

for(int j=10;j>=0;j--)begin
@(negedge tb_intf.clk);
tb_intf.MOSI=Slave_cvg.random_MOSI_seq[j];
end
if(Slave_cvg.random_MOSI_seq[9:8]==3)begin
    check_using_golden_model();
end
@(negedge tb_intf.clk);
tb_intf.SS_n=1;
Slave_cvg.SS_n=tb_intf.SS_n;
end

////////////////////////////////////////////////
/*second test reading mostly*/

Slave_cvg.valid_operations=1;
Slave_cvg.write=0;
for(int i=0;i<TESTS;i++)begin
 @(negedge tb_intf.clk);
 tb_intf.SS_n=0;
 Slave_cvg.SS_n=tb_intf.SS_n;

//->chck_cmd
Slave_cvg.randomizations_counter=i;
assert(Slave_cvg.randomize());
Slave_cvg.post_randomization();

for(int j=10;j>=0;j--)begin
@(negedge tb_intf.clk);
tb_intf.MOSI=Slave_cvg.random_MOSI_seq[j];
end
if(Slave_cvg.random_MOSI_seq[9:8]==3)begin
    check_using_golden_model();
end
@(negedge tb_intf.clk);
tb_intf.SS_n=1;
Slave_cvg.SS_n=tb_intf.SS_n;
end
//////////////////////////////////////////////////////////////////


/***********************************************************************************************************/

  $display("simulation finished");
  $display("summery :correct_count=%d error_count=%d",correct_count,error_count);

  $stop;
end

task address_data_randomize();

  for(int i=0;i<MEM_DEPTH;i++)begin
    assert (RAM_cvg.randomize()); 
    addr_array[i]=RAM_cvg.random_address;
    data_array[addr_array[i]]=RAM_cvg.random_data;
  end
    
endtask //address_randomize

task check_using_golden_model();  
 fork
  begin
    repeat(3)
    @(negedge tb_intf.clk);
    for(int i=7;i>=0;i--)begin
    @(negedge tb_intf.clk);
    golden_model_MISO_reg[i]=golden_model_MISO;
    end
  end

  begin
    repeat(3)
    @(negedge tb_intf.clk);
    for(int i=7;i>=0;i--)begin
    @(negedge tb_intf.clk);
    MISO_reg[i]=tb_intf.MISO;
    end
  end
 join

 if(golden_model_MISO_reg===MISO_reg)begin
  correct_count++;
 end
  else begin
 error_count++;
 $display("%t Erorr:the data in tx=%h expected=%h",$time,MISO_reg,golden_model_MISO_reg);
  end
 
endtask //check_using_golden_model

task check_using_tx(int i);
  repeat(3)
  @(negedge tb_intf.clk);
  if(tb_intf.tx_data===data_array[addr_array[i]])begin
  correct_count++;
  end
  else begin
 error_count++;
 $display("%t Erorr:the data in tx=%h expected=%h",$time,tb_intf.tx_data,data_array[addr_array[i]]);
  end
  repeat(8)
  @(negedge tb_intf.clk);  //wait for the serial output
  
endtask
task direct_testing;
  
  address_data_randomize();
  /********************************************DIRECT TESTING FOR READING AND WRITING****************************************/
  /*************************************************************************/
  /*writing test*/
  /******************/
  for(int i=0;i<MEM_DEPTH;i++)begin
  /*first step giving a write address*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE  00 which is now means write address now the module expects 8 more bits which are the address to be written
  temp_addr=addr_array[i];
  for(int j=7;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=temp_addr[j];
  end
  //->address is complete
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state;

  /************************************************************/
  /*giving data to store at the previous address*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE  01 which is now means write data now the module expects 8 more bits which are the data to be written in the ram
  temp_data=data_array[addr_array[i]];
  for(int j=7;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=temp_data[j];
  end
  //->data is complete
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state;
  end

  /*******************************************************************************************/
  /*******************************************************************************************/
  /*reading test*/
  /**************************/
  for(int i=0;i<MEM_DEPTH;i++)begin
  /*giving a read address*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->read state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE  10 which is now means read address now the module expects 8 more bits which are the address to read from memory
  temp_addr=addr_array[i];
  for(int j=7;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=temp_addr[j];
  end
  //->address is complete
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state;

  /************************************************************/
  /*giving a random data*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE  11 which is now means read data from the givin address, now the module expects 8 more bits which are redundant
  temp_data=data_array[addr_array[i]];
  for(int j=7;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=$random;
  end
  //->data is complete

  check_using_golden_model();
  //a check againest the golden model bit by bit of MISO

  // check_using_tx(i);
  //simple check usnig tx data
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state;
  end
  /***********************************END OF DIRECT TESTING*******************************************************************/
  /*testing the case if ss_n=1 during the deffirent states*/

  /*first step giving a write address*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE  00 which is now means write address now the module expects 8 more bits which are the address to be written
  temp_addr=addr_array[0];
  for(int j=1;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=temp_addr[j];
  end
  //->address is not complete
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state check using sva assertions

  //////////////////////////////////////////////////////
   /*giving data to store at the previous address*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE  01 which is now means write data now the module expects 8 more bits which are the data to be written in the ram
  temp_data=data_array[addr_array[0]];
  for(int j=1;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=temp_data[0];
  end
  //->data is not complete
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state check using SVA assertions
//////////////////////////////////////////////////////
/*giving a read address*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->read state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=0;
  //->WRITE  10 which is now means read address now the module expects 8 more bits which are the address to read from memory
  temp_addr=addr_array[0];
  for(int j=1;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=temp_addr[0];
  end
  //->address is not complete
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
  //->idle state; check using SVA

  /////////////////////////////////////////
   /*giving a random data*/
  @(negedge tb_intf.clk);
  tb_intf.SS_n=0;
  //->CHK_CMD state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE state
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE 0
  @(negedge tb_intf.clk);
  tb_intf.MOSI=1;
  //->WRITE  11 which is now means read data from the givin address, now the module expects 8 more bits which are redundant
  temp_data=data_array[addr_array[0]];
  for(int j=1;j>=0;j--)begin
  @(negedge tb_intf.clk);
  tb_intf.MOSI=$random;
  end
  //->data is not complete
  // check_using_tx(i);
  //simple check usnig tx data
  @(negedge tb_intf.clk);
  tb_intf.SS_n=1;
//check using SVA assertions
endtask
endmodule