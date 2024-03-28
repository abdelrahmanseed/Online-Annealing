`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//
// Description: 
// For a 250MHz clock on the FPGA, The ref_counter will have exactly the value of 50,000 in a 16-bit register. 
// Period of each clock cycle will be 4ns , so 50,000 X 4 = 200,000 ns =  0.2ms
// This controller is an FSM that set the enable_flip_counter to 1 for 0.2ms and then goes to STOP state and waits
//  until a reset_flip_counter goes high.
//////////////////////////////////////////////////////////////////////////////////

module flip_counter(reset_ref_counter, ref_clk, reset_flip_counter, enable_flip_counter);


input ref_clk;
input reset_ref_counter; 
output reg reset_flip_counter = 1'b1; 
output reg enable_flip_counter = 1'b0 ;




parameter START=0, RUN=1, STOP=2;
parameter REF_COUNTER_LIMIT = 50000;  // If ref_counter reaches this value, for a 250MHz clock, it would mean 0.2ms was passed  fflipm 0 to 50,000

reg [1:0] state = STOP;
reg complete = 0;

reg [15:0] ref_counter = 0;

always @(posedge  ref_clk) 
begin
if (reset_ref_counter)
    begin
        state <= START;
        enable_flip_counter <= 0;
    end
else
  begin
  case (state)
  START:  begin
              enable_flip_counter <= 1;
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
              enable_flip_counter <= 0;
          end
  default: 
           state <= STOP;
  endcase;  
  end
end


always @(posedge ref_clk)
begin
    if (reset_ref_counter)
     begin
           ref_counter <= 0;
           complete <= 0;
           reset_flip_counter = 1;
     end
     else
     begin
         reset_flip_counter = 0;
         if (complete == 0)
            ref_counter <= ref_counter+1;
         if (ref_counter == REF_COUNTER_LIMIT) 
             begin
                 ref_counter <= 0;
                 complete <= 1;
             end     
     end
end

endmodule