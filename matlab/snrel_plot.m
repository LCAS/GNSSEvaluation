%snr elevation plot

gnss = read_nmea('../logs/log__003.nma');
%gnss = read_nmea('../logs/FLO3149I.191');

%%
t = [gnss(:).time];

start_times = {'082500', '082700', '083000', '083200', '083500', '083800', '084100', ...
    '084400'};
antenna_labels = {'G8', 'G5', 'G3T', 'TAL', 'G8', 'G5', 'G3T', 'TAL'};

for antenna_id = 1:4
    stime = datetime(start_times(antenna_id),'Format','HHmmss');
    gnss_filtered = gnss(find(t > stime & t < (stime+minutes(1))));
    stime = datetime(start_times(antenna_id+4),'Format','HHmmss');
    gnss_filtered = [gnss_filtered gnss(find(t > stime & t < (stime+minutes(1))))];
    gsv = [gnss_filtered.gsv];
    prn = unique([gsv.prn]);

    mel = [];
    msnr = [];

    for i=1:length(prn)
        ind = find([gsv.prn]==prn(i));
        elevation = [gsv(ind).elevation];
        snr = [gsv(ind).snr];
        if ~isnan(nanmean(snr))
            mel(end+1) = nanmean(elevation);
            msnr(end+1) = nanmean(snr);
        end
    end
    
    f=fit(mel',msnr','poly2')

    plot(f,mel,msnr,'.');xlabel('elevation');ylabel('snr');axis([0 100 40 55]);
    hold on;
    title(sprintf('%s @ %s',antenna_labels{antenna_id},start_times{antenna_id}));    
end
hold off;