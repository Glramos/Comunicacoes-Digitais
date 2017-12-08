clear all;
close all;

Nb = 240000;                                                    	 %N�mero de bits, precisa ser m�ltiplo de 3 e de 8

for i = [Nb, Nb/1000]
    numSamplesPerSymbol = 16;                                            % Fator de superamostragem 16/amostra              
    span = 10;                                                      
    rolloff = 0.25;                                                      % Fator de roll-off

    rectFilter = [rectwin(numSamplesPerSymbol)', zeros(1, 145)];         % Cria filtro retangular com largura Ts
    rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);          % Cria filtro de cosseno levantado

    %--Quest�o 1--%

    rng default                                                      % seed default para o randi
    data = randi([0 1],Nb,1);                                           % Gera Nb bits aleat�rios

    %--Quest�o 2--%

    M = 16;                                                           % M = n�mero de n�veis
    QAM16 = qammod(data, M);                                          % Modula os s�mbolos complexos para 16-QAM

    %--Quest�o 3--%
    N = log2(M);                                                     % N = n�mero de bit por s�mbolo

    txSgnRECTQAM16 = upfirdn(QAM16, rectFilter, numSamplesPerSymbol);  % Aplica o filtro rectangular para 16-QAM

    txSgnRRCQAM16 = upfirdn(QAM16, rrcFilter, numSamplesPerSymbol);    % Aplica o filtro de cosseno levantado para 16-QAM

    %--Quest�o 5--%

    input = de2bi(data,N);  % Dados bin�rios na entrada

    rectFilter = fliplr(rectFilter);
    for value = 1:1:(11*N)

        EbNo(value) = value-1;

        snr = value + 10*log10(N) - 10*log10(numSamplesPerSymbol);                % SNR de acordo com a Es/N0 escolhida
        noiseSignal = awgn(txSgnRECTQAM16,snr,'measured');                         % Gera o ru�do

        rxSgnRECTQAM16 = upfirdn(noiseSignal, rectFilter, 1, numSamplesPerSymbol);  % Aplica o filtro rectangular para 16-QAM
        rxSgnRECTQAM16 = rxSgnRECTQAM16(span+1:end-span);

        demodData = qamdemod(rxSgnRECTQAM16, M);                                    % Demodula o sinal
        output = de2bi(demodData,N);                                              % Saida bin�ria de dados

        [biterrados(value), BER(value)] = biterr(input, output);

    end                                                                % Passando de energia de bit para energia de s�mbolo

    berTheory = berawgn(EbNo,'qam',M,'nondiff');
    figure
    semilogy(EbNo,BER,'b*');
    hold on
    semilogy(EbNo,berTheory,'r:.');
    grid on
    title(strcat('BER 16-QAM RECT Nb=', num2str(i)))

    rrcFilter = fliplr(rrcFilter);
    for value = 1:1:(11*N)
        EbNo(value) = value-1;

        snr = value + 10*log10(N) - 10*log10(numSamplesPerSymbol);                % SNR de acordo com a Es/N0 escolhida
        noiseSignal = awgn(txSgnRRCQAM16,value,'measured');

        rxSgnRRCQAM16 = upfirdn(noiseSignal, rrcFilter, 1, numSamplesPerSymbol);   % Aplica o filtro rectangular para 16-QAM
        rxSgnRRCQAM16 = rxSgnRRCQAM16(span+1:end-span);

        demodData = qamdemod(rxSgnRRCQAM16, M);                                    % Demodula o sinal
        output = de2bi(demodData,N);                                              % Sa�da bin�ria de dados

        [biterrados(value), BER(value)] = biterr(input, output);

    end

    berTheory = berawgn(EbNo,'qam',M,'nondiff');
    figure
    semilogy(EbNo,BER,'b*');
    hold on
    semilogy(EbNo,berTheory,'r:.');
    grid on
    title(strcat('BER 16-QAM RRC Nb=', num2str(i)))

end