for i = 1 : length(XTest)
    if any(YTest{i} == "1")
        figure(1);cla;hold on;
        plot(reshape(XTest{i}(1:numStack,:),1,[]),'r-');
        plot(reshape(XTest{i}(numStack+1:2*numStack,:),1,[]),'b-');
        pred = classify(rnnNet, XTest{i}, 'ExecutionEnvironment', computeEnv, 'SequenceLength', options.SequenceLength);
        plot([1:numStack:numStack*length(pred)],pred(:) == "1",'m-');
        plot([1:numStack:numStack*length(YTest{i})],YTest{i}(:) == "1",'b-');
        pause()
    end
end