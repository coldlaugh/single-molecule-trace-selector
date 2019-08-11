%% README
% In this script, we will use simreps data to train a LSTM nerual net
% that distinguish target signal from noise signal.
% 
% Leyou Zhang, Apr/25/2019

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
    bilstmLayer(numHiddenUnits,'OutputMode','last') % classify based on the final feature frame
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
miniBatchSize = 200;
initLearnRate = 0.002;
learnResource = 'cpu' % Choose between 'cpu' and 'gpu'.
options = trainingOptions('adam',...
    'InitialLearnRate',initLearnRate,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'L2Regularization',0.001,...
    'GradientThreshold',0.1,...
    'Plots','training-progress',...
    'ExecutionEnvironment',learnResource);

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


