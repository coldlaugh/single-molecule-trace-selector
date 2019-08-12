function z = findSequence(x,y)
%     p = inputParser;
%     addOptional(p,'SignalTol',0.5);
%     addOptional(p,'FrameTol',10);
%     parse(p,varargin{:});
    if length(x) > length(y)
%         signalTol = p.Results.SignalTol;
%         frameTol = p.Results.FrameTol;
        signalTol = 0.5;
        frameTol = 10;
        i = 1;
        j = 1;
        miss = 0;
        i0 = 1;
        z = [];
        while i <= length(x) 
            if abs(x(i)-y(j)) <= signalTol
                if j == length(y)
                    z = i0;
                    break;
                end
                i = i + 1;
                j = j + 1;
            elseif miss <= frameTol && j>1
                if j == length(y)
                    z = i0;
                    break;
                end
                i = i + 1;
                j = j + 1;
                miss = miss + 1;
            else
                i0 = i0 + 1;
                i = i0;
                j = 1;
                miss = 0;
            end
        end
        
    else
        z = [];
    end
end