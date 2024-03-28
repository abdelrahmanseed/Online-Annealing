`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//
// Description: 
// For a 250MHz clock on the FPGA, The tictoc_counter will have exactly the value of tictoc_counter_limit in a 32-bit register. 
// Say limit = 50000, Period of each clock cycle will be 4ns , so 50,000 X 4 = 200,000 ns =  0.2ms
// This controller is an FSM that set the global_enable to 1 for 0.2ms and then goes to STOP state and waits
//  until a reset_tictoc goes high.
//////////////////////////////////////////////////////////////////////////////////

module tictoc_counter(reset_tictoc, tictoc_counter_limit, tictoc_clk, global_enable, complete);


input tictoc_clk;
input reset_tictoc; 
input [31:0] tictoc_counter_limit;  // If tictoc_counter reaches this value, for a 250MHz clock, it would mean 0.2ms was passed  from 0 to 50,000
output reg global_enable = 1'b0 ;


parameter START=0, RUN=1, STOP=2;


reg [1:0] state = STOP;
output reg complete = 0;

reg [31:0] tictoc_counter = 0;

always @(posedge  tictoc_clk or posedge reset_tictoc) 
begin
if (reset_tictoc)
    begin
        state <= START;
        global_enable <= 0;//global_enable <= 0;
    end
else
  begin
  case (state)
  START:  begin
              global_enable <= 1;
              state <= RUN;
          end
  RUN:   begin 
              if (complete)
                  state <= STOP;
              else
                  state <= RUN;
               
           end
  STOP: 
          begin
              global_enable <= 0;
          end
  default: 
           state <= STOP;
  endcase;  
  end
end


always @(posedge tictoc_clk or posedge reset_tictoc)
begin
    if (reset_tictoc)
     begin
           tictoc_counter <= 0;
           complete <= 0;
     end
     else
     begin
         if (complete == 0)
            tictoc_counter <= tictoc_counter+1;
         if (tictoc_counter == tictoc_counter_limit) 
             begin
                 tictoc_counter <= 0;
                 complete <= 1;
             end     
     end
end

endmodule