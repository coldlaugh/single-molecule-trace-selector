% smREPS Trace Simulation Routine
% Takes input intensity states and transition probabilities, gamma value, total
% fluorescence counts, frames, and noise level, and generates random smREPS
% traces.
% Alex Johnson-Buck, 3/19/2014
% clear all
% close all

% *******************Parameters to set*************************
function [traces,nbd,tauon,tauoff] = SiMREPS_trace_simulator(tau_on,tau_off,noise_level)
%noise_level = 0.15; % Noise level (currently a constant multiple of totcounts, and independent of channel)
totcounts = 1000; % Total intensity counts for fluorophore in bound state
frames = 1200; % Number of frames
N = 100; % Number of traces to simulate
exposure_time = 0.5; % Time corresponding to each movie frame

framerate = 1./exposure_time;

plotting = 0; % Plot individual traces?  Set = 1 for yes.

%Define bound state lifetimes, in seconds

% Lifetimes estimated from 3/3/2014 experiment in 4X PBS, let-7a, FP3
% tau_on = 17.8;
% tau_off = 35.5;

%tau_on = 30;
%tau_off = 100;

% Background spots
% tau_on = 500;
% tau_off = 500;

% *******************End of Parameters to Set*************************

noise = noise_level*totcounts; 

tau_on = tau_on./exposure_time; % Convert lifetimes to frames
tau_off = tau_off./exposure_time;

%Define intensity states
states = zeros(2);
states(1,1) = 1;
states(2,1) = 0;

%State 1

P11 = exp(-1/tau_on);
P12 = 1-P11;

%State 2

P22 = exp(-1/tau_off);
P21 = 1-P22;

P = [P11 P12; P21 P22];

traces = zeros(N,frames);
nbd = zeros(N,1);
tauon = zeros(N,1);
tauoff = zeros(N,1);

for i = 1:size(P,1)
    P(i,:) = P(i,:)./sum(P(i,:));
end

for m = 1:N
    
    bound_state_true = zeros(frames,1);
    
    k = unidrnd(2); % Start in random state k
    bound_state_true(1,1) = states(k,1);
    for frame = 2:frames
        decider = random('uniform',0,1);
        if decider <= P(k,1)
            k = 1;
            tauon(m) = tauon(m)+1;
        else
            k = 2;
            tauoff(m) = tauoff(m)+1;
        end
        bound_state_true(frame,1) = states(k,1);
        if bound_state_true(frame,1) ~=bound_state_true(frame-1,1)
            nbd(m) = nbd(m) + 1;
        end
    end
    
    % plot(bound_state_true);
    
    Ival = bound_state_true.*totcounts + normrnd(0,noise,frames,1);
    
%     if plotting == 1
%         figure(1)
%         plot(Ival,'k-');
%         % ylim([-0.25 1.25]);
%         pause(0.1);
%     end
    
    traces(m,:)=Ival;
    tauon(m) = exposure_time * tau_on; 
    tauoff(m) = exposure_time * tau_off;
%     if tauon(m) == 0 || tauon(m) > frames
%         tauon(m) = NaN;
%     end
%     if mod(m,50)==0
%         disp(num2str(m));
%     end
    
end

% figure(3)
% plot([1:frames]*exposure_time,traces(2,:));


