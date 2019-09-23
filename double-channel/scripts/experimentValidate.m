% Validate experiments and save the results

if gpuDeviceCount()
    computeEnv = 'gpu';
else
    computeEnv = 'cpu';
end

%% simple CNN
%    ________________________________________________
%   /                                                \
%  (                   Simple CNN                     )
%   \________________________________________________/
inputSize = [32,32,3];
read = @(loc)(imresize(imread(loc),inputSize(1:2)));

for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        userMsg = waitbar(0,strcat('Testing simple CNN in ', exptFolder),'Name','Test');
        netFile = fullfile(exptFolder, "cnn-simple.mat");
        nameFile = fullfile(exptFolder, "fileNames.mat");
        dump = load(netFile, '-mat');
        cnnNet = dump.cnnNet;
        dataset = load(nameFile, '-mat');
        testLabel = zeros(length(dataset.testSet),1);
        testScore = zeros(length(dataset.testSet),1);
        for i = 1 : length(dataset.testSet)
            img = read(fullfile(dataset.imgFolder, strcat(dataset.testSet{i},dataset.imgFormat)));
            [pred, score] =classify(cnnNet, img, 'ExecutionEnvironment', computeEnv);
            testLabel(i) = (pred == "1");
            testScore(i) = score(1);
            waitbar(i / length(dataset.testSet), userMsg);
        end
        saveFile = fullfile(exptFolder, "test-simple-cnn.mat");
        save(saveFile, 'testLabel', 'testScore');
        close(userMsg);
    end
end


%% RNN-LSTM
%    ________________________________________________
%   /                                                \
%  (                    RNN-LSTM                      )
%   \________________________________________________/
read = @(loc)load(loc,'data');
numStack = 10;

for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        userMsg = waitbar(0,strcat('Testing rnn LSTM in ', exptFolder),'Name','Test');
        netFile = fullfile(exptFolder, "rnn-LSTM.mat");
        nameFile = fullfile(exptFolder, "fileNames.mat");
        dump = load(netFile, '-mat');
        rnnNet = dump.rnnNet;
        dataset = load(nameFile, '-mat');
        testLabel = zeros(length(dataset.testSet),1);
        testScore = zeros(length(dataset.testSet),1);
        for i = 1 : length(dataset.testSet)
            data = read(fullfile(dataset.serialFolder, strcat(dataset.testSet{i},dataset.serialFormat)));
            data = data.data;
            normFactor = 1 / max([conv(data(1,:),[1/3,1/3,1/3],'same')+conv(data(2,:),[1/3,1/3,1/3],'same')]);
            data = normFactor * [
                reshape(data(1,1:end-mod(end,numStack)),numStack,[]);
                reshape(data(2,1:end-mod(end,numStack)),numStack,[])
                ];
            [pred, score] = classify(rnnNet, data, 'ExecutionEnvironment', computeEnv);
            testLabel(i) = (pred == "1");
            testScore(i) = score(1);
            waitbar(i / length(dataset.testSet), userMsg);
        end
        saveFile = fullfile(exptFolder, "test-rnn-lstm.mat");
        save(saveFile, 'testLabel', 'testScore');
        close(userMsg);
    end
end


%% RNN-LSTM-Segment
%    ________________________________________________
%   /                                                \
%  (                  RNN-LSTM-Segment                )
%   \________________________________________________/
read = @(loc)load(loc,'data');
numStack = 10;

for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        userMsg = waitbar(0,strcat('Testing rnn LSTM in ', exptFolder),'Name','Test');
        netFile = fullfile(exptFolder, "rnn-LSTM-segment-weighted.mat");
        nameFile = fullfile(exptFolder, "fileNames.mat");
        dump = load(netFile, '-mat');
        rnnNet = dump.rnnNet;
        dataset = load(nameFile, '-mat');
        testLabel = cell(length(dataset.testSet),1);
        testScore = cell(length(dataset.testSet),1);
        for i = 1 : length(dataset.testSet)
            data = read(fullfile(dataset.serialFolder, strcat(dataset.testSet{i},dataset.serialFormat)));
            data = data.data;
            normFactor = 1 / max([conv(data(1,:),[1/3,1/3,1/3],'same')+conv(data(2,:),[1/3,1/3,1/3],'same')]);
            data = normFactor * [
                reshape(data(1,1:end-mod(end,numStack)),numStack,[]);
                reshape(data(2,1:end-mod(end,numStack)),numStack,[])
                ];
            [pred, score] = classify(rnnNet, data, 'ExecutionEnvironment', computeEnv);
            testLabel{i} = (pred == "1");
            testScore{i} = score(1,:);
            waitbar(i / length(dataset.testSet), userMsg);
        end
        saveFile = fullfile(exptFolder, "test-rnn-lstm-segment-weighted.mat");
        save(saveFile, 'testLabel', 'testScore', 'numStack');
        close(userMsg);
    end
end

system('shutdown -s')