%% Setting up constants. 
% baseNet = alexnet;
numClasses = 2;
inputSize = [32,32,3];

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end


expt = '../experiments/experiment1/fileNames.mat';
checkpointFolder = '../net/cnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 500;
batchSize = 100;
algo = 'adam';
learningRate = 0.0005;
L2Reg = 0.00001;
WeightsInitializer = 'glorot';

netFolder = '../experiments/experiment1/';
netOutput = 'cnn-alexnet.mat';

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
    XTrain(:,:,:,iTest) = data;
    YTrain(iTest) = ~contains(dataset.testSet{i},'rejected');
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
%     upsampleLayer()
%     baseNet.Layers(2:end-3)
    convolution2dLayer(5,10,'Padding','same','WeightsInitializer',WeightsInitializer)
    batchNormalizationLayer
    maxPooling2dLayer(3,'Stride',2)
    reluLayer
    
    dropoutLayer
    
    convolution2dLayer(3,10,'Padding','same','WeightsInitializer',WeightsInitializer)
    maxPooling2dLayer(3,'Stride',2)
    reluLayer
    convolution2dLayer(3,10,'Padding','same','WeightsInitializer',WeightsInitializer)
    reluLayer
    convolution2dLayer(3,10,'Padding','same','WeightsInitializer',WeightsInitializer)
    maxPooling2dLayer(3,'Stride',2)
    reluLayer
    
    fullyConnectedLayer(10,'WeightsInitializer',WeightsInitializer,'WeightLearnRateFactor',5,'BiasLearnRateFactor',5)
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


%% Showing acc curve
figure(1);clf;hold on;
for x = 0 : 0.01 : 1
    acc = sum((score(:,1) > x & YTest == "1")) + sum((score(:,1) < x & YTest == "0"));
    acc = acc / length(pred);
    plot(x, acc, 'bo')
end
hold off;