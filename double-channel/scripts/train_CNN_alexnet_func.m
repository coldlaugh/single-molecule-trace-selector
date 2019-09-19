function train_CNN_alexnet_func(exptFolder)
%% Setting up constants. 
baseNet = alexnet;
numClasses = 2;
inputSize = [32,32,3];

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end



expt = fullfile(exptFolder,'fileNames.mat');
checkpointFolder = '../net/cnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 500;
batchSize = 100;
algo = 'adam';
learningRate = 0.001;
L2Reg = 0.00001;
WeightsInitializer = 'glorot';

netFolder = fullfile(exptFolder);
netOutput = 'cnn-alexnet.mat';

assert(contains(expt, netFolder),strcat(...
    "Error: Experiment folder ", expt, ...
    " does not match net output folder ", netFolder))

%%  setup folders
[~,~] = mkdir(checkpointFolder);
[~,~] = mkdir(netFolder);

%% Setup data set

dataset = load(expt,'-mat');
read = @(loc)(imresize(imread(loc),inputSize(1:2)));

% Devide test and train set

numTrain = length(dataset.trainSet);
numTest = length(dataset.testSet);
numTotal = numTrain + numTest;

% Load train / test data from data store

YTrain = zeros([numTrain,1]);
YTest = zeros([numTest,1]);


XTrain = zeros([inputSize,numTrain]);
XTest = zeros([inputSize,numTest]);

iTrain = 1;
iTest = 1;

userMsg = waitbar(0,'Reading image data','Name','Reading image data');

for i = 1 : numTrain
    data = read(fullfile(dataset.imgFolder, strcat(dataset.trainSet{i},dataset.imgFormat)));
    XTrain(:,:,:,iTrain) = data;
    YTrain(iTrain) = ~contains(dataset.trainSet{i},'rejected');
    iTrain = iTrain + 1;
    waitbar(i / numTotal,userMsg);
end

for i = 1 : numTest
    data = read(fullfile(dataset.imgFolder, strcat(dataset.testSet{i},dataset.imgFormat)));
    XTest(:,:,:,iTest) = data;
    YTest(iTest) = ~contains(dataset.testSet{i},'rejected');
    iTest = iTest + 1;
    waitbar((numTrain + i) / numTotal,userMsg);
end

YTrain = categorical(YTrain, [1, 0]);
YTest = categorical(YTest, [1, 0]);

close(userMsg);
%% Setup net

endLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    weightedClassificationLayer('classification',[1,1])
    ];

cnnLayers = [
    imageInputLayer(inputSize,'normalization','zerocenter')
    upsampleLayer
    baseNet(2:end-3)
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
    'ValidationFrequency',floor(numTrain / batchSize * 2),...
    'ValidationPatience',5,...
    'CheckpointPath',''...
);

%% train CNN

[cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
cnnLayers = cnnNet.Layers;
save(fullfile(netFolder, netOutput),'cnnNet','info');

%% classify using CNN
[pred, score] =classify(cnnNet, XTest, 'ExecutionEnvironment', computeEnv, 'MiniBatchSize', batchSize);
plotconfusion(YTest, pred);

