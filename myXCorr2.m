% this implements cross-correlation of inLong and inShort using FFT
% particularly, similar to convolution theorem, cross-correlation
% satisfies:
% fft(xcorr(f,g)) = conj(fft(f))*fft(g)
% the length of fft should satisfy N>=L+P-1, where L and P are the length
% of f and g separately, to avoid alias in frequency sampling circular effect
% note that this xcorr starts from time 0 rather than -infinity
function out = myXCorr2(f, g)

L = length(f);
P = length(g);
NL = L+P-1;
N = 2^nextpow2(NL);

% compute the formular and return a ifft of length NL
if L <= P
    out = ifft(conj(fft(f,N)).*fft(g,N));
    out = out(1:P);
else
    out = ifft(conj(fft(g,N)).*fft(f,N));
    out = out(1:L);
end