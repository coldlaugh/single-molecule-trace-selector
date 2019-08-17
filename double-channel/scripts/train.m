%% setup cnn network
cnnNet = alexnet;
numClasses = 2;
inputSize = [227,227,3];

endLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',100,'BiasLearnRateFactor',100)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
cnnLayers = [
    cnnNet.Layers(1:end-3)
    endLayers
    ];

%% load the training and testing data

rootFolder = '../beta2.0/trainingDataImg/';
categories = {'set1/goodMol','set1/badMol','set2/goodMol','set2/badMol','set3/goodMol','set3/badMol','set4/goodMol','set4/badMol','set5/goodMol'};
ds = fileDatastore(fullfile(rootFolder,categories),'IncludeSubfolders',true, 'FileExtensions', '.png','ReadFcn',@(loc)imread(loc));

f = waitbar(0,'Loading data','Name','Loading progress');

files = ds.Files;

X = cell(size(files));
YR = cell(size(files)); % label for each frame
Y = categorical(contains(files,'good')); % label for each trace

for i = 1 : length(files)
    T = read(ds);
    X{i} = T;
%     YR{i} = categorical(T{2});
    waitbar(i/length(files),f);
end

close(f);

%% randomly assign data to training set and testing set

numTrain = floor(0.5 * length(X));
numTest = length(X) - numTrain;

indTrain = randperm(length(X),numTrain);
indTest = setdiff(1:length(X),indTrain);
indTest = indTest(randperm(length(indTest)));

XTrain = zeros([inputSize,length(indTrain)]);
for i = 1 : length(indTrain)
    XTrain(:,:,:,i) = X{indTrain(i)};
end
YTrain = Y(indTrain);
XTest = zeros([inputSize,length(indTest)]);
for i = 1 : length(indTest)
    XTest(:,:,:,i) = X{indTest(i)};
end
YTest = Y(indTest);
XTest = XTest(:,:,:,~contains(files(indTest),'set5'));
YTest = YTest(~contains(files(indTest),'set5'));

%% set training options
mkdir('checkPoint');
maxEpochs = 200;
numberOfWorkers = 2;
miniBatchSize = 50 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',.001,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','parallel',...
    'Plots','training-progress',...
    'CheckpointPath',fullfile(pwd(),'checkPoint/')...
);

%% train CNN
if strcmp(options.ExecutionEnvironment,'cpu')
    [cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
elseif strcmp(options.ExecutionEnvironment,'gpu')
    pool = gcp();
%     addAttachedFiles(pool,...
%         {
%         '~/Desktop/FRET/beta2.0/imageConversionLayer.m',...
%         '~/Desktop/FRET/beta2.0/TimeSeriesToImg.m'
%         });
%     updateAttachedFiles(pool)
    spmd
        [cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
    end
    cnnNet = cnnNet{1};
    info = info{1};
elseif strcmp(options.ExecutionEnvironment,'parallel')
    [cnnNet,info] = trainNetwork(XTrain,YTrain,cnnLayers,options);
end
cnnLayers = cnnNet.Layers;
save('cnnNet.mat','cnnNet');
