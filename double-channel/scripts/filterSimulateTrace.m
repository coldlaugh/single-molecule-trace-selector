%% All images in simulated traces folder
inputDir = '../data/images-alpha/accepted-simulated';
pattern = '*.jpg';
files = dir(fullfile(inputDir,pattern));
outputDir = '../data/images-alpha/accepted-simulated-filtered';
load('../net/cnn/cnn-alexnet.mat', 'cnnNet');
net = cnnNet;
% Filter images
inputSize = [32, 32, 3];
readFcn = @(loc)(imresize(imread(loc),inputSize(1:2)));
for i = 1 : length(files)
    file = files(i);
    folder = file.folder;
    name = file.name;
    image = zeros(inputSize);
    data = readFcn(fullfile(folder, name));
    image(:) = data(:);
    [label, score] = classify(net, image, 'ExecutionEnvironment', 'cpu');
    if (score(1) > 0.6) 
        movefile(fullfile(inputDir, name), fullfile(outputDir, name));
    else
        delete(fullfile(inputDir, name));
    end
end

