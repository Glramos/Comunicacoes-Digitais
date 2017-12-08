clear all;
close all;

Nb = 240000;                                                    	 %N�mero de bits, precisa ser m�ltiplo de 3 e de 8

numSamplesPerSymbol = 16;                                            % Fator de superamostragem 16/amostra              
span = 10;                                                      
rolloff = 0.25;                                                      % Fator de roll-off

rectFilter = [rectwin(numSamplesPerSymbol)', zeros(1, 145)];         % Cria filtro retangular com largura Ts
rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);          % Cria filtro de cosseno levantado

fvtool(rectFilter,'Analysis','Impulse')
fvtool(rrcFilter,'Analysis','Impulse');

for value = [Nb, Nb/10, Nb/100, Nb/1000, Nb/10000]
    %--Quest�o 1--%
    
    rng default                                                      % seed default para o randi
    data = randi([0 1],value,1);                                     % Gera Nb bits aleat�rios

    %--Quest�o 2--%

    M = 16;                                                          % M = n�mero de n�veis
    QAM16 = pskmod(data, M);                                         % Modula os s�mbolos complexos para 16-QAM

    %--Quest�o 3--%
    N = log2(M);                                                     % N = n�mero de bit por s�mbolo

    txSgnRECTQAM16 = upfirdn(QAM16, rectFilter, numSamplesPerSymbol);% Aplica o filtro rectangular para 16-QAM
    nfft = 2^nextpow2(length(txSgnRECTQAM16));
    [espectroRECTQAM16, f] = pwelch(txSgnRECTQAM16, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    figure
    plot(f, 10*log10(espectroRECTQAM16));
    hold on;

    txSgnRRCQAM16 = upfirdn(QAM16, rrcFilter, numSamplesPerSymbol);  % Aplica o filtro de cosseno levantado para 16-QAM
    nfft = 2^nextpow2(length(txSgnRRCQAM16));
    [espectroRRCQAM16, f] = pwelch(txSgnRRCQAM16, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    plot(f, 10*log10(espectroRRCQAM16));
    
    legend('Retangular Pulse','Rised Cossine Pulse (Nyquist)')
    xlabel('Nomalized Frequency')
    ylabel('Magnitude (dB)')
    title(strcat('Spectral Density for 16-QAM / Nb=',num2str(value)))
    grid
end