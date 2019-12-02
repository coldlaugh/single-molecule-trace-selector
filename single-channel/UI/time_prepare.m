% load('testSearch.mat','XMat','XGrnMat','XRedMat','XFMat','YMat','XTest','XGrnTest','XRedTest','XFTest','YTest');
[XTest,XGrnTest,XRedTest,XFTest,YTest]=loadData('testdata',true,'BalanceEachLabel',false);
name = input('Input a prefix for these files:\n','s');
for i = [1:numel(YTest)]
    if length(XRedTest{i}) >= 3000
        if YTest(i) == 1
            m=num2str(randi(10000000));
            x = XRedTest{i}(1:3000);
            y = XGrnTest{i}(1:3000);
            trace = [x y];
            loc = strcat('time_traces/good_',name,'/trace_',name,'_',m,'.mat');
%             dlmwrite(loc,trace,'precision',4);
            save(loc,'trace');
            
        else
            m=num2str(randi(10000000));
            x = XRedTest{i}(1:3000);
            y = XGrnTest{i}(1:3000);
            trace = [x y];
            loc = strcat('time_traces/bad_',name,'/trace_',name,'_',m,'.mat');
%             dlmwrite(loc,trace,'precision',4);
            save(loc,'trace');
        end
    end
end