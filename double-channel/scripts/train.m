%% Setting up constants. 
baseNet = alexnet;
numClasses = 2;
inputSize = [128,128,3];

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end

dataFolder = '../data/images/';
dataSubFolders = {'accepted','rejected','accepted-simulated'};
checkpointFolder = '../net/cnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 200;
batchSize = 100;
algo = 'adam';
learningRate = 0.00001;
dataUsageForTrain = 0.8;
rejectedDropRate = 0.0;

netFolder = '../net/cnn/';
netOutput = 'cnn-alexnet.mat';

%%  setup folders
[~,~] = mkdir(checkpointFolder);
[~,~] = mkdir(netFolder);

%% Setup data store

ds = fileDatastore(fullfile(dataFolder,dataSubFolders),'IncludeSubfolders',true, 'FileExtensions', '.jpg',...
    'ReadFcn',@(loc)(imresize(imread(loc),inputSize(1:2))));

% Devide test and train set

numTotal = length(ds.Files);
numTrain = floor(dataUsageForTrain * numTotal);
numTest = numTotal - numTrain;

indTrain = randperm(numTotal,numTrain);
indTest = setdiff(1:numTotal,indTrain);
indTest = indTest(randperm(length(indTest)));
% Load train / test data from data store


Y = categorical(contains(ds.Files,'accepted')); % label for each trace


for i = 1 : numTotal
    if any(indTrain == i)
        if (Y(i) == "false") && (rand() < rejectedDropRate)
            indTrain(indTrain == i) = -1;
        end
    else
        if (Y(i) == "false") && (rand() < rejectedDropRate)
            indTest(indTest == i) = -1;
        end
    end
end

indTrain = sort(indTrain(indTrain > 0));
indTest = sort(indTest(indTest > 0));

YTrain = zeros([length(indTrain),1]);
YTest = zeros([length(indTest),1]);


XTrain = zeros([inputSize,length(indTrain)]);
XTest = zeros([inputSize,length(indTest)]);


iTrain = 1;
iTest = 1;

userMsg = waitbar(0,'Reading image data','Name','Reading image data');

for i = 1 : numTotal
    if any(indTrain == i)
        [XTrain(:,:,:,iTrain), info] = read(ds);
        YTrain(iTrain) = contains(info.Filename,'accepted');
        iTrain = iTrain + 1;
    elseif any(indTest == i)
        [XTest(:,:,:,iTest), info] = read(ds);
        YTest(iTest) = contains(info.Filename,'accepted');
        iTest = iTest + 1;
    end
    waitbar(i / numTotal,userMsg);
end
XTest = XTest / 255.0;
XTrain = XTrain / 255.0;
YTrain = categorical(YTrain, [1, 0]);
YTest = categorical(YTest, [1, 0]);
close(userMsg);
%% Setup net

endLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',50,'BiasLearnRateFactor',50)
    softmaxLayer('Name','softmax')
    weightedClassificationLayer('classification',[10,1])
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
    'ValidationData',{XTest,YTest},...
    'ValidationFrequency',floor(length(indTrain) / batchSize * 5),...
    'ValidationPatience',Inf,...
    'CheckpointPath',''...
);

%% train CNN

[cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
cnnLayers = cnnNet.Layers;
save(fullfile(netFolder, netOutput),'cnnNet','indTest','indTrain','info');

%% classify using CNN
[pred, score] =classify(cnnNet, XTest, 'ExecutionEnvironment', computeEnv);
plotconfusion(YTest, pred);