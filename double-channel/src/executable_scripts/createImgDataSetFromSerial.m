% Create labeled serial dataset from trace data
disp("Creating labeled image dataset from labeled serial data")

%% Data Path Setup
settings = jsondecode(fileread('settings.json'));
folder = fullfile(settings.workingDir,settings.serialFolder);
pattern = '*/*.mat';
files = dir(fullfile(folder,pattern));
outputDir = fullfile(settings.workingDir,settings.imgFolder);

%% Create images and organize them into folders
parfor i = 1 : length(files)
    file = files(i);
    [~,rawName,~] = fileparts(file.name);
    dump = load(fullfile(file.folder,file.name),'-mat','data');
    trace = dump.data;
    outputPath = strrep(file.folder, folder, outputDir);
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end
    trace2img([trace(1,:)', trace(2,:)'],fullfile(outputPath,strcat(rawName,'.jpg')));
end


