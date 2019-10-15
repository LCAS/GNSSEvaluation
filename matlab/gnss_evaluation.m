%% GNSS antenna analysis

% export to Latex
print_latex = 0;

% reading NMEA strings with GGA and GSV strings

gnss = read_nmea('../logs/log__003.nma'); % antenna readings
gnss_ref = read_nmea('../logs/FLO3149I.191'); % reference

% UTM timestamps for filtering
t = [gnss(:).time];
t_ref = [gnss_ref(:).time];

%start of each measurement in UTM (here 4 antennas x 2 takes)
% take 1 G8, G5, G3T, TAL
% take 2 G8, G5, G3T, TAL
start_times = {'082500', '082700', '083000', '083200', ...
    '083500', '083800', '084100', '084400'};

% antenna models
antenna_labels = {'G8', 'G5', 'G3T', 'TAL'};
% list of PRNs
prn_list = [12, 24, 25, 19];

%%
for aid = [1 5 2 6 3 7 4 8] % 2 takes for each antenna
    for prn=prn_list
        stime = datetime(start_times(aid),'Format','HHmmss');
        %select 60 seconds from antenna readings
        gnss_filtered = gnss(find(t > stime & t < (stime+minutes(1))));
        gsv = [gnss_filtered.gsv];
        
        %select 60 seconds from reference readings
        gnss_filtered_ref = gnss_ref(find(t_ref > stime & t_ref < (stime+minutes(1))));
        gsv_ref = [gnss_filtered_ref.gsv];
        
        %extract antenna elevation and snr readings
        ind = find([gsv.prn]==prn);
        elevation = [gsv(ind).elevation];
        snr = [gsv(ind).snr];
        %extract reference elevation and snr readings
        ind = find([gsv_ref.prn]==prn);
        elevation_ref = [gsv_ref(ind).elevation];
        snr_ref = [gsv_ref(ind).snr];
        
        if (print_latex)
            fprintf('%s & ',antenna_labels{mod(aid-1,4)+1});
            fprintf([start_times{aid}(1:2) ':' start_times{aid}(3:4) ':' start_times{aid}(5:6) ' & ']);
            fprintf('%.0f & %.0f & %.1f $\\pm$ %.1f & ',prn,nanmean(elevation),nanmean(snr),nanstd(snr));
            fprintf('%.1f $\\pm$ %.1f & ',nanmean(snr_ref),nanstd(snr_ref));
            fprintf('%.1f & %.0f\\\\\n',nanmean(snr)-nanmean(snr_ref),(10^((nanmean(snr)-nanmean(snr_ref))/10))*100);
        else
            fprintf('%s, ',antenna_labels{mod(aid-1,4)+1});
            fprintf(['UTM ' start_times{aid}(1:2) ':' start_times{aid}(3:4) ':' start_times{aid}(5:6) ', ']);
            fprintf('PRN %.0f, EL %.0f, SNR %.1f +/- %.1f, ',prn,nanmean(elevation),nanmean(snr),nanstd(snr));
            fprintf('SNR_ref %.1f +/- %.1f, ',nanmean(snr_ref),nanstd(snr_ref));
            fprintf('dSNR %.1f, dSNR%% %.0f\n',nanmean(snr)-nanmean(snr_ref),(10^((nanmean(snr)-nanmean(snr_ref))/10))*100);
        end        
    end
end


