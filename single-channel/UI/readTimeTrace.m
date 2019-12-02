function d=readTimeTrace(loc,ndiv)
    lmax = 6000;
    m = load(loc,'-mat');
    m = m.trace(:,:);
    if length(m) > lmax
        m(lmax+1:end,:) = [];
    else
        m(end+1:lmax,:) = 0;
    end
    limY = max(conv(sum(m(:,1:2),2),[1/6,1/6,1/3,1/6,1/6],'valid'));
%     m(:,1:2) = m(:,1:2) / limY; 
    if ~exist('ndiv','var')
        ndiv = 10;
    end
    nslice = floor(length(m)/ndiv);
    d = [reshape(m(:,1),[ndiv,nslice])/limY;reshape(m(:,2),[ndiv,nslice])/limY];
    if size(m,2) == 3
        d = {d,min(reshape(m(:,3),[ndiv,nslice]),[],1)};  
    else
        d = {d};
    end
    
end
