% This program is to train an alexNet on the the data of images of donor/accepter
% scatter plot. The alexNet achieves an training accuracy of nearly 100%
% and a test accuracy of 91.5% on Pauls's data and 89.4% on Jieming's data.

%%
% Number of workers to train with. Set this number equal to the number of
% GPUs on you cluster. If you specify more workers than GPUs, the remaining
% workers will be idle.

%% Construct LSMT network

inputSize = 2;
numHiddenUnits1 = 125;
numHiddenUnits2 = 100;
numClasses = 2;
layers = [ ...
    sequenceInputLayer(inputSize)
    dataAugument()
    lstmLayer(numHiddenUnits1,'OutputMode','sequence')
    lstmLayer(numHiddenUnits2,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];


%% Start a parallel pool if one is not already open
pool = gcp('nocreate');
numberOfWorkers =1;
if isempty(pool)
 parpool(numberOfWorkers);
elseif (pool.NumWorkers ~= numberOfWorkers)
 delete(pool);
 parpool(numberOfWorkers);
end
%% Load the training and test data
rootFolder = '/Users/leyou/Desktop/FRET/time_traces_regional/'
categories = {'good_jieming_w8'};
ds = fileDatastore(fullfile(rootFolder,categories), 'FileExtensions', '.dat','ReadFcn',@readTimeTraceRegional);
% addpath('/Users/leyou/Desktop/FRET/time_traces/');

X = ds.readall;
Y = categorical(contains(ds.Files,'good'));
trainsetchoice = randperm(numel(X),floor(numel(X)*0.99));


XTrain = cell(length(trainsetchoice),1);
YTrain = cell(length(trainsetchoice),1);
for i = 1 : length(trainsetchoice)
    XTrain{i} = X{trainsetchoice(i)}{1};
    YTrain{i} = categorical(X{trainsetchoice(i)}{2});
end
YFinalTrain = Y(trainsetchoice);

%% test sample (option 1)

% testsetchoice = setdiff([1:numel(X)],trainsetchoice);
% testsetchoice = testsetchoice(randperm(numel(testsetchoice)));
% XTest = cell(length(testsetchoice),1);
% YTest = cell(length(testsetchoice),1);
% for i = 1 : length(testsetchoice)
%     XTest{i} = X{testsetchoice(i)}{1};
%     YTest{i} = categorical(X{testsetchoice(i)}{2});
% end
% YFinalTest = Y(testsetchoice);
% 
% X = 0;
% Y = 0;
%% use jieming's new w6 and w7 data as test sample (option 2)

categories = {'good_selector_test'};
ds = fileDatastore(fullfile(rootFolder,categories), 'FileExtensions', '.dat','ReadFcn',@readTimeTraceRegional);

X = ds.readall;
Y = categorical(contains(ds.Files,'good'));

testsetchoice = setdiff(1:numel(X),[]);
testsetchoice = testsetchoice(randperm(numel(testsetchoice)));

XTest = cell(length(testsetchoice),1);
YTest = cell(length(testsetchoice),1);
for i = 1 : length(testsetchoice)
    XTest{i} = X{testsetchoice(i)}{1};
    YTest{i} = categorical(X{testsetchoice(i)}{2});
end
YFinalTest = Y(testsetchoice);

X = 0;
y = 0;

%% Shuffle and split data into training and testing

% imdsTrain = imds;
%% Define the learning training options
maxEpochs = 100;
numberOfWorkers =1;
miniBatchSize = 300 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.01,...
    'MaxEpochs',100,...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',0.2, ...
    'MiniBatchSize',miniBatchSize,...
    'Plots','training-progress',...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','cpu') % change 'parallel' to 'cpu' or 'gpu' to train the network on the local computer.

%% Train the network on the cluster
% if exist('net','var')
%     layersTransfer = net.Layers;
%     layersTransfer(end-1) = softmaxLayer();
%     layersTransfer(end) = classificationLayer();
% end
spmd
net = trainNetwork(XTrain,YTrain,layers,options);
end
net = net{1};
layers = net.Layers;

%% Transfer learning

options = trainingOptions('adam',...
    'InitialLearnRate',0.01,...
    'MaxEpochs',100,...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',0.2, ...
    'MiniBatchSize',miniBatchSize,...
    'Plots','training-progress',...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','cpu')

categories = {'good_alex_transfer'};
ds = fileDatastore(fullfile(rootFolder,categories), 'FileExtensions', '.dat','ReadFcn',@readTimeTraceRegional);

X = ds.readall;
Y = categorical(contains(ds.Files,'good'));

testsetchoice = setdiff(1:numel(X),[]);
testsetchoice = testsetchoice(randperm(numel(testsetchoice)));

XTransfer = cell(length(testsetchoice),1);
YTransfer = cell(length(testsetchoice),1);
for i = 1 : length(testsetchoice)
    XTransfer{i} = X{testsetchoice(i)}{1};
    YTransfer{i} = categorical(X{testsetchoice(i)}{2});
end
YFinalTransfer = Y(testsetchoice);

X = 0;
y = 0;

netTransfer = trainNetwork(XTransfer,YTransfer,net.Layers,options);

%% Record the accuracy for this network

[YPred,score] = classify(net,XTest,'MiniBatchSize',200);
acc = zeros(length(YPred),1);
for i = 1 : length(YPred)
    pred = categorical(regionalPropose(score{i}(2,:)));
    acc(i) = sum(pred == YTest{i}) / length(YTest{i});
end

mean(acc)

for i = 1 : length(YPred)
figure(1);
hold off;
plot(reshape(XTest{i}([1:10],:),[3000,1]),'r-');
hold on;
plot(reshape(XTest{i}([11:20],:),[3000,1]),'g-');
% plot([1:300]*10,grp2idx(YPred{i})-1,'c-','LineWidth',5);
label = (grp2idx(YTest{i})-1);
label(conv(label,[1,1,1],'same') == 0) = nan;
pred = regionalPropose(score{i}(2,:)');
pred(conv(pred,[1,1,1],'same') == 0) = nan;
plot([1:300]*10,1.3*pred,'-.','LineWidth',4,'Color','c');
plot([1:300]*10,score{i}(2,:)','m-.','LineWidth',2);
plot([1:300]*10,1.1*label,'b-.','LineWidth',3);
plot([1:300]*10,-0*pred,'-.','LineWidth',4,'Color','c');
plot([1:300]*10,-0*label,'b-.','LineWidth',3);
legend('Red','Green','Proposed region','score','true region')
pause();
end

% acc = sum(YPred == YTest)./numel(YTest)
% 
% %% Generate the confusion matrix for the test data
% [confus,order] = confusionmat(YTest,YPred)

%% save the trained network
save('timeRegional.mat','net')

%% extract image features (optional)
extractFeature = false;
if extractFeature
    parfor i = 1 : 1

    layer = 'fc6'
    trainingFeatures = activations(net, imdsTrain, layer);
    testFeatures = activations(net, imdsTest, layer);

    % extract the class labels
    trainingLabels = imdsTrain.Labels;
    testLabels = imdsTest.Labels;
    % fit image classifier
    classifier = fitcecoc(trainingFeatures, trainingLabels);

    %Classify Test Images
    predictedLabels = predict(classifier,testFeatures);

    accuracy = mean(predictedLabels == testLabels);
    disp(accuracy)
    [confus,order] = confusionmat(imdsTest.Labels,predictedLabels);
    disp(confus)
    disp(order)
    end
end

%% plot false positives and false negatives
PlotFN = false;
if PlotFN
    figure(1)
    if iscell(YTest)
    YTest = YTest{1};
    score = score{1};
    end
    for i = 1 : length(YTest)
        if YTest(i) == categorical('bad') && imdsTest.Labels(i)==categorical('good3T_Test2')
            imshow(readimage(imdsTest,i))
            disp(YTest(i))
            disp(score(i,:))
            disp(imdsTest.Files{i})
            pause()
        end
        if YTest(i) == categorical('good') && imdsTest.Labels(i)==categorical('bad3T_Test2')
            imshow(readimage(imdsTest,i))
            disp(YTest(i))
            disp(score(i,:))
            disp(imdsTest.Files{i})
            pause()
        end
    end
end

