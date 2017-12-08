clear all;
close all;

Nb = 240000;                                                    	%N�mero de bits, precisa ser m�ltiplo de 3 e de 8

numSamplesPerSymbol = 16;                                           % Fator de superamostragem 16/amostra              
span = 10;                                                      
rolloff = 0.25;                                                     % Fator de roll-off

rectFilter = [rectwin(numSamplesPerSymbol)', zeros(1, 145)];        % Cria filtro retangular com largura Ts
rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);         % Cria filtro de cosseno levantado

fvtool(rectFilter,'Analysis','Impulse')
fvtool(rrcFilter,'Analysis','Impulse');

for value = [Nb, Nb/10, Nb/100, Nb/1000, Nb/10000]
    %--Quest�o 1--%
    
    rng default                                                      % seed default para o randi
    data = randi([0 1],value,1);                                     % Gera Nb bits aleat�rios

    %--Quest�o 2--%

    M = 16;                                                          % M = n�mero de n�veis
    QAM64 = pskmod(data, M);                                         % Modula os s�mbolos complexos para 64-QAM

    %--Quest�o 3--%
    N = log2(M);                                                     % N = n�mero de bit por s�mbolo

    txSgnRECTQAM64 = upfirdn(QAM64, rectFilter, numSamplesPerSymbol);% Aplica o filtro rectangular para 64-QAM
    nfft = 2^nextpow2(length(txSgnRECTQAM64));
    [espectroRECTQAM64, f] = pwelch(txSgnRECTQAM64, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    figure
    plot(f, 10*log10(espectroRECTQAM64));
    hold on;

    txSgnRRCQAM64 = upfirdn(QAM64, rrcFilter, numSamplesPerSymbol);  % Aplica o filtro de cosseno levantado para 64-QAM
    nfft = 2^nextpow2(length(txSgnRRCQAM64));
    [espectroRRCQAM64, f] = pwelch(txSgnRRCQAM64, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    plot(f, 10*log10(espectroRRCQAM64));
    
    legend('Retangular Pulse','Rised Cossine Pulse (Nyquist)')
    xlabel('Nomalized Frequency')
    ylabel('Magnitude (dB)')
    title(strcat('Spectral Density for 64-QAM / Nb=',num2str(value)))
    grid
end