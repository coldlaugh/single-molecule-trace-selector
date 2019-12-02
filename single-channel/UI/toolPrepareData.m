


    fid = fopen(file,'r', 'ieee-le');
    len = fread(fid, 1, 'int32');
    Ntraces = fread(fid, 1, 'int16');
    raw = fread(fid,(Ntraces+1)*len,'int16');
    fclose(fid);
    raw = reshape(raw,Ntraces+1,len);
    time = raw(1,:);
    data = raw(2:end,:);
    idonor = 1:2:size(data,1);
    iacceptor = 2:2:size(data,1);
    donor = raw(idonor,:);
    acceptor = raw(iacceptor,:);
    traces = struct();
    traces.time = time;
    traces.donor = donor;
    traces.acceptor = acceptor - 0.09 * traces.donor;
%     save(fullfile(path,strcat(movie_files{fileId}(1:end-7),'.mat')), 'traces', '-mat');



    