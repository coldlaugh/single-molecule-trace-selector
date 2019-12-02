% This program is to train an alexNet on the the data of images of donor/accepter
% scatter plot. The alexNet achieves an training accuracy of nearly 100%
% and a test accuracy of 91.5% on Pauls's data and 89.4% on Jieming's data.

%%
% Number of workers to train with. Set this number equal to the number of
% GPUs on you cluster. If you specify more workers than GPUs, the remaining
% workers will be idle.

%% Construct LSMT network

inputSize = 2 * 20;
numHiddenUnits = 100;
numClasses = 2;
layers = [ ...
    sequenceInputLayer(inputSize)
%     dataAugument()
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];



%% Start a parallel pool if one is not already open
pool = gcp('nocreate');
if isempty(pool)
 parpool(numberOfWorkers);
elseif (pool.NumWorkers ~= numberOfWorkers)
 delete(pool);
 parpool(numberOfWorkers);
end
%% Load the training and test data
rootFolder = '/Users/leyou/Desktop/FRET/beta2.0/trainingData/'
categories = {'set3'};
ds = fileDatastore(fullfile(rootFolder,categories),'IncludeSubfolders',true, 'FileExtensions', '.mat','ReadFcn',@readTimeTrace);
% addpath('/Users/leyou/Desktop/FRET/time_traces/');

X = ds.readall;
Y = categorical(contains(ds.Files,'good'));

% summarize data
Folder = categories';
GoodMolecule = zeros(size(Folder));
BadMolecule = zeros(size(Folder));
for i = 1 : numel(Folder)
    GoodMolecule(i) = sum(contains(ds.Files,Folder{i}) & contains(ds.Files,'good'));
    BadMolecule(i) = sum(contains(ds.Files,Folder{i}) & contains(ds.Files,'bad'));
end
Folder{end+1} = 'Total';
GoodMolecule(end+1) = sum(GoodMolecule);
BadMolecule(end+1) = sum(BadMolecule);
DataSummary = table(Folder,GoodMolecule,BadMolecule);
disp('Summary of loaded data:');
disp(DataSummary);

%% Load simulated training data
rootFolder = '/Users/leyou/Desktop/FRET/beta2.0/trainingData/'
categories = {'set5'};
ds = fileDatastore(fullfile(rootFolder,categories),'IncludeSubfolders',true, 'FileExtensions', '.mat','ReadFcn',@readTimeTrace);
% addpath('/Users/leyou/Desktop/FRET/time_traces/');

Xsim = ds.readall;
Ysim = categorical(contains(ds.Files,'good'));

% summarize simulated data
Folder = categories';
GoodMolecule = zeros(size(Folder));
BadMolecule = zeros(size(Folder));
for i = 1 : numel(Folder)
    GoodMolecule(i) = sum(contains(ds.Files,Folder{i}) & contains(ds.Files,'good'));
    BadMolecule(i) = sum(contains(ds.Files,Folder{i}) & contains(ds.Files,'bad'));
end
DataSummary = table(Folder,GoodMolecule,BadMolecule);
disp('Summary of loaded simulated data:');
disp(DataSummary);
%% split into training and testing data 
trainsetchoice = randperm(numel(X),floor(numel(X)*0.4));
XTrain = cell(length(trainsetchoice)+length(Xsim),1);
YTrain = cell(length(trainsetchoice)+length(Ysim),1);
for i = 1 : length(trainsetchoice)
    XTrain{i} = X{trainsetchoice(i)}{1};
    YTrain{i} = categorical(X{trainsetchoice(i)}{2}>0);
end
YLabelTrain = Y(trainsetchoice);

for i = 1 : length(Xsim)
    XTrain{length(trainsetchoice)+i} = Xsim{i}{1};
    YTrain{length(trainsetchoice)+i} = categorical(Xsim{i}{2}>0);
    YLabelTrain(length(trainsetchoice)+i) = Ysim(i);
end


testsetchoice = setdiff(1:numel(X),trainsetchoice);
testsetchoice = testsetchoice(randperm(numel(testsetchoice)));
XTest = cell(length(testsetchoice),1);
YTest = cell(length(testsetchoice),1);
for i = 1 : length(testsetchoice)
    XTest{i} = X{testsetchoice(i)}{1};
    YTest{i} = categorical(X{testsetchoice(i)}{2}>0);
end
YLabelTest = Y(testsetchoice);


