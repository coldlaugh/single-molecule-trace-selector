%% 
% in this script, we train a CNN network to perform a image classification
% task on smFRET traces. The trained CNN will automatically classify the 
% smFRET traces to be valid or invalid for the next step of data analysis.


%% Load the CNN network (simple version)
numClasses = 2;
inputSize = [2,6000,1];

s = load('cnnNet3.mat');
cnnNet = s.cnnNet;

%% Load the RNN network

s = load('rnnNetB1.mat');
rnnNet = s.rnnNet;


%% Initialize the simple DAG network
CRLayers = [
    imageInputLayer(inputSize,'Normalization','none','Name','data')
    rnnFeatureLayer(rnnNet,'rnnFeatureLayer')
    fullyConnectedLayer(100,'Name','fc_rnn1','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    reluLayer('Name','rnnReLU1')
%     dropoutLayer('Name','rnnDropout1')
    fullyConnectedLayer(50,'Name','fc_rnn2','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    reluLayer('Name','rnnReLU2')
    dropoutLayer('Name','rnnDropout2')
    fullyConnectedLayer(numClasses,'Name','fc_final','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];
dagNet = layerGraph(CRLayers);
%% Initialize the DAG network

cnnLayers = cnnNet.Layers;
cnnLayers = cnnLayers(1:end-3);
rnnFeature = dagNet.Layers(2:7);
CRLayers = [
    cnnLayers
    depthConcatenationLayer(2,'Name','concat')
    fullyConnectedLayer(numClasses,'Name','fc_final','WeightLearnRateFactor',100,'BiasLearnRateFactor',100)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];
dagNet = layerGraph(CRLayers);
dagNet = addLayers(dagNet,rnnFeature);
dagNet = connectLayers(dagNet,'data','rnnFeatureLayer');
dagNet = connectLayers(dagNet,'rnnDropout2','concat/in2');

%% load the training and testing data

rootFolder = '/Users/leyou/Desktop/FRET/beta2.0/trainingData/';
categories = {'set1/goodMol','set2/goodMol','set3/goodMol','set4/goodMol','set5/goodMol','set3/badMol','set4/badMol'};
% categories = {'set2/badMol','set3/badMol','set4/badMol','set1/badMol'};
ds = fileDatastore(fullfile(rootFolder,categories),'IncludeSubfolders',true, 'FileExtensions', '.mat','ReadFcn',@(loc)readTimeTrace(loc,1));

f = waitbar(0,'Loading data','Name','Loading progress');

files = ds.Files;

X = cell(size(files));
YR = cell(size(files)); % label for each frame
Y = categorical(contains(files,'good')); % label for each trace

for i = 1 : length(files)
    T = read(ds);
    X{i} = T{1};
    YR{i} = categorical(T{2});
    waitbar(i/length(files),f);
end

close(f)
%% randomly assign data to training set and testing set

numTrain = floor(0.8 * length(X));
numTest = length(X) - numTrain;

indTrain = randperm(length(X),numTrain);
indTest = setdiff(1:length(X),indTrain);
indTest = indTest(randperm(length(indTest)));

XTrain = zeros([inputSize,length(indTrain)]);
for i = 1 : length(indTrain)
    XTrain(:,:,1,i) = X{indTrain(i)};
end
YTrain = Y(indTrain);
XTest = zeros([inputSize,length(indTest)]);
for i = 1 : length(indTest)
    XTest(:,:,1,i) = X{indTest(i)};
end
YTest = Y(indTest);
XTest = XTest(:,:,:,~contains(files(indTest),'set5'));
YTest = YTest(~contains(files(indTest),'set5'));
%% set training options

maxEpochs = 100;
numberOfWorkers = 20;
miniBatchSize = 50 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.01,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','parallel',...
    'Plots','training-progress',...
    'CheckpointPath',pwd());

%% train CNNRNN
if strcmp(options.ExecutionEnvironment,'cpu')
    [dagNet,info] = trainNetwork(XTrain,YTrain,dagNet,options);
elseif strcmp(options.ExecutionEnvironment,'gpu')
    pool = gcp();
    addAttachedFiles(pool,...
        {
        '~/Desktop/FRET/beta2.0/imageConversionLayer.m',...
        '~/Desktop/FRET/beta2.0/TimeSeriesTo%% set training options'}
    );

maxEpochs = 100;
numberOfWorkers = 20;
miniBatchSize = 50 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.01,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','parallel',...
    'Plots','training-progress',...
    'CheckpointPath',pwd());

%% train CNNRNN
if strcmp(options.ExecutionEnvironment,'cpu')
    [dagNet,info] = trainNetwork(XTrain,YTrain,dagNet,options);
elseif strcmp(options.ExecutionEnvironment,'gpu')
    pool = gcp();
    addAttachedFiles(pool,...
        {
        '~/Desktop/FRET/beta2.0/imageConversionLayer.m',...
        '~/Desktop/FRET/beta2.0/TimeSeriesToImg.m'
        });
    updateAttachedFiles(pool)
    spmd
        [dagNet,info] = trainNetwork(XTrain,YTrain,dagNet,options);
    end
    dagNet = dagNet{1};
    info = info{1};
elseif strcmp(options.ExecutionEnvironment,'parallel')
%         pool = gcp();
%     addAttachedFiles(pool,...
%         {
%         '~/Desktop/FRET/beta2.0/imageConversionLayer.m',...
%         '~/Desktop/FRET/beta2.0/TimeSeriesToImg.m'
%         });
%     updateAttachedFiles(pool);
    [dagNet,info] = trainNetwork(XTrain,YTrain,dagNet,options);
end
% cnnLayers = cnnNet.Layers;
Img.m'
        });
    updateAttachedFiles(pool)
    spmd
        [dagNet,info] = trainNetwork(XTrain,YTrain,dagNet,options);
    end
    dagNet = dagNet{1};
    info = info{1};
