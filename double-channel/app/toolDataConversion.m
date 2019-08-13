classdef toolDataConversion < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        DataConversionToolUIFigure  matlab.ui.Figure
        SaveAllButton               matlab.ui.control.Button
        AssignLabelsoptionalButton  matlab.ui.control.Button
        AssigningLabelsPanel        matlab.ui.container.Panel
        HumanSelectedTraceSegmentsdatfilesListBoxLabel  matlab.ui.control.Label
        HumanSelectedTraceListBox   matlab.ui.control.ListBox
        AddFilesFoldersButton       matlab.ui.control.Button
        DeleteFileButton_2          matlab.ui.control.Button
        ShowPathCheckBox_2          matlab.ui.control.CheckBox
        RawDataPanel                matlab.ui.container.Panel
        AddFilesButton              matlab.ui.control.Button
        DeleteFileButton            matlab.ui.control.Button
        ShowPathCheckBox            matlab.ui.control.CheckBox
        DataFilesListBoxLabel       matlab.ui.control.Label
        DataFilesListBox            matlab.ui.control.ListBox
        ProcessDataButton           matlab.ui.control.Button
    end


    properties (Access = private)
        windowOpened = {} % Description
        fileLoaded = {}% Description
        labelLoaded = {} % Description
        isLabeled = false % Description
        tracesData = {} % Description
        labelData = {} % Description
    end

    methods (Access = public)
    
        function FilePickerReturned(app, event, callbackFcn, files)
            newEvent = struct();
            newEvent.Source = event.Source;
            newEvent.Files = files;
            callbackFcn(app, newEvent);
        end
        
    end

    methods (Access = private)
    
        function traces = loadRawTrace(app, file)
            fid = fopen(file,'r', 'ieee-le');
            len = fread(fid, 1, 'int32');
            Ntraces = fread(fid, 1, 'int16');
            raw = fread(fid,(Ntraces+1)*len,'int16');
            fclose(fid);
            raw = reshape(raw,Ntraces+1,len);
            time = raw(1,:);
            data = raw(2:end,:);
            idonor = 1:2:size(data,1);
            iacceptor = 2:2:size(data,1);
            donor = data(idonor,:);
            acceptor = data(iacceptor,:);
            traces = struct();
            traces.file = file;
            traces.count = size(donor,1);
            traces.time = time;
            traces.donor = donor;
            traces.acceptor = acceptor - 0.09 * donor;
            traces.label = zeros(size(donor));
            traces.islabeled = false;
        end
        
        function traces = loadRawDat(app, file)
            dat = dlmread(file);
            traces.donor = dat(:,2);
            traces.acceptor = dat(:,3);
            traces.file = file;
        end
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.AssigningLabelsPanel.Visible = 'off';
        end

        % Button pushed function: AddFilesButton, 
        % AddFilesFoldersButton
        function AddFilesButtonPushed(app, event)
            if event.Source == app.AddFilesButton
                if isfield(event,'Files')
                    for i = 1 : length(event.Files)
                        if isfile(event.Files{i})
                            if app.ShowPathCheckBox.Value
                                app.DataFilesListBox.Items{end+1} = event.Files{i};
                            else
                                [~,f,ext]=fileparts(event.Files{i});
                                 app.DataFilesListBox.Items{end+1} = strcat(f,ext);
                            end
                            app.DataFilesListBox.ItemsData(end+1) = length(app.DataFilesListBox.Items);
                            app.fileLoaded{end+1} = event.Files{i};
                        end
                    end
                else
                    f = toolFilePicker(app, event, @AddFilesButtonPushed);
                    app.windowOpened{end+1} = f;
                end
            end
            if event.Source == app.AddFilesFoldersButton
                if isfield(event,'Files')
                    for i = 1 : length(event.Files)
                        if isfolder(event.Files{i}) || isfile(event.Files{i})
                            if app.ShowPathCheckBox_2.Value 
                                app.HumanSelectedTraceListBox.Items{end+1} = event.Files{i};
                            else
                                [~,f,ext]=fileparts(event.Files{i});
                                if isempty(ext)
                                    ext = '/..';
                                end
                                app.HumanSelectedTraceListBox.Items{end+1} = strcat(f,ext);
                            end                            
                            app.HumanSelectedTraceListBox.ItemsData(end+1) = length(app.HumanSelectedTraceListBox.Items);
                            app.labelLoaded{end+1} = event.Files{i};
                        end
                    end
                else
                    f = toolFilePicker(app, event, @AddFilesButtonPushed);
                    app.windowOpened{end+1} = f;
                end
            end
            
        end

        % Close request function: DataConversionToolUIFigure
        function DataConversionToolUIFigureCloseRequest(app, event)
            for i = 1 : length(app.windowOpened)
                if isvalid(app.windowOpened{i})
                    delete(app.windowOpened{i})
                end
            end
            delete(app)            
        end

        % Button pushed function: DeleteFileButton, DeleteFileButton_2
        function DeleteFileButtonPushed(app, event)
            if event.Source == app.DeleteFileButton
                value = app.DataFilesListBox.Value;
                if ~isempty(value)
                    app.DataFilesListBox.Items(value) = [];
                    app.DataFilesListBox.ItemsData(end) = [];
                    app.fileLoaded(value) = [];
                end
            end
            if event.Source == app.DeleteFileButton_2
                value = app.HumanSelectedTraceListBox.Value;
                if ~isempty(value)
                    app.HumanSelectedTraceListBox.Items(value) = [];
                    app.HumanSelectedTraceListBox.ItemsData(end) = [];
                    app.labelLoaded(value) = [];
                end
            end
            
        end

        % Button pushed function: AssignLabelsoptionalButton
        function AssignLabelsoptionalButtonPushed(app, event)
            app.AssigningLabelsPanel.Visible = 'on';
            app.isLabeled = true;
        end

        % Value changed function: ShowPathCheckBox, ShowPathCheckBox_2
        function ShowPathCheckBoxValueChanged(app, event)
            if event.Source == app.ShowPathCheckBox
                value = app.ShowPathCheckBox.Value;
                if value
                    app.DataFilesListBox.Items = app.fileLoaded;
                else
                    
                    for i = 1 : length(app.fileLoaded)
                        [~,f,ext] = fileparts(app.fileLoaded{i});
                        app.DataFilesListBox.Items{i} = [f,ext];
                    end
                end
            elseif event.Source == app.ShowPathCheckBox_2
                value = app.ShowPathCheckBox_2.Value;
                if value
                    app.HumanSelectedTraceListBox.Items = app.labelLoaded;
                else
                    
                    for i = 1 : length(app.labelLoaded)
                        [~,f,ext] = fileparts(app.labelLoaded{i});
                        if isempty(ext)
                            ext = '/..';
                        end
                        app.HumanSelectedTraceListBox.Items{i} = strcat(f,ext);
                    end
                end
            end
        end

        % Button pushed function: ProcessDataButton
        function ProcessDataButtonPushed(app, event)

            pb = uiprogressdlg(app.DataConversionToolUIFigure,'Title','Please Wait',...
                   'Message','Converting Raw Data');
            app.tracesData = {};
            for i = 1 : length(app.fileLoaded)
                app.tracesData{i} = loadRawTrace(app, app.fileLoaded{i});
                pb.Value = i / length(app.fileLoaded);
            end
            close(pb)
            
            pb = uiprogressdlg(app.DataConversionToolUIFigure,'Title','Please Wait',...
                   'Message','Converting Label Data');
            app.labelData = {} ;
            for i = 1 : length(app.labelLoaded)
                file = app.labelLoaded{i};
                if isfile(file)
                    app.labelData{end+1} = loadRawDat(app, app.labelLoaded{i});
                elseif isfolder(file)
                    content = dir(file);
                    for j = 1 : length(content)
                        if ~content(j).isdir
                            [~,~,ext] = fileparts(content(j).name);
                            if strcmp(ext,'.dat')
                                app.labelData{end+1} = loadRawDat(app, ...
                                    fullfile(content(j).folder,content(j).name));
                            end
                        end
                    end
                end
                pb.Value = i / length(app.labelLoaded);
            end
            close(pb)
            
            pb = uiprogressdlg(app.DataConversionToolUIFigure,'Title','Please Wait',...
                   'Message','Matching Raw Traces To Label Data');
            nMatch = 0;
            
            dataFiles = cell(size(app.fileLoaded));
            for i = 1 : length(app.fileLoaded)
                [~,f] = fileparts(app.fileLoaded{i});
                dataFiles{i} = f;
            end
            [~,itrace] = sort(dataFiles);
            labelFiles = cell(length(app.labelData),1);
            for i = 1 : length(app.labelData)
                [~,f] = fileparts(app.labelData{i}.file);
                labelFiles{i} = f;
            end
            [~,ilabel] = sort(labelFiles);
            
            % Name based matching
            dTime = 30;
            for i = 1 : length(app.tracesData)
                traces = app.tracesData{itrace(i)};
                tic
                for j = 1 : traces.count
                    for k = 1 : length(ilabel)
                        
                        if mod(k,10) == 1
                            pb.Message = strcat('Matching Raw Traces To Label Data (', ...
                                    num2str(nMatch),' Traces Matched)',...
                                    '(',num2str(round((1.3*length(app.tracesData)-i)*mean(dTime)/60)),'min remaining)');
                        end  
                        
                        label = app.labelData{ilabel(k)};
                        [~,ftrace,~] = fileparts(traces.file);
                        [~,flabel,~] = fileparts(label.file);
                        z = strfind(flabel,ftrace);
                        if z
                            zdonor = findSequence_mex(conv(traces.donor(j,:),[-1,1],'valid'),...
                            conv(label.donor,[-1,1],'valid'));
                            if ~isempty(zdonor)
                                zacceptor = findSequence_mex(conv(traces.acceptor(j,:),[-1,1],'valid'),...
                                    conv(label.acceptor,[-1,1],'valid'));
                            end
                            if ~isempty(zdonor) && ~isempty(zacceptor) && abs(zdonor-zacceptor)<2
                                zend = zdonor + length(label.donor);
                                traces.label(j,zdonor:zend) = 1;
                                ilabel(k) = [];
                                traces.islabeled = true;
                                nMatch = nMatch + 1;
                                pb.Value = nMatch / length(labelFiles);
                                break
                            end
                        end                        
                    end
                end
                dTime(end+1) = toc;
                app.tracesData{itrace(i)} = traces;
            end
            
            % Data based matching
            dTime = dTime(end);
            for i = 1 : length(app.tracesData)
                traces = app.tracesData{itrace(i)};
                tic
                for j = 1 : traces.count
                    for k = 1 : length(ilabel)
                        
                        if mod(k,10) == 1
                            pb.Message = strcat('Final Checking (', ...
                                    num2str(nMatch),' Traces Matched)',...
                                    '(',num2str(round((length(app.tracesData)-i)*mean(dTime)/60)),'min remaining)');
                        end
                        
                        label = app.labelData{ilabel(k)};
                        zdonor = findSequence_mex(conv(traces.donor(j,:),[-1,1],'valid'),...
                            conv(label.donor,[-1,1],'valid'));
                        if ~isempty(zdonor)
                            zacceptor = findSequence_mex(conv(traces.acceptor(j,:),[-1,1],'valid'),...
                                conv(label.acceptor,[-1,1],'valid'));
                        end
                        if ~isempty(zdonor) && ~isempty(zacceptor) && abs(zdonor-zacceptor)<2
                            zend = zdonor + length(label.donor);
                            traces.label(j,zdonor:zend) = 1;
                            traces.islabeled = true;
                            ilabel(k) = [];
                            nMatch = nMatch + 1;
                            pb.Value = nMatch / length(labelFiles);
                            break
                        end
                    end
                end
                dTime(end+1) = toc;
                app.tracesData{itrace(i)} = traces;
            end
            pb.Message = strcat('Finished: ', num2str(nMatch),' label data are matched with raw traces.');
            pause(3);
            pb.Value = 1;
            close(pb)
            
            app.SaveAllButton.Enable = 'on';
        end

        % Button pushed function: SaveAllButton
        function SaveAllButtonPushed(app, event)
            pb = uiprogressdlg(app.DataConversionToolUIFigure,'Title','Please Wait');
            pb.Message = strcat('Saving Converted Data To Traces File Locations');
            for i = 1 : length(app.tracesData)
                traces = app.tracesData{i};
                [folder,file,~] = fileparts(traces.file);
                save(strcat(folder,'/',file,'.mltraces'),'traces','-mat');
                pb.Value = i / length(app.tracesData);
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create DataConversionToolUIFigure
            app.DataConversionToolUIFigure = uifigure;
            app.DataConversionToolUIFigure.Position = [100 100 952 616];
            app.DataConversionToolUIFigure.Name = 'Data Conversion Tool';
            app.DataConversionToolUIFigure.CloseRequestFcn = createCallbackFcn(app, @DataConversionToolUIFigureCloseRequest, true);

            % Create SaveAllButton
            app.SaveAllButton = uibutton(app.DataConversionToolUIFigure, 'push');
            app.SaveAllButton.ButtonPushedFcn = createCallbackFcn(app, @SaveAllButtonPushed, true);
            app.SaveAllButton.BackgroundColor = [0.4706 0.6706 0.1882];
            app.SaveAllButton.FontColor = [1 1 1];
            app.SaveAllButton.Enable = 'off';
            app.SaveAllButton.Position = [841 40 100 22];
            app.SaveAllButton.Text = 'Save All';

            % Create AssignLabelsoptionalButton
            app.AssignLabelsoptionalButton = uibutton(app.DataConversionToolUIFigure, 'push');
            app.AssignLabelsoptionalButton.ButtonPushedFcn = createCallbackFcn(app, @AssignLabelsoptionalButtonPushed, true);
            app.AssignLabelsoptionalButton.BackgroundColor = [0.4706 0.6706 0.1882];
            app.AssignLabelsoptionalButton.FontColor = [1 1 1];
            app.AssignLabelsoptionalButton.Position = [18 33 100 36];
            app.AssignLabelsoptionalButton.Text = {'Assign Labels'; '(optional)'};

            % Create AssigningLabelsPanel
            app.AssigningLabelsPanel = uipanel(app.DataConversionToolUIFigure);
            app.AssigningLabelsPanel.Title = 'Assigning Labels';
            app.AssigningLabelsPanel.Position = [484 77 457 530];

            % Create HumanSelectedTraceSegmentsdatfilesListBoxLabel
            app.HumanSelectedTraceSegmentsdatfilesListBoxLabel = uilabel(app.AssigningLabelsPanel);
            app.HumanSelectedTraceSegmentsdatfilesListBoxLabel.HorizontalAlignment = 'right';
            app.HumanSelectedTraceSegmentsdatfilesListBoxLabel.Position = [20 466 249 22];
            app.HumanSelectedTraceSegmentsdatfilesListBoxLabel.Text = 'Human Selected Trace Segments (*.dat files) ';

            % Create HumanSelectedTraceListBox
            app.HumanSelectedTraceListBox = uilistbox(app.AssigningLabelsPanel);
            app.HumanSelectedTraceListBox.Items = {};
            app.HumanSelectedTraceListBox.Position = [20 42 418 425];
            app.HumanSelectedTraceListBox.Value = {};

            % Create AddFilesFoldersButton
            app.AddFilesFoldersButton = uibutton(app.AssigningLabelsPanel, 'push');
            app.AddFilesFoldersButton.ButtonPushedFcn = createCallbackFcn(app, @AddFilesButtonPushed, true);
            app.AddFilesFoldersButton.Position = [20 8 109 22];
            app.AddFilesFoldersButton.Text = 'Add Files/Folders';

            % Create DeleteFileButton_2
            app.DeleteFileButton_2 = uibutton(app.AssigningLabelsPanel, 'push');
            app.DeleteFileButton_2.ButtonPushedFcn = createCallbackFcn(app, @DeleteFileButtonPushed, true);
            app.DeleteFileButton_2.Position = [128 8 100 22];
            app.DeleteFileButton_2.Text = 'Delete File';

            % Create ShowPathCheckBox_2
            app.ShowPathCheckBox_2 = uicheckbox(app.AssigningLabelsPanel);
            app.ShowPathCheckBox_2.ValueChangedFcn = createCallbackFcn(app, @ShowPathCheckBoxValueChanged, true);
            app.ShowPathCheckBox_2.Text = 'Show Path';
            app.ShowPathCheckBox_2.Position = [376 8 80 22];

            % Create RawDataPanel
            app.RawDataPanel = uipanel(app.DataConversionToolUIFigure);
            app.RawDataPanel.Title = 'Raw Data';
            app.RawDataPanel.Position = [18 77 457 530];

            % Create AddFilesButton
            app.AddFilesButton = uibutton(app.RawDataPanel, 'push');
            app.AddFilesButton.ButtonPushedFcn = createCallbackFcn(app, @AddFilesButtonPushed, true);
            app.AddFilesButton.Position = [20 8 100 22];
            app.AddFilesButton.Text = 'Add Files';

            % Create DeleteFileButton
            app.DeleteFileButton = uibutton(app.RawDataPanel, 'push');
            app.DeleteFileButton.ButtonPushedFcn = createCallbackFcn(app, @DeleteFileButtonPushed, true);
            app.DeleteFileButton.Position = [119 8 100 22];
            app.DeleteFileButton.Text = 'Delete File';

            % Create ShowPathCheckBox
            app.ShowPathCheckBox = uicheckbox(app.RawDataPanel);
            app.ShowPathCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowPathCheckBoxValueChanged, true);
            app.ShowPathCheckBox.Text = 'Show Path';
            app.ShowPathCheckBox.Position = [376 8 80 22];

            % Create DataFilesListBoxLabel
            app.DataFilesListBoxLabel = uilabel(app.RawDataPanel);
            app.DataFilesListBoxLabel.HorizontalAlignment = 'right';
            app.DataFilesListBoxLabel.Position = [20 466 59 22];
            app.DataFilesListBoxLabel.Text = 'Data Files';

            % Create DataFilesListBox
            app.DataFilesListBox = uilistbox(app.RawDataPanel);
            app.DataFilesListBox.Items = {};
            app.DataFilesListBox.Position = [20 42 418 425];
            app.DataFilesListBox.Value = {};

            % Create ProcessDataButton
            app.ProcessDataButton = uibutton(app.DataConversionToolUIFigure, 'push');
            app.ProcessDataButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessDataButtonPushed, true);
            app.ProcessDataButton.BackgroundColor = [0.851 0.3294 0.102];
            app.ProcessDataButton.FontColor = [1 1 1];
            app.ProcessDataButton.Position = [722 40 100 22];
            app.ProcessDataButton.Text = 'Process Data';
        end
    end

    methods (Access = public)

        % Construct app
        function app = toolDataConversion

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.DataConversionToolUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.DataConversionToolUIFigure)
        end
    end
end