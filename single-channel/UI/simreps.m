%% analyzing simreps data using machine learning

%% data 

MUT = [];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 fM MUT n1.tif_whole_traces.mat');
MUT = tracesMUT.traces;
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 fM MUT n2.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 fM MUT n3.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_500fM-1_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_500fM-2_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_500fM-3_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];

WT = [];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE4_F-1_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE4_F-2_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE4_F-3_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE4_A-1_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE4_A-2_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE4_A-3_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC1-1_1200_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC1-2_1200_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC1-3_1200_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC2-1_1200_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC2-2_1200_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE1_NDC2-3_1200_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/NDC n1_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/NDC n2_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/NDC n3_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_NDC-1_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_NDC-2_whole_traces.mat');
WT = [WT;tracesWT.traces];
tracesWT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/RE12_NDC-3_whole_traces.mat');
WT = [WT;tracesWT.traces];

n = size(WT,1) + size(MUT,1);
d = 20;
l = size(WT,2) / d;
class = [1,2];
X = cell(n,1);
Y = zeros(n,1);

sigma = std(MUT(:));
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

%% net 

inputSize = d ;  % the dimension of the smFRET traces
numHiddenUnits = 100; % the num of hidden units of the RNN layer
numClasses = length(class); % classification class: valid frame / invalid frame

rnnLayers = [...
    sequenceInputLayer(inputSize)
    %bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
%     fullyConnectedLayer(numHiddenUnits)
%     reluLayer
%     dropoutLayer(0.5)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    simrepsClassificationLayer
    ];  % the layers of RNN

%% analyze net
analyzeNetwork(rnnLayers)
%% train

maxEpochs = 30;
numberOfWorkers = 1;
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

%% classification results
[YPred,score] = classify(rnnNet,X,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu');
acc = sum(YPred == Y)./numel(Y);
plotconfusion(Y,YPred);
[confus,order] = confusionmat(Y,YPred)

%% signiture plots

nshow = 10;
[value,order] = sort(score(:,1),'descend');
order = order(order<=size(MUT,1));
figure(1)
mshow = 0;
while mshow < 50 * nshow
    for i = 1 : nshow
        subplot(nshow,1,i)
        plot(reshape(X{order(mshow+i)},1,[]),'r-');
        xlabel(['score=',num2str(score(order(mshow+i),1))]);
        set(gca,'xticklabel',[])
    end
    pause()
mshow = mshow + nshow; 
end
% [value,order] = sort(score(:,2),'descend');
% figure(2)
% for i = 1 : nshow
%     subplot(nshow,1,i)
%     plot(reshape(X{order(i)},1,[]),'r-');
%     axis off
% end

%% new test data 

MUT = [];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n1.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n2.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n3.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n4.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n5.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n6.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n7.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];
tracesMUT = load('/Users/leyou/Desktop/FRET/beta2.0/SiMREPSdata/50 nM WT n8.tif_whole_traces.mat');
MUT = [MUT;tracesMUT.traces];

WT = [];
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

% classification test data
[YPred,score] = classify(rnnNet,X,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu');
acc = sum(YPred == Y)./numel(Y);
plotconfusion(Y,YPred);
[confus,order] = confusionmat(Y,YPred)

%% test data : signiture plots

nshow = 10;
[value,order] = sort(score(:,1),'descend');
order = order(order<size(MUT,1));
figure(1)
mshow = 0;
while mshow < 80 * nshow
    for i = 1 : nshow
        subplot(nshow,1,i)
        plot(reshape(X{order(mshow+i)},1,[]),'r-');
        xlabel(['score=',num2str(value(i+mshow))]);
        set(gca,'xticklabel',[])
    end
    pause()
mshow = mshow + nshow; 
end

%% test with trace simulator
f = waitbar(0,'Please wait...');
progress = 0;
ngrid = 33;
tauon_lim = 80;
tauon_min = 0;
tauoff_lim = 80;
tauoff_min = 80;
scoreAccept = [];
scoreReject = [];
nbdAccept = [];
nbdReject = [];
tauAccept = [];
tauReject = [];
for n1 = 1 : ngrid^2
    tau_on = tauon_min + (tauon_lim-tauon_min) * rand();
    tau_off = tauoff_min + (tauoff_lim - tauoff_min) * rand();
    [MUT,nbd,tauon] = SiMREPS_trace_simulator_mex(tau_on,tau_off,0.5);
    progress = progress + 0.2 / ngrid^2;
    waitbar(progress,f);
    WT = [];
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
    for i = size(MUT,1)+1 : n  % wild type
        j = i - size(MUT,1);
        X{i} = (WT(j,:)-mean(WT(j,:)))/std(WT(j,:));
        X{i} = reshape(X{i},d,[]);
        Y(i) = class(2);
    end
    Y = categorical(Y);
    [YPred,score] = classify(rnnNet,X,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu');
    progress = progress + 0.8 / ngrid^2;
    waitbar(progress,f);
    scoreAccept = [scoreAccept; score(YPred == '1',1)];
    scoreReject = [scoreReject; score(YPred == '2',1)];
    nbdAccept = [nbdAccept;nbd(YPred == '1')];
    nbdReject = [nbdReject;nbd(YPred == '2')];
    tauAccept = [tauAccept;tauon(YPred == '1')];
    tauReject = [tauReject;tauon(YPred == '2')];
end
close(f)

%% characterize trace simulator results

nbd = [nbdAccept;nbdReject];
tau = [tauAccept;tauReject];
score = [scoreAccept;scoreReject];


figure(1)
clf;
histogram(tau(tau<200),'BinWidth',2.5,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
hold on
histogram(tauAccept(tauAccept<200),'BinWidth',2.5,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
legend('All','ML Accepted')
xlabel \tau_{on}
ylabel count

figure(2)
clf;
histogram(nbd(nbd<100),'BinWidth',1,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
hold on
histogram(nbdAccept(nbdAccept<100),'BinWidth',1,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
legend('All','ML Accepted')
xlabel N_{b+d}
ylabel count

figure(3);
clf;
hold on;

binWidth = [2,4];
tauRange = [5:binWidth(1):100];
nbdRange = [1:binWidth(2):100];
Z = zeros(length(tauRange),length(nbdRange));
count = Z;


for i = 1 : length(tauRange)
    for j = 1 : length(nbdRange)
        g = tau>(tauRange(i)-binWidth(1)/2) & tau<(tauRange(i)+binWidth(1)/2)...
            & nbd>(nbdRange(j)-binWidth(2)/2) & nbd<(nbdRange(j)+binWidth(2)/2);
        Z(i,j) = Z(i,j) + sum(score(g));
        count(i,j) = count(i,j) + sum(g);
    end
end
imagesc(tauRange,nbdRange,Z'./count')
xlim(tauRange([1,end]))
ylim(nbdRange([1,end]))
colorbar
xlabel \tau_{on}
ylabel N_{b+d}
% plot(tauReject,nbdReject,'bo')
hold off
% set(gca,'xScale','log')

%%

trace = SiMREPS_trace_simulator_mex(20,64.1,0.05);
[YPred,score] = classify(rnnNet,reshape(trace(1,:),d,[]));
figure(2)
plot(trace(1,:))
title(num2str(mean(score(:,1))))