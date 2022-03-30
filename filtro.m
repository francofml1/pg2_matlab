function [] = filtro(sinal, t, fct_Hz, ordem, h_tipo, Fs)

    %% Filtragem dos sinais

    % ordem = 21; % Ordem do filtro
    % fct_Hz = [1.5e4]; % Frequencia de corte do filtro [Hz]
    % h_tipo = 'high';
    fct1 = fct_Hz / (Fs / 2) % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2
    Ts = 1 / Fs;

    % Geração do filtro
    if (length(fct1) > 1)
        h = fir1(ordem, fct1, 'bandpass');
    else
        h = fir1(ordem, fct1, h_tipo);
    end

    figure('Name', 'Resposta do Filtro'),
    freqz(h, 1) % Plota a resposta do filtro

    sinal_filt = filter(h, 1, sinal)'; % implementado como uma convolucao entre sinal e filtro

    %$ Medição do Espectro
    [Y, ~, f1, ~] = analisador_de_spectro(sinal, Ts);

    [Y_filt, ~, f2, ~] = analisador_de_spectro(sinal_filt', Ts);

    figure('Name', 'Sinais em Frequencia')
    subplot(2, 2, 1)
    plot(f1, 10 * log10(fftshift(abs(Y))), 'r');
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
    subplot(2, 2, 2)
    plot(f2, 10 * log10(fftshift(abs(Y_filt))), 'k');
    grid on;
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    xlabel('Frequência [Hz]')
    ylabel('PSD')

    % figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
    subplot(223)
    p3 = plot(t, (sinal), 'r');
    title('Sinal Recebido no Piezoelétrico')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p3.LineWidth = 1.5;
    subplot(224)
    p4 = plot(t, (sinal_filt), 'k');
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p4.LineWidth = 1.5;
