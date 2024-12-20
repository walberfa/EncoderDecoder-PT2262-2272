`timescale 1ns/10ps

module gera_ax(
    input logic [7:0] A_F, A_01, // entradas vindas do comp_endereco
    output logic [15:0] Ax // saida do módulo
);

/* 
Gera um valor para "Ax" baseado nos valores em A_01 e A_F. 
Bit 0 (A_F=0 && A_01=0) : 00. 
Bit 1 (A_F=0 && A_01=1) : 11. 
Bit F (A_F=1) : 01. 
*/

always_comb begin : gera_valor_Ax
    //A0
    if(A_F[0]==1) Ax[1:0] = 01;
    else begin
        if(A_01[0]==1) Ax[1:0] = 11;
        else Ax[1:0] = 00;
    end
    //A1
    if(A_F[1]==1) Ax[3:2] = 01;
    else begin
        if(A_01[1]==1) Ax[3:2] = 11;
        else Ax[3:2] = 00;
    end
    //A2
    if(A_F[2]==1) Ax[5:4] = 01;
    else begin
        if(A_01[2]==1) Ax[5:4] = 11;
        else Ax[5:4] = 00;
    end
    //A3
    if(A_F[3]==1) Ax[7:6] = 01;
    else begin
        if(A_01[3]==1) Ax[7:6] = 11;
        else Ax[7:6] = 00;
    end
    //A4
    if(A_F[4]==1) Ax[9:8] = 01;
    else begin
        if(A_01[4]==1) Ax[9:8] = 11;
        else Ax[9:8] = 00;
    end
    //A5
    if(A_F[5]==1) Ax[11:10] = 01;
    else begin
        if(A_01[5]==1) Ax[11:10] = 11;
        else Ax[11:10] = 00;
    end
    //A6
    if(A_F[6]==1) Ax[13:12] = 01;
    else begin
        if(A_01[6]==1) Ax[13:12] = 11;
        else Ax[13:12] = 00;
    end
    //A7
    if(A_F[7]==1) Ax[15:14] = 01;
    else begin
        if(A_01[7]==1) Ax[15:14] = 11;
        else Ax[15:14] = 00;
    end
end

endmodule