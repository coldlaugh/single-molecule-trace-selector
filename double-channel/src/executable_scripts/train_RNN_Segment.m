disp("Begin to train LSTM segmentation for each experiments")

%% Data Path Setup
settings = jsondecode(fileread('settings.json'));
exptRootFolder = fullfile(settings.workingDir, settings.exptFolder);

%%
for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = fullfile(exptRootFolder,strcat(num2str(condition),'-',num2str(expt),'/'));
        disp("* Training " + exptFolder)
        train_RNN_segment_func(exptFolder);
    end
end