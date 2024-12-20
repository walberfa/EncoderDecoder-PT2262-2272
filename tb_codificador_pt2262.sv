/*
Projeto Final de Lógica Digital
Autor: Walber Florencio de Almeida
CI Inovador - Polo UFC
Testbench do codificador_pt2262
*/

`timescale 1ns/10ps

module tb_codificador_pt2262();
    logic [7:0] A; 
    logic [3:0] D; 
    logic clk, reset, sync, cod_o;

    codificador_pt2262 cod1(
        .A(A), // endereço de entrada, trinário
        .D(D), // dado de entrada
        .clk(clk), // 3MHz conforme especificação do clock
        .reset(reset), // reset ativo alto
        .cod_o(cod_o), // saida codificada
        .sync(sync) // indica geração do simbolo sync
        );

    initial	begin // Gera o pulso do clock
	    clk = 0;
	    forever #167ns clk = ~clk;
    end

    initial begin
        reset = 1; 

        A = 8'b10z1z010; // endereco de entrada
        D = 4'b0011; // dado de entrada
        #334ns;

        reset = 0;
        #50ms; // durante esse tempo, a tranmissão finaliza e começa outra logo em sequência

        reset = 1; // o reset interrompe a tranmissão em andamento
        #1ms;

        $finish;
    end

endmodule