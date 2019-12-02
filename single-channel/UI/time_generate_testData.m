

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Analyzes docking time traces of TIR   %
%                                        %
%  Xiaowei 10/99                         %
%  Rueda 2002-03-04                      %
%                                        %
%  Jan. 05, added nlfilter               %
%                                        %
% Sept 2009, added trace saving and hist %
%  - Alex Johnson-Buck                   %
%                                        %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Parameters to set **********************
skip = 1;

default_threshold = 300; % Minimum total counts needed (donor + acceptor) to consider trace.

% Parameters for estimating the number of molecules with donor, acceptor,
% or colocalized donor and acceptor.
donor_threshold = default_threshold;
acceptor_threshold = default_threshold;

% End of parameters to set *******************
answer = questdlg('Which .traces files would you like to load? (Multiple selection allowed)',...
    'Automatic traces selector',...
    'Select','Cancel','Select');

if ~strcmp(answer,'Select')
    return
end


% get movie files
[movie_files, path] = uigetfile('*.traces','select traces','MultiSelect','on');  


currentPath = pwd();


if ~iscell(movie_files)
    movie_files = {movie_files};
end

answer = questdlg('Which folder contains .dat files?','Automatic Trace Selector',...
    'Select','No .dat files','Cancel','Select');

if ~strcmp(answer,'Select')
    return
end

goodMolPath = uigetdir(path,'select folder with .dat files');
goodMolList = ls(strcat(goodMolPath,'/*.dat'));

threshold = inputdlg({['Intensity threshold for molecule/non-molecule (current value: ',num2str(default_threshold),'):']},...
    'Intensity threshold for molecule/non-molecule',...
    [1,100],...
    {num2str(default_threshold)});

threshold = str2double(threshold{1});


if isempty(threshold) == 1 || ischar(threshold) == 1
    threshold = default_threshold;
end

% set save directory
[saveFile,savePath] = uiputfile('*.mat','Set folder and prefix for saving data set','prefix');

if isequal(saveFile,0) || isequal(savePath,0)
   return
end

if ~exist(strcat(savePath,'goodMol'), 'dir')
    mkdir(strcat(savePath,'goodMol'));
end
if ~exist(strcat(savePath,'badMol'), 'dir')
    mkdir(strcat(savePath,'badMol'));
end


for fileId = 1 : length(movie_files)
    
    movie_file = movie_files{fileId};

    donor_offset = 0;

    acceptor_offset = 0;

%     warning off MATLAB:divideByZero;

    skip = 1;
    delay = 0;


    if isempty(skip)
        skip = 1;
    end
    
