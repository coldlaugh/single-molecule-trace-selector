%% COMPILING FUNCTIONS
if exist('codegen')
    disp("==================== COMPLIING FUNCTIONS ====================")
    fprintf(" * Trace Simulator Function  ---  in progress\n")
    simreps_trace_simulator_make();
    fprintf("\b\b\b\b\b\b\b\b\b\b\b\bDone\n")
    disp("==================== FINISHED ====================")
end

%% TESTING WITH SIMULATED TRACES
if ~exist('rnnNet','var') %% check if rnnNet has been loaded
    errMsg = "Variable rnnNet does not exist. Please load trained RNN first";
    error(errMsg);
end
if exist('trace_simulator_mex')
    disp("Compiled simulator is found. Using compiled trace simulator");
    simulator_func = @trace_simulator_mex;
else
    disp("Compiled simulator is not found. Using script trace simulator")
    simulator_func = @trace_simulator;
end

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
    [TRACE_SIM,nbd,tauon,tauoff] = simulator_func(tau_on,tau_off,0.2); % tau_on/tau_off/noise level
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