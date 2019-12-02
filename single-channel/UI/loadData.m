% This function load ".mat" data that are generated from the movie files

function [XMat,XGrnMat,XRedMat,XFMat,YMat] = loadData(varargin)
    p =inputParser;
    addOptional(p,'testdata',false);
    addOptional(p,'BalanceEachLabel',true);
    parse(p,varargin{:})
    if ~p.Results.testdata
        [mat_files, path, fi] = uigetfile('*Train*.mat','MultiSelect','on');
    else
        [mat_files, path, fi] = uigetfile('*Test*.mat','MultiSelect','on');
    end
    if ~iscell(mat_files)
        mat_files = {mat_files};
    end
    
%     n = 0;
%     for i = 1 : length(mat_files)
%         A = load(strcat(path,mat_files{i}));
%         for j = 1 : length(A.XMat)
%             if ~isempty(A.XMat{j})
%                 n = n + 1;
%             end
%         end
%     end
    
    XMat = cell(10,1);
    XGrnMat = cell(10,1);
    XRedMat = cell(10,1);
    XFMat = cell(10,1);
    YMat = zeros(10,1);
    
    n = 0;
    for i = 1 : length(mat_files)
        A = load(strcat(path,mat_files{i}));      
        for j = 1 : length(A.XMat)
            if ~isempty(A.XMat{j})
                n = n + 1;
                m = max(conv(A.XGrnMat{j}+A.XRedMat{j},[1/6,1/6,1/3,1/6,1/6],'valid'));  
                XMat{n} = A.XMat{j};  %FRET signal
                XGrnMat{n} = A.XGrnMat{j}/m;  %Green light signal
                XRedMat{n} = A.XRedMat{j}/m;  %Red light signal
%                 XGrnMat{n} = conv(A.XGrnMat{j},[1/6,1/6,1/3,1/6,1/6],'valid')/m;  %Green light signal
%                 XRedMat{n} = conv(A.XRedMat{j},[1/6,1/6,1/3,1/6,1/6],'valid')/m;  %Red light signal
                filter = [-1/18,-1/18,-1/9,-1/9,0,1/9,1/9,1/18,1/18];
                XFMat{n} = conv(A.XMat{j},filter,'valid');  %edge of FRET signal
                YMat(n) = A.YMat(j);  %true label
            end
        end
    end
    
    if p.Results.BalanceEachLabel
        n = sum(YMat);
        ch = [true(1,4*n+5),false(1,length(XMat)-(4*n+5))];
        ch = ch(randperm(length(ch))) & (YMat == 0);
        XMat = [XMat(YMat == 1);XMat(ch)];
        XGrnMat = [XGrnMat(YMat == 1);XGrnMat(ch)];
        XRedMat = [XRedMat(YMat == 1);XRedMat(ch)];
        XFMat = [XFMat(YMat == 1);XFMat(ch)];
        YMat = [YMat(YMat == 1);YMat(ch)];
    end

end
