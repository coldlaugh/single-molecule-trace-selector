disp("Begin to train CNN for each experiments")

%% Data Path Setup
settings = jsondecode(fileread('settings.json'));
exptRootFolder = fullfile(settings.workingDir, settings.exptFolder);

%%

for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = fullfile(exptRootFolder,strcat('experiment', num2str(condition),'-',num2str(expt),'/'));
        disp("* Training " + exptFolder)
        train_CNN_func(exptFolder);
    end
end

%Uncomment if need to shutdown computer after training

%system('shutdown -s')