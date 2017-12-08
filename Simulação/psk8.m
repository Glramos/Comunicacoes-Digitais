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

    M = 8;                                                           % M = n�mero de n�veis
    PSK8 = pskmod(data, M);                                          % Modula os s�mbolos complexos para 8-PSK

    %--Quest�o 3--%
    N = log2(M);                                                     % N = n�mero de bit por s�mbolo

    txSgnRECTPSK8 = upfirdn(PSK8, rectFilter, numSamplesPerSymbol);  % Aplica o filtro rectangular para 8-PSK
    nfft = 2^nextpow2(length(txSgnRECTPSK8));
    [espectroRECTPSK8, f] = pwelch(txSgnRECTPSK8, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    figure
    plot(f, 10*log10(espectroRECTPSK8));
    hold on;

    txSgnRRCPSK8 = upfirdn(PSK8, rrcFilter, numSamplesPerSymbol);    % Aplica o filtro de cosseno levantado para 8-PSK
    nfft = 2^nextpow2(length(txSgnRRCPSK8));
    [espectroRRCPSK8, f] = pwelch(txSgnRRCPSK8, [], [], nfft, numSamplesPerSymbol,'centered', 'power');

    plot(f, 10*log10(espectroRRCPSK8));
    
    legend('Retangular Pulse','Rised Cossine Pulse (Nyquist)')
    xlabel('Nomalized Frequency')
    ylabel('Magnitude (dB)')
    title(strcat('Spectral Density for 8-PSK / Nb=',num2str(value)))
    grid
end