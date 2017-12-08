clear all;
close all;

Nb = 240000;                                                                       %Número de bits, precisa ser múltiplo de 3 e de 8

for i = [Nb, Nb/1000]
    numSamplesPerSymbol = 16;                                                      % Fator de superamostragem 16/amostra              
    span = 10;                                                      
    rolloff = 0.25;                                                                % Fator de roll-off

    rectFilter = [rectwin(numSamplesPerSymbol)', zeros(1, 145)];                   % Cria filtro retangular com largura Ts
    rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);                    % Cria filtro de cosseno levantado

    %--Questão 1--%

    rng default                                                                    % seed default para o randi
    data = randi([0 1],Nb,1);                                                      % Gera Nb bits aleatórios

    %--Questão 2--%

    M = 16;                                                                        % M = número de níveis
    QAM64 = qammod(data, M);                                                       % Modula os símbolos complexos para 64-QAM

    %--Questão 3--%
    N = log2(M);                                                                   % N = número de bit por símbolo

    txSgnRECTQAM64 = upfirdn(QAM64, rectFilter, numSamplesPerSymbol);              % Aplica o filtro rectangular para 64-QAM

    txSgnRRCQAM64 = upfirdn(QAM64, rrcFilter, numSamplesPerSymbol);                % Aplica o filtro de cosseno levantado para 64-QAM

    %--Questão 5--%

    input = de2bi(data,N);  % Dados binários na entrada

    rectFilter = fliplr(rectFilter);
    for value = 1:1:(11*N)

        EbNo(value) = value-1;

        snr = value + 10*log10(N) - 10*log10(numSamplesPerSymbol);                 % SNR de acordo com a Es/N0 escolhida
        noiseSignal = awgn(txSgnRECTQAM64,snr,'measured');                         % Gera o ruído

        rxSgnRECTQAM64 = upfirdn(noiseSignal, rectFilter, 1, numSamplesPerSymbol); % Aplica o filtro rectangular para 64-QAM
        rxSgnRECTQAM64 = rxSgnRECTQAM64(span+1:end-span);

        demodData = qamdemod(rxSgnRECTQAM64, M);                                   % Demodula o sinal
        output = de2bi(demodData,N);                                               % Saida binária de dados

        [biterrados(value), BER(value)] = biterr(input, output);

    end                                                                            % Passando de energia de bit para energia de símbolo

    berTheory = berawgn(EbNo,'qam',M,'nondiff');
    figure
    semilogy(EbNo,BER,'b*');
    hold on
    semilogy(EbNo,berTheory,'r:.');
    grid on
    title(strcat('BER 64-QAM RECT Nb=', num2str(i)))

    rrcFilter = fliplr(rrcFilter);
    for value = 1:1:(11*N)
        EbNo(value) = value-1;

        snr = value + 10*log10(N) - 10*log10(numSamplesPerSymbol);                 % SNR de acordo com a Es/N0 escolhida
        noiseSignal = awgn(txSgnRRCQAM64,value,'measured');

        rxSgnRRCQAM64 = upfirdn(noiseSignal, rrcFilter, 1, numSamplesPerSymbol);   % Aplica o filtro rectangular para 64-QAM
        rxSgnRRCQAM64 = rxSgnRRCQAM64(span+1:end-span);

        demodData = qamdemod(rxSgnRRCQAM64, M);                                    % Demodula o sinal
        output = de2bi(demodData,N);                                               % Saída binária de dados

        [biterrados(value), BER(value)] = biterr(input, output);

    end

    berTheory = berawgn(EbNo,'qam',M,'nondiff');
    figure
    semilogy(EbNo,BER,'b*');
    hold on
    semilogy(EbNo,berTheory,'r:.');
    grid on
    title(strcat('BER 64-QAM RRC Nb=', num2str(i)))

end