%% Data Path Setup

folder = '/Users/lzhang865/Desktop/github/single-molecule-trace-selector/double-channel/data/serial/simulated';
pattern = '*.dat';
files = dir(fullfile(folder,pattern));
outputDir = '../data/images-alpha';

%% Create images and organize them into folders
parfor i = 1 : length(files)
    file = files(i);
    dump = load(fullfile(file.folder,file.name),'-mat','traces');
    trace = dump.data;
    outputPath = strcat(outputDir,'simulated/');
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end
    trace2img([trace.donor(1,:)', trace.acceptor(2,:)'],fullfile(outputPath,strcat(rawName,'-',num2str(j),'.jpg')));
end


