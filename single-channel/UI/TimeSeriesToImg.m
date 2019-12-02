function [Img] = TimeSeriesToImg(X)
 % [Img]=TimeSeriesToImg(X) 
 % convert a time series X to a 2-D intensity matrice Img
    resol = 60; % image resolution is 227 * 227
    if isa(X,'gpuArray')
        Img = zeros(resol,resol,3,classUnderlying(X),class(X)); % initialize intensity matrice
        ImgR = zeros(resol,resol,classUnderlying(X),class(X));
        ImgG = zeros(resol,resol,classUnderlying(X),class(X));
        ImgB = zeros(resol,resol,classUnderlying(X),class(X));
    else
        Img = zeros(resol,resol,3,class(X)); % initialize intensity matrice
        ImgR = zeros(resol,resol,class(X));
        ImgG = zeros(resol,resol,class(X));
        ImgB = zeros(resol,resol,class(X));
    end
    
%     [limlow,limhigh] = bounds(X,2); % calculate axis limit 
%     limlow = [min(limlow),min(limlow)];
%     limhigh = [max(limhigh),max(limhigh)];
    limlow = [0,0];
    limhigh = [1,1];
%     limhigh = [1.1,1.1];
    ind = round(resol*...
        [(X(1,:)-limlow(1))/(limhigh(1)-limlow(1));
        (X(2,:)-limlow(2))/(limhigh(2)-limlow(2))]...
        ); % calculate each pixel
    ind = min(ind,resol);
    ind = max(ind,1);
    ind = sub2ind([resol,resol],ind(1,:),resol + 1 - ind(2,:)); % calculate linear index for pixels
    increment = 1; % pixel intensity increment 
    incrementR = increment * [length(ind):-1:1]/length(ind);
    incrementG = increment * [1:length(ind)]/length(ind);
    incrementB = increment;
    intensityR = accumarray(ind',incrementR');
    intensityG = accumarray(ind',incrementG');
    intensityB = accumarray(ind',incrementB');
    ImgR(1:length(intensityR)) = intensityR;
    ImgG(1:length(intensityG)) = intensityG;
    ImgB(1:length(intensityB)) = intensityB;
    Img(:,:,1) = (ImgR - mean(ImgR))/std(ImgR(:));
    Img(:,:,2) = (ImgG - mean(ImgG))/std(ImgG(:));
    Img(:,:,3) = (ImgB - mean(ImgB))/std(ImgB(:));
    x = linspace(-1/sqrt(2),1/sqrt(2),5);
    [x,y] = meshgrid(x,x);
    filter = sinc(x.^2+y.^2);
    Img(:,:,1) = conv2(Img(:,:,1),filter,'same');
    Img(:,:,2) = conv2(Img(:,:,2),filter,'same');
    Img(:,:,3) = conv2(Img(:,:,3),filter,'same');
    Img = min(Img,10);
%     Img = min(Img,1); % set intensity to Img matrice.
%     Img = Img + Img';
    
    return;
end