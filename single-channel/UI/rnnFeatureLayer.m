classdef rnnFeatureLayer < nnet.layer.Layer

    properties
        % (Optional) Layer properties

        % Layer properties go here
        rnnNet
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters

        % Layer learnable parameters go here
    end
    
    methods
        function layer = rnnFeatureLayer(rnnNet,name)
            % (Optional) Create a myLayer
            % This function must have the same name as the layer

            % Layer constructor function goes here
            
            
            if nargin == 1
                layer.Name = 'rnnFeatureLayer';
                layer.rnnNet = SeriesNetwork(rnnNet.Layers(1:end));
            elseif nargin == 2
                layer.Name = name;
                layer.rnnNet = SeriesNetwork(rnnNet.Layers(1:end));
            end
            
            
            layer.Description = ...
                'extract rnn learned feature';
            
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer at prediction time and
            % output the result
            %
            % Inputs:
            %         layer    -    Layer to forward propagate through
            %         X        -    Input data
            % Output:
            %         Z        -    Output of layer forward function
            
            % Layer forward function for prediction goes here
            
            ndiv = layer.rnnNet.Layers(1).InputSize / size(X,1);    
            n = size(X,4);
%             nFeature = 2 * size(X,2) / ndiv;
            nFeature = size(X,2) / ndiv;
            if isa(X,'gpuArray')
                Z = zeros([1,1,nFeature,n],classUnderlying(X),class(X));
            else
                Z = zeros([1,1,nFeature,n],class(X));
            end
            
%             tic
            xc = cell([n,1]);
            for i = 1 : n
                xc{i} = [reshape(X(1,:,1,i),ndiv,[]);reshape(X(2,:,1,i),ndiv,[])];
            end 
            y = predict(layer.rnnNet,xc);
            for i = 1 : n
                Z(1,1,:,i) = y{i}(2,:);
            end
%             toc
        end

        function [dLdX] = backward(~, X, ~, ~, ~)
            % Backward propagate the derivative of the loss function through 
            % the layer
            %
            % Inputs:
            %         layer             - Layer to backward propagate through
            %         X                 - Input data
            %         Z                 - Output of layer forward function            
            %         dLdZ              - Gradient propagated from the deeper layer
            %         memory            - Memory value which can be used in
            %                             backward propagation
            % Output:
            %         dLdX              - Derivative of the loss with respect to the
            %                             input data
            %         dLdW1, ..., dLdWn - Derivatives of the loss with respect to each
            %                             learnable parameter
            
            % Layer backward function goes here
            
            dLdX = 0 * X; %This layer doesn't have a learnable parameter so we don't need a backward function
            
            
        end
    end
end