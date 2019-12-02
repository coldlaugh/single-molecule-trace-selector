function z = regionalPropose(x,varargin)
    p = inputParser;
    addOptional(p,'delay',2);
    addOptional(p,'strength',0.1);
    addOptional(p,'tolframe',3);
    parse(p,varargin{:});
    strength = p.Results.strength;
    delay = p.Results.delay;
    tol = p.Results.tolframe;
    z = 0 * x;
    m = 0;
    mframe = 0;
    frameMem = zeros(100,1);
    isOn = false;
    i = 1;
    while i <= length(x)
        if isOn
            if x(i) >= cutoff(m,isOn,strength,delay) 
                z(i) = 1;
                m = m + 1;
                i = i + 1;
                mframe = 0;
            else
                mframe = mframe + 1;
                if mframe > tol || x(i) <= cutoff(m,~isOn,strength,delay)
                    isOn = false;
                    m = 0;
                    i = i + 1;
                    z(frameMem(frameMem>0)) = 0;
                    if i > 3
                        z([i-3,i-2,i-1]) = 0; % for safety, exclude the last two frame from selection.
                    end
                else
                    z(i) = 1;
                    frameMem(mframe) = i; 
                    i = i + 1;
                end
            end  
        else
            if x(i) <= cutoff(m,isOn,strength,delay)
                z(i) = 0;
                m = m + 1;
                i = i + 1;
                mframe = 0;         
            else
                mframe = mframe + 1;
                if mframe > tol || x(i) >= cutoff(m,~isOn,strength,delay)
                    z(i) = 1;
                    isOn = true;
                    i = i + 1;
                    z(frameMem(frameMem>0)) = 1;
                    m = 0;
                else
                    frameMem(mframe) = i;
                    i = i + 1;
                end
            end
        end
    end
    
    
    
end


function z = cutoff(m,isOn,strength,delay)
    if isOn
        z = 0.5 - strength * sig(m,[1/delay,delay]);
    else
        z = 0.5 + strength * sig(m,[1/delay,delay]);
    end
end

function z = sig(x,c)
    z = 1./(1 + exp(-c(1)*(x-c(2))));
end