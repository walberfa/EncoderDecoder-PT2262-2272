`timescale 1ns/10ps

module tb_codec();
    logic [7:0] A; 
    logic [3:0] D; 
    logic clk, reset, cod_i, dv;

    decodificador_pt2272 decod1(
        .A(A),
        .clk(clk),
        .reset(reset),
        .cod_i(cod_i),
        .D(D),
        .dv(dv)
    );

    initial	begin
	    clk = 0;
	    forever #167ns clk = ~clk;
    end

    initial begin
        reset = 1;
        #334ns;

        reset = 0;
        A = 8'b10z1z010;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;
               
        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;
               
        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;
               
        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //0
        #334us;

        cod_i = 0;
        #1002us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;
               
        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;
               
        cod_i = 1; //1
        #1002us;

        cod_i = 0;
        #334us;

        cod_i = 1; //SYNC
        #334us;

        cod_i = 0;
        #12ms;

        reset = 1;
        #334ns;
        $finish;
    end

endmodule