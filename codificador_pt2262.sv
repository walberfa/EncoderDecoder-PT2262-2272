/*
Projeto Final de Lógica Digital
Autor: Walber Florencio de Almeida
CI Inovador - Polo UFC
*/

`timescale 1ns/10ps

module codificador_pt2262(
    input logic clk, // 3MHz conforme especificação do clock
    input logic reset, // reset ativo alto
    input logic [7:0] A, // endereço de entrada, trinário
    input logic [3:0] D, // dado de entrada
    output logic sync, // indica geração do simbolo sync
    output logic cod_o  // saida codificada
);

logic [3:0] prox_estado, estado_atual; // usados para administrar os estados
logic [6:0] counter1, counter2, counter_ff1, counter_ff2; //contadores
logic [1:0] wave; // par de bits usado para auxiliar na construção da forma de onda
logic [15:0] Ax; //bits de endereços. Bit 0 = 00. Bit 1 = 11. Bit F = 01. 
logic [7:0] A_F, A_01; //saídas de comp_endereco, indicam se tem F na entrada A
logic osc; // 12kHz conforme especificação do oscilador

// Instancia do bloco comp_endereco
comp_endereco Ax01F(.A(A), .A_01(A_01), .A_F(A_F));

// O bloco instanciado a seguir gera um valor para "Ax" baseado nos valores em A_01 e A_F
gera_ax gera_ax(.A_F(A_F), .A_01(A_01), .Ax(Ax));

// Instancia do bloco para gerar o OSC na frequencia correta a partir do CLK
oscilador osc1(.clk(clk), .rst(reset), .osc(osc));

// Bloco FF para atualizar o estado e os contadores junto com o oscilador
always_ff @(posedge osc) begin: atualiza_estado_e_contadores
    estado_atual <= prox_estado;
    counter_ff1 <= counter1;
    counter_ff2 <= counter2;
end

/*
O bloco a seguir representa a máquina de estados do sistema de codificação.
Os estados existentes são o INICIO e um estado para cada bit (endereço e dado) 
a ser transmitido, incluindo o SYNC.
*/
always_comb begin : maquina_de_estados
    prox_estado = estado_atual;
    counter1 = 0;
    sync = 0;
    wave = 2'bx;
    if(reset) prox_estado = 0;
    else
        case(estado_atual)
        0: prox_estado = 1; //INICIO
        1: begin //A0
            counter1 = counter_ff1 + 1;
            wave = Ax[1:0];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 2;
            end
        end
        2: begin //A1
            counter1 = counter_ff1 + 1;
            wave = Ax[3:2];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 3;
            end
        end
        3: begin //A2
            counter1 = counter_ff1 + 1;
            wave = Ax[5:4];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 4;
            end
        end
        4: begin //A3
            counter1 = counter_ff1 + 1;
            wave = Ax[7:6];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 5;
            end
        end
        5: begin //A4
            counter1 = counter_ff1 + 1;
            wave = Ax[9:8];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 6;
            end
        end
        6: begin //A5
            counter1 = counter_ff1 + 1;
            wave = Ax[11:10];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 7;
            end
        end
        7: begin //A6
            counter1 = counter_ff1 + 1;
            wave = Ax[13:12];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 8;
            end
        end
        8: begin //A7
            counter1 = counter_ff1 + 1;
            wave = Ax[15:14];
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 9;
            end
        end
        9: begin //D3
            counter1 = counter_ff1 + 1;
            if(D[3]==1) wave = 2'b11;
            else wave = 2'b00;
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 10;
            end
        end
        10: begin //D2
            counter1 = counter_ff1 + 1;
            if(D[2]==1) wave = 2'b11;
            else wave = 2'b00;
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 11;
            end
        end
        11: begin //D1
            counter1 = counter_ff1 + 1;
            if(D[1]==1) wave = 2'b11;
            else wave = 2'b00;
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 12;
            end
        end
        12: begin //D0
            counter1 = counter_ff1 + 1;
            if(D[0]==1) wave = 2'b11;
            else wave = 2'b00;
            if(counter1==32) begin
                counter1 = 0;
                prox_estado = 13;
            end
        end
        13: begin //SYNC
            counter1 = counter_ff1 + 1;
            wave = 2'b10;
            sync = 1;
            if(counter1==127) begin
                counter1 = 0;
                prox_estado = 0;
                sync = 0;
            end
        end
        endcase
end

/*
O bloco a seguir gera a forma de onda da saída, baseado no valor de wave
e contando os ciclos do oscilador para manter a saída em nível lógico alto e baixo
no tempo correto.
*/
always_comb begin : define_forma_de_onda_da_saida
    counter2 = 0;
    cod_o = 0;
    case(wave)
    2'b00: begin //Bit 0
        counter2 = counter_ff2 + 1;
        if(counter2<=4) cod_o = 1;
        else if(counter2<=16) cod_o = 0;
        else if(counter2<=20) cod_o = 1;
        else if(counter2>20) cod_o = 0;
        if(counter2==32) counter2 = 0;
    end
    2'b11: begin //Bit 1
        counter2 = counter_ff2 + 1;
        if(counter2<=12) cod_o = 1;
        else if(counter2<=16) cod_o = 0;
        else if(counter2<=28) cod_o = 1;
        else if(counter2>28) cod_o = 0;
        if(counter2==32) counter2 = 0;
    end
    2'b01: begin //Bit F
        counter2 = counter_ff2 + 1;
        if(counter2<=4) cod_o = 1;
        else if(counter2<=16) cod_o = 0;
        else if(counter2<=28) cod_o = 1;
        else if(counter2>28) cod_o = 0;
        if(counter2==32) counter2 = 0;
    end
    2'b10: begin //SYNC
        counter2 = counter_ff2 + 1;
        if(counter2<=4) cod_o = 1;
        else cod_o = 0;
        if(counter2==128) counter2 = 0;
    end
    endcase
end

endmodule