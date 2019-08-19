function trace2img(traceData, file)
    fig = figure('Name','trace2img');
    nstart = 1;
    filter = [1/6,2/3,1/6];
    x = conv(traceData(nstart:end, 1), filter);
    y = conv(traceData(nstart:end, 2), filter);
    scatter(x,y,'MarkerEdgeColor',...
        'k','MarkerFaceColor','k','MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.2);
    fig.Position = [100   100   200   200];
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

