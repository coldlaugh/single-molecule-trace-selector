%    ________________________________________________
%   /                                                \
%  (     Validate FRET histogram for cnn and rnn      )
%   \________________________________________________/


read = @(loc) load(loc, '-mat');
token = 'HaMMy';
close all;
for expt = 1 : 1
    for condition = 1 : 1
        truthSegCell = {};
        cnnSegCell = {};
        rnnSegCell = {};
        crnnSegCell = {};
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        filename = "fileNames.mat";
        cnnfile = "test-simple-cnn.mat";
        rnnfile = "test-rnn-lstm.mat";
        segmentfile = "test-rnn-lstm-segment.mat";
        files = load(fullfile(exptFolder, filename),'-mat');
        cnnData = load(fullfile(exptFolder, cnnfile),'-mat');
        rnnData = load(fullfile(exptFolder, rnnfile),'-mat');
        segData = load(fullfile(exptFolder, segmentfile),'-mat');
        for i = 1 : length(files.testSet)
            if ~contains(files.testSet{i}, token)
                continue;
            end
            trace = read(fullfile(files.serialFolder,strcat(files.testSet{i},files.serialFormat)));
            if contains(files.testSet{i},'accepted')
                seg = [];
                for j = 1 : length(trace.data)
                    if trace.data(3,j)
                        seg = [seg;j trace.data(1,j) trace.data(2,j) trace.data(2,j)/(trace.data(1,j)+trace.data(2,j))];
                    elseif ~isempty(seg)
                        truthSegCell{end+1} = seg;
                        seg = [];
                    end
                end
            end
            if cnnData.testLabel(i)==1
                seg = [];
                for j = 1 : length(trace.data)
                    if j > length(segData.testLabel{i}) * segData.numStack
                        continue;
                    end
                    if segData.testLabel{i}(ceil(j / segData.numStack))
                        seg = [seg;j trace.data(1,j) trace.data(2,j) trace.data(2,j)/(trace.data(1,j)+trace.data(2,j))];
                    elseif ~isempty(seg)
                        cnnSegCell{end+1} = seg;
                        seg = [];
                    end
                end
            end
            if rnnData.testLabel(i)==1
                seg = [];
                for j = 1 : length(trace.data)
                    if j > length(segData.testLabel{i}) * segData.numStack
                        continue;
                    end
                    if segData.testLabel{i}(ceil(j / segData.numStack))
                        seg = [seg;j trace.data(1,j) trace.data(2,j) trace.data(2,j)/(trace.data(1,j)+trace.data(2,j))];
                    elseif ~isempty(seg)
                        rnnSegCell{end+1} = seg;
                        seg = [];
                    end
                end
            end
            if rnnData.testLabel(i)==1 && cnnData.testLabel(i)==1
                seg = [];
                for j = 1 : length(trace.data)
                    if j > length(segData.testLabel{i}) * segData.numStack
                        continue;
                    end
                    if segData.testLabel{i}(ceil(j / segData.numStack))
                        seg = [seg;j trace.data(1,j) trace.data(2,j) trace.data(2,j)/(trace.data(1,j)+trace.data(2,j))];
                    elseif ~isempty(seg)
                        crnnSegCell{end+1} = seg;
                        seg = [];
                    end
                end
            end
        end
        fret_hist(truthSegCell);
        fig = figure(1); title("Ground Truth"); saveas(fig, fullfile(exptFolder, strcat(token, '_FRET_hist_truth.fig')));
        close 1; close 2;
        fret_hist(cnnSegCell);
        fig = figure(1); title("Conv. Neural Net"); saveas(fig, fullfile(exptFolder, strcat(token, '_FRET_hist_cnn-simple.fig')));
        close 1; close 2;
        fret_hist(rnnSegCell);
        fig = figure(1); title("Recur. Neural Net"); saveas(fig, fullfile(exptFolder, strcat(token, '_FRET_hist_rnn.fig')));
        close 1; close 2;
        fret_hist(crnnSegCell);
        fig = figure(1); title("Conv. + Recur. Neural Net"); saveas(fig, fullfile(exptFolder, strcat(token, '_FRET_hist_cnn_and_rnn.fig')));
        close 1; close 2;
        pause()
    end
end

