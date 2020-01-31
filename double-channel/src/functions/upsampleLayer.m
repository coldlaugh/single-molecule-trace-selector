classdef upsampleLayer < nnet.layer.Layer

    properties
        % (Optional) Layer properties

        % Layer properties go here
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters

        % Layer learnable parameters go here
    end
    
    methods
        function layer = upsampleLayer(name)
            % (Optional) Create a myLayer
            % This function must have the same name as the layer

            % Layer constructor function goes here
            
            if nargin == 0
                layer.Name = 'Upsample';
            end
            
            if nargin == 1
                layer.Name = name;
            end
            
            layer.Description = ...
                'Image Upsample conversion layer';
            
        end
        
        function Z = predict(~, X)
            % Forward input data through the layer at prediction time and
            % output the result
            %
            % Inputs:
            %         layer    -    Layer to forward propagate through
            %         X        -    Input data
            % Output:
            %         Z        -    Output of layer forward function
            
            % Layer forward function for prediction goes here
            targetPixel = 227;
            n = size(X,4);
            if isa(X,'gpuArray')
                Z = zeros(targetPixel,targetPixel,3,n,classUnderlying(X),class(X));
                for i = 1 : n
                    Z(:,:,:,i) = imresize(X(:,:,:,i), ...
                        [targetPixel, targetPixel]);
                end
            else
                Z = zeros(targetPixel,targetPixel,3,n,class(X));
                for i = 1 : n
                    Z(:,:,:,i) = imresize(X(:,:,:,i), ...
                        [targetPixel, targetPixel]);
                end
            end
            
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
            
            dLdX = X; %This layer doesn't have a learnable parameter so we don't need a backward function
        end
    end
end