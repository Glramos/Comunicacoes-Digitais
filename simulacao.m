clear all;
close all;

%--Questão 1--%
Nb = 24000;                                                     %Número de bits, precisa ser múltiplo de 3 e de 8

rng default                                                     % seed default para o randi
data = randi([0 1],Nb,1);                                       % Gera Nb bits aleatórios


%--Questão 2--%

%-----BPSK----%
M = 2;                                                          % M = número de níveis
BPSK = pskmod(data, M);                                         % Modula os símbolos complexos para BPSK

%-----8-PSK----%
M = 8;                                                          % M = número de níveis
N = log2(M);                                                    % N = número de bit por símbolo

dataInMatrix = reshape(data,length(data)/N,N);                  % Reformula o vetor para gerar os símbolos para o 8-PSK
dataSymbolsIn = bi2de(dataInMatrix);                            % Gera os inteiros com base no vetor aleatório criado

PSK8 = pskmod(dataSymbolsIn, M);                                % Modula os símbolos complexos para 8-PSK

%-----16-QAM---%
M = 16;                                                         % M = número de níveis
N = log2(M);                                                    % N = número de bit por símbolo

dataInMatrix = reshape(data,length(data)/N,N);                  % Reformula o vetor para gerar os símbolos para o 16-QAM
dataSymbolsIn = bi2de(dataInMatrix);                            % Gera os inteiros com base no vetor aleatório criado

QAM16 = qammod(dataSymbolsIn, M);                               % Modula os símbolos complexos para 16-QAM

%-----64-QAM---%
M = 64;                                                         % M = número de níveis

N = log2(M);                                                    % N = número de bit por símbolo

dataInMatrix = reshape(data,length(data)/N,N);                  % Reformula o vetor para gerar os símbolos para o 64-QAM
dataSymbolsIn = bi2de(dataInMatrix);                            % Gera os inteiros com base no vetor aleatório criado

QAM64 = qammod(dataSymbolsIn, M);                               % Modula os símbolos complexos para 64-QAM

txSig = awgn(QAM64,10);

x = scatterplot(txSig,1,0,'g.');
hold on
scatterplot(QAM64,1,0,'k*', x);


%--Questão 3--%
numSamplesPerSymbol = 16;                                       % Fator de superamostragem 16/amostra              
span = 10;                                                      
rolloff = 0.25;                                                 % Fator de roll-off
Ts = 1/10^6 * N

rectFilter = rectpulse(-Ts,Ts)
rccFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);     % Cria filtro de cosseno levantado

txSignalBPSK = upfirdn(BPSK, rrcFilter, numSamplesPerSymbol);   % Aplica o filtro de cosseno levantado para BPSK

