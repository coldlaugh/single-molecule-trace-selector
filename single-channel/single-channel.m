%% README
% In this script, we will use simreps data to train a LSTM nerual net
% that distinguish target signal from noise signal.
% 
% Leyou Zhang, Apr/25/2019

%% COMPILING FUNCTIONS
disp("==================== COMPLIING FUNCTIONS ====================")
fprintf(" * Trace Simulator Function\n")
simreps_trace_simulator_make();
fprintf("\b  ---  Done\n")
disp("==================== FINISHED ====================")

%% DATA LOADING

disp("==================== DATA LOADING ====================")
disp("")

folder = 'SiMREPSdata/';

filesMUT = {'RE12_50fM-1_whole_traces.mat';
    'RE12_50fM-2_whole_traces.mat';
    'RE12_50fM-3_whole_traces.mat';
    '50 fM MUT n1.tif_whole_traces.mat';
    '50 fM MUT n2.tif_whole_traces.mat';
    '50 fM MUT n3.tif_whole_traces.mat';
    };
filesWT = {
    '50 nM WT n1.tif_whole_traces.mat';
    '50 nM WT n2.tif_whole_traces.mat';
    '50 nM WT n3.tif_whole_traces.mat';
    '50 nM WT n4.tif_whole_traces.mat';
    'RE12_NDC-1_whole_traces';
    'RE12_NDC-2_whole_traces';
    'RE12_NDC-3_whole_traces';
    
};

disp('LOADING THE FOLLOWING FILES AS MUTANT DATA:');
MUT = [];
for i = 1 : length(filesMUT)
    fprintf(strcat(" * ",filesMUT{i}))
    tracesMUT = load(strcat(folder,filesMUT{i}));
    if isempty(MUT)
        MUT = tracesMUT.traces;
    else
        MUT = [MUT;tracesMUT.traces];
    end
    fprintf(strcat(" ---- ", num2str(size(tracesMUT.traces,1))," Traces Loaded\n"));
end


disp('LOADING THE FOLLOWING FILES AS WILD TYPE DATA:');
WT = [];
for i = 1 : length(filesWT)
    fprintf(strcat(" * ",filesWT{i}))
    tracesWT = load(strcat(folder,filesWT{i}));
    if isempty(WT)
        WT = tracesWT.traces;
    else
        WT = [WT;tracesWT.traces];
    end
    fprintf(strcat(" ---- ", num2str(size(tracesWT.traces,1))," Traces Loaded\n"));
end
disp("")
disp("==================== DATA LOADING ENDED ====================")

%% DATA NORMALIZATION

disp("==================== NORMALIZING DATA ====================")

n_MUT = size(MUT,1); %% number of mutant traces
n_WT = size(WT,1); %% number of wild type traces
n = n_MUT + n_WT; %% total number of traces
d = 20; % bin size for LSTM 
frame = size(WT,2); % number of frames for one trace
l = frame / d; % length of trace after binning
class = {'MUT','WT'}; % give a name for each class
X = cell(n,1); % Data variable
Y = cell(n,1); % Target variable

for i = 1 : n_MUT  % Appending mutant data to X, Y
    X{i} = (MUT(i,:) - mean(MUT(i,:))) /std(MUT(i,:)); % nomalization
    X{i} = reshape(X{i},d,[]);
    Y{i} = class{1};
end

for i = n_MUT + 1 : n  % Appending wild type data to X, Y
    j = i - size(MUT,1);
    X{i} = (WT(j,:) - mean(WT(j,:))) /std(WT(j,:)); % nomalization
    X{i} = reshape(X{i},d,[]);
    Y{i} = class{2};
end

Y = categorical(Y); 

fprintf("Prepared %i traces in mutant group and %i traces in wild type group\n"...
    ,sum(Y == "MUT"), sum(Y == "WT") );

disp("==================== NORMALIZION FINISHED====================")
%% INITIALIZE LSTM 

disp("==================== INITIALIZE LSTM ====================")

