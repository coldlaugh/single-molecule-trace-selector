%% Setting up constants. 
cnnNet = alexnet;
numClasses = 2;
inputSize = [64,64,3];

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'parallel';
end

dataFolder = '../data/images/';
dataSubFolders = {'accepted','rejected'};
userMsg = waitbar(0,'Reading image data','Name','Reading image data');
checkpointFolder = '../net/cnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 200;
batchSize = 500;
algo = 'adam';
learningRate = 0.01;
dataUsageForTrain = 0.8;
rejectedDropRate = 0.6;

netFolder = '../net/cnn/';
netOutput = 'cnn-alexnet.mat';

%%  setup folders
[~,~] = mkdir(checkpointFolder);
[~,~] = mkdir(netFolder);

%% Setup data store

ds = fileDatastore(fullfile(dataFolder,dataSubFolders),'IncludeSubfolders',true, 'FileExtensions', '.jpg',...
    'ReadFcn',@(loc)imresize(imread(loc),'Outputsize',inputSize(1:2)));

%% Load train / test data from data store

numTotal = length(ds.Files);
numTrain = floor(dataUsageForTrain * numTotal);
numTest = floor(numTotal - numTrain);

indTrain = randperm(numTotal,numTrain);
indTest = setdiff(1:numTotal,indTrain);
indTest = indTest(randperm(length(indTest)));

XTrain = zeros([inputSize,length(indTrain)]);
XTest = zeros([inputSize,length(indTest)]);

Y = categorical(contains(ds.Files,'accepted')); % label for each trace
YTrain = Y(indTrain);
YTest = Y(indTest);

iTrain = 1;
iTest = 1;
for i = 1 : numTotal
    if any(indTrain == i)
        XTrain(:,:,:,iTrain) = read(ds);
        iTrain = iTrain + 1;
    else
        XTest(:,:,:,iTest) = read(ds);
        iTest = iTest + 1;
    end
    waitbar(i / numTotal,userMsg);
end

close(userMsg);
%% Setup net

endLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',100,'BiasLearnRateFactor',100)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')
    ];

cnnLayers = [
    imageInputLayer(inputSize)
    upsampleLayer()
    cnnNet.Layers(2:end-3)
    endLayers
    ];

options = trainingOptions(...
     algo,...
    'InitialLearnRate',learningRate,...
    'MaxEpochs',maxTrainEpochs,...
    'MiniBatchSize',batchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment',computeEnv,...
    'Plots','training-progress',...
    'ValidationData',{XTest,YTest},...
    'ValidationFrequency',floor(numTrain / batchSize * 5),...
    'ValidationPatience',Inf,...
    'CheckpointPath',''...
);

%% train CNN

[cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
cnnLayers = cnnNet.Layers;
save(fullfile(netFolder, netOutput),'cnnNet','indTest','indTrain');
