function layer = image2sequence(varargin)



inputArguments = iParseInputArguments(varargin{:});

end


function inputArguments = iParseInputArguments(varargin)
parser = iCreateParser();
parser.parse(varargin{:});
inputArguments = iConvertToCanonicalForm(parser.Results);
end

function p = iCreateParser(varargin)
p = inputParser;

defaultName = 'image to sequence layer';

addRequired(p,  'BinSize', @iAssertValidBinSize);
addParameter(p, 'Name', defaultName, @iAssertValidLayerName);
end

function iAssertValidLayerName(name)
nnet.internal.cnn.layer.paramvalidation.validateLayerName(name)
end

function iAssertValidBinSize(sz)
isValidSize = (numel(sz) == 1) && (mod(sz,1) == 0) && (sz > 0);
if ~isValidSize
    error(message('nnet_cnn:layer:ImageToSequenceLayer:InvalidBinSize'));
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

