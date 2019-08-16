function trace2img(traceData, file)
    fig = figure('Name','trace2img');
    nstart = 1;
    scatter(traceData(nstart:end,1),traceData(nstart:end,2),'MarkerEdgeColor',...
        'k','MarkerFaceColor','k','MarkerFaceAlpha',0,'MarkerEdgeAlpha',1.0);
    fig.Position = [200   200   256   256];
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
    img = imresize(img,[227,227]);
    imwrite(img,file);
    close(fig)

