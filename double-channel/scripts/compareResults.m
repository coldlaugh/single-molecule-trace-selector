%% compare testing results

for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        cnnFile = "test-simple-cnn.mat";
        rnnFile = "test-rnn-lstm.mat";
        rnnSegFile = "test-rnn-lstm-segment-weighted.mat";
        fileName = "fileNames.mat";
        fileData = load(fullfile(exptFolder, fileName), '-mat');
        label = ~contains(fileData.testSet, 'rejected');
        cnnData = load(fullfile(exptFolder, cnnFile),'-mat');
        rnnData = load(fullfile(exptFolder, rnnFile),'-mat');
        segData = load(fullfile(exptFolder, rnnSegFile),'-mat');
        disp("============================");
        disp(exptFolder);
        disp('cnn vs truth:');
        compare(cnnData.testLabel==1, label');
        disp('rnn vs truth:');
        compare(rnnData.testLabel==1, label');
        disp('cnn vs rnn:')
        compare(cnnData.testLabel==1, rnnData.testLabel==1);
        disp('cnn && rnn vs truth:')
        compare(cnnData.testLabel==1 & rnnData.testLabel==1, label');
        pause;
    end
end

function compare(testLabel, trueLabel)
        tn = sum((~testLabel) & (~trueLabel));
        tp = sum((testLabel) & (trueLabel));
        fn = sum((~testLabel) & (trueLabel));
        fp = sum((testLabel) & (~trueLabel));
        disp(strcat('condordance = ',  num2str( (tn+tp) / (tn+tp+fn+fp)) ));
        disp(strcat('sensitivity = ',  num2str(tp / (tp + fn)) ))
        disp(strcat('specifity = ', num2str(tn / (tn + fp)) ))
        disp(strcat('precision = ', num2str(tp / (tp + fp)) ))
end