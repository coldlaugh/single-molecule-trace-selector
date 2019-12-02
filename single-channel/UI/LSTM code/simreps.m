%% analyzing simreps data using machine learning

%% data 
% positive control experiment data
MUT = [];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Positive controls 2018-05-29 and 2018-05-23/IL6_1000fM_whole_traces.mat');
MUT = tracesMUT.traces;
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Positive controls 2018-05-29 and 2018-05-23/B_1000fM_driftcorrected_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Positive controls 2018-05-29 and 2018-05-23/A_1000fM_driftcorrected_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
% tracesMUT = load('SiMREPSdata/RE12_500fM-1_whole_traces.mat');
% MUT = [MUT;tracesMUT.traces];
% tracesMUT = load('SiMREPSdata/RE12_500fM-2_whole_traces.mat');
% MUT = [MUT;tracesMUT.traces];
% tracesMUT = load('SiMREPSdata/RE12_500fM-3_whole_traces.mat');
% MUT = [MUT;tracesMUT.traces];
%negative control experiment data
WT = [];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Blanks 2018-06-15/1A_PEG_only_1_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Blanks 2018-06-15/1B_PEG+STV_1_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Blanks 2018-06-15/1C_PEG+STV+BSA_1_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Blanks 2018-06-15/2A_PEG_only_2_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Blanks 2018-06-15/2B_PEG+STV_2_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/Protein data (CONFIDENTIAL)/Blanks 2018-06-15/2C_PEG+STV+BSA_2_traces.mat');
WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC1-1_1200_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC1-2_1200_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC1-3_1200_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC2-1_1200_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC2-2_1200_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC2-3_1200_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/NDC n1_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/NDC n2_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/NDC n3_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_NDC-1_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_NDC-2_whole_traces.mat');
% WT = [WT;tracesWT.traces];
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_NDC-3_whole_traces.mat');
% WT = [WT;tracesWT.traces];

% data preparation
augmentMUT = 4;
augmentWT = 1;
n = (1 + augmentMUT) * size(MUT,1) + (1 + augmentWT) * size(WT,1);
d = 40;

class = [1,2];
X = cell(n,1);
Y = zeros(n,1);


for i = 1 : size(MUT,1)  % mutent
    X{i} = (MUT(i,:)-mean(MUT(i,:)))/std(MUT(i,:));   
    X{i} = reshape(X{i},d,[]);
    Y(i) = class(1);
end

for i = size(MUT,1)+1 : size(MUT,1)+size(WT,1)  % wild type
    j = i - size(MUT,1);
    X{i} = (WT(j,:)-mean(WT(j,:)))/std(WT(j,:));
    X{i} = reshape(X{i},d,[]);
    Y(i) = class(2);
end

% data augmentation for MUT data
for m = 1 : augmentMUT
    for i = 1 : size(MUT,1)  % wild type
        k = m * size(MUT,1) + size(WT,1) + i;
        X{k} = (MUT(i,:)-mean(MUT(i,:)))/std(MUT(i,:));
        X{k} = circshift(X{k},randi(length(X{k}))) + normrnd(0,0.0*rand(),size(X{k}));
        X{k} = reshape(X{k},d,[]);
        Y(k) = class(1);
    end
end

% data augmentation for WT data
for m = 1 : augmentWT
    for i = 1 : size(WT,1)  % wild type
        k = (1 + augmentMUT) * size(MUT,1) + m * size(WT,1) + i;
        X{k} = (WT(i,:)-mean(WT(i,:)))/std(WT(i,:));
        X{k} = circshift(X{k},randi(length(X{k}))) + normrnd(0,0.1*rand(),size(X{k}));
        X{k} = reshape(X{k},d,[]);
        Y(k) = class(2);
    end
end


Y = categorical(Y);

%% net 

inputSize = d ;  % the dimension of the smFRET traces
numHiddenUnits = 20; % the num of hidden units of the RNN layer
numClasses = length(class); % classification class: valid frame / invalid frame

