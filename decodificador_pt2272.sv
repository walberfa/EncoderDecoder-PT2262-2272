/*
Projeto Final de Lógica Digital
Autor: Walber Florencio de Almeida
CI Inovador - Polo UFC
*/
`timescale 1ns/10ps

module decodificador_pt2272(
input logic  clk, // 3MHz conforme especificação
input logic reset, // reset ativo alto
input logic [7:0] A, // endereço de entrada, trinário
input logic cod_i,  // dado codificado de entrada
output logic [3:0] D, // dado recebido registrado
output logic dv       // sinalização de novo dado valido recebido, sincrono ao mesmo dominio de clock da saída "D"
);

logic [3:0] prox_estado, estado_atual; // usados para administrar os estados
logic [6:0] counter, counter_ff;  //contadores
logic [15:0] Ax_recebido, Ax_lido; //bits de endereços. Bit 0 = 00. Bit 1 = 11. Bit F = 01. Usados para comparar o A recebido e o lido
logic [3:0] Dx; // usado para guardar o valor de D temporariamente
logic [7:0] A_F, A_01; //saídas de comp_endereco, indicam se tem F na entrada A
logic osc; // 12kHz conforme especificação do oscilador

// Instancia do bloco comp_endereco
comp_endereco Ax01F(.A(A), .A_01(A_01), .A_F(A_F));

// O bloco instanciado a seguir gera um valor para "Ax" baseado nos valores em A_01 e A_F
gera_ax gera_ax(.A_F(A_F), .A_01(A_01), .Ax(Ax_recebido));

// Instancia do bloco para gerar o OSC na frequencia correta a partir do CLK
oscilador osc1(.clk(clk), .rst(reset), .osc(osc));

// Bloco FF para atualizar o estado e o contador
always_ff @(posedge osc or posedge reset) begin : atualiza_estado_e_contadores
    if(reset) begin
        estado_atual <= 0;
        D <= 4'b0;
        dv <= 0;
    end
    else begin 
        estado_atual <= prox_estado;
        counter_ff <= counter;
        if(estado_atual==14 && Ax_lido==Ax_recebido) begin
            D <= Dx;
            dv <= 1;
        end 
        else dv <= 0;
    end
end

/*
O bloco a seguir representa a máquina de estados do sistema de decodificação.
Os estados existentes são o INICIO, um estado para cada bit (endereço e dado) 
a ser lido, incluindo o SYNC, e o final para atualizar o valor de D e subir dv.
*/
always_comb begin
    prox_estado = estado_atual;
    counter = 0;

    if(reset) begin
        prox_estado = 0;
        Ax_lido = 16'b0;
        Dx = 4'b0;
    end
    else
    case(estado_atual)
        0: begin //INICIO
            prox_estado = 1;
        end
        1: begin //A0
            counter = counter_ff + 1;
            if (counter_ff==5 && cod_i==1) Ax_lido[1]=1;
            if (counter_ff==21 && cod_i==1) Ax_lido[0]=1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 2;
            end
        end
        2: begin //A1
            counter = counter_ff + 1;
            if (counter_ff==5 && cod_i==1) Ax_lido[3]=1;
            if (counter_ff==21 && cod_i==1) Ax_lido[2]=1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 3;
            end
        end
        3: begin //A2
            counter = counter_ff + 1;
            if (counter_ff==5 && cod_i==1) Ax_lido[5] = 1;
            if (counter_ff==21 && cod_i==1) Ax_lido[4] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 4;
            end
        end
        4: begin //A3
            counter = counter_ff + 1;
            if (counter_ff==5 && cod_i==1) Ax_lido[7] = 1;
            if (counter_ff==21 && cod_i==1) Ax_lido[6] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 5;
            end
        end
        5: begin //A4
            counter = counter_ff + 1;
            Dx = 4'b0;
            if (counter_ff==5 && cod_i==1) Ax_lido[9] = 1;
            if (counter_ff==21 && cod_i==1) Ax_lido[8] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 6;
            end
        end
        6: begin //A5
            counter = counter_ff + 1;
            Dx = 4'b0;
            if (counter_ff==5 && cod_i==1) Ax_lido[11] = 1;
            if (counter_ff==21 && cod_i==1) Ax_lido[10] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 7;
            end
        end
        7: begin //A6
            counter = counter_ff + 1;
            Dx = 4'b0;
            if (counter_ff==5 && cod_i==1) Ax_lido[13] = 1;
            if (counter_ff==21 && cod_i==1) Ax_lido[12] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 8;
            end
        end
        8: begin //A7
            counter = counter_ff + 1;
            Dx = 4'b0;
            if (counter_ff==5 && cod_i==1) Ax_lido[15] = 1;
            if (counter_ff==21 && cod_i==1) Ax_lido[14] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 9;
            end
        end
        9: begin //D3
            counter = counter_ff + 1;
            Ax_lido = Ax_lido;
            if (counter_ff==5 && cod_i==1) Dx[3] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 10;
            end
        end
        10: begin //D2
            counter = counter_ff + 1;
            Ax_lido = Ax_lido;
            if (counter_ff==5 && cod_i==1) Dx[2] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 11;
            end
        end
        11: begin //D1
            counter = counter_ff + 1;
            Ax_lido = Ax_lido;
            if (counter_ff==5 && cod_i==1) Dx[1] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 12;
            end
        end
        12: begin //D0
            counter = counter_ff + 1;
            Ax_lido = Ax_lido;
            if (counter_ff==5 && cod_i==1) Dx[0] = 1;
            if (counter_ff==31) begin
                counter = 0;
                prox_estado = 13;
            end
        end
        13: begin //SYNC
            counter = counter_ff + 1;
            Ax_lido = Ax_lido;
            Dx = Dx;
            if (counter_ff==127) begin
                counter = 0;
                prox_estado = 14;
            end
        end
        14: begin //FIM
            prox_estado = 0;
        end
        endcase
end

endmodule