inputSize = d ;  % the dimension of the smFRET traces
numHiddenUnits = 1000; % the num of hidden units
numClasses = length(class); % number of classes
weight = [1,100]; % weight for the two classes
rnnLayers = [...
    sequenceInputLayer(inputSize)
    %bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','last') % classify based on the final feature frame
%     fullyConnectedLayer(numHiddenUnits)
%     reluLayer
%     dropoutLayer(0.5)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    simrepsClassificationLayer("Weighted Loss",weight) % weighted loss function
    ];  % the layers of RNN

disp("==================== INITIALIZATION FINISHED====================")
%% NETWORK STRUCTURE CHECK
% comment the following line if you want to skip the checking
analyzeNetwork(rnnLayers)
%% TRAINING THE LSTM

disp("==================== TRAINING THE LSTM ====================")
maxEpochs = 100;
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
disp("==================== TRAINING FINISHED ====================")
%% RESULTS
disp("==================== VISUALIZING TRAINING RESULTS ====================")

[YPred,score] = classify(rnnNet,X,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu'); %predict
accuracy = sum(YPred == Y) ./ numel(Y); %Accuracy
plotconfusion(Y,YPred);
[confMat,label] = confusionmat(Y,YPred); % The confusion matrix

disp("==================== VISUALIZATION FINISHED FINISHED ====================")
%% ANALYSIS
disp("==================== ANALYZING RESULTS ====================")
disp("Press up/down/left/right to navigate through pages");
nshow = 10; % number of traces on one page
[~,order] = sort(score(:,1),'descend'); % sort scores 
order = order(order<=size(MUT,1)); % grab only mutant data
fig = figure(1);
key = '';
PlotTraces(X, score, order, nshow, "");
set(fig,'KeyPressFcn',@(src,event)PlotTraces(X, score, order, nshow, event.Key));

disp("==================== ANALYSIS FINISHED ====================")
%% TEST ON INDEPENDENT DATA
disp("==================== TESTING NEW DATA ====================")
disp("")

folder = 'SiMREPSdata/';

filesMUT_TEST = {};
filesWT_TEST = {
'50 nM WT n5.tif_whole_traces.mat';
'50 nM WT n6.tif_whole_traces.mat';
'50 nM WT n7.tif_whole_traces.mat';
'50 nM WT n8.tif_whole_traces.mat';
};

disp('LOADING THE FOLLOWING FILES AS MUTANT DATA:');
MUT_TEST = [];
for i = 1 : length(filesMUT_TEST)
    fprintf(strcat(" * ",filesMUT_TEST{i}))
    tracesMUT = load(strcat(folder,filesMUT_TEST{i}));
    if isempty(MUT_TEST)
        MUT_TEST = tracesMUT.traces;
    else
        MUT_TEST = [MUT_TEST;tracesMUT.traces];
    end
    fprintf(strcat(" ---- ", num2str(size(tracesMUT.traces,1))," Traces Loaded\n"));
end


disp('LOADING THE FOLLOWING FILES AS WILD TYPE DATA:');
WT_TEST = [];
for i = 1 : length(filesWT_TEST)
    fprintf(strcat(" * ",filesWT_TEST{i}))
    tracesWT = load(strcat(folder,filesWT_TEST{i}));
    if isempty(WT_TEST)
        WT_TEST = tracesWT.traces;
    else
        WT_TEST = [WT_TEST;tracesWT.traces];
    end
    fprintf(strcat(" ---- ", num2str(size(tracesWT.traces,1))," Traces Loaded\n"));
end
disp("")

% Normalization

n_MUT_TEST = size(MUT_TEST,1); %% number of mutant traces
n_WT_TEST = size(WT_TEST,1); %% number of wild type traces
n_TEST = n_MUT_TEST + n_WT_TEST; %% total number of traces
X_TEST = cell(n_TEST,1); % Data variable
Y_TEST = cell(n_TEST,1); % Target variable

for i = 1 : n_MUT_TEST  % Appending mutant data to X, Y
    X_TEST{i} = (MUT_TEST(i,:) - mean(MUT_TEST(i,:))) / std(MUT_TEST(i,:)); % nomalization
    X_TEST{i} = reshape(X_TEST{i},d,[]);
    Y_TEST{i} = class{1};
end

for i = n_MUT_TEST + 1 : n_TEST  % Appending wild type data to X, Y
    j = i - size(MUT_TEST,1);
    X_TEST{i} = (WT_TEST(j,:) - mean(WT_TEST(j,:))) / std(WT_TEST(j,:)); % nomalization
    X_TEST{i} = reshape(X_TEST{i},d,[]);
    Y_TEST{i} = class{2};
end

Y_TEST = categorical(Y_TEST); 

fprintf("Prepared %i traces in mutant group and %i traces in wild type group\n"...
    ,sum(Y_TEST == "MUT"), sum(Y_TEST == "WT") );


[YPred,score] = classify(rnnNet,X_TEST,'MiniBatchSize',miniBatchSize,'ExecutionEnvironment','cpu'); %predict
plotconfusion(Y_TEST,YPred);
[confMat,label] = confusionmat(Y_TEST,YPred); % The confusion matrix

disp("==================== TESTING FINISHED ====================")

%% PLOT TEST RESULT
disp("==================== PLOTTING TEST RESULTS ====================")
disp("Press up/down/left/right to navigate through pages");
nshow = 10; % number of traces on one page
[~,order] = sort(score(:,1),'descend'); % sort scores 
fig2 = figure(2);
PlotTraces(X_TEST, score, order, nshow, "");
set(fig2,'KeyPressFcn',@(src,event)PlotTraces(X_TEST, score, order, nshow, event.Key));

disp("==================== PLOTTING FINISHED ====================")


%% TESTING WITH SIMULATED TRACES
disp("==================== TESTING WITH SIMULATED TRACES ====================")
f = waitbar(0,'Please wait...'); % progress bar
progress = 0;
ngrid = 500;
tauon_range = 100;
tauon_min = 0;
tauoff_range = 100;
tauoff_min = 0;
scoreAccept = [];
scoreReject = [];
nbdAccept = [];
nbdReject = [];
tauAccept = [];
tauReject = [];
tauoffAccept = [];
tauoffReject = [];
fprintf(" ");
for n1 = 1 : ngrid^2
    tau_on = tauon_min + tauon_range * rand();
    tau_off = tauoff_min + tauoff_range * rand();
    [TRACE_SIM,nbd,tauon,tauoff] = SiMREPS_trace_simulator_mex(tau_on,tau_off,0.2); % tau_on/tau_off/noise level
    waitbar(progress,f);
    
    n_SIM = size(TRACE_SIM,1);
    X_SIM = cell(n_SIM,1);
    Y_SIM = cell(n_SIM,1);

    for i = 1 : n_SIM  % mutent
        temp = (TRACE_SIM(i,:)-mean(TRACE_SIM(i,:)))/std(TRACE_SIM(i,:));
        X_SIM{i} = reshape(temp,d,[]);
    end
    
    [YPred,score] = classify(rnnNet,X_SIM,'ExecutionEnvironment','cpu');
    
    progress = progress + 1 / ngrid^2;
    waitbar(progress,f);
    
    accepted = (YPred == "MUT");
    rejected = (YPred == "WT");
    scoreAccept = [scoreAccept; score(accepted,1)];
    scoreReject = [scoreReject; score(rejected,1)];
    nbdAccept = [nbdAccept;nbd(accepted)];
    nbdReject = [nbdReject;nbd(rejected)];
    tauAccept = [tauAccept;tauon(accepted)];
    tauReject = [tauReject;tauon(rejected)];
    tauoffAccept = [tauoffAccept;tauoff(accepted)];
    tauoffReject = [tauoffReject;tauoff(rejected)];
    
    fprintf('\b');
    if mod(n1,4) == 0
        fprintf('\\');
    elseif mod(n1,4) == 1
        fprintf('|');
    elseif mod(n1,4) == 2
        fprintf('/');
    else
        fprintf('-');
    end
end
fprintf('\b\n')
close(f)
disp("==================== FINISHED TESTING ====================")
%% VISUALIZATION OF TEST RESULTS
disp("==================== VISUALIZAING TEST RESULTS ====================")

nbd = [nbdAccept;nbdReject];
tau = [tauAccept;tauReject];
tau_off =  [tauoffAccept;tauoffReject];
score = [scoreAccept;scoreReject];


figure(1)
clf;
histogram(tau,'BinWidth',2.5,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
hold on
histogram(tauAccept,'BinWidth',2.5,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
legend('All','ML Accepted')
xlabel \tau_{on}
ylabel count
xlim([0 300]);
title("Counting of Accepted Traces")

figure(2)
clf;
histogram(nbd,'BinWidth',1,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
hold on
histogram(nbdAccept,'BinWidth',1,'DisplayStyle','stairs','Normalization','count','LineWidth',2)
legend('All','ML Accepted')
xlabel N_{b+d}
ylabel count
xlim([0 200]);
title("Counting of Accepted Traces")

figure(3);
clf;
hold on;
binWidth = [2,4];
tauRange = [5:binWidth(1):100];
nbdRange = [1:binWidth(2):100];
Z = zeros(length(tauRange),length(nbdRange));


for i = 1 : length(tauRange)
    for j = 1 : length(nbdRange)
        ga = tauAccept>(tauRange(i)-binWidth(1)/2) & tauAccept<(tauRange(i)+binWidth(1)/2)...
            & nbdAccept>(nbdRange(j)-binWidth(2)/2) & nbdAccept<(nbdRange(j)+binWidth(2)/2);
        g = tau>(tauRange(i)-binWidth(1)/2) & tau<(tauRange(i)+binWidth(1)/2)...
            & nbd>(nbdRange(j)-binWidth(2)/2) & nbd<(nbdRange(j)+binWidth(2)/2);
        Z(i,j) = sum(ga(:))/max(sum(g(:)),1);
    end
end

imagesc(tauRange,nbdRange,Z')
xlim(tauRange([1,end]))
ylim(nbdRange([1,end]))
colorbar
xlabel \tau_{on}
ylabel N_{b+d}
% plot(tauReject,nbdReject,'bo')
hold off
% set(gca,'xScale','log')
title("Acceptance Rate Heat Map");

figure(4)
clf;
plot(tauAccept,nbdAccept,'ro')
xlabel \tau_{on}
ylabel n_{b+d}
title("Scatter Plot of Accepted Traces");


figure(5);
clf;
hold on;

binWidth = [2,4];
tauRange = [5:binWidth(1):100];
nbdRange = [1:binWidth(2):100];

Z = zeros(length(tauRange),length(tauRange));
for i = 1 : length(tauRange)
    for j = 1 : length(tauRange)
        ga = tauAccept>(tauRange(i)-binWidth(1)/2) & tauAccept<(tauRange(i)+binWidth(1)/2)...
            & tauoffAccept>(tauRange(j)-binWidth(1)/2) & tauoffAccept<(tauRange(j)+binWidth(1)/2);
        g = tau>(tauRange(i)-binWidth(1)/2) & tau<(tauRange(i)+binWidth(1)/2)...
            & tau_off>(tauRange(j)-binWidth(1)/2) & tau_off<(tauRange(j)+binWidth(1)/2);
        Z(i,j) = sum(ga(:))/max(sum(g(:)),1);
    end
end

imagesc(tauRange,tauRange,Z')
xlim(tauRange([1,end]))
ylim(nbdRange([1,end]))
colorbar
xlabel \tau_{on}
ylabel \tau_{off}
title("Acceptance Rate Heat Map");

figure(6)
clf;
plot(tauAccept,tauoffAccept,'ro')
xlabel \tau_{on}
ylabel \tau_{off}
hold on;
x = 0:0.1:80;
for nb = 4:30
plot(x,1200/nb - x,'b-');
end
hold off
title("Scatter Plot of Accepted Traces");



disp("==================== VISUALIZATION FINISHIED ====================")
