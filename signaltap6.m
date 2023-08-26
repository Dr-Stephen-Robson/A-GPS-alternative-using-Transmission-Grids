clear OFFSET_SAVE
clear ind_fine
clear ind_all
clear res_all
clear offset
clear GPS_TIME


%----Generate the Base Chirp for the Later Demodulation Process-------%
carrier =  1.310719995117188e+06;
f =  10485760;
t = 1/f;
l=32768;
ttt = 0:t:t*(65537-202);
 ccc = cos(2*pi*carrier*ttt);
 sss = sin(2*pi*carrier*ttt);
 res_all = zeros(1,1024*32);
  num_samples =1024;
            k = 2^(10)/2;
            base_down_chirp = zeros(1,num_samples);
            for n=1:num_samples
                if k<= (0)
                    k = k+2^10;
                end
                k = k - 1;
                base_down_chirp(n) = exp(1i*2*pi*(k)*(k/(2^10*2)));
            end
%---------------------------------------------------------------------%
%version control
%when I go to \bin64 and open alt_signaltap from there, it stops the
%crashing
cd('E:\intelFPGA\22.1std\quartus\bin64')
alt_signaltap_run( 'END_CONNECTION' )
%addpath('E:\intelFPGA\22.1std\quartus\bin64')
fprintf('Start Signal Tap');
 
x=alt_signaltap_run('E:\newLoRa_DE10_branch_restored\newLoRa_201122_restored\stp3.stp','signed', 'auto_signaltap_1');
figure(1); clf;
N=length(x);
 xsave= [];

 %-----------------Main Loop----------------------------------------------
for i=1:1000
    l=1;
    i
tic
x=alt_signaltap_run('E:\newLoRa_DE10_branch_restored\newLoRa_201122_restored\stp3.stp','signed', 'auto_signaltap_1');
a3= double(x(:,1));

%----noise----------------------------------------------------------
a3_noise = a3;% awgn(a3,-25,'measured');

GPS_local= double(x(:,2));
GPS_true= double(x(:,3));
 X= GPS_true> 0.5;
GPS_TIME = strfind(X',[0 1]);
 X2= GPS_local> 0.5;
LOCAL_TIME = strfind(X2',[0 1]);
offset = GPS_TIME(1) - LOCAL_TIME
% for s = 1:1000


%--Run the fine shift operation for 32 fine shifts--------------------%
for n = 1:32 %fine shift
    a2 = a3_noise(100+n : end-100+n-1);
down_sign=(a2).*ccc' + 1i*(a2).*sss';
out_upc2 = (resample(down_sign, 1, 32))';
out_upc3 = awgn(out_upc2,0,'measured');
received_sig = out_upc3(100:100+1023);
dechirped = received_sig.*conj(base_down_chirp);
fftres(:,n) = (abs(fft(dechirped)));
end
%----------------------------------------------------------------------%

%---------construct the large timing estimate------------------------------
for j=1:1024
for k = 1:32
    res_all(l) = fftres(j,33-k);
    l=l+1;
end
end
%---------construct the large timing estimate------------------------------



[~,ind_fine(i)]=max(max(fftres));
ind_fine(i)
[~,ind_all(i)]=max(res_all);
ind_all(i)
OFFSET_SAVE(i) = offset;
toc
end
timing_estimate = (OFFSET_SAVE + ind_all)';
timing_estimate_mod = mod(timing_estimate,2^15);
full_timing_estimate = timing_estimate_mod - mean(timing_estimate_mod(1:500));
