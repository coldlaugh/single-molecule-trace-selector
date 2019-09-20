%    ________________________________________________
%   /                                                \
%  (     Validate FRET histogram for cnn and rnn      )
%   \________________________________________________/


read = @(loc) load(loc, '-mat');
token = 'W6';
for expt = 1 : 10
    for condition = 1 : 2
        truthSegCell = {};
        cnnSegCell = {};
        rnnSegCell = {};
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
            if cnnData.testLabel(i)
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
            if rnnData.testLabel(i)
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
        end
        fret_hist(truthSegCell);
        fret_hist(cnnSegCell);
        fret_hist(rnnSegCell);
    end
end

