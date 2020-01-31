%% compare testing results

for expt = 1 : 10
    for condition = 1 : 2
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
        disp('cnn vs truth:')
        compare(cnnData.testLabel==1, label');
        disp('rnn vs truth:')
        compare(rnnData.testLabel==1, label');
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
        disp(" " + "tp" + " " + "fn")
        disp(" " + "fp" + " " + "tn")
        disp(" " + tp + " " + fn)
        disp(" " + fp + " " + tn)
        disp(strcat('condordance = ',  num2str( (tn+tp) / (tn+tp+fn+fp)) ));
        disp(strcat('sensitivity = ',  num2str(tp / (tp + fn)) ))
        disp(strcat('specifity = ', num2str(tn / (tn + fp)) ))
        disp(strcat('precision = ', num2str(tp / (tp + fp)) ))
end