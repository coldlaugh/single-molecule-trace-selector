%    ________________________________________________
%   /                                                \
%  (     Plot Segmented traces by cnn and rnn         )
%   \________________________________________________/


read = @(loc) load(loc, '-mat');
for expt = 1 : 10
    for condition = 1 : 2
        tnc = 0; tpc = 0; fnc = 0; fpc = 0;
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        filename = "fileNames.mat";
        segmentfile = "test-rnn-lstm-segment.mat";
        files = load(fullfile(exptFolder, filename),'-mat');
        segData = load(fullfile(exptFolder, segmentfile),'-mat');
        for i = 1 : length(files.testSet)
            trace = read(fullfile(files.serialFolder,strcat(files.testSet{i},files.serialFormat)));
            segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
            [tn, tp, fn, fp] = compare(segLabel==1, trace.data(3,:)==1);
            tnc = tnc + tn; tpc = tpc + tp;
            fnc = fnc + fn; fpc = fpc + fp;
        end
        disp("============================");
        disp(exptFolder);
        disp("rnn segmentation:")
        disp_result(tnc, tpc, fnc, fpc)
        pause
    end
end

function label = flatten(trace, segLabel, numStack)
    n = length(trace);
    label = zeros(1, n);
    for i = 1 : length(segLabel) * numStack
        label(i) = segLabel(ceil(i / numStack)) == 1;
    end
end

function [tn, tp, fn, fp] = compare(testLabel, trueLabel)
        tn = sum((~testLabel) & (~trueLabel));
        tp = sum((testLabel) & (trueLabel));
        fn = sum((~testLabel) & (trueLabel));
        fp = sum((testLabel) & (~trueLabel));
end

function disp_result(tn, tp, fn, fp)
        disp(strcat('condordance = ',  num2str( (tn+tp) / (tn+tp+fn+fp)) ))
        disp(strcat('sensitivity = ',  num2str(tp / (tp + fn)) ))
        disp(strcat('specifity = ', num2str(tn / (tn + fp)) ))
        disp(strcat('precision = ', num2str(tp / (tp + fp)) ))
end