% summary of training and testing data
Name = {'Training';'Testing'};
GoodMolecule = zeros(size(Name));
BadMolecule = zeros(size(Name));
GoodMolecule(1) = sum(YLabelTrain=='true');
BadMolecule(1) = sum(YLabelTrain=='false');
GoodMolecule(2) = sum(YLabelTest=='true');
BadMolecule(2) = sum(YLabelTest=='false');
DataSummary = table(Name,GoodMolecule,BadMolecule);
disp('Summary of training and testing data:');
disp(DataSummary);

%% Define the transfer learning training options
maxEpochs = 2400;
numberOfWorkers =1;
miniBatchSize = 4 * 500 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.005,...
    'MaxEpochs',maxEpochs,...
    'LearnRateDropPeriod',600, ...
    'LearnRateDropFactor',0.5, ...
    'LearnRateSchedule','piecewise',...
    'MiniBatchSize',miniBatchSize,...
    'Plots','training-progress',...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','gpu'); % change 'parallel' to 'cpu' or 'gpu' to train the network on the local computer.

%% Train the network on the cluster
if strcmp(options.ExecutionEnvironment,'cpu')
    net = trainNetwork(XTrain,YLabelTrain,layers,options);
else
    pool = gcp('nocreate');
    addAttachedFiles(pool,{'/Users/leyou/Desktop/FRET/beta2.0/dataAugument.m'});
    updateAttachedFiles(pool);
    spmd
        net = trainNetwork(XTrain,YLabelTrain,layers,options);
    end
    net = net{1};
end
layers = net.Layers;
% save('traineBidLSTM2layer.mat','net')
%% Record the accuracy for this network
env = 'cpu';
if strcmp(env,'gpu')
    pool = gcp('nocreate');
    addAttachedFiles(pool,{'/Users/leyou/Desktop/FRET/beta2.0/dataAugument.m'});
    updateAttachedFiles(pool);
    spmd
        tic
        [YPred,Yscore] = classify(net,XTest,'ExecutionEnvironment','gpu');
        toc
        disp('Done prediction');
    end
    YPred = YPred{1};
    Yscore = Yscore{1};
else
    [YPred,Yscore] = classify(net,XTest);
end
acc = sum(YPred == YLabelTest)./numel(YTest);
disp(['Prediction accuracy = ',num2str(acc)]);
confusionmat(YLabelTest,YPred)
%% Export the test result to files

path = '/Users/leyou/Desktop/FRET/beta2.0/testResult/';
files = ds.Files(testsetchoice);
T = table(files,YLabelTest,YPred,Yscore);
writetable(T,strcat(path,'testResult.csv'));

%% Plot traces of TP,TN,FP,FN

showResult(T);


%% train regional selection LSTM

%% Construct LSMT network

inputSize = 2 * 10;
numHiddenUnits = 100;
numClasses = 2;
Rlayers = [ ...
    sequenceInputLayer(inputSize)
    dataAugument()
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

%% Load the training and test data

XR = X(contains(ds.Files,'good'));
trainsetchoice = randperm(numel(XR),floor(numel(XR)*0.25));

XRTrain = cell(length(trainsetchoice),1);
YRTrain = cell(length(trainsetchoice),1);
for i = 1 : length(trainsetchoice)
    XRTrain{i} = XR{trainsetchoice(i)}{1};
    YRTrain{i} = categorical(XR{trainsetchoice(i)}{2}>0);
end

%% Define the transfer learning training options
maxEpochs = 160;
numberOfWorkers =1;
miniBatchSize = 2 * 600 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.0008,...
    'MaxEpochs',maxEpochs,...
    'LearnRateDropPeriod',50, ...
    'LearnRateDropFactor',0.6, ...
    'LearnRateSchedule','piecewise',...
    'MiniBatchSize',miniBatchSize,...
    'Plots','training-progress',...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','gpu') % change 'parallel' to 'cpu' or 'gpu' to train the network on the local computer.

%% Train the network on the cluster
if strcmp(options.ExecutionEnvironment,'cpu')
    netR = trainNetwork(XRTrain,YRTrain,Rlayers,options);
else
    pool = gcp('nocreate');
    addAttachedFiles(pool,{'/Users/leyou/Desktop/FRET/beta2.0/dataAugument.m'});
    updateAttachedFiles(pool);
    spmd
        netR = trainNetwork(XRTrain,YRTrain,Rlayers,options);
    end
    netR = netR{1};
end
Rlayers = netR.Layers;
