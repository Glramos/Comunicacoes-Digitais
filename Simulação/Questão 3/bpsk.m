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

    M = 2;                                                           % M = n�mero de n�veis
    BPSK = pskmod(data, M);                                          % Modula os s�mbolos complexos para BPSK

    %--Quest�o 3--%
    N = log2(M);                                                     % N = n�mero de bit por s�mbolo

    txSgnRECTBPSK = upfirdn(BPSK, rectFilter, numSamplesPerSymbol);  % Aplica o filtro rectangular para BPSK
    nfft = 2^nextpow2(length(txSgnRECTBPSK));
    [espectroRECTBPSK, f] = pwelch(txSgnRECTBPSK, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    figure
    plot(f, 10*log10(espectroRECTBPSK));
    hold on;

    txSgnRRCBPSK = upfirdn(BPSK, rrcFilter, numSamplesPerSymbol);    % Aplica o filtro de cosseno levantado para BPSK
    nfft = 2^nextpow2(length(txSgnRRCBPSK));
    [espectroRRCBPSK, f] = pwelch(txSgnRRCBPSK, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    plot(f, 10*log10(espectroRRCBPSK));
    
    legend('Retangular Pulse','Rised Cossine Pulse (Nyquist)')
    xlabel('Nomalized Frequency')
    ylabel('Magnitude (dB)')
    title(strcat('Spectral Density for BPSK / Nb=',num2str(value)))
    grid
end