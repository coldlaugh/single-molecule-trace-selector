%% Construct a LSTM network with an image input.
numHiddenUnits = 100;
numClasses = 2;
layers =[
    imageInputLayer([2,3000,1],'Name','input layer')
    img2seqLayer(30,'Name','img2seq')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ]