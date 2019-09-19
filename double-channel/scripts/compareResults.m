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
        disp('cnn:');
        tn = sum((~cnnData.testLabel) & (~label'));
        tp = sum((cnnData.testLabel) & (label'));
        fn = sum((~cnnData.testLabel) & (label'));
        fp = sum((cnnData.testLabel) & (~label'));
        disp(strcat('condordance = ',  num2str( (tn+tp) / (tn+tp+fn+fp)) ));
        disp(strcat('sensitivity = ',  num2str(tp / (tp + fn)) ))
        disp(strcat('specifity = ', num2str(tn / (tn + fp)) ))
        disp(strcat('precision = ', num2str(tp / (tp + fp)) ))
        disp('rnn:');
        tn = sum((~rnnData.testLabel) & (~label'));
        tp = sum((rnnData.testLabel) & (label'));
        fn = sum((~rnnData.testLabel) & (label'));
        fp = sum((rnnData.testLabel) & (~label'));
        disp(strcat('condordance = ',  num2str( (tn+tp) / (tn+tp+fn+fp)) ));
        disp(strcat('sensitivity = ',  num2str(tp / (tp + fn)) ))
        disp(strcat('specifity = ', num2str(tn / (tn + fp)) ))
        disp(strcat('precision = ', num2str(tp / (tp + fp)) ))
        pause;
    end
end