%% Data Path Setup

folder = '/Users/lzhang865/Desktop/github/single-molecule-trace-selector/double-channel/data/traces';
pattern = '*.mltraces';
files = dir(fullfile(folder,pattern));
outputDir = '../data/images-alpha/';

%% Create images and organize them into folders
parfor i = 1 : length(files)
    file = files(i);
    dump = load(fullfile(file.folder,file.name),'-mat','traces');
    trace = dump.traces;
    if ~trace.islabeled
        disp(strcat("Skipping file ",file.name," because file is not labeled"));
        continue
    end
    for j = 1 : size(trace.donor,1)
        [~,rawName,~] = fileparts(file.name);
        if any(trace.label(j,:))
            outputPath = strcat(outputDir,'accepted/');
        else
            outputPath = strcat(outputDir,'rejected/');
        end
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
        trace2img([trace.donor(j,:)', trace.acceptor(j,:)'],fullfile(outputPath,strcat(rawName,'-',num2str(j),'.jpg')));
    end
end


