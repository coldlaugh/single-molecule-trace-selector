%%
% In this script, we train a RNN to perform a sequence to 
% sequence classification task on smFRET traces. The trained RNN will 
% automatically classify each frame of smFRET traces to be valid or 
% invalid for the next step of data analysis.  

%% Initialize the RNN network

inputSize = 2 * 10 ;  % the dimension of the smFRET traces
numHiddenUnits = 100; % the num of hidden units of the RNN layer
numClasses = 2; % classification class: valid frame / invalid frame

rnnLayers = [...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];  % the layers of RNN

%% load the training and testing data

rootFolder = '/Users/leyou/Desktop/FRET/beta2.0/trainingData/';
% categories = {'set1/goodMol','set2/goodMol','set3/goodMol','set4/goodMol','set5/goodMol','set4/badMol','set3/badMol','set2/badMol'};
categories = {'set3/goodMol'};
ds = fileDatastore(fullfile(rootFolder,categories),'IncludeSubfolders',true, 'FileExtensions', '.mat','ReadFcn',@readTimeTrace);

f = waitbar(0,'Loading data','Name','Loading progress');

files = ds.Files;

X = cell(size(files));
Y = cell(size(files));

for i = 1 : length(files)
    T = read(ds);
    X{i} = T{1};
    Y{i} = categorical(T{2});
    waitbar(i/length(files),f);
end

close(f)
%% randomly assign data to training set and testing set

numTrain = floor(0.6 * length(X));
numTest = length(X) - numTrain;

indTrain = randperm(length(X),numTrain);
indTest = setdiff(1:length(X),indTrain);
indTest = indTest(randperm(length(indTest)));

XTrain = X(indTrain);
YTrain = Y(indTrain);
XTest = X(indTest);
YTest = Y(indTest);
XTest = XTest(~contains(files(indTest),'set5'));
YTest = YTest(~contains(files(indTest),'set5'));

%% set training options

maxEpochs = 100;
numberOfWorkers = 1;
miniBatchSize = 500 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.005,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'ExecutionEnvironment','gpu');

%% train RNN
if strcmp(options.ExecutionEnvironment,'cpu')
    [rnnNet,info] = trainNetwork(XTrain,YTrain,rnnLayers,options);
else
    spmd
        [rnnNet,info] = trainNetwork(XTrain,YTrain,rnnLayers,options);
    end
    rnnNet = rnnNet{1};
    info = info{1};
end
rnnLayers = rnnNet.Layers;
% save('rnnNetB2.mat','rnnNet');
%% test RNN

[YPred,score] = classify(rnnNet,XTest,'MiniBatchSize',200);
acc = zeros(length(YPred),1);
rAcc = zeros(length(YPred),1);
for i = 1 : length(YPred)
    pred = categorical(regionalPropose(score{i}(2,:)));
    acc(i) = sum(pred == YTest{i}) / length(YTest{i});
    target = categorical(1);
    rAcc(i) = sum((pred == target) & (YTest{i} == target)) / max(sum(YTest{i} == target),sum(pred == target));
end

mean(acc)
mean(rAcc)


%% go over test results
for i = 1 : length(YPred)
figure(1);cla;
donor = reshape(XTest{i}(1:10,:),1,[]); % recover donor signal
acceptor = reshape(XTest{i}(11:20,:),1,[]); % recover acceptor signal
plot(donor,'Color',[0,0.5,0]);
hold on;
plot(acceptor,'r');
label = grp2idx(YTest{i})-1;
label(conv(label,[1,1,1],'same') == 0) = nan;
pred = regionalPropose(score{i}(2,:)');
pred(conv(pred,[1,1,1],'same') == 0) = nan;
numFrame = length(donor);
ym = max([donor acceptor]);
plot(1:10:numFrame,1.3 * ym * pred,'-.','LineWidth',4,'Color','c');
plot(1:10:numFrame,score{i}(2,:)','m-.','LineWidth',2);
plot(1:10:numFrame,1.1 * ym * label,'b-.','LineWidth',3);
plot(1:10:numFrame,0 * pred,'-.','LineWidth',4,'Color','c');
plot(1:10:numFrame,0 * label,'b-.','LineWidth',3);
legend('Red','Green','Proposed region','score','true region')
pause();
end

