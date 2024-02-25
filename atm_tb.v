module atm_tb;

    reg  clk,rst;
    reg  [15:0] userPassword;
    reg  card_inserted;
    reg  language_selection_enable;
    reg  [1:0] OpSelector;
    reg  anotherSelctor;
    reg  [15:0] DepVal;
    reg  [15:0] WithVal;
    wire [15:0]atm_output;

    atm a1(clk,rst,userPassword,card_inserted,language_selection_enable,OpSelector,anotherSelctor,DepVal,WithVal,atm_output);

    integer i;
    integer j;
    parameter MIN_VALUE  = 2'b01; //min value for opselector
    parameter MAX_VALUE  = 2'b11; //max value for opselector
    parameter MIN_VALUE1 = 0;     //min value for deposit/withdraw
    parameter MAX_VALUE1 = 10000; //max value for deposit/withdraw
    parameter MIN_VALUE2 = 1000;  //min value for users
    parameter MAX_VALUE2 = 1006;  //max value for users


    //clock generation
    initial begin
        clk = 0;
        forever begin
            #1 clk=~clk;
        end
    end

    initial begin
        //this is the initial state where we check the reset option, if it's correctly working
        rst = 1;
        userPassword = 0;
        card_inserted=0;
        language_selection_enable=0;
        OpSelector=0;
        anotherSelctor=0;
        DepVal=0;
        WithVal=0;
        @(negedge clk);
        if(atm_output !=0 )
            $stop();

        //Below is the constrained Test

        //The reset will now disabled and a card is inserted
        rst=0;
        card_inserted=1;
        @(negedge clk);
        //The user should be selecting the language now, 1 for english and 0 for arabic
        rst=0;
        language_selection_enable=1;
        @(negedge clk);
        //Now the user will enter the password
        rst=0;
        userPassword <= 1002;
        @(negedge clk);
        //The user will choose "DEPOSIT" service
        rst = 0;
        OpSelector = 2'b10;
        @(negedge clk);
        //the user will enter value to be deposited, DepVal
        rst=0;
        DepVal = 400;
        @(negedge clk);
        //Now the user Will select another service
        rst=0;
        anotherSelctor = 1;
        @(negedge clk);
        //Now we want to check the new balance
        rst=0;
        OpSelector=2'b11;
        @(negedge clk);
        //Now we want to select another service
        rst=0;
        anotherSelctor=1;
        @(negedge clk);
        //Now we select "withdraw"
        rst=0;
        OpSelector=2'b01;
        @(negedge clk);
        //Now we enter the value to be withdrawn, WithVal
        rst=0;
        WithVal=300;
        @(negedge clk);
        //Now the user Will select another service
        rst=0;
        anotherSelctor = 1;
        @(negedge clk);
        //Now we want to check the new balance
        rst=0;
        OpSelector=2'b11;
        @(negedge clk);
        //Now we exit
        rst=0;
        anotherSelctor=0;
        @(negedge clk);
        //Reset everything before entering the randomized test
        rst=1;
        @(negedge clk);




        //Below is the randomized test
        for(j = 0;j<1000;j=j+1) begin 
            //this is first state, inserting the card
            rst=0;
            card_inserted=1;
            @(negedge clk);
            //The user should be selecting the language now
            rst=0;
            language_selection_enable=1;
            @(negedge clk);
            //Now the user will enter the password
            rst=0;
            userPassword <= $urandom_range(MIN_VALUE2, MAX_VALUE2);
            for(i=0;i<100;i=i+1)begin
                    //this step is by default for selecting another operation
                    rst=0;
                    anotherSelctor = 1; //
                    OpSelector=2'b00;
                    card_inserted=1;
                    language_selection_enable=1;
                    DepVal=0;
                    WithVal=0;
                    @(negedge clk);

                    //this step is to select withdraw,deposit or balance check
                    rst=0;
                    OpSelector <= $urandom_range(MIN_VALUE, MAX_VALUE); //
                    card_inserted=1;
                    language_selection_enable=1;
                    anotherSelctor=1;
                    DepVal  <= 0; //
                    WithVal <= 0; //
                    @(negedge clk);
                    
                    //Additional step if user wants to deposit/withdraw
                    if(OpSelector == 2'b10 || OpSelector == 2'b01) begin
                        rst=0;
                        DepVal  <= $urandom_range(MIN_VALUE1, MAX_VALUE1); //
                        WithVal <= $urandom_range(MIN_VALUE1, MAX_VALUE1); //
                        card_inserted=1;
                        language_selection_enable=1;
                        anotherSelctor=1;
                        @(negedge clk);
                    end
                    @(negedge clk);
            end
            //Reseting before going to next user
            userPassword = 0;
            card_inserted=0;
            language_selection_enable=0;
            OpSelector=0;
            anotherSelctor=0;
            DepVal=0;
            WithVal=0;
            @(negedge clk);
        end

        $stop();
    end
endmodule