%histogrammer

%Loads HaMMy files and histograms smFRET values.  Calculated apparent
%deltaG of two-state docking transitions based on hard user-defined FRET thresholds.

function fret_hist(segcell)

indiv_hist = 0;
agg_hist = 1;
timebins = 1;
minframes = 100; % Set to zero if you want to include all frames from each molecule
% minframes = 0;
threshold = 0.5;
threshold2 = 0.5;
R = 8.3145E-3;
T = 295;
framestousemat = round([0.25*minframes 0.5*minframes 0.75*minframes minframes]);

for trial = 4
    framestouse = framestousemat(1,trial);

histbins = [-0.2:0.1:1.2];

histbins2 = [0:0.05:1];



numsegments = length(segcell);

for i=1:numsegments
   if mod(size(segcell{i},1),timebins)==0
       numbins = size(segcell{i},1)/timebins;
   else
       numbins = round((size(segcell{i},1)-timebins)/timebins);
   end
   for j = 1:numbins
       for k = 1:size(segcell{i},2)
       avgcell{i}(j,k)=mean(segcell{i}(timebins*(j-1)+1:timebins*j,k));
       end
   end
end



% %Create individual histograms
if indiv_hist == 1
for i = 1:numsegments
%    trace = segcell{i};
   trace = avgcell{i};
%    figure(1)
%    plot(trace(:,1),trace(:,2),'b-',trace(:,1),trace(:,3),'r-')
%    figure(2)
%    plot(trace(:,1),trace(:,4),'k-');
%    figure(3)
%    hist(trace(:,4),histbins);
%    text(0.45, 0.9, sprintf('%d',cellstr(fname{1,i})),'units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold');
%    text(0.35, 0.9, cellstr(fname{1,i}),'units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');
   A=corrcoef(avgcell{1,i}(:,2),avgcell{1,i}(:,3));
   disp('Donor-acceptor covariance:');disp(num2str(A(1,2)));
   pause;
end
end


%Create aggregate histogram
if agg_hist ==1
total_fret = zeros(0,1);
mean_fret = zeros(0,1);
median_fret = zeros(0,1);
mol_name = cell(2,0);
fract_hi = zeros(0,1);
fract_mid = zeros(0,1);
keq = zeros(0,4);
m=0;
for i = 1:numsegments
    if size(avgcell{i},1) >= minframes/timebins
    m = m+1;
    if minframes == 0
        framestouse = size(segcell{i},1)-timebins;
    end
    mean_fret = cat(1,mean_fret,mean(avgcell{i}(1:framestouse/timebins,4)));
    median_fret = cat(1,median_fret,median(avgcell{i}(1:framestouse/timebins,4)));
    total_fret = cat(1,total_fret,avgcell{i}(1:framestouse/timebins,4));
    num_hi=0;
    num_mid=0;
    for k = 1:framestouse/timebins
        if avgcell{i}(k,4) > threshold
            num_hi = num_hi+1;
        elseif avgcell{i}(k,4) < threshold || avgcell{i}(k,4) > threshold2
            num_mid = num_mid+1;
        end
    end
    fract_hi(m,1)=num_hi/k;
    fract_mid(m,1)=num_mid/k;
    keq(m,trial)=fract_mid(m,1)/fract_hi(m,1);
%     mol_name{1,m} = fname{1,i};
    end
end
dG(:,trial) = -R*T*log(keq(:,trial)); 
p = isfinite(dG(:,trial));
for m = 1:size(dG,1)
% if dG(m,trial) > 0
%     mol_name{2,m}='hi';
% else
%     mol_name{2,m}='lo';
% end
end
% for i = 1:size(dG,1)
%     if isfinite(i,1)=0
%         dG(i,1)=NaN;
%     end
% end
figure;
[A B] = hist(total_fret,histbins);
L = sum(A(1:floor(size(A,2)/2)));
H = sum(A(floor(size(A,2)/2):size(A,2)));

bar(B,A/sum(A),'FaceColor',[0.7 0.7 0.7],'LineWidth',2.5);
% title('FRET histogram');
xlim([-0.25 1.25]);
xlabel('FRET', 'fontsize',27);
ylabel('P', 'fontsize',27,'fontangle','italic');
set(gca,'fontsize',27,'xtick', [-0.25:0.25:1.25],'LineWidth',3,'TickLength',[0.02 0.02]);
ylim([0 0.4]);
agghist = hist(total_fret,histbins);
% figure
% [fract_hi_hist bins2] = hist(fract_hi,histbins2);
% bar(bins2, fract_hi_hist,'FaceColor',[0.7 0.7 0.7],'LineWidth',2.5);
% title('FRET histogram');
% xlim([-0.1 1.1]);
% xlabel('f_h_i_g_h_-_F_R_E_T', 'fontsize',27,'fontangle','italic');
% ylabel('N', 'fontsize',27,'fontangle','italic');
% set(gca,'fontsize',27,'xtick', [-0.25:0.25:1.25],'LineWidth',3,'TickLength',[0.02 0.02]);
% ylim([0 max(fract_hi_hist)*1.25]);
% axis square;

% figure
% hist(fract_mid,histbins2);
% title('Fraction of Trace in Mid FRET State');
% figure
x = -10:2.5:10;     % Note: with 50 frames of observation, can't distinguish between |dG|>10 kJ/mol and infinity
% Change infinite values of dG so that they are still displayed at the
% extremes of the bar graph.
for m = 1:size(dG,1)        
    if dG(m,trial) > max(x)
        dG(m,trial) = max(x);
    elseif dG(m,trial) < min(x)
        dG(m,trial) = min(x);
    end
end
% x = cat(2,-inf,x,inf);
dGhist = histc(dG(:,trial),x);
% bar(x,dGhist);
% xlim([min(x)-2 max(x)+2]);
% title('histogram: deltaG of undocking')
% set(get(gca,'XLabel'),'String','dG_u_n_d_o_c_k (kJ/mol)');
% set(get(gca,'YLabel'),'String','Counts');
numused = m;
% text(0.1,0.8,strcat('Number of molecules: ',num2str(numused)),'Units','Normalized');

figure
hist(mean_fret,histbins);
[avg_hist bins3] = hist(mean_fret,histbins);
bar(histbins, avg_hist,'FaceColor',[0.7 0.7 0.7],'LineWidth',2.5);
% title('<FRET> Histogram');
xlim([-0.1 1.1]);
xlabel('<FRET>', 'fontsize',27,'fontangle','italic');
ylabel('N', 'fontsize',27,'fontangle','italic');
set(gca,'fontsize',27,'xtick', [-0.25:0.25:1.25],'LineWidth',3,'TickLength',[0.02 0.02]);
ylim([0 max(avg_hist)*1.25]);
text(0.1,0.8,strcat('N =',num2str(numused)),'Units','Normalized','FontSize',27);
axis square;

% figure
% hist(median_fret,histbins);
% avg_hist = hist(median_fret,histbins);
% disp('Number of molecules used:');
% disp(num2str(numused));
end
% mol_name = mol_name';



disp('Fraction low:');
L/(L+H)
disp('Fraction high:');
H/(L+H)

end

A = A/sum(A);