%     filename = strcat(path, movie_file(1:size(movie_file,2)-7), '.traces');
    filename = strcat(path, movie_file);
    fid = fopen(filename,'r', 'ieee-le');
    string2 = strcat(goodMolPath, '/', movie_file(1:size(movie_file,2)-7),'_');
    len = fread(fid, 1, 'int32');
    disp('===============================================');
    disp(strcat('The length of the time traces is:  ', num2str(len)));
    Ntraces = fread(fid, 1, 'int16');
    disp(['The number of traces is: ' num2str(Ntraces)])
    raw = fread(fid,(Ntraces+1)*len,'int16');
    fclose(fid);
    raw = reshape(raw,Ntraces+1,len);
    disp('Done reading data');
    
    %    disp(raw);

    index=(1:(Ntraces+1)*len);

    time1 = zeros(1,len);
    Data=zeros(Ntraces+1,len);
    donor=zeros(Ntraces/2,len);
    acceptor=zeros(Ntraces/2,len);
    fretE=zeros(Ntraces/2,len);

    time_1 = zeros(len,1);
    donor_1 = zeros(len,Ntraces/2);
    acceptor_1 = zeros(len,Ntraces/2);

    time=(0:(len-1));
    Data(index)=raw(index);
    time1(1,:) = Data(1,:);

    for i=1:(Ntraces/2)
        donor(i,:)=Data(i*2,:)-donor_offset;
        acceptor(i,:)=Data(i*2+1,:)-acceptor_offset;
    end
    
    quit_flag = false;
    th_int = [1 100];
    sumcounts = zeros(Ntraces/2);
    for m = 1:(Ntraces/2)
        if numel(donor(m,:))>th_int(2)
            sumcounts(m) = mean(donor(m,th_int(1):th_int(2))) + mean(acceptor(m,th_int(1):th_int(2)));
        else
            quit_flag = true;
            break
        end
    end
    
    if quit_flag
        continue
    end
    
    donor_interval = th_int;
    acceptor_interval = th_int;
    donor_spots = 0;
    acceptor_spots = 0;
    colocalized_spots = 0;
    donormean = zeros(Ntraces/2);
    acceptormean = zeros(Ntraces/2);
    
    for m = 1:Ntraces/2
        donormean(m) = mean(donor(m,donor_interval(1):donor_interval(2)));
        acceptormean(m) = mean(acceptor(m,acceptor_interval(1):acceptor_interval(2)));
        if donormean(m) > donor_threshold && acceptormean(m) > acceptor_threshold
            colocalized_spots = colocalized_spots+1;
        elseif donormean(m) > donor_threshold
            donor_spots = donor_spots+1;
        elseif acceptormean(m) > acceptor_threshold
            acceptor_spots = acceptor_spots+1;
        end
    end

    disp('Donor Only Molecules:');
    disp(num2str(donor_spots));
    disp('Acceptor Only Molecules:');
    disp(num2str(acceptor_spots));
    disp('Colocalized Molecules:');
    disp(num2str(colocalized_spots));

    

    


    savedTraces = zeros(len+1,0);

    m = 1;
    
    % save data
    
    XRed = cell(Ntraces/2,1);
    XGreenn = cell(Ntraces/2,1);
    YTimeMat = cell(Ntraces/2,1);
    YMat = zeros(Ntraces/2,1);
    
    acceptorData = cell(Ntraces/2,1);
    donorData = cell(Ntraces/2,1);
    YSequenceLabel = cell(Ntraces/2,1);
    YLabel = zeros(Ntraces/2,1);
    
    

    while (m <= (Ntraces/2)) && (m > 0)
        
        if m == 15
            disp('m=15')
        end
        
        donor_1 = donor(m,:)';
        acceptor_1 = acceptor(m,:)' - 0.09*donor_1;
        fret_1 = acceptor_1./(donor_1 + acceptor_1);
        
        if sumcounts(m) > threshold

            acceptorData{m} = acceptor_1(1:len);
            donorData{m} = donor_1(1:len);
            YSequenceLabel{m} = 0 * fret_1(1:len); 
            
            [textStart,textEnd] = regexp(goodMolList,strcat(regexptranslate('escape',string2),'(HaMMy_trace_)?',num2str(m),'_\d*.dat'));
            
            if ~isempty(textStart)
                
                YLabel(m) = 1;
                
                for nfile = 1:numel(textStart) % loop through all found files
                    thisFileName = goodMolList(textStart(nfile):textEnd(nfile)); % .dat file name for molecule m
                    traceData = dlmread(thisFileName);
                    timeStartAccept = findSequence(conv(donorData{m},[-1,1]),...
                        conv(traceData(:,2),[-1,1],'valid'));  % find matching sequence between .dat file and .traces file 
                    timeStartDonor = findSequence(conv(acceptorData{m},[-1,1]),...
                        conv(traceData(:,3),[-1,1],'valid'));  % conv by [-1,1] to eliminate effects of background noise.

                    if (~isempty(timeStartAccept) && ~isempty(timeStartDonor))
                        if timeStartAccept == timeStartDonor
                            startFrame = timeStartAccept - 1;
                            finalFrame = timeStartAccept + length(traceData) - 2;
                            YSequenceLabel{m}(startFrame:finalFrame) = 1;
                        else
                            disp('inconsistent matching occurred');
                        end
                    else
                        disp('matching not found');
                        YLabel(m) = -2; % label for traces whose .dat doesn't match .traces 
                    end
                end
            else
                YLabel(m) = 0; % label for unchosen molecules
            end
        else
            YLabel(m) = -1; % label for short traces < threshold
        end
        m = m + 1;
    end
    
    disp('Done preparing data');

    
    % postprocess and output
    erase = @(str1,str2) str1(1 : end - length(str2));
    for i = 1 : length(YLabel)
       if YLabel(i) == 1
            x = donorData{i};
            y = acceptorData{i};
            z = YSequenceLabel{i};
            trace = [x y z];
            loc = strcat(savePath,'goodMol/',erase(saveFile,'.mat'),'_',erase(movie_file,'.traces'),'_',num2str(i),'.mat');
            save(loc,'trace');
       elseif YLabel(i) == 0
            x = donorData{i};
            y = acceptorData{i};
            z = YSequenceLabel{i};
            trace = [x y z];
            loc = strcat(savePath,'badMol/',erase(saveFile,'.mat'),'_',erase(movie_file,'.traces'),'_',num2str(i),'.mat');
            save(loc,'trace');
       end
    end
    disp('Done saving data.');
    
    disp('===============================================');
end




