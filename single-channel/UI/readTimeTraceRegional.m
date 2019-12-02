function d=readTimeTraceRegional(loc)
    m = load(loc,'-mat');
    m = m.trace(:,:);
    ndiv = 1;
    ndata = length(m);
    nslice = floor(ndata/ndiv);
    nkeep = nslice * ndiv;
    d = [reshape(m(1:nkeep,1),[ndiv,nslice]);reshape(m(1:nkeep,2),[ndiv,nslice])];
    d = {d,max(reshape(m(1:nkeep,3),[ndiv,nslice]))};   
end