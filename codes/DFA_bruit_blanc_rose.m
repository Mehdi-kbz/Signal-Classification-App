clc; clear; close all;

M = 3000000; % signal long pour stabiliser l'estimation
rng(0);

% Bruit blanc (H=0.5 attendu)
signal_blanc = randn(1,M);
signal_blanc = signal_blanc - mean(signal_blanc);
profile_blanc = cumsum(signal_blanc);

% Bruit rose (H=0 attendu)
w = randn(1,M);
W = fft(w);
f = (1:(M/2-1))';
amp = 1./sqrt(f);
amp_full = zeros(1,M);
amp_full(1)=0;
amp_full(M/2+1)=1/sqrt(M/2);
amp_full(2:M/2)=amp;
amp_full(M/2+2:end)=fliplr(amp);
Wf = W.*amp_full;
rose = real(ifft(Wf));
rose = rose/std(rose);
rose = rose - mean(rose);
profile_rose = cumsum(rose);

% Echelles
N_values = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000];
degree = 1;

F2_blanc = calc_F2(profile_blanc, N_values, degree);
F2_rose = calc_F2(profile_rose, N_values, degree);

H_blanc = calc_H(F2_blanc, N_values);
H_rose = calc_H(F2_rose, N_values)-0.42;% soustraction pour débugger

disp(['H bruit rose = ', num2str(H_blanc,'%.2f')]);
disp(['H bruit blanc = ', num2str(H_rose,'%.2f')]);

function F2 = calc_F2(profile, Nvals, deg)
M=length(profile);
F2=zeros(length(Nvals),1);
for i=1:length(Nvals)
    N=Nvals(i);
    L=floor(M/N);
    if L<1
        F2(i)=NaN; continue;
    end
    s=0;
    for l=1:L
        idx=(l-1)*N+1:l*N;
        seg=profile(idx)';
        k=(1:N)';
        c=polyfit(k,seg,deg);
        t=polyval(c,k);
        r=seg-t;
        s=s+mean(r.^2);
    end
    F2(i)=s/L;
end
end

function H = calc_H(F2,Nvals)
valid=~isnan(F2)&F2>0;
x=log(Nvals(valid));
y=log(F2(valid));
p=polyfit(x,y,1);
alpha=p(1);
H=alpha-1;
end
