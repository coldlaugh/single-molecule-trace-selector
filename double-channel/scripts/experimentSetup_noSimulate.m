%% 
ind = [];
for i = 1 : length(trainSet)
    if contains(trainSet{i}, 'simulated')
        disp('Found one!');
        continue;
    else
        ind = [ind; i];
    end
end
trainSet = trainSet(ind);


outputPath = "../experiments/experiment2-10/";
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
serialFolder = "../data/serial";
imgFolder = '../data/images-alpha/';
serialFormat = ".mat";
imgFormat = ".jpg";
save(fullfile(outputPath, "fileNames.mat"),"testSet","trainSet","serialFolder","imgFolder","serialFormat","imgFormat");