% A = 'n';
% while strcmp(A,'y') ~= 1
%     disp('Please select the window for cross-correlation analysis.')
%     k = waitforbuttonpress;              % Hold program until user selects region
%     point1 = get(gca,'CurrentPoint');    % button down detected
%     finalRect = rbbox;                   % return figure units
%     point2 = get(gca,'CurrentPoint');    % button up detected
%     point1(1:2,1) = point1(1:2,1).*framerate;
%     point2(1:2,1) = point2(1:2,1).*framerate;
%     point1 = point1(1,1:2);              % extract x and y
%     point2 = point2(1,1:2);
%     p1 = min(point1,point2);             % calculate locations
%     offset = abs(point1-point2);         % and dimensions
%     x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
%     y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
%     sboxd{m} = horzcat(p1(1),p1(1)+offset(1));  % Store x min/max for later use.
%     hold on
%     axis manual
%     plot(x./framerate,y,'b','LineWidth',1) % redraw in dataspace units
%     hold off
%     t_1 = floor(sboxd{m}(1,1)');
%     t_2 = ceil(sboxd{m}(1,2)');
%     if t_2>size(traces(1,:),2)
%         t_2=size(traces(1,:),2);
%     end
%     A = input('satisfied with the window? y = yes, n= no,','s');
%     if isempty(A)
%         A='y';
%     end
% end
% if  t_1 < 1
%     n_1 = 1;
% else
%     n_1 = 1 + t_1;
% end
% if  t_2 < 1
%     n_2 = 1;
% else
%     n_2 = t_2;
% end
% if strcmp(A,'y')==1
%     N = xcorr(traces(1,n_1:n_2),traces(1,n_1:n_2),'unbiased');
%     N = N';
%     len2 = (size(N,1)+1)/2;
%     N1 = flipud(N(1:len2));
%     N2 = N(len2:len2*2-1);
%     Nav = (N1+N2)./2;
%     Nav = Nav-min(Nav(1:round(len2/2)));
%     Nav = Nav./max(Nav(1:round(len2/2)));
%     figure(2)
%     plot(0:1/framerate:(len2-1)*1/framerate,Nav,'k.-');
%     ylabel('Norm. Autocorrelation');
%     xlabel('Time (s)');
%     set(gca,'FontSize',16,'LineWidth',3);
%     ans6 = input('Fit cross-correlation curve (requires EZFit toolbox)?','s');
%     if strcmp(ans6,'y')==1
%         A = 'n';
%         while strcmp(A,'y') ~= 1
%             disp('Please select the window for cross-correlation analysis.')
%             k = waitforbuttonpress;              % Hold program until user selects region
%             point1 = get(gca,'CurrentPoint');    % button down detected
%             finalRect = rbbox;                   % return figure units
%             point2 = get(gca,'CurrentPoint');    % button up detected
%             point1(1:2,1) = point1(1:2,1).*framerate;
%             point2(1:2,1) = point2(1:2,1).*framerate;
%             point1 = point1(1,1:2);              % extract x and y
%             point2 = point2(1,1:2);
%             p1 = min(point1,point2);             % calculate locations
%             offset = abs(point1-point2);         % and dimensions
%             x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
%             y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
%             sboxd{m} = horzcat(p1(1),p1(1)+offset(1));  % Store x min/max for later use.
%             hold on
%             axis manual
%             plot(x./framerate,y,'b','LineWidth',2) % redraw in dataspace units
%             hold off
%             t_1 = floor(sboxd{m}(1,1)');
%             t_2 = ceil(sboxd{m}(1,2)');
%             if t_2>len2
%                 t_2=len2;
%             end
%             A = input('satisfied with the window? y = yes, n= no,','s');
%             if isempty(A)
%                 A='y';
%             end
%         end
%         if  t_1 < 1
%             n_1 = 1;
%         else
%             n_1 = 1 + t_1/1;
%         end
%         if  t_2 < 1
%             n_2 = 1;
%         else
%             n_2 = t_2/1;
%         end
%         xmin = n_1;
%         xmax = n_2;
%         figure(2)
%         plot((xmin-1)/framerate:1/framerate:(xmax-1)/framerate,Nav(xmin:xmax),'k.-','LineWidth',2,'MarkerSize',15);
%         ylabel('Norm. Autocorrelation');
%         xlabel('Time (s)');
%         xlim([(xmin-2)/framerate xmax/framerate]);
%         ylim([min(Nav(xmin:xmax))-0.1 max(Nav(xmin:xmax))+0.1]);
%         set(gca,'FontSize',16,'LineWidth',3);
%         showfit('f(x) = a*(1-exp(-x/t))+b','fitcolor','red');
%     else
%     end
% end

end