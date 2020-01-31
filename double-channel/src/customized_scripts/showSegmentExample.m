%    ________________________________________________
%   /                                                \
%  (     Plot Segmented traces by cnn and rnn         )
%   \________________________________________________/


read = @(loc) load(loc, '-mat');
token = 'rib';
% close all;
for expt = 1 : 1
    for condition = 1 : 1
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        filename = "fileNames.mat";
        cnnfile = "test-simple-cnn.mat";
        rnnfile = "test-rnn-lstm.mat";
        segmentfile = "test-rnn-lstm-segment-weighted.mat";
        files = load(fullfile(exptFolder, filename),'-mat');
        cnnData = load(fullfile(exptFolder, cnnfile),'-mat');
        rnnData = load(fullfile(exptFolder, rnnfile),'-mat');
        segData = load(fullfile(exptFolder, segmentfile),'-mat');
        for i = 1 : length(files.testSet)
            if ~contains(files.testSet{i}, token)
                continue;
            end
            if ~ (rnnData.testLabel(i) || cnnData.testLabel(i) || contains(files.testSet{i},'accepted'))
                continue;
            end  
%             if ~ (rnnData.testLabel(i) && cnnData.testLabel(i))
%                 continue;
%             end
            trace = read(fullfile(files.serialFolder,strcat(files.testSet{i},files.serialFormat)));
            figure(1);cla;clf;hold on;
            if contains(files.testSet{i},'accepted')
                disp("Showing ground truth")
                subplot(4,1,1); hold on;
                plot_trace(trace.data, trace.data(3,:));
                title("Showing ground truth")
            end
            if cnnData.testLabel(i)
                disp("Showing cnn result")
                subplot(4,1,2); hold on;
                segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
                plot_trace(trace.data, segLabel)
                title("Showing cnn result")
            end
            if rnnData.testLabel(i)
                disp("Showing rnn result")
                subplot(4,1,3); hold on;
                segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
                plot_trace(trace.data, segLabel)
                title("Showing rnn result")
            end
            if rnnData.testLabel(i) && cnnData.testLabel(i)
                disp("Showing cnn + rnn result")
                subplot(4,1,4); hold on;
                segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
                plot_trace(trace.data, segLabel)
                title("Showing cnn + rnn result")
            end
            pause()
        end
    end
end

function label = flatten(trace, segLabel, numStack)
    n = length(trace);
    label = zeros(1, n);
    for i = 1 : length(segLabel) * numStack
        label(i) = segLabel(ceil(i / numStack)) == 1;
    end
end

function plot_trace(trace, segLabel)
    frame = 1 : length(trace);
    segLabel = boolean(segLabel);
    p = plot(frame, trace(1,:),'b--');
    if ~isempty(p)
        p.Color(4) = 0.2;
    end
    p = plot(frame, trace(2,:),'r--');
    if ~isempty(p)
        p.Color(4) = 0.2;
    end
    frame(~segLabel) = nan;
    trace(:,~segLabel) = nan;
    p = plot(frame, trace(1,:),'b-');
    if ~isempty(p)
        p.Color(4) = 1;
    end
    p = plot(frame, trace(2,:),'r-');
    if ~isempty(p)
        p.Color(4) = 1;
    end
%     xlim()
end

