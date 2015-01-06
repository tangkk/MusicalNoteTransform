function myPlot(f, spec)

close all;

figure;
plot(f,spec);
title('Single-Sided Amplitude Spectrum of song');
xlabel('Frequency (Hz)');
ylabel('|song(f)|');