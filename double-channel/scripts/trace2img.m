function trace2img(traceData, file)
    fig = figure('Name','trace2img');
    nstart = 1;
    filter = [1/12,1/12,1/6,1/3,1/6,1/12,1/12];
    x = conv(traceData(nstart:end, 1), filter);
    y = conv(traceData(nstart:end, 2), filter);
    scatter(x,y,'MarkerEdgeColor',...
        'k','MarkerFaceColor','k','MarkerFaceAlpha',0,'MarkerEdgeAlpha',0.5);
    fig.Position = [100   100   300   300];
    graph = gca;
    graph.XLim = [-0.0,1.0] .* max(traceData(nstart:end,1));
    graph.YLim = [-0.0,1.0] .* max(traceData(nstart:end,2));
    graph.XTick = [];
    graph.YTick = [];
    axis square;
    box on;
    graph.Position = [-0.02,-0.02,1.04,1.04];
    saveas(graph,file);
    img = imread(file);
    img = imresize(img,[128,128]);
    imwrite(img,file);
    close(fig)

