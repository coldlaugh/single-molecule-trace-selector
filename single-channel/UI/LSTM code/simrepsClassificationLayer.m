classdef simrepsClassificationLayer < nnet.layer.ClassificationLayer
        
    properties
        % (Optional) Layer properties

        % Layer properties go here
        weight = 50;
        regulator = 2;
    end
 
    methods
        function layer = simrepsClassificationLayer(name, w)           
            % (Optional) Create a myClassificationLayer

            % Layer constructor function goes here
            
            if nargin == 1
                layer.Name = name;
            elseif nargin == 2
                layer.Name = name;
                layer.weight = w;
            end
            
            % Set layer description
            layer.Description = 'classification layer for simreps data';
            
        end

        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         loss  - Loss between Y and T

            % Layer forward loss function goes here
            N = size(T,2);
            e = T.*log(Y).*repmat([1;layer.weight],[1,N]);
            f = layer.regulator * repmat([1;0],[1,N]).*T.*(Y - 1).^2;
            loss = -sum(e(:)) / N - sum(f(:)) / N ;
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % Backward propagate the derivative of the loss function
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         dLdY  - Derivative of the loss with respect to the predictions Y

            % Layer backward loss function goes here
            
            N = size(T,2);
            dLdY = - T.*repmat([1;layer.weight],[1,N])./Y/N - ...
                2*layer.regulator*repmat([1;0],[1,N]).*T.*(Y - 1) / N;
            
        end
    end
end