# Encoder-Decoder-01F
Projeto Final da disciplina de Lógica Digital da especialização em Microeletrônica

##

O pacote de dados usado nos PT2262 (codificador) -PT2272 (decodificador) para transmitir 8 bits de endereço (A) + 4 bits de dados (D) permite controlar 4 dispositivos a distância.
Durante a transmissão são gerados 4 possíveis símbolos na saída:

- O endereço tem valor trinário - pode ser codificados para cada bit os símbolos 0, 1 e F.
- O símbolo "SYNC" só ocorre sempre no final de uma transmissão e tem a maior parte do tempo em nível baixo. O dado recebido só pode ser considerado válido (mudança na saída D e saída dv do decodificador ativa por 1 ciclo de clock) após o final de todos os bits do pacote e símbolo SYNC estando todos os bits recebidos razoavelmente bem formatados.

![a0](https://github.com/user-attachments/assets/a7f439e9-63e1-4029-8b06-49eb9cdc5d7a)

Sendo cada bit representado pelos símbolos 0, 1, F e SYNC descritos a seguir em função da base de tempo OSC com período alfa:

![code](https://github.com/user-attachments/assets/46801e24-9172-47d9-9588-5340c4dbec30)

O símbolo de SYNC dura 4 bits, sendo que apenas 1/8 de bit fica em nível lógico alto:

![sync](https://github.com/user-attachments/assets/b184f725-1d1a-4e36-9525-787cabf41360)

## Arquivos:

- codificador_pt2262.sv: Codifica os bits de endereço e dados e gera a forma de onda;
- comp_endereco.sv: Usado para simular um sistema analógico que interpreta o símbolo F;
- decodificador_pt2272.sv: Recebe a forma de onda e interpreta para bits de endereço e dados;
- gera_ax.sv: Transforma a entrada de bits trinários em valores binários de mais fácil entendimento;
- oscilador.sv: Gera um ciclo do oscilador a cada 250 ciclos de clock;
- tb_codificador_pt2262.sv: Testa o codificador;
- tb_decodificador_pt2272.sv: Testa o codificador e o decodificador funcionando em conjunto.

## Como funciona?

### Codificador

Recebe como entrada os bits de endereço (A - 8 bits trinários) e os de dados (D - 4 bits), e a saída são a forma de onda codificada (cod_o), como saída serial, e o sinal sync que fica em alto durante a transmissão do bit sync.

### Decodificador

Recebe como entrada os bits de endereço (A - 8 bits trinários) e a forma de onda codificada (cod_i) serial, e tem como saída os bits de dados (D) e um bit de dado válido (dv) que fica em alto quando o endereço de entrada A é igual ao decodificado.
