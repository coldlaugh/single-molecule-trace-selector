%    ________________________________________________
%   /                                                \
%  (     Plot Segmented traces by cnn and rnn         )
%   \________________________________________________/


read = @(loc) load(loc, '-mat');
token = 'W7';
close all;
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
            if ~ (rnnData.testLabel(i) && cnnData.testLabel(i))
                continue;
            end
            trace = read(fullfile(files.serialFolder,strcat(files.testSet{i},files.serialFormat)));
%             if contains(files.testSet{i},'accepted')
%                 disp("Showing ground truth")
%                 plot_trace(trace.data, trace.data(3,:));
%             end
%             if cnnData.testLabel(i)
%                 disp("Showing cnn result")
%                 segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
%                 plot_trace(trace.data, segLabel)
%             end
%             if rnnData.testLabel(i)
%                 disp("Showing rnn result")
%                 segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
%                 plot_trace(trace.data, segLabel)
%             end
            if rnnData.testLabel(i) && cnnData.testLabel(i)
                disp("Showing cnn + rnn result")
                segLabel = flatten(trace.data, segData.testLabel{i}, segData.numStack);
                plot_trace(trace.data, segLabel)
            end
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
    figure(1);cla;hold on;
    frame = 1 : length(trace);
    segLabel = boolean(segLabel);
    p = plot(frame, trace(1,:),'b--');
    p.Color(4) = 0.1;
    p = plot(frame, trace(2,:),'r--');
    p.Color(4) = 0.1;
    p = plot(frame(segLabel), trace(1,segLabel),'b-');
    p.Color(4) = 0.8;
    p = plot(frame(segLabel), trace(2,segLabel),'r-');
    p.Color(4) = 0.8;
    xlim([0 2000])
    pause
end