elseif strcmp(options.ExecutionEnvironment,'parallel')
%         pool = gcp();
%     addAttachedFiles(pool,...
%         {
%         '~/Desktop/FRET/beta2.0/imageConversionLayer.m',...
%         '~/Desktop/FRET/beta2.0/TimeSeriesToImg.m'
%         });
%     updateAttachedFiles(pool);
    [dagNet,info] = trainNetwork(XTrain,YTrain,dagNet,options);
end
% cnnLayers = cnnNet.Layers;
% save('dagNet.mat','dagNet');


%% test CNN
env = 'cpu';
if strcmp(env,'gpu')
    spmd
        [YPred,score] = classify(dagNet,XTest,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','gpu');
    end
    YPred = YPred{1};
    score = score{1};
else
    [YPred,score] = classify(dagNet,XTest,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu');
end
acc = sum(YPred == YTest)./numel(YTest);
plotconfusion(YTest,YPred);
[confus,order] = confusionmat(YTest,YPred)

%% go over test results
for i = 1 : length(YPred)
figure(1);clf;
subplot(2,2,[1,2]);
donor = XTest(1,:,:,i); % recover donor signal
acceptor = XTest(2,:,:,i); % recover acceptor signal
plot(donor,'Color',[0,0.5,0]);
hold on;
plot(acceptor,'r');
legend('donor','acceptor')
title(['target = ',char(YTest(i)),', predict = ',char(YPred(i))]);
subplot(2,2,3)
imshow(1-TimeSeriesToImg(XTest(:,:,:,i)));
title(['score = ',num2str(max(score(i,:)))]);
pause();
end

%% threshold vs. specifity

sp = [];
thres = linspace(0,1,100);
for i = 1 : length(thres)
    p = categorical(score(:,2) > thres(i));
    sp = [sp;sum(p == YTest)./numel(YTest)];
end

figure(2)
plot(thres,sp,'LineWidth',2);
