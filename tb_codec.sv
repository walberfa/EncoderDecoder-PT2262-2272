`timescale 1ns/10ps

module tb_codec();
    logic [7:0] A; 
    logic [3:0] D_dec, D_cod; 
    logic clk, reset, cod, dv;

    decodificador_pt2272 decod1(
        .A(A),
        .clk(clk),
        .reset(reset),
        .cod_i(cod),
        .D(D_dec),
        .dv(dv)
    );

    codificador_pt2262 cod1(
        .A(A),
        .D(D_cod),
        .clk(clk),
        .reset(reset),
        .cod_o(cod),
        .sync()
    );

    initial	begin // Gera o pulso do clock
	    clk = 0;
	    forever #167ns clk = ~clk;
    end

    initial begin
        reset = 1; 

        A = 8'b01z01z10; // endereco de entrada
        D_cod = 4'b1011; // dado de entrada
        #334ns;

        reset = 0;
        #50ms; // durante esse tempo, a tranmissão finaliza e começa outra logo em sequência

        reset = 1; // o reset interrompe a tranmissão em andamento
        #1ms;

        $finish;
    end


endmodule