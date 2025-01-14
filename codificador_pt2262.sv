/*
Projeto Final de Lógica Digital
Autor: Walber Florencio de Almeida
CI Inovador - Polo UFC
10 jan 2025
*/
`timescale 1ns/10ps

module codificador_pt2262(
    input logic clk,        // 3MHz conforme especificação do clock
    input logic reset,      // reset ativo em alto
    input logic [7:0] A,    // endereço de entrada, trinário
    input logic [3:0] D,    // dado de entrada
    output logic sync,      // indica geração do simbolo sync
    output logic cod_o      // saída codificada
);

logic [6:0] counter, counter_ff;        // contadores
logic [1:0] wave;                       // par de bits usado para auxiliar na construção da forma de onda
logic [15:0] Ax;                        // bits de endereços. Bit 0 = 00. Bit 1 = 11. Bit F = 01. 
logic [7:0] A_F, A_01;                  // saídas de comp_endereco, indicam se tem F na entrada A
logic osc;                              // 12kHz conforme especificação do oscilador

// Instancia do bloco comp_endereco
comp_endereco Ax01F(.A(A), .A_01(A_01), .A_F(A_F));

// O bloco instanciado a seguir gera um valor para "Ax" baseado nos valores em A_01 e A_F
gera_ax gera_ax(.A_F(A_F), .A_01(A_01), .Ax(Ax));

// Instancia do bloco para gerar o OSC na frequencia correta a partir do CLK
oscilador osc1(.clk(clk), .rst(reset), .osc(osc));

typedef enum integer{INICIO, A0, A1, A2, A3, A4, A5, A6, A7, D3, D2, D1, D0, SYNC} estado_tipo;

estado_tipo prox_estado;    // sinal que contém o próximo estado a ser registrado
estado_tipo estado_atual;   // registrador do estado atual

// Bloco FF para atualizar o estado e o contador junto com o oscilador.
always_ff @(posedge osc or posedge reset) begin: atualiza_estado_e_contadores
    if (reset) begin
        estado_atual <= INICIO;
        counter_ff <= 0;
    end 
    else begin
        estado_atual <= prox_estado;    // Atualiza o estado
        counter_ff <= counter;          // Incrementa o contador
    end
end

/*
O bloco a seguir representa a máquina de estados do sistema de codificação.
Os estados existentes são o INICIO e um estado para cada bit (endereço e dado) 
a ser transmitido, incluindo o SYNC.
*/
always_comb begin : maquina_de_estados
    prox_estado = estado_atual;
    sync = 0;
    wave = 2'bx;
    cod_o = 0;
    counter = 0;
    
    // Máquina de estados
    case(estado_atual)
    INICIO: prox_estado = A0;
    A0: begin
        counter = counter_ff + 1;   // Incrementa o contador
        wave = Ax[1:0];             // Atualiza o valor de wave de acordo com Ax
        if(counter==32) begin       // Após 32 ciclos, zera o contador e muda de estado
            counter = 0;
            prox_estado = A1;
        end
    end
    A1: begin
        counter = counter_ff + 1;
        wave = Ax[3:2];
        if(counter==32) begin
            counter = 0;
            prox_estado = A2;
        end
    end
    A2: begin 
        counter = counter_ff + 1;
        wave = Ax[5:4];
        if(counter==32) begin
            counter = 0;
            prox_estado = A3;
        end
    end
    A3: begin
        counter = counter_ff + 1;
        wave = Ax[7:6];
        if(counter==32) begin
            counter = 0;
            prox_estado = A4;
        end
    end
    A4: begin
        counter = counter_ff + 1;
        wave = Ax[9:8];
        if(counter==32) begin
            counter = 0;
            prox_estado = A5;
        end
    end
    A5: begin
        counter = counter_ff + 1;
        wave = Ax[11:10];
        if(counter==32) begin
            counter = 0;
            prox_estado = A6;
        end
    end
    A6: begin 
        counter = counter_ff + 1;
        wave = Ax[13:12];
        if(counter==32) begin
            counter = 0;
            prox_estado = A7;
        end
    end
    A7: begin 
        counter = counter_ff + 1;
        wave = Ax[15:14];
        if(counter==32) begin
            counter = 0;
            prox_estado = D3;
        end
    end
    D3: begin
        counter = counter_ff + 1;
        if(D[3]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==32) begin
            counter = 0;
            prox_estado = D2;
        end
    end
    D2: begin
        counter = counter_ff + 1;
        if(D[2]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==32) begin
            counter = 0;
            prox_estado = D1;
        end
    end
    D1: begin
        counter = counter_ff + 1;
        if(D[1]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==32) begin
            counter = 0;
            prox_estado = D0;
        end
    end
    D0: begin
        counter = counter_ff + 1;
        if(D[0]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==32) begin
            counter = 0;
            prox_estado = SYNC;
        end
    end
    SYNC: begin
        counter = counter_ff + 1;
        wave = 2'b10;
        sync = 1;
        if(counter==127) begin
            counter = 0;
            prox_estado = INICIO;
        end
    end
    endcase

    /*
    O bloco a seguir gera a forma de onda da saída, baseado no valor de wave
    e contando os ciclos do oscilador para manter a saída em nível lógico alto e baixo
    no tempo correto.
    */
    case(wave)
    2'b00: begin //Bit 0
        if(counter==0) cod_o = 0;
        else if(counter<=4) cod_o = 1;
        else if(counter<=16) cod_o = 0;
        else if(counter<=20) cod_o = 1;
        else if(counter>20) cod_o = 0;
    end
    2'b11: begin //Bit 1
        if(counter==0) cod_o = 0;
        else if(counter<=12) cod_o = 1;
        else if(counter<=16) cod_o = 0;
        else if(counter<=28) cod_o = 1;
        else if(counter>28) cod_o = 0;
    end
    2'b01: begin //Bit F
        if(counter==0) cod_o = 0;
        else if(counter<=4) cod_o = 1;
        else if(counter<=16) cod_o = 0;
        else if(counter<=28) cod_o = 1;
        else if(counter>28) cod_o = 0;
    end
    2'b10: begin //SYNC
        if(counter==0) cod_o = 0;
        else if(counter<=4) cod_o = 1;
        else cod_o = 0;
    end
    endcase
end

endmodule
