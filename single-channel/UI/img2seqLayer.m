classdef img2seqLayer < nnet.layer.Layer
    
    properties
        BinSize
    end
    
    properties (Learnable)
        
    end
    
    methods
        
        function this = img2seqLayer(varargin)
            inputArguments = iParseInputArguments(varargin{:});
            this.Name = inputArguments.Name;
            this.BinSize = inputArguments.BinSize;
        end
        
        function Z = predict(this,X)
           dimX = size(X);
           bin = this.BinSize;
           if numel(dimX) == 4
               if mod(dimX(2),bin) ~= 0
                   error(message('img2seqLayer: bin size fit divide length of image into ingeter'));
               end
               if dimX(3) ~= 1
                   error(message('img2seqLayer: color depth of image is not 1'));
               end
               Z = reshape(X, dimX(1) * bin, dimX(2) / bin ,dimX(4));
               Z = permute(Z, [1,3,2]);
           elseif numel(dimX) == 3
               if mod(dimX(2),bin) ~= 0
                   error(message('img2seqLayer: bin size fit divide length of image into ingeter'));
               end
               Z = reshape(X, dimX(1) * bin, dimX(2) / bin ,dimX(3));
               Z = permute(Z, [1,3,2]);
           elseif numel(dimX) == 2
               if mod(dimX(2),bin) ~= 0
                   error(message('img2seqLayer: bin size fit divide length of image into ingeter'));
               end
               Z = reshape(X, dimX(1) * bin, dimX(2) / bin, 1);
               Z = permute(Z, [1,3,2]);
           else
               error(message('img2seqLayer: invalid image size'));
           end
        end
        
%         function [Z,momery] = forward(this,X)
%         end
        
        function [dLdX] = backward(~, X, ~, ~, ~)
            % backward  Return empty value
            dLdX = 0 * X;
        end
        
        
    end
    
    


% inputArguments = iParseInputArguments(varargin{:});

end


function inputArguments = iParseInputArguments(varargin)
parser = iCreateParser();
parser.parse(varargin{:});
inputArguments = iConvertToCanonicalForm(parser.Results);
end

function p = iCreateParser(varargin)
p = inputParser;

defaultName = 'imageToSequenceLayer';

addRequired(p,  'BinSize', @iAssertValidBinSize);
addParameter(p, 'Name', defaultName, @iAssertValidLayerName);
end

function iAssertValidLayerName(name)
nnet.internal.cnn.layer.paramvalidation.validateLayerName(name)
end

function iAssertValidBinSize(sz)
isValidSize = (numel(sz) == 1) && (mod(sz,1) == 0) && (sz > 0) && isreal(sz);
if ~isValidSize
    error(message('img2seqLayer:InvalidBinSize'));
end
end

function inputArguments = iConvertToCanonicalForm(params)
try
    inputArguments = struct;
    inputArguments.BinSize = params.BinSize;
    inputArguments.Name = char(params.Name); % make sure strings get converted to char vectors
catch e
    % Reduce the stack trace of the error message by throwing as caller
    throwAsCaller(e)
end
end

