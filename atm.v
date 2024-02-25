module atm (
  input wire clk, rst,
  input reg [15:0] userPassword,
  input wire card_inserted,
  input wire language_selection_enable,
  input wire [1:0] OpSelector,
  input wire anotherSelctor,
  input wire [15:0] DepVal,
  input wire [15:0] WithVal,
  output reg [15:0]atm_output
);

reg [15:0] my_2d_array [0:5][0:1];

  // Initialization with decimal numbers greater than 6000
  initial begin
    my_2d_array[0][0] = 1000;    //pin
    my_2d_array[0][1] = 10000;   //balance

    my_2d_array[1][0] = 1001;    //pin
    my_2d_array[1][1] = 20000;   //balance

    my_2d_array[2][0] = 1002;    //pin
    my_2d_array[2][1] = 50;      //balance
 
    my_2d_array[3][0] = 1003;    //pin
    my_2d_array[3][1] = 9999;    //balance

    my_2d_array[4][0] = 1004;    //pin
    my_2d_array[4][1] = 7777;    //balance
end

// Task with a for loop
task automatic verification;
  input reg [15:0] psswd;
  output reg verif;
  output reg [3:0] index;
  integer i;

  begin
    verif = 1'b0;

    // Initialization using a for loop
    for (i = 0; i < 5; i = i + 1) begin
      if (my_2d_array[i][0] == psswd) begin
        verif = 1'b1;
        index = i;
      end
    end
  end
endtask

function [2:0] BankingOperationSelection; //function bta5od input opselector w tdina op
    input [1:0] select;

  case(select)
      2'b01 : BankingOperationSelection = 3'b101; //withdraw
      2'b10 : BankingOperationSelection = 3'b100; //deposit
      2'b11 : BankingOperationSelection = 3'b110; //balance
  endcase
endfunction

//Below are the states
parameter INITIAL = 3'b000;
parameter LANGUAGE_SELECTION = 3'b001;
parameter PASSWORD_VERIFICATION = 3'b010;
parameter BANKING_OPERATION_SELECTION = 3'b011;
parameter DEPOSIT_OPERATION = 3'b100;
parameter WITHDRAW_OPERATION = 3'b101;
parameter BALANCE_OPERATION = 3'b110;
parameter ANOTHER_SERVICE = 3'b111;

reg [2:0] state_counter; // 3-bit counter to track state transitions
reg [2:0] current_state;
reg [2:0] next_state;
reg[2:0] op;
reg Verified;
reg [3:0] index; //logged in user
reg with_enable;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= INITIAL;
        state_counter <= 3'b0;
    end else begin
        current_state <= next_state;
        state_counter <= state_counter + 1; // Increment the counter on every state change
    end
end

always @(*) begin
    case (current_state)
    
        INITIAL: begin
                    // Define conditions for transitioning to the next state
                    if (card_inserted) begin
                        next_state = LANGUAGE_SELECTION;
                    end
                    else begin
                        next_state = INITIAL;
                    end
        end

        LANGUAGE_SELECTION : begin
                    if (language_selection_enable) begin // 1 is for english
                          next_state = PASSWORD_VERIFICATION;
                    end
                    else begin
                          next_state = PASSWORD_VERIFICATION; // 0 for arabic
                    end
        end

        PASSWORD_VERIFICATION : begin
          verification(userPassword, Verified, index); //Verifying user's credentials
          if(Verified)
          begin
            next_state=BANKING_OPERATION_SELECTION;
            $display("Welcome User");
          end
          else begin
            next_state=INITIAL;
            $display("Wrong Pin");
          end
        end

        //di elbedaya men gwa elstates ely bgad, kol ely fo2 dol verification
        BANKING_OPERATION_SELECTION : begin
         op = BankingOperationSelection(OpSelector);
         next_state = op;
        end

        DEPOSIT_OPERATION : begin
          my_2d_array[index][1] = my_2d_array[index][1] + DepVal;
          $display("Deposit Done");
          next_state = ANOTHER_SERVICE;
        end

        WITHDRAW_OPERATION : begin
          if(WithVal <= my_2d_array[index][1]) begin
            my_2d_array[index][1] = my_2d_array[index][1] - WithVal;
            with_enable=1; 
            $display("Please wait for your money to come out, Thank you");
          end
          else begin  
             with_enable=0;
             $display("Not enough balance, try again");
          end    
          next_state = ANOTHER_SERVICE;
        end

        BALANCE_OPERATION : begin
          //we can display here the user's balance but we are displaying it as atm output
          next_state = ANOTHER_SERVICE;
        end

        ANOTHER_SERVICE : begin
          if (anotherSelctor) begin //Then the user wants to do another operation
            next_state = BANKING_OPERATION_SELECTION;
          end
          else begin //The user wants to terminate
            next_state = INITIAL;
          end
        end
        default: next_state = INITIAL; //No need for it, only here for best practice
    endcase
end

always @(*) begin
  case (current_state)

    INITIAL:                      atm_output   <=0;

    LANGUAGE_SELECTION:           atm_output   <=0;

    PASSWORD_VERIFICATION:        atm_output   <=0;
    
    BANKING_OPERATION_SELECTION : atm_output   <=0;

    WITHDRAW_OPERATION :          if(with_enable) 
                                    atm_output <= WithVal;
                                  else
                                    atm_output <=0;
    
    DEPOSIT_OPERATION:            atm_output   <=0;

    BALANCE_OPERATION:            atm_output    = my_2d_array[index][1];

    ANOTHER_SERVICE:              atm_output   <=0;

  endcase
end
endmodule