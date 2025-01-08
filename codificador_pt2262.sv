/*
Projeto Final de Lógica Digital
Autor: Walber Florencio de Almeida
CI Inovador - Polo UFC
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

logic [3:0] prox_estado, estado_atual;  // usados para administrar os estados
logic [6:0] counter;                    // contador
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

/*
Bloco FF para atualizar o estado e o contador junto com o oscilador.
Além disso, nesse bloco o contador é zerado quando necessário.
*/
always_ff @(posedge osc or posedge reset) begin: atualiza_estado_e_contadores
    if (reset) begin
        estado_atual <= 0;
        counter <= 0;
    end 
    else begin
        estado_atual <= prox_estado;
        counter <= counter + 1;    // Incrementa o contador
        
        if (counter==31 && (estado_atual!=13 || wave!=2'b10)) counter<=0; // Zera o contador em 31 ao final da transmissão dos bits de endereço e dados
        if (counter==127 && (estado_atual==13 || wave==2'b10)) counter<=0; // Zera o contador em 127 no SYNC
    end
end

/*
O bloco a seguir representa a máquina de estados do sistema de codificação.
Os estados existentes são o INICIO e um estado para cada bit (endereço e dado) 
a ser transmitido, incluindo o SYNC.
*/
always_comb begin : maquina_de_estados
    prox_estado = estado_atual;
    sync = 0; // Inicializa a sincronização
    wave = 2'bx; // Inicializa a variável wave com um valor indefinido
        
    case(estado_atual)
    0: prox_estado = 1; //INICIO
    1: begin //A0
        wave = Ax[1:0];
        if(counter==31) prox_estado = 2;
    end
    2: begin //A1
        wave = Ax[3:2];
        if(counter==31) prox_estado = 3;
    end
    3: begin //A2
        wave = Ax[5:4];
        if(counter==31) prox_estado = 4;
    end
    4: begin //A3
        wave = Ax[7:6];
        if(counter==31) prox_estado = 5;
    end
    5: begin //A4
        wave = Ax[9:8];
        if(counter==31) prox_estado = 6;
    end
    6: begin //A5
        wave = Ax[11:10];
        if(counter==31) prox_estado = 7;
    end
    7: begin //A6
        wave = Ax[13:12];
        if(counter==31) prox_estado = 8;
    end
    8: begin //A7
        wave = Ax[15:14];
        if(counter==31) prox_estado = 9;
    end
    9: begin //D3
        if(D[3]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==31) prox_estado = 10;
    end
    10: begin //D2
        if(D[2]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==31) prox_estado = 11;
    end
    11: begin //D1
        if(D[1]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==31) prox_estado = 12;
    end
    12: begin //D0
        if(D[0]==1) wave = 2'b11;
        else wave = 2'b00;
        if(counter==31) prox_estado = 13;
    end
    13: begin //SYNC
        wave = 2'b10;
        sync = 1;
        if(counter==127) begin
            prox_estado = 0;
        end
    end
    endcase
end

/*
O bloco a seguir gera a forma de onda da saída, baseado no valor de wave
e contando os ciclos do oscilador para manter a saída em nível lógico alto e baixo
no tempo correto.
*/
always_comb begin: define_forma_de_onda_da_saida
    cod_o = 0;
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
