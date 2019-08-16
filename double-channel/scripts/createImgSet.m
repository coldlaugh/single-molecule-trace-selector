%% Data Path Setup

folder = '/Users/lzhang865/Desktop/github/single-molecule-trace-selector-master/double-channel/data/traces';
pattern = '*.mltraces';
files = dir(fullfile(folder,pattern));
outputDir = '../data/images/';

%% Create images and organize them into folders
parfor i = 1 : length(files)
    file = files(i);
    if (contains(file.folder,'bad') && (rand() > 0.5))
        continue;
    end
    outputPath = strcat(outputDir,file.folder(length(rootDir)+1:end));
    if ~exist(outputPath,'dir')
        mkdir(outputPath);
    end
    traceData = readTimeTrace(fullfile(file.folder,file.name));
    traceData = traceData{1};
    n = size(traceData,1);
    traceData = [reshape(traceData(1:n/2,:),1,[])' reshape(traceData(n/2+1:end,:),1,[])'];
    [~,name,~] = fileparts(file.name);
    createImage(traceData(:,:),fullfile(outputPath,strcat(name,'.png')));
    figure(2);hold on;plot(traceData(:,1));plot(traceData(:,2));
end


