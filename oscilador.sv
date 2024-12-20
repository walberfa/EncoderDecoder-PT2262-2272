/*
O oscilador tem pulsos aproximadamente 250x maiores que o clock.
CLK: frequência de 3MHz equivale a aproximadamente um período de 333ns.
OSC: frequência de 12kHz equivale a aproximadamente um período de 83,3us.
*/

`timescale 1ns/10ps

module oscilador(
    input logic clk, // 3MHz conforme especificação do clock 
    input logic rst, // reset ativo alto
    output logic osc // 12kHz conforme especificação do oscilador
);

logic [6:0] counter; // contador para contar até 125

always_ff @(posedge clk) begin 
    if(rst) begin
        counter <= 0;
        osc <= 1;
    end
    else begin
        osc <= osc;
        if(counter==125) begin
            counter <= 0; // zera o contador após 125
            osc <= ~osc; // alterna o oscilador entre 0 e 1
        end
        else begin
            counter <= counter + 1;
        end
    end
end

endmodule