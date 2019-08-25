function trace2img(traceData, file)
    fig = figure('Name','trace2img');
    nstart = 1;
    filter = [1/12,1/12,1/6,1/3,1/6,1/12,1/12];
%     filter = 1;
    x = conv(traceData(nstart:end, 1), filter);
    y = conv(traceData(nstart:end, 2), filter);
    plot(x,y,'ro');
    fig.Position = [100   100   300   300];
    graph = gca;
%     graph.XLim = [-0.0,1.0] .* max(traceData(nstart:end,1));
%     graph.YLim = [-0.0,1.0] .* max(traceData(nstart:end,2));
    graph.XTick = [];
    graph.YTick = [];
    axis square;
    box off;
    graph.Position = [-0.02,-0.02,1.04,1.04];
    if ~isempty(file)
        saveas(graph,file);
        img = imread(file);
        img = imresize(img,[256,256]);
        imwrite(img,file);
    else
        pause();
    end
    close(fig)

