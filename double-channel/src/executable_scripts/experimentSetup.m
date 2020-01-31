% Setup Training Experimental Samples
disp("Setting Up Training Experimental Samples")
%% 
settings = jsondecode(fileread('settings.json'));
serialFolder = fullfile(settings.workingDir,settings.serialFolder);
imgFolder = fullfile(settings.workingDir,settings.imgFolder);
exptFolder = fullfile(settings.workingDir, settings.exptFolder);
pattern = '*/*.mat';
files = dir(fullfile(serialFolder,pattern));
%%

% Ratio between training sample size and test sample size
trainRatio = 0.8;

% Optional drop parameter to restrict very large data set
dropRatioW = 0.8;

%% Randomly choosing training data set and testing data set

disp('Processing')
trainSet = {};
testSet = {};
for i = 1 : length(files)
    file = files(i);
    [~,rawName,format] = fileparts(file.name);
    folder = file.folder(length(serialFolder) + 1 : end);
    serialPath = fullfile(file.folder, file.name);
    imgPath = fullfile(imgFolder, folder, strcat(rawName, '.jpg'));
    if ~(exist(imgPath,'file') && exist(serialPath, 'file'))
        disp(strcat("Skipping file ",rawName, ":File not in both img and serial folders"));
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

%Setup output path to save the chosen training/testing data set
outputPath = fullfile(exptFolder, "experiment1-1/");
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
serialFolder = '../data/serial';
imgFolder = '../data/images-alpha/';
serialFormat = '.mat';
imgFormat = '.jpg';
save(fullfile(outputPath, "fileNames.mat"),"testSet","trainSet","serialFolder","imgFolder","serialFormat","imgFormat");

disp('Training/Testing Data Set Saved To "' + outputPath + '"')