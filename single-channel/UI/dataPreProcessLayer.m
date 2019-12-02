classdef dataPreProcessLayer < nnet.layer.Layer

    properties
        % (Optional) Layer properties

        % Layer properties go here
        Ndiv
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters

        % Layer learnable parameters go here
    end
    
    methods
        function layer = dataPreProcessLayer(name,ndiv)
            % (Optional) Create a myLayer
            % This function must have the same name as the layer

            % Layer constructor function goes here
            
            if nargin == 0
                layer.Name = 'preprocess';
                layer.Ndiv = 20;
            end
            
            if nargin == 1
                layer.Name = name;
                layer.Ndiv = 20;
            end
            
            if nargin == 2
                layer.Name = name;
                layer.Ndiv = ndiv;
            end
            
            layer.Description = ...
                ['Preprocessing with with bin width ',num2str(layer.Ndiv)];
            
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
            
            ndiv = layer.Ndiv;    
            dim = size(X);
            if length(dim) == 3
                if mod(dim(3),ndiv) ~= 0 % if ndiv can't divide sequence length
                    %zero pad sequence 
                    for i = 1 : ndiv - mod(dim(3),ndiv)
                        X(:,:,i) = 0;
                    end
                end
                Z = reshape(permute(X,[1,3,2]),[dim(1)*ndiv,dim(3)/ndiv,dim(2)]);
                Z = permute(Z,[1,3,2]);
            elseif length(dim) == 2
                if isa(X,'gpuArray')
                    Z = zeros(dim(1)*ndiv,dim(2),classUnderlying(X),class(X));
                else
                    Z = zeros(dim(1)*ndiv,dim(2),class(X));
                end
            end
        end

        function [Z, memory] = forward(layer, X)
            % (Optional) Forward input data through the layer at training
            % time and output the result and a memory value
            %
            % Inputs:
            %         layer  - Layer to forward propagate through
            %         X      - Input data
            % Output:
            %         Z      - Output of layer forward function
            %         memory - Memory value which can be used for
            %                  backward propagation

            % Layer forward function for training goes here
            
            ndiv = layer.Ndiv;    
            dim = size(X);
            if length(dim) == 3
                if mod(dim(3),ndiv) ~= 0 % if ndiv can't divide sequence length
                    %zero pad sequence 
                    for i = 1 : ndiv - mod(dim(3),ndiv)
                        X(:,:,i) = 0;
                    end
                end
                Z = reshape(permute(X,[1,3,2]),[dim(1)*ndiv,dim(3)/ndiv,dim(2)]);
                Z = permute(Z,[1,3,2]);
                if isa(Z,'gpuArray')
                    Z = Z + 0.05 * randn(size(Z),classUnderlying(X),class(X));
                else
                    Z = Z + 0.05 * randn(size(Z),class(X));
                end
            elseif length(dim) == 2
                if isa(X,'gpuArray')
                    Z = zeros(dim(1)*ndiv,dim(2),classUnderlying(X),class(X));
                else
                    Z = zeros(dim(1)*ndiv,dim(2),class(X));
                end
            end
            memory = [];
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