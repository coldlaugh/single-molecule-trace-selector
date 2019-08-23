% smFRET Trace Simulation Routine
% Generates simulated smFRET traces with specified number of states, number
% of molecules, donor and acceptor photobleaching probabilities per frame,
% total fluorescent counts, and noise level.  The transition probabilities
% and FRET values for each state are generated randomly (currently using a
% gamma distribution to avoid negative or very large values).
% Alex Johnson-Buck, 3/8/2011-11/21/2017
% clear all
% close all
% f = waitbar(0,'Simulating traces');
function simulateTrace()

for experiment = 1 : 1000
    % Number of FRET states (excluding photobleached state)
    Ns = randi(1)+1;

    % Number of molecules to simulate
    Nmol = 10;

    % Plot all traces (1 = yes, 0 = no)?
    save_traces = 1;

    gamma = 1; % Ratio of Cy5 intensity under 100% FRET to Cy3 intensity under no FRET. (Simulates differences in quantum yield, detector efficiency, etc.)

    totcounts = 1000; %Total intensity counts for Cy5 in high-FRET state (Cy3 intensity is determined based on totcounts, FRET, and gamma).
    frames = 4000; %Number of frames
    noise = random('Uniform',0.05,0.2)*totcounts; % Noise level (currently a constant multiple of totcounts, and independent of channel)

    %Define transition probabilities between states (if they don't add up to
    %100%, they will be renormalized automatically)

    % Donor and acceptor photobleaching probabilities
    Pbleach_d = 1/1000;
    Pbleach_a = 1/1000;

    % Generate random transition probability matrix
    % Pmat = random('Gamma',2,0.006,Ns,Ns);
    % Pmat = random('exp',0.05,Ns,Ns);
    Pmat = random('uniform',0.005,0.03,Ns,Ns);
    % Structure of transition probability matrix 
    % 
    % 1-sum P21  0     0     0
    % P12  1-sum 0     0     0
    % Px   Px    1-sum 0     0
    % Py   Py    0     1-sum 0
    % 0    0     Py    Px    1

    % Append bleaching transition probabilities to bottom of rate constant matrix
    pbleachmat = cat(1,Pbleach_d*ones(1,Ns),Pbleach_a*ones(1,Ns),zeros(1,Ns));
    Pmat = cat(1,Pmat,pbleachmat);

    % Append bleached molecule transition probabilities to right of matrix
    pbleachmat = cat(1,zeros(Ns,3),zeros(2,3),[Pbleach_a Pbleach_d 1]);
    Pmat = cat(2, Pmat, pbleachmat);

    % Set diagonal values to 0
    for m = 1:Ns+3
        Pmat(m,m) = 0;
    end

    % Set diagonal values to 1 - (sum of all other elements in column)
    for m = 1:Ns+3
        Pmat(m,m) = 1-sum(Pmat(:,m));
    end

    % Generate random FRET states
    states = random('Uniform',0,1,Ns,1); % Generate donor values
    states = sort(states); % Sort from smallest to largest
    if (states(end) - states(1) < 0.4)
        continue;
    end
    states = cat(2,states,1-states);
    states = cat(1,states,[0 1; 1 0; 0 0]);
    states = states*totcounts;
    
    
    P = Pmat;
    for m = 1:size(Pmat,1)
        P(m,:) = sum(Pmat(1:m,:),1);
    end


    fret_true = zeros(frames,1);
    acceptor_true = fret_true;
    donor_true = fret_true;

    traces_donor = zeros(Nmol,frames);
    traces_acceptor = traces_donor;
    
    for molnum = 1:Nmol

    k = randi([1,Ns-1]); % Select random initial state
    fret_true(1,1) = states(k,1);
    acceptor_true(1,1) = states(k,2);
    donor_true(1,1) = states(k,1)/gamma;
%     fret_true(1,1) = acceptor_true(1,1)/(acceptor_true(1,1)+donor_true(1,1));
    switch_count = 0;
    for frame = 2:frames
        decider = random('Uniform',0,1);
        chosen = 0; % Next state not chosen
        for n = 1:size(P,1)
            if chosen == 0
                if decider <= P(n,k)
                    if (k ~= n)
                        switch_count = switch_count + 1;
                    end
                    k = n; % next state is n
                    chosen = 1; % choice has been made
                    break;
                end
            end
        end
        acceptor_true(frame,1) = states(k,2);
        donor_true(frame,1) = states(k,1)/gamma;
    %     fret_true(1,1) = acceptor_true(1,1)/(acceptor_true(1,1)+donor_true(1,1));
    end
    
    if (switch_count < 10)
        continue;
    end
    % plot(fret_true);

    acceptor = acceptor_true + random('normal',0,noise,frames,1);
    donor = donor_true + random('normal',0,noise,frames,1);

    baseline = min([acceptor;donor]);
    if (baseline < 0)
        acceptor = acceptor - baseline;
        donor = donor - baseline;
    end
    selection = (acceptor_true>0) & (donor_true>0);
    FRET = acceptor./(donor+acceptor);
    
    if save_traces==1
%         waitbar(experiment/100,f,'Simulating traces');
        path = '../data/images/accepted-simulated/';
        trace = [donor acceptor selection];
        symbols = ['a':'z' 'A':'Z' '0':'9'];
        MAX_ST_LENGTH = 10;
        stLength = randi(MAX_ST_LENGTH)+3;
        nums = randi(numel(symbols),[1 stLength]);
        st = symbols (nums);
        loc = strcat(path,'simulatedTrace_',st,'.jpg');
        trace2img([donor acceptor],loc);
%         save(loc,'trace');
    end
    
    traces_donor(molnum,:) = donor';
    traces_acceptor(molnum,:) = acceptor';
    end
    
end

% close(f);

