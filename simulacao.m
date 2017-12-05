clear all;
close all;

%--Quest�o 1--%
Nb = 24000;                                                     %N�mero de bits, precisa ser m�ltiplo de 3 e de 8

rng default                                                     % seed default para o randi
data = randi([0 1],Nb,1);                                       % Gera Nb bits aleat�rios


%--Quest�o 2--%

%-----BPSK----%
M = 2;                                                          % M = n�mero de n�veis
BPSK = pskmod(data, M);                                         % Modula os s�mbolos complexos para BPSK

%-----8-PSK----%
M = 8;                                                          % M = n�mero de n�veis
N = log2(M);                                                    % N = n�mero de bit por s�mbolo

dataInMatrix = reshape(data,length(data)/N,N);                  % Reformula o vetor para gerar os s�mbolos para o 8-PSK
dataSymbolsIn = bi2de(dataInMatrix);                            % Gera os inteiros com base no vetor aleat�rio criado

PSK8 = pskmod(dataSymbolsIn, M);                                % Modula os s�mbolos complexos para 8-PSK

%-----16-QAM---%
M = 16;                                                         % M = n�mero de n�veis
N = log2(M);                                                    % N = n�mero de bit por s�mbolo

dataInMatrix = reshape(data,length(data)/N,N);                  % Reformula o vetor para gerar os s�mbolos para o 16-QAM
dataSymbolsIn = bi2de(dataInMatrix);                            % Gera os inteiros com base no vetor aleat�rio criado

QAM16 = qammod(dataSymbolsIn, M);                               % Modula os s�mbolos complexos para 16-QAM

%-----64-QAM---%
M = 64;                                                         % M = n�mero de n�veis

N = log2(M);                                                    % N = n�mero de bit por s�mbolo

dataInMatrix = reshape(data,length(data)/N,N);                  % Reformula o vetor para gerar os s�mbolos para o 64-QAM
dataSymbolsIn = bi2de(dataInMatrix);                            % Gera os inteiros com base no vetor aleat�rio criado

QAM64 = qammod(dataSymbolsIn, M);                               % Modula os s�mbolos complexos para 64-QAM

txSig = awgn(QAM64,10);

x = scatterplot(txSig,1,0,'g.');
hold on
scatterplot(QAM64,1,0,'k*', x);


%--Quest�o 3--%
numSamplesPerSymbol = 16;                                       % Fator de superamostragem 16/amostra              
span = 10;                                                      
rolloff = 0.25;                                                 % Fator de roll-off
Ts = 1/10^6 * N

rectFilter = rectpulse(-Ts,Ts)
rccFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);     % Cria filtro de cosseno levantado

txSignalBPSK = upfirdn(BPSK, rrcFilter, numSamplesPerSymbol);   % Aplica o filtro de cosseno levantado para BPSK

