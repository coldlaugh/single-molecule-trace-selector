%% Main Entrance

% Check MATLAB version

if verLessThan('matlab','9.6')
    warning(strcat('Training CNN Requires MATLAB Version R2019a or Above. ',...
        + ' You Are Running an Old MATLAB Version.'))
elseif verLessThan('matlab','9.4')
    error(strcat('The Script Requires MATLAB Version R2018a or Above. ',...
        + ' You Are Running an Old MATLAB Version. Please Upgrade To R2019a or Above.'))
end


location = mfilename('fullpath');
cd(fileparts(mfilename('fullpath')));


disp("==============================")
disp("===Select a script to run===")
disp("==============================")
disp("1. Setup Training Data")
disp("2. Training: CNN")
disp("3. Training: LSTM")
disp("4. Training: LSTM Segmentation")
disp("5. Validating: Test Trained Nets On Testing Dataset")

choice = input('Your Choice: ');

switch choice
    case 1
        createSerialDataSet();
        createImgDataSetFromSerial();
        experimentSetup();
    case 2
        train_CNN()
    case 3
        train_RNN()
    case 4
        train_RNN_Segment()
    case 5
        experimentValidate()
end