%% Setting up constants. 
baseNet = alexnet;
numClasses = 2;
inputSize = [64,64,3];

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end

dataFolder = '../data/images/';
dataSubFolders = {'accepted','rejected'};
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
    'ReadFcn',@(loc)(single(imresize(imread(loc),inputSize(1:2), 'bilinear'))));

%% Devide test and train set

numTotal = length(ds.Files);
numTrain = floor(dataUsageForTrain * numTotal);
numTest = numTotal - numTrain;

indTrain = randperm(numTotal,numTrain);
indTest = setdiff(1:numTotal,indTrain);
indTest = indTest(randperm(length(indTest)));
%% Load train / test data from data store
XTrain = zeros([inputSize,length(indTrain)]);
XTest = zeros([inputSize,length(indTest)]);

Y = categorical(contains(ds.Files,'accepted')); % label for each trace
YTrain = Y(indTrain);
YTest = Y(indTest);

iTrain = 1;
iTest = 1;

userMsg = waitbar(0,'Reading image data','Name','Reading image data');

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
    fullyConnectedLayer(numClasses,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer()
    ];

cnnLayers = [
    imageInputLayer(inputSize,'normalization','none')
    upsampleLayer()
    baseNet.Layers(2:end-3)
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
    'ValidationData',{XTrain,YTrain},...
    'ValidationFrequency',floor(numTrain / batchSize * 5),...
    'ValidationPatience',Inf,...
    'CheckpointPath',''...
);

%% train CNN

[cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
cnnLayers = cnnNet.Layers;
save(fullfile(netFolder, netOutput),'cnnNet','indTest','indTrain');

%% classify using CNN
[pred, score] =classify(cnnNet, XTrain, 'ExecutionEnvironment', computeEnv);
plotconfusion(YTrain, pred);