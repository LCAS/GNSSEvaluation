function out = read_nmea(filename)

out = [];
gsv = [];

fid = fopen(filename);

if fid == -1
    return
end

while ~feof(fid)
    s = fgetl(fid);
    if strcmp(s(1:6),'$GPGGA')
        ss = strsplit(s,{',','*'},'CollapseDelimiters',false);
        if ~isempty(ss{2}) && ~isempty(ss{3})
            lat = str2double(ss{3}(1:2)) + (str2double(ss{3}(3:end))/60);
            if ss{4} == 'S'
                lat = lat * -1;
            end
            lon = str2double(ss{5}(1:3)) + (str2double(ss{5}(4:end))/60);
            if ss{6} == 'W'
                lon = lon * -1;
            end
            out(end+1).lat = lat;
            out(end).lon = lon;
            out(end).qfix = str2num(ss{7});
            out(end).sats = str2num(ss{8});
            out(end).hdop = str2num(ss{9});
            out(end).gsv = gsv;
            out(end).time = datetime(ss{2},'Format','HHmmss.SS');
            gsv = [];
        end
    elseif strcmp(s(1:6),'$GPGSV')
        ss = strsplit(s,{',','*'},'CollapseDelimiters',false);
        if str2num(ss{4}) ~= 0 && ~mod(length(ss)-5,4)
            for i=5:4:length(ss)-1
                snr = NaN;
                if ~isempty(ss{i+3})
                    snr = str2num(ss{i+3});
                end
                gsv(end+1).prn = str2num(ss{i});
                gsv(end).elevation = str2num(ss{i+1});
                gsv(end).asimuth = str2num(ss{i+2});
                gsv(end).snr = snr;
            end
        end
    end
end

fclose(fid);
