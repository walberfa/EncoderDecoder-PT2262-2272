# Encoder-Decoder-01F
Projeto Final da disciplina de Lógica Digital da especialização em Microeletrônica

##

O pacote de dados usado nos PT2262 (codificador) -PT2272 (decodificador) para transmitir 8 bits de endereço (A) + 4 bits de dados (D) permite controlar 4 dispositivos a distância.
Durante a transmissão são gerados 4 possíveis símbolos na saída:

- O endereço tem valor trinário - pode ser codificados para cada bit os símbolos 0, 1 e F.
- O símbolo "SYNC" só ocorre sempre no final de uma transmissão e tem a maior parte do tempo em nível baixo. O dado recebido só pode ser considerado válido (mudança na saída D e saída dv do decodificador ativa por 1 ciclo de clock) após o final de todos os bits do pacote e símbolo SYNC estando todos os bits recebidos razoavelmente bem formatados.

![a0](https://github.com/user-attachments/assets/a7f439e9-63e1-4029-8b06-49eb9cdc5d7a)

Sendo cada bit representado pelos símbolos 0, 1, F e SYNC descritos a seguir em função da base de tempo OSC com período alfa ():

![code](https://github.com/user-attachments/assets/46801e24-9172-47d9-9588-5340c4dbec30)

O símbolo de SYNC dura 4 bits. sendo que apenas 1/8 de bit fica em nível lógico alto:

![sync](https://github.com/user-attachments/assets/b184f725-1d1a-4e36-9525-787cabf41360)

