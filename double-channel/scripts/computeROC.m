%% compare testing results

for condition = 1 : 2
    fpr_cnn = [];
    tpr_cnn = [];
    fpr_rnn = [];
    tpr_rnn = [];
    for expt = 1 : 10
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        cnnFile = "test-simple-cnn.mat";
        rnnFile = "test-rnn-lstm.mat";
        fileName = "fileNames.mat";
        fileData = load(fullfile(exptFolder, fileName), '-mat');
        label = ~contains(fileData.testSet, 'rejected');
        cnnData = load(fullfile(exptFolder, cnnFile),'-mat');
        rnnData = load(fullfile(exptFolder, rnnFile),'-mat');
        disp("============================");
        disp(exptFolder);
        [tpr,fpr] = roc(cnnData.testScore, label);
        tpr_cnn = [tpr_cnn tpr];
        fpr_cnn = [fpr_cnn fpr];
        [tpr,fpr] = roc(rnnData.testScore, label);
        tpr_rnn = [tpr_rnn tpr];
        fpr_rnn = [fpr_rnn fpr];
    end
    figure(condition); cla; hold on;
    plot(mean(fpr_cnn, 2), mean(tpr_cnn, 2), 'r-');
    plot(mean(fpr_rnn, 2), mean(tpr_rnn, 2), 'g-');
    legend('CNN','LSTM');
    title(strcat("condition ", num2str(condition)));
    disp("Condition: " + condition);
    disp("AOC of cnn:");   
    disp(aoc(mean(fpr_cnn, 2), mean(tpr_cnn, 2)));
    disp("AOC of rnn:");
    disp(aoc(mean(fpr_rnn, 2), mean(tpr_rnn, 2)));
end

function [tpr, fpr] = roc(score, label)
    n_roc = 10000;
    tn = zeros(n_roc, 1);
    tp = zeros(n_roc, 1);
    fn = zeros(n_roc, 1);
    fp = zeros(n_roc, 1);
    count = 0;
    for p = linspace(0,1,n_roc)
        count = count + 1;
        tn(count) = sum((score < p) & (~label'));
        tp(count) = sum((score > p) & (label'));
        fn(count) = sum((score < p) & (label'));
        fp(count) = sum((score > p) & (~label'));
    end
    fpr = fp ./ (tn + fp);
    tpr = tp ./ (tp + fn);
end

function s = aoc(fpr, tpr)
    n_interp = 10000;
    [fpr, index] = unique(fpr);
    tpr = tpr(index);
    value = interp1(fpr, tpr, linspace(0,1,n_interp));
    s = sum(value) / n_interp;
end