gnss = read_nmea('../logs/log__003.nma');
%gnss = read_nmea('../logs/FLO3149I.191');

%%
t = [gnss(:).time];

start_times = {'082500', '082700', '083000', '083200', '083500', '083800', '084100', ...
    '084400'};
antenna_labels = {'G8', 'G5', 'G3T', 'TAL', 'G8', 'G5', 'G3T', 'TAL'};

antenna_id = 3;

stime = datetime(start_times(antenna_id),'Format','HHmmss');

gnss_filtered = gnss(find(t > stime & t < (stime+minutes(1))));

gsv = [gnss_filtered.gsv];

prn = unique([gsv.prn]);

gsize = ceil(sqrt(length(prn)));
mel = [];
msnr = [];

for i=1:length(prn)
    ind = find([gsv.prn]==prn(i));
    elevation = [gsv(ind).elevation];
    snr = [gsv(ind).snr];
    
    subplot(gsize,gsize,i), histogram(snr,20.5:55.5);
    ylabel('snr')
    l = axis;
    axis([25 60 0 50]);
    title(sprintf('PRN: %d, EL: %.2f, SNR: %.2f',prn(i),mean(elevation),nanmean(snr)));
    fprintf('%d %.2f %.2f\n',prn(i),nanmean(snr),nanmean(elevation));
    mel(end+1) = nanmean(elevation);
    msnr(end+1) = nanmean(snr);
end

f=fit(mel',msnr','poly2')

subplot(gsize,gsize,i), plot(f,mel,msnr,'.k');xlabel('elevation');ylabel('snr');
title(sprintf('%s @ %s',antenna_labels{antenna_id},start_times{antenna_id}));

[x y] = ll2utm([gnss_filtered.lat],[gnss_filtered.lon]);
x =  x - mean(x);
y =  y - mean(y);
err = sum(sqrt(x.^2+y.^2));
pos_std = [std(x) std(y)];
subplot(gsize,gsize,i+1); 
plot(x,y,'.k');axis([-0.10 0.10 -0.10 0.10]);xlabel('lat [m]');ylabel('lon [m]');title(sprintf('err: %.2f [m]',err))
