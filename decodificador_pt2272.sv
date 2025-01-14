/*
Projeto Final de Lógica Digital
Autor: Walber Florencio de Almeida
CI Inovador - Polo UFC
10 jan 2025
*/
`timescale 1ns/10ps

module decodificador_pt2272(
input logic  clk,       // 3MHz conforme especificação
input logic reset,      // reset ativo alto
input logic [7:0] A,    // endereço de entrada, trinário
input logic cod_i,      // dado codificado de entrada
output logic [3:0] D,   // dado recebido registrado
output logic dv         // sinalização de novo dado valido recebido, sincrono ao mesmo dominio de clock da saída "D"
);

logic [6:0] counter, counter_ff;                // contadores
logic [15:0] Ax_recebido, Ax_lido, Ax_lido_ff;  // bits de endereços. Bit 0 = 00. Bit 1 = 11. Bit F = 01. Usados para comparar o A recebido e o lido
logic [3:0] Dx, Dx_ff, D_ff;                    // usados para guardar o valor de D temporariamente
logic [7:0] A_F, A_01;                          // saídas de comp_endereco, indicam se tem F na entrada A
logic osc;                                      // 12kHz conforme especificação do oscilador

typedef enum integer{INICIO, A0, A1, A2, A3, A4, A5, A6, A7, D3, D2, D1, D0, SYNC, FIM} estado_tipo;

estado_tipo prox_estado;    // sinal que contém o próximo estado a ser registrado
estado_tipo estado_atual;   // registrador do estado atual

// Instancia do bloco comp_endereco
comp_endereco Ax01F(.A(A), .A_01(A_01), .A_F(A_F));

// O bloco instanciado a seguir gera um valor para "Ax" baseado nos valores em A_01 e A_F
gera_ax gera_ax(.A_F(A_F), .A_01(A_01), .Ax(Ax_recebido));

// Instancia do bloco para gerar o OSC na frequencia correta a partir do CLK
oscilador osc1(.clk(clk), .rst(reset), .osc(osc));

// Bloco FF para atualizar o estado e o contador junto com o oscilador e manter os valores das variáveis temporárias
always_ff @(posedge osc or posedge reset) begin : atualiza_estado_e_contadores
    if(reset) begin
        estado_atual <= 0;
        counter_ff <= 0;
        D_ff <= 0;
        Dx_ff <= 0;
        Ax_lido_ff <= 0;
    end
    else begin 
        estado_atual <= prox_estado;
        counter_ff <= counter;
        D_ff <= D;
        Dx_ff <= Dx;
        Ax_lido_ff <= Ax_lido;
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
    Ax_lido = Ax_lido_ff;
    Dx = Dx_ff;
    D = D_ff;
    dv = 0;

    if(reset) begin
        prox_estado = 0;
        counter = 0;
        Ax_lido = 16'b0;
        Dx = 4'b0;
        D = 4'b0;
        dv = 0;
    end
    else
    
    // Máquina de estados
    case(estado_atual)
        INICIO: begin
            if (cod_i==1) prox_estado = A0;      // Inicia quando cod_i sobe
        end
        A0: begin
            counter = counter_ff + 1;                   // Incrementa o contador
            if (counter==7 && cod_i==1) Ax_lido[1]=1;   // Verifica o valor de cod_i no 7° ciclo e atualiza Ax_lido
            if (counter==24 && cod_i==1) Ax_lido[0]=1;  // Verifica o valor de cod_i no 24° ciclo e atualiza Ax_lido
            if (counter==32) begin                      // Após 32 ciclos, zera o contador e muda de estado
                counter = 0;
                prox_estado = A1;
            end
        end
        A1: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[3]=1;
            if (counter==24 && cod_i==1) Ax_lido[2]=1;
            if (counter==32) begin
                counter = 0;
                prox_estado = A2;
            end
        end
        A2: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[5] = 1;
            if (counter==24 && cod_i==1) Ax_lido[4] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = A3;
            end
        end
        A3: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[7] = 1;
            if (counter==24 && cod_i==1) Ax_lido[6] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = A4;
            end
        end
        A4: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[9] = 1;
            if (counter==24 && cod_i==1) Ax_lido[8] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = A5;
            end
        end
        A5: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[11] = 1;
            if (counter==24 && cod_i==1) Ax_lido[10] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = A6;
            end
        end
        A6: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[13] = 1;
            if (counter==24 && cod_i==1) Ax_lido[12] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = A7;
            end
        end
        A7: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Ax_lido[15] = 1;
            if (counter==24 && cod_i==1) Ax_lido[14] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = D3;
            end
        end
        D3: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Dx[3] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = D2;
            end
        end
        D2: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Dx[2] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = D1;
            end
        end
        D1: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Dx[1] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = D0;
            end
        end
        D0: begin
            counter = counter_ff + 1;
            if (counter==7 && cod_i==1) Dx[0] = 1;
            if (counter==32) begin
                counter = 0;
                prox_estado = SYNC;
            end
        end
        SYNC: begin
            counter = counter_ff + 1;
            if (counter==120) begin
                counter = 0;
                prox_estado = FIM;
            end
        end
        FIM: begin // Se o Ax lido for igual ao Ax recebido (entrada A), então sobe dv por um ciclo e atualiza D
            if(Ax_lido==Ax_recebido) begin 
                D = Dx;
                dv = 1;
                Dx = 0; // Reseta Dx
            end
            prox_estado = INICIO;
        end
        endcase
end

endmodule
