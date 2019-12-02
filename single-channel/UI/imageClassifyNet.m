%%
% Number of workers to train with. Set this number equal to the number of
% GPUs on you cluster. If you specify more workers than GPUs, the remaining
% workers will be idle.
numberOfWorkers =1;
% Scale batch size with expected number of GPUs
miniBatchSize = 300 * numberOfWorkers;
% Scale learning rate with batch size
learningRate = 0.00125 * numberOfWorkers;
%% Load the AlexNet network
networkOriginal = alexnet;
layersOriginal = networkOriginal.Layers;
% Copy all but the last 3 layers
layersTransfer = layersOriginal(1:end-3);
% Replace the fully connected layer with a higher learning rate
% The output size should be equal to the number of labels in your
layersTransfer(end+1) = fullyConnectedLayer(2,...
 'WeightLearnRateFactor',10,...
 'BiasLearnRateFactor',20);
% Replace the softmax and classification layers
layersTransfer(end+1) = softmaxLayer();
layersTransfer(end+1) = classificationLayer();
%% Start a parallel pool if one is not already open
pool = gcp('nocreate');
if isempty(pool)
 parpool(numberOfWorkers);
elseif (pool.NumWorkers ~= numberOfWorkers)
 delete(pool);
 parpool(numberOfWorkers);
end
%% Copy local AWS credentials to all workers
setenv('AWS_ACCESS_KEY_ID', 'AKIAJFLVLDUKEP3I2P6Q');
setenv('AWS_SECRET_ACCESS_KEY', ...
'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');
setenv('AWS_REGION', 'us-east-1');
aws_access_key_id = getenv('AWS_ACCESS_KEY_ID');
aws_secret_access_key_id = getenv('AWS_SECRET_ACCESS_KEY');
spmd
 setenv('AWS_ACCESS_KEY_ID',aws_access_key_id);
 setenv('AWS_SECRET_ACCESS_KEY',aws_secret_access_key_id);
 setenv('AWS_REGION', 'us-east-1');
end
%% Load the training and test data
% rootFolder = 's3://fretml/image_traces/';
rootFolder = '/Users/leyou/Desktop/FRET/image_traces/'
categories = {'good_Alex_train','bad_Alex_train'};
imds = imageDatastore(fullfile(rootFolder,categories), 'LabelSource', 'foldernames');
imds.ReadFcn = @(loc)imresize(imread(loc),[227,227]);
%% Shuffle and split data into training and testing
% [imdsTrain,imdsTest] = splitEachLabel(shuffle(imds),0.99);
imdsTrain = imds;
%% Define the transfer learning training options
optionsTransfer = trainingOptions('sgdm',...
 'MiniBatchSize',miniBatchSize,...
 'MaxEpochs',100,...
 'InitialLearnRate',learningRate,...
 'LearnRateDropFactor',0.1,...
 'LearnRateDropPeriod',20,...
 'Verbose',true,...
 'Plots','training-progress',...
 'ExecutionEnvironment','parallel'); % change 'parallel' to 'cpu' or 'gpu' to train the network on the local computer.

%% Train the network on the cluster
if exist('net','var')
    layersTransfer = net.Layers;
    layersTransfer(end-1) = softmaxLayer();
    layersTransfer(end) = classificationLayer();
end
net = trainNetwork(imdsTrain,layersTransfer,optionsTransfer);
%% Record the accuracy for this network
% Uses the trained network to classify the test images on the local machine
% and compares this to their ground truth labels.
rootFolder = '/Users/leyou/Desktop/FRET/image_traces/'
categories = {'good_Alex_test','bad_Alex_test'};
imds = imageDatastore(fullfile(rootFolder,categories), 'LabelSource', 'foldernames');
imds.ReadFcn = @(loc)imresize(imread(loc),[227,227]);
% [imdsTrain,imdsTest] = splitEachLabel(shuffle(imds),0.01);
imdsTest = imds;
YTest = cell(1);
score = cell(1);
parfor i = 1 : 1
     gpuDevice()
    [YTest{i},score{i}] = classify(net,imdsTest,'ExecutionEnvironment','gpu');
    accuracy = sum(YTest{i} == imdsTest.Labels)/numel(imdsTest.Labels)
    disp(accuracy)
    [confus,order] = confusionmat(imdsTest.Labels,YTest{i})
    disp(confus)
    disp(order)    
end
%% Generate the confusion matrix for the test data
% [confus,order] = confusionmat(imdsTest.Labels,YTest)

%% save the trained network
save('trainedAlexNetOnImageCond4.mat','net')

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
        if YTest(i) == categorical("bad") && imdsTest.Labels(i)==categorical("good3T_Test2")
            imshow(readimage(imdsTest,i))
            disp(YTest(i))
            disp(score(i,:))
            disp(imdsTest.Files{i})
            pause()
        end
        if YTest(i) == categorical("good") && imdsTest.Labels(i)==categorical("bad3T_Test2")
            imshow(readimage(imdsTest,i))
            disp(YTest(i))
            disp(score(i,:))
            disp(imdsTest.Files{i})
            pause()
        end
    end
end

