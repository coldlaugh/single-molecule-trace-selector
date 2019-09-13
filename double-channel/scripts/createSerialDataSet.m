%% Data Path Setup
folder = '/Users/lzhang865/Desktop/github/single-molecule-trace-selector/double-channel/data/traces';
pattern = '*.mltraces';
files = dir(fullfile(folder,pattern));
outputDir = '../data/serial/';
dropoutRejected = 1;

%% Create images and organize them into folders
for i = 1 : length(files)
    file = files(i);
    dump = load(fullfile(file.folder,file.name),'-mat','traces');
    trace = dump.traces;
    if ~trace.islabeled
        disp(strcat("Skipping file ",file.name," because file is not labeled"));
        continue
    end
    for j = 1 : size(trace.donor,1)
        [~,rawName,~] = fileparts(file.name);
        if (length(trace.donor(j,:)) <= 1000)
            continue;
        end
        if (length(trace.donor(j,:)) >= 5000)
            trace.donor(j,1:5000) = trace.donor(j,1:5000);
            trace.acceptor(j,1:5000) = trace.acceptor(j,1:5000);
            trace.time = trace.time(1:5000);
            trace.label(j,1:5000) = trace.label(j,1:5000);
        end
        if any(trace.label(j,:))
            outputPath = strcat(outputDir,'accepted/');
        elseif (rand() < dropoutRejected)
            outputPath = strcat(outputDir,'rejected/');
        else
            continue;
        end
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
        data = [
            trace.donor(j,:); 
            trace.acceptor(j,:);
            trace.label(j,1 : length(trace.acceptor(j,:)))
            ];
        outputName = fullfile(outputPath,strcat(rawName,'-',num2str(j),'.mat'));
        save(outputName,'data');
    end
end


