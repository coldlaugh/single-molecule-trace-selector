

dimA = [dimX(1),dimX(2),nslice*ndiv];
dimZ = [dimX(1)*ndiv,dimX(2),nslice]; 
indX = 1:prod(dimA);
[indX1,indX2,indX3] = ind2sub(dimX,indX);
indZ1 = mod(indX3-1,ndiv) + ndiv * (indX1 - 1) + 1;
indZ2 = indX2;
indZ3 = ceil(indX3/ndiv);
indZ = sub2ind(dimZ,indZ1,indZ2,indZ3);