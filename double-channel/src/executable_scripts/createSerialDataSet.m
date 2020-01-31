% Create labeled serial dataset from trace data
disp("Creating labeled serial dataset from trace data")

%% Data Path Setup
settings = jsondecode(fileread('settings.json'));
folder = fullfile(settings.workingDir,settings.traceFolder);
pattern = '*.mltraces';
files = dir(fullfile(folder,pattern));
outputDir = fullfile(settings.workingDir,settings.serialFolder);
dropoutRejected = 1;

%% Create images and organize them into folders
for i = 1 : length(files)
    file = files(i);
    dump = load(fullfile(file.folder,file.name),'-mat','traces');
    trace = dump.traces;
    if ~trace.islabeled
        disp(strcat(" -- Skipping trace dataset ",file.name,": Dataset is not labeled"));
        continue
    end
    for j = 1 : size(trace.donor,1)
        [~,rawName,~] = fileparts(file.name);
        if (length(trace.donor(j,:)) <= 1000)
            continue;
        end
        if (length(trace.donor(j,:)) >= 5000)
            trace.donor(j,1:5000) = trace.donor(j,1:5000);
            trace.acceptor(j,1:5000) = trace.acceptor(j,1:5000);
            trace.time = trace.time(1:5000);
            trace.label(j,1:5000) = trace.label(j,1:5000);
        end
        if any(trace.label(j,:))
            outputPath = strcat(outputDir,'accepted/');
        elseif (rand() < dropoutRejected)
            outputPath = strcat(outputDir,'rejected/');
        else
            continue;
        end
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
        data = [
            trace.donor(j,:); 
            trace.acceptor(j,:);
            trace.label(j,1 : length(trace.acceptor(j,:)))
            ];
        outputName = fullfile(outputPath,strcat(rawName,'-',num2str(j),'.mat'));
        save(outputName,'data');
    end
end


