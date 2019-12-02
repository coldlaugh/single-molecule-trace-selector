% This program is to train an alexNet on the the data of images of donor/accepter
% scatter plot. The alexNet achieves an training accuracy of nearly 100%
% and a test accuracy of 91.5% on Pauls's data and 89.4% on Jieming's data.

%%
% Number of workers to train with. Set this number equal to the number of
% GPUs on you cluster. If you specify more workers than GPUs, the remaining
% workers will be idle.

%% Construct LSMT network

inputSize = 2 * 30;
numHiddenUnits = 50;
numClasses = 2;
layers = [ ...
    sequenceInputLayer(inputSize)
%     dataPreProcessLayer('preprocess',30)
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];
addpath(pwd());
%% Construct a DAG network

lgraph = layerGraph(layers);
figure
plot(lgraph)

%% Start a parallel pool if one is not already open
pool = gcp('nocreate');
if isempty(pool)
 parpool(numberOfWorkers);
elseif (pool.NumWorkers ~= numberOfWorkers)
 delete(pool);
 parpool(numberOfWorkers);
end
%% Load the training and test data
rootFolder = '/Users/leyou/Desktop/FRET/time_traces/'
categories = {'good_paul','bad_paul','good_jieming','bad_jieming','good_julia','bad_julia'};
ds = fileDatastore(fullfile(rootFolder,categories), 'FileExtensions', '.dat','ReadFcn',@readTimeTrace);
addpath('/Users/leyou/Desktop/FRET/time_traces/');

X = ds.readall;
Y = categorical(contains(ds.Files,'good'));

trainsetchoice = randperm(numel(X),floor(numel(X)*0.8));
testsetchoice = setdiff([1:numel(X)],trainsetchoice);
testsetchoice = testsetchoice(randperm(numel(testsetchoice)));

XTrain = X(trainsetchoice);
YTrain = Y(trainsetchoice);

XTest = X(testsetchoice);
YTest = Y(testsetchoice);

X = 0;
Y = 0;
%% Shuffle and split data into training and testing

% imdsTrain = imds;
%% Define the transfer learning training options
maxEpochs = 1000;
numberOfWorkers =1;
miniBatchSize = 300 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.005,...
    'MaxEpochs',maxEpochs,...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',0.9, ...
    'LearnRateSchedule','piecewise',...
    'MiniBatchSize',miniBatchSize,...
    'Plots','training-progress',...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','gpu') % change 'parallel' to 'cpu' or 'gpu' to train the network on the local computer.

%% Train the network on the cluster
% if exist('net','var')
%     layersTransfer = net.Layers;
%     layersTransfer(end-1) = softmaxLayer();
%     layersTransfer(end) = classificationLayer();
% end
spmd
addpath('/Users/leyou/Desktop/FRET/beta2.0');
net = trainNetwork(XTrain,YTrain,layers,options);
end
net = net{1};
layers = net.Layers;
% save('trainedLSTMDropout.mat','net')

%% Transfer learning data

categories = {'good_selector_test','bad_selector_test'};
ds = fileDatastore(fullfile(rootFolder,categories), 'FileExtensions', '.dat','ReadFcn',@readTimeTrace);

X = ds.readall;
Y = categorical(contains(ds.Files,'good'));

trainsetchoice = randperm(numel(X),floor(numel(X)*0.1));
testsetchoice = setdiff([1:numel(X)],trainsetchoice);
testsetchoice = testsetchoice(randperm(numel(testsetchoice)));

       

% balance the sample number in each label
ntransfer = length(trainsetchoice);
for i = 1 : 5
    for j = 1 : ntransfer
        if Y(trainsetchoice(j)) == 'true'
            trainsetchoice = [trainsetchoice,trainsetchoice(j)];
        end
    end
end

XTransfer = X(trainsetchoice);
YTransfer = Y(trainsetchoice);

XTest = X(testsetchoice);
YTest = Y(testsetchoice);

% X = 0;
% Y = 0;

%% train transfer learning network
options = trainingOptions('adam',...
    'InitialLearnRate',0.002,...
    'MaxEpochs',40,...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',0.3, ...
    'MiniBatchSize',miniBatchSize,...
    'Plots','training-progress',...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','cpu')
% spmd
    netTransfer = trainNetwork(XTransfer,YTransfer,net.Layers,options);
% end
netTransfer = netTransfer{1};
%% Record the accuracy for this network

[YPred,Yscore] = classify(net,XTest);
acc = sum(YPred == YTest)./numel(YTest)

%% Generate the confusion matrix for the test data
[confus,order] = confusionmat(YTest,YPred)

%% Use the regional LSTM to view the results
workspace = load('timeRegional.mat');
rnet = workspace.net;
[RYPred,score] = classify(rnet,XTest,'MiniBatchSize',200);


for i = 1 : length(RYPred)
    if YPred(i) == 'true' 
        figure(1);
        hold off;
        plot(reshape(XTest{i}([1:10],:),[3000,1]),'r-');
        hold on;
        plot(reshape(XTest{i}([11:20],:),[3000,1]),'g-');
        % plot([1:300]*10,grp2idx(YPred{i})-1,'c-','LineWidth',5);
        pred = regionalPropose(score{i}(2,:)');
        pred(conv(pred,[1,1,1],'same') == 0) = nan;
        plot([1:300]*10,1.3*pred,'-.','LineWidth',4,'Color','c');
        plot([1:300]*10,score{i}(2,:)','m-.','LineWidth',2);
        plot([1:300]*10,-0*pred,'-.','LineWidth',4,'Color','c');
        legend('Red','Green','Proposed region','score')
        if YTest(i) == 'true'
            title(strcat("ground truth = selected,"," score = ",num2str(Yscore(i,2))));
        else
            title(strcat("ground truth = not selected, ","score = ",num2str(Yscore(i,2))));
        end
        pause();
    end
end

%% save the trained network
% save('BiLSTMnet.mat','net')

