%% Setting up constants. 
baseNet = alexnet;
numClasses = 2;
inputSize = [32,32,3];

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end

dataFolder = '../data/images-smooth/';
dataSubFolders = {'accepted','rejected','accepted-simulated'};
checkpointFolder = '../net/cnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 100;
batchSize = 500;
algo = 'adam';
learningRate = 0.0001;
L2Reg = 0.001;
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
Y2 = categorical(contains(ds.Files,'simulated'));

for i = 1 : numTotal
    if any(indTrain == i)
        if (Y(i) == "false") && (rand() < rejectedDropRate)
            indTrain(indTrain == i) = -1;
        end
    elseif any(indTest == i)
        if (Y(i) == "false") && (rand() < rejectedDropRate)
            indTest(indTest == i) = -1;
%         elseif Y2(i) == "true"
%             indTest(indTest == i) = -1;
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
    else
        read(ds);
    end
    waitbar(i / numTotal,userMsg);
end
XTest = XTest / 255.0;
XTrain = XTrain / 255.0;
YTrain = categorical(YTrain, [1, 0]);
YTest = categorical(YTest, [1, 0]);
indPerm = randperm(length(YTest));
XTest = XTest(:,:,:,indPerm);
YTest = categorical(YTest(indPerm));
close(userMsg);
%% Setup net

endLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    weightedClassificationLayer('classification',[1,1])
    ];

cnnLayers = [
    imageInputLayer(inputSize,'normalization','zerocenter')
%     upsampleLayer()
%     baseNet.Layers(2:end-3)
    convolution2dLayer(3,30)
    reluLayer
    maxPooling2dLayer(3,'Stride',2)
    batchNormalizationLayer
    convolution2dLayer(3,30)
    reluLayer
%     maxPooling2dLayer(3,'Stride',2)
    convolution2dLayer(3,30)
    reluLayer
    convolution2dLayer(3,10)
    reluLayer
    averagePooling2dLayer(3,'Stride',2)
    fullyConnectedLayer(300)
    reluLayer
    endLayers
    ];

options = trainingOptions(...
     algo,...
    'InitialLearnRate',learningRate,...
    'L2Regularization',L2Reg,...
    'MaxEpochs',maxTrainEpochs,...
    'MiniBatchSize',batchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment',computeEnv,...
    'Plots','training-progress',...
    'ValidationData',{XTest,YTest},...
    'ValidationFrequency',floor(length(indTrain) / batchSize * 2),...
    'ValidationPatience',20,...
    'CheckpointPath',''...
);

%% train CNN

[cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
cnnLayers = cnnNet.Layers;
save(fullfile(netFolder, netOutput),'cnnNet','indTest','indTrain','info');

%% classify using CNN
[pred, score] =classify(cnnNet, XTest, 'ExecutionEnvironment', computeEnv, 'MiniBatchSize', batchSize);
plotconfusion(YTest, pred);