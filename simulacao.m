clear all;
close all;

%--Quest�o 1--%
Nb = 240000;                                                     %N�mero de bits, precisa ser m�ltiplo de 3 e de 8

rng default                                                      % seed default para o randi
data = randi([0 1],Nb,1);                                        % Gera Nb bits aleat�rios


%--Quest�o 2--%

%-----BPSK----%
M = 2;                                                           % M = n�mero de n�veis
BPSK = pskmod(data, M);                                          % Modula os s�mbolos complexos para BPSK

%-----8-PSK----%
M = 8;                                                           % M = n�mero de n�veis
N = log2(M);                                                     % N = n�mero de bit por s�mbolo

dataInMatrix = reshape(data,length(data)/N,N);                   % Reformula o vetor para gerar os s�mbolos para o 8-PSK
dataSymbolsIn = bi2de(dataInMatrix);                             % Gera os inteiros com base no vetor aleat�rio criado

PSK8 = pskmod(dataSymbolsIn, M);                                 % Modula os s�mbolos complexos para 8-PSK

%-----16-QAM---%
M = 16;                                                          % M = n�mero de n�veis
N = log2(M);                                                     % N = n�mero de bit por s�mbolo

dataInMatrix = reshape(data,length(data)/N,N);                   % Reformula o vetor para gerar os s�mbolos para o 16-QAM
dataSymbolsIn = bi2de(dataInMatrix);                             % Gera os inteiros com base no vetor aleat�rio criado

QAM16 = qammod(dataSymbolsIn, M);                                % Modula os s�mbolos complexos para 16-QAM

%-----64-QAM---%
M = 64;                                                          % M = n�mero de n�veis

N = log2(M);                                                     % N = n�mero de bit por s�mbolo

dataInMatrix = reshape(data,length(data)/N,N);                   % Reformula o vetor para gerar os s�mbolos para o 64-QAM
dataSymbolsIn = bi2de(dataInMatrix);                             % Gera os inteiros com base no vetor aleat�rio criado

QAM64 = qammod(dataSymbolsIn, M);                                % Modula os s�mbolos complexos para 64-QAM

% txSig = awgn(QAM64,10);

% x = scatterplot(txSig,1,0,'g.');
% hold on
% scatterplot(QAM64,1,0,'k*', x);


%--Quest�o 3--%
numSamplesPerSymbol = 16;                                        % Fator de superamostragem 16/amostra              
span = 10;                                                      
rolloff = 0.25;                                                  % Fator de roll-off

rectFilter = [rectwin(numSamplesPerSymbol)', zeros(1, 145)];     % Cria filtro retangular com largura Ts
rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);      % Cria filtro de cosseno levantado

fvtool(rectFilter,'Analysis','Impulse')
fvtool(rrcFilter,'Analysis','Impulse');

%-----BPSK----%
M = 2;                                                           % M = n�mero de n�veis
N = log2(M);                                                     % N = n�mero de bit por s�mbolo

Ts = 1/10^6 * N;                                                 % Calcula tempo de s�mbolo

nfft = 2^nextpow2(length(txSgnRectBPSK));

txSgnRectBPSK = upfirdn(BPSK, rectFilter, numSamplesPerSymbol);  % Aplica o filtro rectangular para BPSK
[espectroRECTBPSK, f] = pwelch(txSgnRectBPSK, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

txSgnRCCBPSK = upfirdn(BPSK, rrcFilter, numSamplesPerSymbol);    % Aplica o filtro de cosseno levantado para BPSK
[espectroRRCBPSK, f] = pwelch(txSgnRCCBPSK, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

figure
plot(f, 10*log10(espectroRECTBPSK));
hold on;
plot(f, 10*log10(espectroRRCBPSK));
legend('Pulso Retangular','Cosseno Levantado')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('Spectral Density for BPSK')
grid

%-----8-PSK----%
M = 8;                                                           % M = n�mero de n�veis
N = log2(M);                                                     % N = n�mero de bit por s�mbolo

Ts = 1/10^6 * N;                                                 % Calcula tempo de s�mbolo

nfft = 2^nextpow2(length(txSgnRCCPSK8));

txSgnRectBPSK = upfirdn(PSK8, rectFilter, numSamplesPerSymbol);  % Aplica o filtro rectangular para 8-PSK
[espectroRECTBPSK, f] = pwelch(txSgnRectBPSK, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

txSgnRCCPSK8 = upfirdn(PSK8, rrcFilter, numSamplesPerSymbol);    % Aplica o filtro de cosseno levantado para 8-PSK
[espectroRRCPSK8, f] = pwelch(txSgnRCCPSK8, [], [], [], numSamplesPerSymbol,'centered', 'power');

figure
plot(f, 10*log10(espectroRECTPSK8));
hold on;
plot(f, 10*log10(espectroRRCPSK8));
legend('Pulso Retangular','Cosseno Levantado')
xlabel('Normalized Frequency')
ylabel('Magnitude (dB)')
title('Spectral Density for 64-QAM')
grid

%-----16-QAM---%
M = 16;                                                          % M = n�mero de n�veis
N = log2(M);                                                     % N = n�mero de bit por s�mbolo

Ts = 1/10^6 * N;                                                 % Calcula tempo de s�mbolo



txSgnRectQAM16 = upfirdn(QAM16, rectFilter, numSamplesPerSymbol); % Aplica o filtro rectangular para 16-QAM
nfft = 2^nextpow2(length(txSgnRectQAM16));
[espectroRECTQAM16, f] = pwelch(txSgnRectQAM16, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

txSgnRCCQAM16 = upfirdn(QAM16, rrcFilter, numSamplesPerSymbol);  % Aplica o filtro de cosseno levantado para 16-QAM
nfft = 2^nextpow2(length(txSgnRCCQAM16));
[espectroRRCQAM16, f] = pwelch(txSgnRCCQAM16, [], [], [], numSamplesPerSymbol,'centered', 'power');

figure
plot(f, 10*log10(espectroRECTQAM16));
hold on;
plot(f, 10*log10(espectroRRCQAM16));
legend('Pulso Retangular','Cosseno Levantado')
xlabel('Normalized Frequency')
ylabel('Magnitude (dB)')
title('Spectral Density for 64-QAM')
grid

%-----64-QAM---%
M = 64;                                                          % M = n�mero de n�veis
N = log2(M);                                                     % N = n�mero de bit por s�mbolo

Ts = 1/10^6 * N;                                                 % Calcula tempo de s�mbolo

txSgnRectBPSK = upfirdn(QAM64, rectFilter, numSamplesPerSymbol); % Aplica o filtro rectangular para 64-QAM

nfft = 2^nextpow2(length(txSgnRectQAM64));
[espectroRECTBPSK, f] = pwelch(txSgnRectBPSK, [], [], nfft, numSamplesPerSymbol,'centered', 'power');


txSgnRRCQAM64 = upfirdn(QAM64, rrcFilter, numSamplesPerSymbol);  % Aplica o filtro de cosseno levantado para 64-QAM

nfft = 2^nextpow2(length(txSgnRRCQAM64));
[espectroRRCQAM64, f] = pwelch(txSgnRCCQAM64, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

figure
plot(f, 10*log10(espectroRECTQAM64));
hold on;
plot(f, 10*log10(espectroRRCQAM64));
legend('Pulso Retangular','Cosseno Levantado')
xlabel('Normalized Frequency')
ylabel('Magnitude (dB)')
title('Spectral Density for 64-QAM')
grid


