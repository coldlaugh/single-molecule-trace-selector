read = @(loc)load(loc,'data');
for i = randperm(length(dataset.testSet))
    data = read(fullfile(dataset.serialFolder, strcat(dataset.testSet{i},dataset.serialFormat)));
    data = data.data;
    normFactor = 1 / max([conv(data(1,:),[1/3,1/3,1/3],'same')+conv(data(2,:),[1/3,1/3,1/3],'same')]);
    label = data(3,:);
    traceOriginal = data;
    data = normFactor * [
        reshape(data(1,1:end-mod(end,numStack)),numStack,[]);
        reshape(data(2,1:end-mod(end,numStack)),numStack,[])
        ];
    trace = data;
    figure(3);cla;
    plot(traceOriginal(1,:),'g-');
    hold on;
    plot(traceOriginal(2,:),'r-');
    [pred, score] = classify(rnnNet, trace, 'ExecutionEnvironment', computeEnv, 'MiniBatchSize', batchSize, 'SequenceLength', options.SequenceLength);
    plot(linspace(1,numStack * length(score), length(score)), (pred == "1") / normFactor,'b.-');
    plot(label / normFactor * 0.9,'k.-');
    pause;
end