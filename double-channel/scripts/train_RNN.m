%% Setting up constants. 

numClasses = 2;
numHiddenUnits = 100;
numStack = 10;

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end

dataFolder = '../data/serial';
dataSubFolders = {'accepted','rejected'};
checkpointFolder = '../net/rnn/checkpoint/';
checkpointFreq = 10;

maxTrainEpochs = 500;
batchSize = 100;
algo = 'adam';
learningRate = 0.0001;
L2Reg = 0.00001;
WeightsInitializer = 'glorot';
dataUsageForTrain = 0.8;
rejectedDropRate = 0.8;

netFolder = '../net/rnn/';
netOutput = 'rnn-LSTM.mat';

%%  setup folders
[~,~] = mkdir(checkpointFolder);
[~,~] = mkdir(netFolder);

%% Setup data store

ds = fileDatastore(fullfile(dataFolder,dataSubFolders),'IncludeSubfolders',true, 'FileExtensions', '.mat',...
    'ReadFcn',@(loc)load(loc,'data'));

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
        elseif Y2(i) == "true"
            indTest(indTest == i) = -1;
        end
    end
end

indTrain = indTrain(indTrain > 0);
indTest = indTest(indTest > 0);

YTrain = zeros([length(indTrain),1]);
YTest = zeros([length(indTest),1]);


XTrain = cell([length(indTrain),1]);
XTest = cell([length(indTest),1]);

FileTrain = cell([length(indTrain),1]);
FileTest = cell([length(indTest),1]);

iTrain = 1;
iTest = 1;

userMsg = waitbar(0,'Reading serial data','Name','Reading serial data');

for i = 1 : numTotal
    [data, info] = read(ds);
    data = single(data.data);
    data(1,:) = conv(data(1,:), [1/3,1/3,1/3], 'same');
    data(2,:) = conv(data(2,:), [1/3,1/3,1/3], 'same');
    normFactor = 1 / max(data(1,:) + data(2,:));
    data = normFactor * stackTrace(data(1,:), data(2,:), numStack);
    if any(indTrain == i)
        XTrain{iTrain} = data;
        YTrain(iTrain) = contains(info.Filename,'accepted');
        FileTrain{iTrain} = info.Filename;
        iTrain = iTrain + 1;
    elseif any(indTest == i)
        XTest{iTest} = data;
        YTest(iTest) = contains(info.Filename,'accepted');
        FileTest{iTest} = info.Filename;
        iTest = iTest + 1;
    end
    waitbar(i / numTotal,userMsg);
end
YTrain = categorical(YTrain, [1, 0]);
YTest = categorical(YTest, [1, 0]);
indPerm = randperm(length(YTest));
XTest = XTest(indPerm);
YTest = categorical(YTest(indPerm));
FileTest = FileTest(indPerm);
close(userMsg);
%% Setup net

rnnLayers = [
    sequenceInputLayer(2 * numStack)
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    lstmLayer(numHiddenUnits, 'OutputMode', 'last')
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer
    classificationLayer
    ];

options = trainingOptions(...
     algo,...
    'InitialLearnRate',learningRate,...
    'L2Regularization',L2Reg,...
    'MaxEpochs',maxTrainEpochs,...
    'MiniBatchSize',batchSize,...
    'Shuffle','once',...
    'ExecutionEnvironment',computeEnv,...
    'Plots','training-progress',...
    'ValidationData',{XTest,YTest},...
    'ValidationFrequency',floor(length(indTrain) / batchSize * 2),...
    'ValidationPatience',20,...
    'CheckpointPath',''...
);

%% train RNN

[rnnNet,info] = trainNetwork(XTrain,YTrain,rnnLayers,options);
rnnLayers = rnnNet.Layers;
save(fullfile(netFolder, netOutput),'rnnNet','indTest','indTrain','info');

%% classify using RNN
[pred, score] =classify(rnnNet, XTest, 'ExecutionEnvironment', computeEnv, 'MiniBatchSize', batchSize);
plotconfusion(YTest, pred);


%% Showing acc curve
figure(1);clf;hold on;
for x = 0 : 0.01 : 1
    acc = sum((score(:,1) > x & YTest == "1")) + sum((score(:,1) < x & YTest == "0"));
    acc = acc / length(pred);
    plot(x, acc, 'bo')
end
hold off;