rnnLayers = [...
    sequenceInputLayer(inputSize)
    % the net can have deeper lstm layers
%     bilstmLayer(numHiddenUnits,'OutputMode','sequence') 
%     bilstmLayer(numHiddenUnits,'OutputMode','sequence') 
%     bilstmLayer(numHiddenUnits,'OutputMode','sequence') 
%     bilstmLayer(numHiddenUnits,'OutputMode','sequence') 
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    simrepsClassificationLayer
    ];  % the layers of RNN

%% analyze net

% show network input and output dimensions.
% Require analyzeNetwork package

% analyzeNetwork(rnnLayers)
%% network warm-up

maxEpochs = 3;
numberOfWorkers = 2;
miniBatchSize = 200 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.005,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'L2Regularization',0.001,...
    'GradientThreshold',0.1,...
    'Plots','training-progress',...
    'ExecutionEnvironment','cpu');

[rnnNet,info] = trainNetwork(X,Y,rnnLayers,options);
rnnLayers = rnnNet.Layers;

%% train 

maxEpochs = 40;
numberOfWorkers = 3;
miniBatchSize = 200 * numberOfWorkers;
options = trainingOptions('adam',...
    'InitialLearnRate',0.002,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'L2Regularization',0.001,...
    'GradientThreshold',0.1,...
    'Plots','training-progress',...
    'ExecutionEnvironment','cpu');

[rnnNet,info] = trainNetwork(X,Y,rnnLayers,options);
rnnLayers = rnnNet.Layers;

%% classification result
nd = 1 : size(MUT,1)+size(WT,1);
[YPred,score] = classify(rnnNet,X(nd),'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu');
acc = sum(YPred == Y(nd))./numel(Y(nd));
plotconfusion(Y(nd),YPred);
[confus,order] = confusionmat(Y(nd),YPred)

%% representative plots

nshow = 10; % number of traces in one page
[value,order] = sort(score(:,1),'descend');
order = order(order<=size(MUT,1)); % to only show traces in MUT
figure(1)
mshow = 0;
while mshow < floor(length(score) / nshow)*nshow
    for i = 1 : nshow
        subplot(nshow,1,i)
        plot(reshape(X{order(mshow+i)}(1:d,:),1,[]),'r-');
        xlabel(['score=',num2str(score(order(mshow+i),1))]);
        set(gca,'xticklabel',[])
    end
    pause()
mshow = mshow + nshow; 
end

%% new test data 

MUT = [];
tracesMUT = load('SiMREPSdata/50 nM WT n1.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n2.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n3.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n4.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n5.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n6.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n7.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('SiMREPSdata/50 nM WT n8.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];

WT = []; % leave WT blank
% tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n1.tif_whole_traces.mat');
% WT = [WT;tracesWT.traces];


n = size(WT,1) + size(MUT,1);
d = 20;
l = size(WT,2) / d;
class = [1,2];
X = cell(n,1);
Y = zeros(n,1);

for i = 1 : size(MUT,1)  % mutent
    X{i} = (MUT(i,:)-mean(MUT(i,:)))/std(MUT(i,:));
    X{i} = reshape(X{i},d,[]);
    Y(i) = class(1);
end

sigma = std(WT(:));
for i = size(MUT,1)+1 : n  % wild type
    j = i - size(MUT,1);
    X{i} = (WT(j,:)-mean(WT(j,:)))/std(WT(j,:));
    X{i} = reshape(X{i},d,[]);
    Y(i) = class(2);
end

Y = categorical(Y);

%% classification new test data
[YPred,score] = classify(rnnNet,X,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu');
acc = sum(YPred == Y)./numel(Y);
plotconfusion(Y,YPred);
[confus,order] = confusionmat(Y,YPred)

%% test data : representative plots

nshow = 10;
[value,order] = sort(score(:,1),'descend');
order = order(order<size(MUT,1));
figure(1)
mshow = 0;
while mshow < floor(length(score) / nshow)*nshow
    for i = 1 : nshow
        subplot(nshow,1,i)
        plot(reshape(X{order(mshow+i)}(1:d,:),1,[]),'r-');
        xlabel(['score=',num2str(value(i+mshow))]);
        set(gca,'xticklabel',[])
    end
    pause()
mshow = mshow + nshow; 
end
