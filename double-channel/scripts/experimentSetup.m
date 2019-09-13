%%
serialFolder = '/Users/lzhang865/Desktop/github/single-molecule-trace-selector/double-channel/data/serial/';
imgFolder = '/Users/lzhang865/Desktop/github/single-molecule-trace-selector/double-channel/data/images-alpha/';
pattern = '*/*.mat';
files = dir(fullfile(serialFolder,pattern));
%%

trainRatio = 0.8;
dropRatioW = 0.8;

%% 
trainSet = {};
testSet = {};
for i = 1 : length(files)
    file = files(i);
    [~,rawName,format] = fileparts(file.name);
    folder = file.folder(length(serialFolder) + 1 : end);
    serialPath = fullfile(file.folder, file.name);
    imgPath = fullfile(imgFolder, folder, strcat(rawName, '.jpg'));
    if ~(exist(imgPath,'file') && exist(serialPath, 'file'))
        disp(strcat("Skipping file ",rawName, "because it is not in both img and serial folders"));
        continue;
    end
    
    
    if (folder == "accepted")
        if (rand() < trainRatio)
            trainSet{end+1} = fullfile(folder, rawName);
        else
            testSet{end+1} = fullfile(folder, rawName);
        end
    end
    
    if (folder == "simulated")
        trainSet{end+1} = fullfile(folder, rawName);
    end
    
    if (folder == "rejected")
        if regexp(rawName,"W\d_.+") == 1
            if (rand() < dropRatioW)
                continue;
            end
        end
        if (rand() < trainRatio)
            trainSet{end+1} = fullfile(folder, rawName);
        else
            testSet{end+1} = fullfile(folder, rawName);
        end
    end
end

%% DISPLAY RESULTS
disp("==================================================================")
disp(["     "      ,"accepted"      ,"rejected"       ,"simulated"])
disp(["train", sum(contains(trainSet, 'accepted')),sum(contains(trainSet, 'rejected')),sum(contains(trainSet, 'simulated'))])
disp(["test ", sum(contains(testSet, 'accepted')),sum(contains(testSet, 'rejected')),sum(contains(testSet, 'simulated'))])

%% 
outputPath = "../experiments/experiment1/";
serialFormat = ".mat";
imgFormat = ".jpg";
save(fullfile(outputPath, "fileNames.mat"),"testSet","trainSet","serialFolder","imgFolder","serialFormat","imgFormat");