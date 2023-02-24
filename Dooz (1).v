
module mainPage(p1,p2,clk,reset,start,botplay,turnA,turnB,selectA,selectB,winnerA,winnerB,equal);

input [3:0] p1,p2;
input clk,start,reset,botplay;

output reg turnA,turnB,winnerA,winnerB,equal;
output reg [8:0] selectA,selectB;

`define  IDLE 3'b000
`define  TURNA 3'b001
`define  TURNB 3'b010
`define  WIN 3'b011
`define  EQUAL 3'b100
`define  BOT  3'b101

//Just because Function must have at least on input
reg FuncVar;

reg sflag,winerflag;
reg [1:0] resflag;

reg [2:0] state,next_state;
reg [8:0] valid,plain;
reg [8:0] output_table;
reg [3:0] p3;

reg a,bflag;
reg [3:0]b;
always @(posedge clk) begin
    state=next_state;
end

always @(state or p1 or p2 or start or reset)begin
    if (reset==1) begin
        valid=9'b000000000;
        plain=9'b000000000;
		output_table=9'bxxxxxxxxx;
        resflag=0;
        sflag=0;
        winnerA=0;
        winnerB=0;
        bflag=0;
        next_state=`IDLE;
    end

    if (state==`IDLE && start==1 && reset==0 && botplay!=1)begin
        //a=$random()%2;
        a=0;
        if(a==0)
            next_state=`TURNA;
        if(a==1)
            next_state=`TURNB;
    end

    if (state==`IDLE && start==1 && reset==0 && botplay==1)begin
        //a=$random()%2;
        next_state=`TURNA;
        bflag=1;
    end
    if (state==`TURNA && reset==0)begin
        if (p1<10 && p1>0)begin
            if(~valid[p1-1])begin
                    valid[p1-1]=1;
					output_table[p1-1]=0;
					show_output();//output_table
                    sflag=1;
                end
        end
        if (sflag==1)begin
            resflag=winner_checker(valid,plain);
            if (resflag[0])begin
                next_state=`WIN;
                winerflag=0;
            end
            if (resflag[1])begin
                next_state=`EQUAL;
            end
            if (resflag==0 && bflag==0)begin
                next_state=`TURNB;
                sflag=0;
            end
            if(resflag==0 && bflag==1)begin
                next_state=`BOT;
                sflag=0;
            end
        end
    end

    if(state==`BOT && reset==0)begin
        p3=select(valid,plain);
        plain[p3-1]=1;
        valid[p3-1]=1;
        resflag=winner_checker(valid,plain);
        if (resflag==0)
            next_state=`TURNA;
        if (resflag[0])begin
                next_state=`WIN;
                winerflag=1;
            end
        if (resflag[1])begin
            next_state=`EQUAL;
        end
        
    end

	if (state==`TURNB &&  reset==0)begin
        if (p2<10 && p2>0)begin
            if(~valid[p2-1])begin
                    valid[p2-1]=1;
                    plain[p2-1]=1;
					output_table[p2-1]=1;
					show_output();//output_table);
                    sflag=1;
                end
        end
        if (sflag==1)begin
            resflag=winner_checker(valid,plain);
            if (resflag[0])begin
                next_state=`WIN;
                winerflag=1;
            end
            if (resflag[1])begin
                next_state=`EQUAL;
            end
            if (resflag==0)begin
                next_state=`TURNA;
                sflag=0;
            end
        end
	end	  
end

always@(state)
begin

    if(state== `TURNA)
	begin
	  turnA=1;			
	end
    else
        turnA=0;
	if(state== `TURNB)
	begin
	  turnB=1; 			
	end
    else
        turnB=0;
    if(state==`WIN)
    begin
       if(winerflag==1)
            winnerB=1;
        else
            winnerA=0;
    end
    if (state==`EQUAL)
        equal=1;
    else
        equal=0;	
end

always @(*)begin
    for(b=0 ; b<9 ; b=b+1)begin
        selectB[b]=plain[b] & valid[b];
        selectA[b]=plain[b] ^ valid[b];
    end
end

//show output table
task show_output();//output_table);
  
   //input [8:0] output_table;
   integer i,j;
   begin
   for(i=0;i<3;i=i+1)
      begin
       for(j=0;j<3;j=j+1)
        begin
          $write(output_table[3*i+j]);		
          $write(" ");
		end
      $display("");
      end	  
   end
 
 endtask
//wining function
function [1:0] winner_checker; 
  
  input [8:0] valid,plain;
  reg Flag;
  begin 
	 Flag=1'b0;
     //first row
     if(valid[0]==1 && valid[1]==1 && valid[2]==1 && plain[0] == plain[1]  &&  plain[0]== plain[2] )
	    Flag=1'b1;
	 //second row  
     if(valid[3]==1 && valid[4]==1 && valid[5]==1 && plain[3] == plain[4]  &&  plain[5]== plain[3] )
	    Flag=1'b1;  	 
	 //third row 
     if(valid[6]==1 && valid[7]==1 && valid[8]==1 && plain[6] == plain[7]  &&  plain[6]== plain[8] )
	    Flag=1'b1;  
	 //first column 
     if(valid[0]==1 && valid[3]==1 && valid[6]==1 && plain[0] == plain[6]  &&  plain[0]== plain[3] )
	    Flag=1'b1; 
	 //second column 
     if(valid[1]==1 && valid[4]==1 && valid[7]==1 && plain[1] == plain[4]  &&  plain[1]== plain[7] )
	    Flag=1'b1; 
	 //third column 
     if(valid[2]==1 && valid[8]==1 && valid[5]==1 && plain[2] == plain[8]  &&  plain[5]== plain[2] )
	    Flag=1'b1;  
	 //main diagonal 
     if(valid[0]==1 && valid[4]==1 && valid[8]==1 && plain[0] == plain[4]  &&  plain[4]== plain[8] )
	    Flag=1'b1;  
	 //sub-diameter 
     if(valid[2]==1 && valid[4]==1 && valid[6]==1 && plain[2] == plain[4]  &&  plain[2]== plain[6] )
	    Flag=1'b1;
     if (valid==9'b111111111 && Flag==0)
        winner_checker[1]=1;
     else
        winner_checker[1]=0;    
	 winner_checker[0]=Flag;
    end 	   
endfunction

function [3:0] select;
    input [8:0] valid,plain;

    reg flag;
begin
    flag=1;
    if ((valid[1]==1 && valid[2]==1 && plain[1]== plain[2] && plain[1]==1) ||
        (valid[6]==1 && valid[3]==1 && plain[3]== plain[6] && plain[3]==1) ||
        (valid[8]==1 && valid[4]==1 && plain[8]== plain[4] && plain[4]==1) && flag)
        begin
            if (~valid[0]) begin
            select=1;
            flag=0;
            end
        end
    if ((valid[1]==1 && valid[0]==1 && plain[1]== plain[0] && plain[1]==1) ||
        (valid[6]==1 && valid[4]==1 && plain[4]== plain[6] && plain[4]==1) ||
        (valid[8]==1 && valid[5]==1 && plain[8]== plain[5] && plain[5]==1) && flag)
        begin
            if (~valid[2]) begin
            select=3;
            flag=0;
            end
        end
    if ((valid[5]==1 && valid[2]==1 && plain[5]== plain[2] && plain[5]==1) ||
        (valid[6]==1 && valid[7]==1 && plain[7]== plain[6] && plain[7]==1) ||
        (valid[0]==1 && valid[4]==1 && plain[0]== plain[4] && plain[4]==1) && flag)
        begin
            if (~valid[8]) begin
            select=9;
            flag=0;
            end
        end
    if ((valid[7]==1 && valid[8]==1 && plain[8]== plain[7] && plain[8]==1) ||
        (valid[0]==1 && valid[3]==1 && plain[3]== plain[0] && plain[3]==1) ||
        (valid[2]==1 && valid[4]==1 && plain[2]== plain[4] && plain[4]==1) && flag)
        begin
            if (~valid[6]) begin
            select=7;
            flag=0;
            end
        end

    if ((valid[0]==1 && valid[2]==1 && plain[0]== plain[2] && plain[0]==1) ||
        (valid[4]==1 && valid[7]==1 && plain[4]== plain[7] && plain[4]==1) && flag)
        begin
            if (~valid[1]) begin
            select=2;
            flag=0;
            end
        end

    if ((valid[0]==1 && valid[6]==1 && plain[0]== plain[6] && plain[0]==1) ||
        (valid[4]==1 && valid[5]==1 && plain[4]== plain[5] && plain[4]==1) && flag)
        begin
            if (~valid[3]) begin
            select=4;
            flag=0;
            end
        end
    if ((valid[8]==1 && valid[2]==1 && plain[8]== plain[2] && plain[8]==1) ||
        (valid[4]==1 && valid[3]==1 && plain[4]== plain[3] && plain[4]==1) && flag)
        begin
            if (~valid[5]) begin
            select=6;
            flag=0;
            end
        end
    if ((valid[8]==1 && valid[6]==1 && plain[8]== plain[6] && plain[8]==1) ||
        (valid[4]==1 && valid[1]==1 && plain[4]== plain[1] && plain[4]==1) && flag)
        begin
            if (~valid[7]) begin
            select=8;
            flag=0;
            end
        end
    if ((valid[6]==1 && valid[2]==1 && plain[6]== plain[2] && plain[6]==1) ||
        (valid[5]==1 && valid[3]==1 && plain[3]== plain[5] && plain[3]==1) ||
        (valid[8]==1 && valid[0]==1 && plain[8]== plain[0] && plain[0]==1)||
        (valid[1]==1 && valid[7]==1 && plain[1]== plain[7] && plain[1]==1) && flag)
        begin
            if (~valid[4]) begin
            select=5;
            flag=0;
            end
        end

//not losing situation

    if ((valid[1]==1 && valid[2]==1 && plain[1]== plain[2] && plain[1]==0) ||
        (valid[6]==1 && valid[3]==1 && plain[3]== plain[6] && plain[3]==0) ||
        (valid[8]==1 && valid[4]==1 && plain[8]== plain[4] && plain[4]==0) && flag)
        begin
            if (~valid[0]) begin
            select=1;
            flag=0;
            end
        end
    if ((valid[1]==1 && valid[0]==1 && plain[1]== plain[0] && plain[1]==0) ||
        (valid[6]==1 && valid[4]==1 && plain[4]== plain[6] && plain[4]==0) ||
        (valid[8]==1 && valid[5]==1 && plain[8]== plain[5] && plain[5]==0) && flag)
        begin
            if (~valid[2]) begin
            select=3;
            flag=0;
            end
        end
    if ((valid[5]==1 && valid[2]==1 && plain[5]== plain[2] && plain[5]==0) ||
        (valid[6]==1 && valid[7]==1 && plain[7]== plain[6] && plain[7]==0) ||
        (valid[0]==1 && valid[4]==1 && plain[0]== plain[4] && plain[4]==0) && flag)
        begin
            if (~valid[8]) begin
            select=9;
            flag=0;
            end
        end
    if ((valid[7]==1 && valid[8]==1 && plain[8]== plain[7] && plain[8]==0) ||
        (valid[0]==1 && valid[3]==1 && plain[3]== plain[0] && plain[3]==0) ||
        (valid[2]==1 && valid[4]==1 && plain[2]== plain[4] && plain[4]==0) && flag)
        begin
            if (~valid[6]) begin
            select=7;
            flag=0;
            end
        end

    if ((valid[0]==1 && valid[2]==1 && plain[0]== plain[2] && plain[0]==0) ||
        (valid[4]==1 && valid[7]==1 && plain[4]== plain[7] && plain[4]==0) && flag)
        begin
            if (~valid[1]) begin
            select=2;
            flag=0;
            end
        end

    if ((valid[0]==1 && valid[6]==1 && plain[0]== plain[6] && plain[0]==0) ||
        (valid[4]==1 && valid[5]==1 && plain[4]== plain[5] && plain[4]==0) && flag)
        begin
            if (~valid[3]) begin
            select=4;
            flag=0;
            end
        end
    if ((valid[8]==1 && valid[2]==1 && plain[8]== plain[2] && plain[8]==0) ||
        (valid[4]==1 && valid[3]==1 && plain[4]== plain[3] && plain[4]==0) && flag)
        begin
            if (~valid[5]) begin
            select=6;
            flag=0;
            end
        end
    if ((valid[8]==1 && valid[6]==1 && plain[8]== plain[6] && plain[8]==0) ||
        (valid[4]==1 && valid[1]==1 && plain[4]== plain[1] && plain[4]==0) && flag)
        begin
            if (~valid[7]) begin
            select=8;
            flag=0;
            end
        end
    if ((valid[6]==1 && valid[2]==1 && plain[6]== plain[2] && plain[6]==0) ||
        (valid[5]==1 && valid[3]==1 && plain[3]== plain[5] && plain[3]==0) ||
        (valid[8]==1 && valid[0]==1 && plain[8]== plain[0] && plain[0]==0)||
        (valid[1]==1 && valid[7]==1 && plain[1]== plain[7] && plain[1]==0) && flag)
        begin
            if (~valid[4]) begin
            select=5;
            flag=0;
            end
        end

// not winnig or losing situation
    if(flag)begin
        if(valid[4]==0)begin
            select=5;
            flag=0;
        end
        if(~(valid[0] && valid[2] && valid[6] && valid[8]) && flag)begin
            while (flag) begin
                select=$random()%9;
                select=select+1;
                if(valid[select-1]==0 && (select==1 || select==3 || select==7 || select==9))
                    flag=0;
            end
        end

        if(flag)begin
            while (flag) begin
                select=$random()%9;
                select=select+1;
                if(valid[select-1]==0)
                    flag=0;
            end
        end

    end
   
end
    
endfunction

endmodule
