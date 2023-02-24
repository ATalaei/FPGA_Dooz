module test1();

reg [3:0] p1,p2;
reg clk,reset,start;

wire turnA,turnB,winnerA,winnerB,equal;
wire [8:0] selectA,selectB;



mainPage d1(p1,p2,clk,reset,start,turnA,turnB,selectA,selectB,winnerA,winnerB,equal);



initial begin
    clk=0;
    #40 reset=1;
    #30 reset=0;
    start=1;
    #90 start=0;
    p1=9;
    #100 p2=5;
    #100 p1=6;
    #100 p2=3;
    #100 p1=7;
    #100 p2=8;
    #100 p1=2;
    #100 p2=4;
    #100 p1=1;
    #150;
end




initial begin
    forever begin
        #50 clk=~clk;
    end
end






endmodule
